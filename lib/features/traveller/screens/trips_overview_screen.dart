import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../presentation/providers/trips_provider.dart';
import '../widgets/skeleton_box.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../utils/add_flight_navigation.dart';
import 'active_disruptions_screen.dart';
import 'upcoming_trips_screen.dart';
import 'border_ready_screen.dart';
import 'sentinel_monitor_screen.dart';

class TripsOverviewScreen extends StatefulWidget {
  final bool showBottomNav;

  const TripsOverviewScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<TripsOverviewScreen> createState() => _TripsOverviewScreenState();
}

class _TripsOverviewScreenState extends State<TripsOverviewScreen> {
  final Set<String> _deletingTripIds = {};

  BoxDecoration _getCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrips();
    });
  }

  Future<void> _loadTrips() async {
    if (!mounted) return;
    try {
      await context.read<TripsProvider>().loadTrips();
    } catch (_) {}
  }

  Future<void> _handleAddFlightTap() async {
    final tripsProvider = context.read<TripsProvider>();
    final auth = context.read<AuthProvider>();

    await openAddFlightWithLimit(
      context: context,
      currentTrips: tripsProvider.trips.length,
      hasUnlimitedFlights: auth.user?.hasUnlimitedFlightMonitoring ?? false,
      onReturn: () async {
        if (!mounted) return;
        await _loadTrips();
      },
    );
  }

  Future<void> _toggleTracking(TripModel trip) async {
    final tripsProvider = context.read<TripsProvider>();
    final newStatus = !trip.trackingEnabled;

    try {
      await tripsProvider.setLiveTracking(trip.id, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                newStatus ? Icons.check_circle : Icons.info_outline,
                color: newStatus ? const Color(0xFF10B981) : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 10),
              Text(
                newStatus
                    ? 'Sentinel™ Protection Enabled!'
                    : 'Sentinel™ Protection Disabled.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update tracking: ${e.toString()}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDeleteTrip(TripModel trip) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Delete this trip?',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteTrip(trip);
    }
  }

  Future<void> _deleteTrip(TripModel trip) async {
    if (_deletingTripIds.contains(trip.id)) return;

    setState(() {
      _deletingTripIds.add(trip.id);
    });

    final tripsProvider = context.read<TripsProvider>();
    final success = await tripsProvider.deleteTrip(trip.id);

    if (mounted) {
      setState(() {
        _deletingTripIds.remove(trip.id);
      });
      if (!success) {
        final error = tripsProvider.errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ?? 'Failed to delete trip.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        );
        tripsProvider.clearError();
      }
    }
  }

  bool _hasReadableTripValue(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'unknown' &&
        normalized != '--';
  }

  String _tripFlightLabel(TripModel trip) {
    if (_hasReadableTripValue(trip.flightNumber)) return trip.flightNumber;
    if (_hasReadableTripValue(trip.tripName)) return trip.tripName;
    return 'Trip added';
  }

  String _tripLocationLabel(String value, String fallback) {
    return _hasReadableTripValue(value) ? value : fallback;
  }

  String _tripRouteLabel(TripModel trip) {
    final origin = _tripLocationLabel(trip.origin, 'Origin not set');
    final destination =
        _tripLocationLabel(trip.destination, 'Destination not set');
    return '$origin → $destination';
  }

  String _tripDateLabel(TripModel trip) {
    if (_hasReadableTripValue(trip.departureDate)) return trip.departureDate;
    if (_hasReadableTripValue(trip.totalDuration ?? '')) {
      return trip.totalDuration!;
    }
    return 'Date not set';
  }

  String _timeLabel(String? isoLike, String fallback) {
    if (isoLike == null || isoLike.trim().isEmpty) return fallback;
    
    String to12Hour(String hh, String mm) {
      int hour = int.parse(hh);
      String amPm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '${hour.toString().padLeft(2, '0')}:$mm $amPm';
    }

    final isoMatch = RegExp(r'T(\d{2}):(\d{2})').firstMatch(isoLike);
    if (isoMatch != null) return to12Hour(isoMatch.group(1)!, isoMatch.group(2)!);
    
    final plainMatch = RegExp(r'^(\d{2}):(\d{2})').firstMatch(isoLike.trim());
    if (plainMatch != null) return to12Hour(plainMatch.group(1)!, plainMatch.group(2)!);
    
    return isoLike;
  }

  @override
  Widget build(BuildContext context) {
    final tripsProvider = context.watch<TripsProvider>();
    final auth = context.watch<AuthProvider>();

    final isLoading = tripsProvider.isLoading && tripsProvider.trips.isEmpty;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _buildTripsSkeleton(),
        bottomNavigationBar: widget.showBottomNav
            ? const TravellerBottomNav(activeIndex: 1)
            : null,
      );
    }

    if (tripsProvider.state == TripsState.error && tripsProvider.trips.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load trips:\n${tripsProvider.errorMessage}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadTrips,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.showBottomNav
            ? const TravellerBottomNav(activeIndex: 1)
            : null,
      );
    }

    final trips = tripsProvider.trips;
    final bool isEmpty = trips.isEmpty;
    final int monitoredCount = trips.where((t) => t.trackingEnabled).length;
    final int alertsCount = trips
        .expand((t) => t.timeline)
        .where((leg) => (leg.activeAlerts ?? 0) > 0)
        .length;
    final int upcomingCount = trips.length;

    final List<TripModel> monitoredTrips =
        trips.where((t) => t.trackingEnabled).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Trips',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage all your flights',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: _handleAddFlightTap,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Overview 3-Card Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFFFFC229),
                      count: isEmpty ? '--' : '$monitoredCount',
                      label: 'Monitored',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UpcomingTripsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.error_outline,
                      iconColor: const Color(0xFFEF4444),
                      count: isEmpty ? '--' : '$alertsCount',
                      label: 'Alerts',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ActiveDisruptionsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF10B981),
                      count: isEmpty ? '--' : '$upcomingCount',
                      label: 'Upcoming',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UpcomingTripsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Sentinel Protected Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sentinel™ Protected',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (monitoredTrips.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'We have no sentinel activity',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monitoredTrips.length,
                  itemBuilder: (context, index) {
                    final trip = monitoredTrips[index];
                    final firstLeg = trip.timeline.isNotEmpty ? trip.timeline.first : null;
                    final origin = _tripLocationLabel(trip.origin, 'Origin not set');
                    final destination = _tripLocationLabel(trip.destination, 'Destination not set');
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildProtectedFlightCard(
                        trip: trip,
                        airlineCode: _tripFlightLabel(trip),
                        risk: '${(firstLeg?.riskLevel ?? 'LOW').toUpperCase()} RISK',
                        riskColor: _getRiskColor(firstLeg?.riskLevel),
                        from: origin,
                        fromTime: _timeLabel(firstLeg?.fromTime, 'Departure'),
                        to: destination,
                        toTime: _timeLabel(firstLeg?.toTime, 'Arrival'),
                        statusText: trip.trackingEnabled ? 'ACTIVE' : trip.status.toUpperCase(),
                        delayProb: firstLeg?.delayProb ?? '0%',
                        activeAlerts: firstLeg?.activeAlerts ?? 0,
                        date: _tripDateLabel(trip),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 28), // ── Upcoming Trips Section ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Upcoming Trips',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UpcomingTripsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: Color(0xFFFFC229),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'No upcoming trip for now',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    final firstLeg = trip.timeline.isNotEmpty ? trip.timeline.first : null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildUpcomingCard(trip, firstLeg),
                    );
                  },
                ),

              const SizedBox(height: 28),

              // Two Half-Width bottom action cards
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ActiveDisruptionsScreen(),
                            ),
                          );
                        },
                        child: _buildQuickActionButton(
                          icon: Icons.remove_red_eye_outlined,
                          label: 'View\nDisruptions',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  BorderReadyScreen(),
                            ),
                          );
                        },
                        child: _buildQuickActionButton(
                          icon: Icons.verified_user_outlined,
                          label: 'BorderReady™',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? const TravellerBottomNav(activeIndex: 1)
          : null,
    );
  }

  Widget _buildTripsSkeleton() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonBox(width: 130, height: 50, radius: 14),
                const SkeletonBox(width: 42, height: 42, radius: 14),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: const SkeletonBox(height: 96, radius: 18)),
                const SizedBox(width: 12),
                Expanded(child: const SkeletonBox(height: 96, radius: 18)),
                const SizedBox(width: 12),
                Expanded(child: const SkeletonBox(height: 96, radius: 18)),
              ],
            ),
            const SizedBox(height: 28),
            const SkeletonBox(width: 180, height: 24, radius: 12),
            const SizedBox(height: 14),
            const SkeletonBox(height: 132, radius: 20),
            const SizedBox(height: 28),
            const SkeletonBox(width: 160, height: 24, radius: 12),
            const SizedBox(height: 14),
            const SkeletonBox(height: 112, radius: 18),
            const SizedBox(height: 12),
            const SkeletonBox(height: 112, radius: 18),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(String? risk) {
    if (risk == null) return const Color(0xFF10B981);
    final l = risk.toLowerCase();
    if (l == 'high') return const Color(0xFFEF4444);
    if (l == 'medium') return const Color(0xFFFFC229);
    return const Color(0xFF10B981);
  }

  Widget _buildUpcomingCard(TripModel trip, TripTimelineItem? firstLeg) {
    final isDeleting = _deletingTripIds.contains(trip.id);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _getCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tripFlightLabel(trip),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tripRouteLabel(trip),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _tripDateLabel(trip),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: isDeleting ? null : () => _confirmDeleteTrip(trip),
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isDeleting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE11D48),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.delete_outline,
                              color: Color(0xFFE11D48),
                              size: 16,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trip.trackingEnabled ? 'Active Sentinel' : 'Not Monitored',
                    style: TextStyle(
                      color: trip.trackingEnabled
                          ? const Color(0xFF10B981)
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _toggleTracking(trip),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: trip.trackingEnabled
                            ? const Color(0xFF10B981).withOpacity(0.12)
                            : const Color(0xFFFFC229).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: trip.trackingEnabled
                              ? const Color(0xFF10B981).withOpacity(0.3)
                              : const Color(0xFFFFC229).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        trip.trackingEnabled
                            ? 'Sentinel™ Enabled'
                            : 'Enable Sentinel™',
                        style: TextStyle(
                          color: trip.trackingEnabled
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFFC229),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectedFlightCard({
    required TripModel trip,
    required String airlineCode,
    required String risk,
    required Color riskColor,
    required String from,
    required String fromTime,
    required String to,
    required String toTime,
    required String statusText,
    required String delayProb,
    required int activeAlerts,
    required String date,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SentinelMonitorScreen(initialTrip: trip),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Sentinel™ Monitoring',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        risk,
                        style: TextStyle(
                          color: riskColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  airlineCode,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      from,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fromTime,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.swap_horiz,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
                  size: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      to,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Delay Probability: ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      delayProb,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Active Alerts: ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '$activeAlerts',
                      style: TextStyle(
                        color: activeAlerts > 0
                            ? const Color(0xFFEF4444)
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                date,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
