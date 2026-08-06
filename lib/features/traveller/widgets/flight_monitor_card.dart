import 'dart:async';
import 'package:flutter/material.dart';
import '../data/datasources/flight_remote_datasource.dart';
import '../screens/flight_detail_screen.dart';
import '../models/trip_model.dart';

class FlightMonitorCard extends StatefulWidget {
  final TripModel? activeTrip;

  const FlightMonitorCard({super.key, this.activeTrip});

  @override
  State<FlightMonitorCard> createState() => _FlightMonitorCardState();
}

class _FlightMonitorCardState extends State<FlightMonitorCard> {
  // ── State ─────────────────────────────────────────────────────────────────
  FlightStatusModel? _statusData;
  bool _isPolling = false;
  DateTime? _lastChecked;
  Timer? _pollTimer;
  Timer? _labelTimer; // ticks every minute to refresh "X min ago" without a new API call
  String? _pollError;

  // ── Helpers ───────────────────────────────────────────────────────────────
  /// Normalises any date string to YYYY-MM-DD so the backend doesn't return 400.
  static String _toYMD(String raw) {
    if (raw.isEmpty) return '';
    // Already YYYY-MM-DD
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) return raw;
    try {
      return DateTime.parse(raw).toIso8601String().split('T').first;
    } catch (_) {
      return '';
    }
  }

  // ── Status Mapping ────────────────────────────────────────────────────────
  /// Maps AirLabs' raw `status` to a human-readable label.
  static String _mapStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'active':
        return 'En-Route';
      case 'en-route':
        return 'En-Route';
      case 'landed':
        return 'Landed';
      case 'landed_estimated':
        return 'Landed (Est.)';
      case 'cancelled':
        return 'Cancelled';
      case 'delayed':
        return 'Delayed';
      case 'diverted':
        return 'Diverted';
      case 'incident':
        return 'Incident';
      case 'scheduled':
      default:
        return 'Scheduled';
    }
  }

  /// Returns icon + color pair for each status.
  static (IconData, Color) _statusStyle(String raw) {
    switch (raw.toLowerCase()) {
      case 'active':
      case 'en-route':
        return (Icons.flight, const Color(0xFF10B981)); // green
      case 'landed':
      case 'landed_estimated':
        return (Icons.flight_land, const Color(0xFF6366F1)); // indigo
      case 'cancelled':
        return (Icons.cancel_outlined, const Color(0xFFEF4444)); // red
      case 'delayed':
        return (Icons.access_time, const Color(0xFFFFC229)); // yellow
      case 'diverted':
        return (Icons.alt_route, const Color(0xFFF59E0B)); // amber
      case 'incident':
        return (Icons.warning_amber_rounded, const Color(0xFFEF4444)); // red
      default:
        return (Icons.schedule, const Color(0xFF9AA5B8)); // grey
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _poll(); // immediate first poll
    // Poll every 5 minutes for fresh status
    _pollTimer = Timer.periodic(const Duration(minutes: 5), (_) => _poll());
    // Tick every minute so "Last checked: Xm ago" label updates without an API call
    _labelTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(FlightMonitorCard old) {
    super.didUpdateWidget(old);
    // If the parent pushes a new trip (e.g. after pull-to-refresh) re-poll immediately.
    if (old.activeTrip?.flightNumber != widget.activeTrip?.flightNumber ||
        old.activeTrip?.departureDate != widget.activeTrip?.departureDate) {
      _pollTimer?.cancel();
      _poll();
      _pollTimer = Timer.periodic(const Duration(minutes: 5), (_) => _poll());
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _labelTimer?.cancel();
    super.dispose();
  }

  // ── Poll ──────────────────────────────────────────────────────────────────
  Future<void> _poll() async {
    final trip = widget.activeTrip;
    if (trip == null || trip.flightNumber.isEmpty) return;
    if (!mounted) return;

    setState(() {
      _isPolling = true;
      _pollError = null;
    });

    // Normalise date to YYYY-MM-DD — the backend rejects anything else with 400
    final dateParam = _toYMD(trip.departureDate);
    debugPrint('[FlightMonitorCard] Polling ${trip.flightNumber} date=$dateParam');

    try {
      final result = await FlightRemoteDatasource.fetchFlightStatus(
        trip.flightNumber,
        flightDate: dateParam,
        expectedOrigin: trip.origin,
        expectedDestination: trip.destination,
      );
      debugPrint('[FlightMonitorCard] API status=${result.status} delay=${result.delayMinutes}');
      if (mounted) {
        setState(() {
          _statusData = result;
          _lastChecked = DateTime.now();
          _isPolling = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pollError = e.toString().replaceAll('Exception: ', '');
          _isPolling = false;
        });
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String get _lastCheckedLabel {
    if (_isPolling) return 'Checking…';
    if (_lastChecked == null) return 'Never';
    final diff = DateTime.now().difference(_lastChecked!);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final trip = widget.activeTrip;
    if (trip == null) return const SizedBox.shrink();

    final timelineFirst = trip.timeline.isNotEmpty ? trip.timeline.first : null;

    // Use live status if we have it, else fall back to what the trip has stored
    final rawStatus = _statusData?.status ?? trip.status;
    final statusLabel = _mapStatus(rawStatus);
    final (statusIcon, statusColor) = _statusStyle(rawStatus);

    // Delay info from live data takes priority
    final delayMinutes = _statusData?.delayMinutes ?? 0;
    final delayProb = timelineFirst?.delayProb ?? '0%';
    final activeAlerts = timelineFirst?.activeAlerts?.toString() ?? '0';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FlightDetailScreen(trip: trip)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP ROW: Flight number + Live Status Badge ──────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sentinel™ Monitoring',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        trip.flightNumber.isEmpty ? 'Flight' : trip.flightNumber,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Live status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: statusColor.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pulsing dot for en-route
                      if (rawStatus.toLowerCase() == 'active')
                        _PulsingDot(color: statusColor)
                      else
                        Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── ROUTE ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AirportCol(
                    code: trip.origin.isEmpty ? 'N/A' : trip.origin,
                    label: 'Departure',
                    context: context,
                  ),
                  Transform.rotate(
                    angle: -0.8,
                    child: const Icon(Icons.flight, color: Color(0xFFFFC229), size: 30),
                  ),
                  _AirportCol(
                    code: trip.destination.isEmpty ? 'N/A' : trip.destination,
                    label: 'Arrival',
                    context: context,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── STATS ROW ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Delay probability
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delay Probability',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 110,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: delayMinutes > 0 ? 80 : 30,
                              decoration: BoxDecoration(
                                color: delayMinutes > 0
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          delayMinutes > 0 ? '+${delayMinutes}min' : delayProb,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Active alerts
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Active Alerts',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activeAlerts,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── LAST CHECKED FOOTER ──────────────────────────────────────
            Row(
              children: [
                Icon(
                  _isPolling ? Icons.sync : Icons.radar,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  'Last checked: $_lastCheckedLabel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                // Manual refresh button
                GestureDetector(
                  onTap: _isPolling ? null : _poll,
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: _isPolling
                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.2)
                            : const Color(0xFFFFC229),
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          color: _isPolling
                              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.2)
                              : const Color(0xFFFFC229),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Error message (subtle, non-blocking)
            if (_pollError != null) ...[
              const SizedBox(height: 6),
              Text(
                '⚠ Radar sync failed — showing cached status',
                style: TextStyle(
                  color: const Color(0xFFFFC229).withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _AirportCol extends StatelessWidget {
  final String code;
  final String label;
  final BuildContext context;

  const _AirportCol({
    required this.code,
    required this.label,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Column(
      children: [
        Text(
          code,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// Animated pulsing green dot used to indicate live en-route status.
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }
}
