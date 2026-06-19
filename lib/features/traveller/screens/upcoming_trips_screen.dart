import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../repositories/trip_repository.dart';
import '../utils/add_flight_navigation.dart';
import '../widgets/traveller_bottom_nav.dart';

class UpcomingTripsScreen extends StatefulWidget {
  const UpcomingTripsScreen({super.key});

  @override
  State<UpcomingTripsScreen> createState() => _UpcomingTripsScreenState();
}

class _UpcomingTripsScreenState extends State<UpcomingTripsScreen> {
  final TripRepository _tripRepository = TripRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  List<TripModel> _trips = [];
  UserProfile? _profile;
  final Set<String> _deletingTripIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    TripRepository.tripsVersion.addListener(_onTripsChanged);
    _loadLimitData();
  }

  @override
  void dispose() {
    TripRepository.tripsVersion.removeListener(_onTripsChanged);
    super.dispose();
  }

  void _onTripsChanged() {
    _loadLimitData();
  }

  Future<void> _loadLimitData() async {
    try {
      final results = await Future.wait([
        _tripRepository.fetchUserTrips(
          onCachedData: (cachedData) {
            if (mounted) {
              setState(() {
                _trips = cachedData;
                if (_profile != null) {
                  _isLoading = false;
                  _errorMessage = null;
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
                if (_trips.isNotEmpty || !_isLoading) {
                  _isLoading = false;
                  _errorMessage = null;
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
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
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
        await _loadLimitData();
      },
    );
  }

  Future<void> _confirmDeleteTrip(TripModel trip) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0C162A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete this trip?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
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

    final originalTrips = List<TripModel>.from(_trips);
    setState(() {
      _deletingTripIds.add(trip.id);
      _trips.removeWhere((item) => item.id == trip.id);
    });

    try {
      await _tripRepository.deleteTrip(trip.id);
      if (!mounted) return;
      await _loadLimitData();
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
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFE11D48),
        ),
      );
    }
  }

  bool _hasReadableTripValue(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty && normalized != 'unknown' && normalized != '--';
  }

  String _tripFlightLabel(TripModel trip) {
    if (_hasReadableTripValue(trip.flightNumber)) return trip.flightNumber;
    if (_hasReadableTripValue(trip.tripName)) return trip.tripName;
    return 'Trip added';
  }

  String _tripLocationLabel(String value, String fallback) {
    return _hasReadableTripValue(value) ? value : fallback;
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
  String _formatFlightTime(String? isoLike, String fallback) {
    if (isoLike == null || isoLike.trim().isEmpty) return fallback;
    // ISO string with a 'T' separator — extract the HH:mm after the T.
    final isoMatch = RegExp(r'T(\d{2}):(\d{2})').firstMatch(isoLike);
    if (isoMatch != null) return '${isoMatch.group(1)}:${isoMatch.group(2)}';
    // Plain HH:mm (no date prefix) — return as-is after validation.
    final plainMatch = RegExp(r'^(\d{2}):(\d{2})').firstMatch(isoLike.trim());
    if (plainMatch != null) return '${plainMatch.group(1)}:${plainMatch.group(2)}';
    // Unrecognised format — show the raw string so no data is lost.
    return isoLike;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Upcoming Trips',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _handleAddFlightTap,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 1),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Failed to load trips:\n$_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_trips.isEmpty)
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
                final flightLabel = _tripFlightLabel(trip);
                final origin = _tripLocationLabel(trip.origin, 'Origin not set');
                final destination =
                    _tripLocationLabel(trip.destination, 'Destination not set');
                final departureDate = _tripDateLabel(trip);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildUpcomingFlightCard(
                    airlineName: flightLabel,
                    flightCode: flightLabel,
                    status: trip.trackingEnabled ? 'Active' : trip.status,
                    statusColor: trip.trackingEnabled
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFFC229),
                    from: origin,
                    fromTime: _formatFlightTime(firstLeg?.fromTime, 'Departure'),
                    fromCity: origin,
                    to: destination,
                    toTime: _formatFlightTime(firstLeg?.toTime, 'Arrival'),
                    toCity: destination,
                    terminal: 'Terminal not set',
                    gate: 'Gate not set',
                    date: departureDate,
                    isDeleting: _deletingTripIds.contains(trip.id),
                    onDelete: () => _confirmDeleteTrip(trip),
                  ),
                );
              }).toList(),
          ],
        ),
    );
  }

  Widget _buildUpcomingFlightCard({
    required String airlineName,
    required String flightCode,
    required String status,
    required Color statusColor,
    required String from,
    required String fromTime,
    required String fromCity,
    required String to,
    required String toTime,
    required String toCity,
    required String terminal,
    required String gate,
    required String date,
    required bool isDeleting,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    airlineName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    flightCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: isDeleting ? null : onDelete,
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
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fromTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fromCity,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.swap_horiz,
                color: Colors.white24,
                size: 24,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    to,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    toTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    toCity,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.04)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.white30, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$terminal  •  $gate',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Text(
                date,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
