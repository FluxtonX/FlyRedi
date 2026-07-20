import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../presentation/providers/trips_provider.dart';
import '../utils/add_flight_navigation.dart';
import '../widgets/traveller_bottom_nav.dart';

class UpcomingTripsScreen extends StatefulWidget {
  const UpcomingTripsScreen({super.key});

  @override
  State<UpcomingTripsScreen> createState() => _UpcomingTripsScreenState();
}

class _UpcomingTripsScreenState extends State<UpcomingTripsScreen> {
  final Set<String> _deletingTripIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLimitData();
    });
  }

  Future<void> _loadLimitData() async {
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
        await _loadLimitData();
      },
    );
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

  String _formatFlightTime(String? isoLike, String fallback) {
    if (isoLike == null || isoLike.trim().isEmpty) return fallback;
    final isoMatch = RegExp(r'T(\d{2}):(\d{2})').firstMatch(isoLike);
    if (isoMatch != null) return '${isoMatch.group(1)}:${isoMatch.group(2)}';
    final plainMatch = RegExp(r'^(\d{2}):(\d{2})').firstMatch(isoLike.trim());
    if (plainMatch != null) return '${plainMatch.group(1)}:${plainMatch.group(2)}';
    return isoLike;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upcoming Trips',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
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
    final tripsProvider = context.watch<TripsProvider>();
    final trips = tripsProvider.trips;
    final isLoading = tripsProvider.isLoading && trips.isEmpty;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
        ),
      );
    }

    if (tripsProvider.state == TripsState.error && trips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Failed to load trips:\n${tripsProvider.errorMessage}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLimitData,
      color: const Color(0xFFFFC229),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (trips.isEmpty)
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
              ...trips.map((trip) {
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
              }),
          ],
        ),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    flightCode,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fromTime,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fromCity,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.swap_horiz,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
                size: 24,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    to,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    toTime,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    toCity,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$terminal  •  $gate',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Text(
                date,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
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
