import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../repositories/trip_repository.dart';
import '../widgets/skeleton_box.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../utils/add_flight_navigation.dart';
import 'active_disruptions_screen.dart';
import 'upcoming_trips_screen.dart';
import 'border_ready_screen.dart';
import 'sentinel_monitor_screen.dart';
import 'live_flight_tracker_screen.dart';

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
  final ProfileRepository _profileRepository = ProfileRepository();
  List<TripModel> _trips = [];
  UserProfile? _profile;
  final Set<String> _deletingTripIds = {};
  bool _isLoading = true;
  bool _hasLoadedTrips = false;
  String? _errorMessage;

  // Reusable decoration — avoids recreating identical objects per card per rebuild
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
    TripRepository.tripsVersion.addListener(_onTripsChanged);
    _loadTrips();
  }

  @override
  void dispose() {
    TripRepository.tripsVersion.removeListener(_onTripsChanged);
    super.dispose();
  }

  void _onTripsChanged() {
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    if (!mounted) return;
    setState(() {
      _isLoading = !_hasLoadedTrips;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _repository.fetchUserTrips(
          onCachedData: (cachedData) {
            if (mounted) {
              setState(() {
                _trips = cachedData;
                if (_profile != null) {
                  _isLoading = false;
                  _hasLoadedTrips = true;
                }
              });
            }
          },
        ),
        _profileRepository.getProfile(
          onCachedData: (cachedData) {
            if (mounted) {
              setState(() {
                _profile = cachedData;
                if (_trips.isNotEmpty || _hasLoadedTrips) {
                  _isLoading = false;
                  _hasLoadedTrips = true;
                }
              });
            }
          },
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _trips = results[0] as List<TripModel>;
        _profile = results[1] as UserProfile;
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

  Future<void> _handleAddFlightTap() async {
    await openAddFlightWithLimit(
      context: context,
      currentTrips: _trips.length,
      hasUnlimitedFlights: _profile?.hasUnlimitedFlightMonitoring ?? false,
      onReturn: () async {
        if (!mounted) return;
        await _loadTrips();
      },
    );
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
          flightNumber: trip.flightNumber,
          origin: trip.origin,
          destination: trip.destination,
          departureDate: trip.departureDate,
          bookingReference: trip.bookingReference,
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
                color: newStatus ? const Color(0xFF10B981) : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              SizedBox(width: 10),
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
              child: Text(
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

    final originalTrips = List<TripModel>.from(_trips);
    setState(() {
      _deletingTripIds.add(trip.id);
      _trips.removeWhere((item) => item.id == trip.id);
    });

    try {
      await _repository.deleteTrip(trip.id);
      if (!mounted) return;
      await _loadTrips();
      if (!mounted) return;
      setState(() {
        _deletingTripIds.remove(trip.id);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _trips = originalTrips;
        _deletingTripIds.remove(trip.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete trip: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          
        ),
      );
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

  /// Extracts HH:mm from an ISO-8601 string without applying any timezone
  /// conversion.  Aviationstack embeds the local airport time in the string
  /// itself (e.g. "2026-06-19T16:15:00+00:00" where 16:15 IS the local time),
  /// so calling DateTime.parse().toLocal() would shift the value a second time
  /// (e.g. +5 h on a PKT device → 21:15).  We avoid that by reading the
  /// time component directly.
  String _timeLabel(String? isoLike, String fallback) {
    if (isoLike == null || isoLike.trim().isEmpty) return fallback;
    // ISO string with a 'T' separator — extract the HH:mm after the T.
    final isoMatch = RegExp(r'T(\d{2}):(\d{2})').firstMatch(isoLike);
    if (isoMatch != null) return '${isoMatch.group(1)}:${isoMatch.group(2)}';
    // Plain HH:mm (no date prefix) — return as-is after validation.
    final plainMatch = RegExp(r'^(\d{2}):(\d{2})').firstMatch(isoLike.trim());
    if (plainMatch != null)
      return '${plainMatch.group(1)}:${plainMatch.group(2)}';
    // Unrecognised format — show the raw string so no data is lost.
    return isoLike;
  }

  String _lastCheckedLabel(TripModel trip) {
    if (!_hasReadableTripValue(trip.lastTrackedAt ?? '')) return 'Pending';
    return _timeLabel(trip.lastTrackedAt, 'Pending');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _buildTripsSkeleton(),
        bottomNavigationBar: widget.showBottomNav
            ? const TravellerBottomNav(activeIndex: 1)
            : null,
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'Failed to load trips:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadTrips,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.showBottomNav
            ? const TravellerBottomNav(activeIndex: 1)
            : null,
      );
    }

    final bool isEmpty = _trips.isEmpty;
    final int monitoredCount = _trips.where((t) => t.trackingEnabled).length;
    final int alertsCount = _trips
        .expand((t) => t.timeline)
        .where((leg) => (leg.activeAlerts ?? 0) > 0)
        .length;
    final int upcomingCount = _trips.length;

    final List<TripModel> monitoredTrips =
        _trips.where((t) => t.trackingEnabled).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
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
                      SizedBox(height: 4),
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

              SizedBox(height: 24),

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
                  SizedBox(width: 12),
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
                  SizedBox(width: 12),
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

              SizedBox(height: 28),

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
                  Row(
                    children: [
                      SizedBox(width: 6),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 14),

              if (monitoredTrips.isEmpty)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 36),
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
                      padding: EdgeInsets.only(bottom: 12.0),
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

              SizedBox(height: 28), // ── Upcoming Trips Section ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), size: 18),
                      SizedBox(width: 8),
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
                    child: Text(
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
              SizedBox(height: 14),

              if (isEmpty)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 36),
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
                  itemCount: _trips.length,
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    final firstLeg = trip.timeline.isNotEmpty ? trip.timeline.first : null;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: _buildUpcomingCard(trip, firstLeg),
                    );
                  },
                ),

              SizedBox(height: 28),

              // Live Flight Tracker Quick Action
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LiveFlightTrackerScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFFFFC229).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFC229).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.map_outlined, color: Color(0xFFFFC229), size: 24),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Flight Tracker',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Track your flight on the map in real-time',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),

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
                    SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BorderReadyScreen(),
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
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 130, height: 50, radius: 14),
                SkeletonBox(width: 42, height: 42, radius: 14),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: SkeletonBox(height: 96, radius: 18)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 96, radius: 18)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 96, radius: 18)),
              ],
            ),
            SizedBox(height: 28),
            const SkeletonBox(width: 180, height: 24, radius: 12),
            SizedBox(height: 14),
            const SkeletonBox(height: 132, radius: 20),
            SizedBox(height: 28),
            const SkeletonBox(width: 160, height: 24, radius: 12),
            SizedBox(height: 14),
            const SkeletonBox(height: 112, radius: 18),
            SizedBox(height: 12),
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
      padding: EdgeInsets.all(18),
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
                  SizedBox(height: 4),
                  Text(
                    _tripRouteLabel(trip),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 2),
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
                        color: Color(0xFFE11D48).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isDeleting
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE11D48),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.delete_outline,
                              color: Color(0xFFE11D48),
                              size: 16,
                            ),
                    ),
                  ),
                  SizedBox(height: 8),
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
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _toggleTracking(trip),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: trip.trackingEnabled
                            ? Color(0xFF10B981).withOpacity(0.12)
                            : Color(0xFFFFC229).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: trip.trackingEnabled
                              ? Color(0xFF10B981).withOpacity(0.3)
                              : Color(0xFFFFC229).withOpacity(0.3),
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
        padding: EdgeInsets.all(16),
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
              padding: EdgeInsets.all(8),
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
            SizedBox(height: 12),
            Text(
              count,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
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
        padding: EdgeInsets.all(18),
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
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
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
                    SizedBox(height: 4),
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
                    SizedBox(height: 4),
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
            SizedBox(height: 16),
            Divider(color: Theme.of(context).colorScheme.outline),
            SizedBox(height: 10),
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
            SizedBox(height: 8),
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
      padding: EdgeInsets.symmetric(vertical: 18),
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
          SizedBox(height: 8),
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
