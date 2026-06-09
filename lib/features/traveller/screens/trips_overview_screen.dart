import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';
import '../widgets/skeleton_box.dart';
import '../widgets/traveller_bottom_nav.dart';
import 'active_disruptions_screen.dart';
import 'upcoming_trips_screen.dart';
import 'add_flight_screen.dart';
import 'border_ready_screen.dart';
import 'flight_detail_screen.dart';

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
  final TripRepository _repository = TripRepository();
  List<TripModel> _trips = [];
  bool _isLoading = true;
  bool _hasLoadedTrips = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    if (!mounted) return;
    setState(() {
      _isLoading = !_hasLoadedTrips;
      _errorMessage = null;
    });

    try {
      final trips = await _repository.fetchUserTrips();
      if (!mounted) return;
      setState(() {
        _trips = trips;
        _isLoading = false;
        _hasLoadedTrips = true;
      });
    } catch (e) {
      if (!mounted) return;
      if (_hasLoadedTrips) {
        setState(() {
          _errorMessage = null;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not refresh trips.'),
            backgroundColor: Color(0xFFE11D48),
          ),
        );
        return;
      }
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTracking(TripModel trip) async {
    bool newStatus = !trip.trackingEnabled;
    // Optimistic UI update
    setState(() {
      final index = _trips.indexWhere((t) => t.id == trip.id);
      if (index != -1) {
        _trips[index] = TripModel(
          id: trip.id,
          userId: trip.userId,
          tripName: trip.tripName,
          origin: trip.origin,
          destination: trip.destination,
          totalDuration: trip.totalDuration,
          stops: trip.stops,
          timeline: trip.timeline,
          trackingEnabled: newStatus,
          status: trip.status,
          lastTrackedAt: trip.lastTrackedAt,
          shareToken: trip.shareToken,
          isShared: trip.isShared,
        );
      }
    });

    try {
      await _repository.enableTripLiveTracking(trip.id, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                newStatus ? Icons.check_circle : Icons.info_outline,
                color: newStatus ? const Color(0xFF10B981) : Colors.white70,
              ),
              const SizedBox(width: 10),
              Text(
                newStatus
                    ? 'Sentinel™ Protection Enabled!'
                    : 'Sentinel™ Protection Disabled.',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0C162A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
      );
    } catch (e) {
      // Revert optimistic update on failure
      setState(() {
        final index = _trips.indexWhere((t) => t.id == trip.id);
        if (index != -1) {
          _trips[index] = trip;
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update tracking: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: _buildTripsSkeleton(),
        bottomNavigationBar:
            widget.showBottomNav ? const TravellerBottomNav(activeIndex: 1) : null,
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load trips:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadTrips,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        bottomNavigationBar:
            widget.showBottomNav ? const TravellerBottomNav(activeIndex: 1) : null,
      );
    }

    bool isEmpty = _trips.isEmpty;
    int monitoredCount = _trips.where((t) => t.trackingEnabled).length;
    int alertsCount = _trips
        .expand((t) => t.timeline)
        .where((leg) => (leg.activeAlerts ?? 0) > 0)
        .length;
    int upcomingCount = _trips.length;

    List<TripModel> monitoredTrips =
        _trips.where((t) => t.trackingEnabled).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Trips',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage all your flights',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddFlightScreen(),
                        ),
                      );
                    },
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
                  const Text(
                    'Sentinel™ Protected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981), // Green
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Active',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (monitoredTrips.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C162A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'We have no sentinel activity',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                ...monitoredTrips.map((trip) {
                  final firstLeg =
                      trip.timeline.isNotEmpty ? trip.timeline.first : null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildProtectedFlightCard(
                      airlineCode:
                          firstLeg?.airlineCode ?? trip.tripName.toUpperCase(),
                      risk: '${(firstLeg?.riskLevel ?? 'LOW').toUpperCase()} RISK',
                      riskColor: _getRiskColor(firstLeg?.riskLevel),
                      from: firstLeg?.from ?? trip.origin,
                      fromTime: firstLeg?.fromTime ?? '--',
                      to: firstLeg?.to ?? trip.destination,
                      toTime: firstLeg?.toTime ?? '--',
                      statusText: trip.status.toUpperCase(),
                      delayProb: firstLeg?.delayProb ?? '0%',
                      activeAlerts: firstLeg?.activeAlerts ?? 0,
                      date: firstLeg?.date ?? '--',
                    ),
                  );
                }).toList(),

              const SizedBox(height: 28), // ── Upcoming Trips Section ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff,
                          color: Colors.white.withOpacity(0.5), size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Upcoming Trips',
                        style: TextStyle(
                          color: Colors.white,
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
                    color: const Color(0xFF0C162A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'No upcoming trip for now',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                ..._trips.map((trip) {
                  final firstLeg =
                      trip.timeline.isNotEmpty ? trip.timeline.first : null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildUpcomingCard(trip, firstLeg),
                  );
                }).toList(),

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
                              builder: (context) => const BorderReadyScreen(),
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
      bottomNavigationBar:
          widget.showBottomNav ? const TravellerBottomNav(activeIndex: 1) : null,
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
              children: const [
                SkeletonBox(width: 130, height: 50, radius: 14),
                SkeletonBox(width: 42, height: 42, radius: 14),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Expanded(child: SkeletonBox(height: 96, radius: 18)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 96, radius: 18)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 96, radius: 18)),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
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
                    firstLeg?.airlineCode ?? trip.tripName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trip.origin} → ${trip.destination}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    firstLeg?.date ?? '--',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trip.trackingEnabled ? 'Active Sentinel' : 'Not Monitored',
                    style: TextStyle(
                      color: trip.trackingEnabled
                          ? const Color(0xFF10B981)
                          : Colors.white30,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _toggleTracking(trip),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
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
          color: const Color(0xFF0C162A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.04),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectedFlightCard({
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
        if (airlineCode == 'UA 2847') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FlightDetailScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sentinel™ is tracking $airlineCode live. No disruptions reported.',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF0C162A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0C162A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.04),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Sentinel™ Monitoring',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
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
                  style: const TextStyle(
                    color: Colors.white,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fromTime,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.swap_horiz,
                  color: Colors.white24,
                  size: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      to,
                      style: const TextStyle(
                        color: Colors.white,
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
            Divider(color: Colors.white.withOpacity(0.04)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Delay Probability: ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      delayProb,
                      style: const TextStyle(
                        color: Colors.white,
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
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '$activeAlerts',
                      style: TextStyle(
                        color: activeAlerts > 0
                            ? const Color(0xFFEF4444)
                            : Colors.white,
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
                  color: Colors.white.withOpacity(0.25),
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
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
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
