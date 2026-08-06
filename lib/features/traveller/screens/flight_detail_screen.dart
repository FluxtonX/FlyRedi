import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../models/trip_model.dart';
import 'flight_details_screen.dart';
import 'border_ready_screen.dart';
import 'sentinel_monitor_screen.dart';
import 'ai_assistant_screen.dart';
import 'live_flight_tracker_screen.dart';
import '../data/datasources/flight_remote_datasource.dart';

class FlightDetailScreen extends StatefulWidget {
  final TripModel trip;

  const FlightDetailScreen({super.key, required this.trip});

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  FlightStatusModel? _liveStatus;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchLiveDetails();
    // Auto-refresh every 30 seconds for live tracking
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _fetchLiveDetails(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  static String _toYMD(String raw) {
    if (raw.isEmpty) return '';
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) return raw;
    try {
      return DateTime.parse(raw).toIso8601String().split('T').first;
    } catch (_) {
      return '';
    }
  }

  Future<void> _fetchLiveDetails({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final dateParam = _toYMD(widget.trip.departureDate);
    try {
      final status = await FlightRemoteDatasource.fetchFlightStatus(
        widget.trip.flightNumber,
        flightDate: dateParam,
        expectedOrigin: widget.trip.origin,
        expectedDestination: widget.trip.destination,
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          _liveStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '—';
    
    // First, try direct ISO time extraction to avoid timezone conversion shift
    final match = RegExp(r'T(\d{2}):(\d{2})').firstMatch(timeStr);
    if (match != null) {
      final hh = int.parse(match.group(1)!);
      final mm = match.group(2)!;
      final period = hh >= 12 ? 'PM' : 'AM';
      final displayH = hh % 12 == 0 ? 12 : hh % 12;
      return '${displayH.toString().padLeft(2, '0')}:$mm $period';
    }

    final plainMatch = RegExp(r'^(\d{2}):(\d{2})').firstMatch(timeStr.trim());
    if (plainMatch != null) {
      final hh = int.parse(plainMatch.group(1)!);
      final mm = plainMatch.group(2)!;
      final period = hh >= 12 ? 'PM' : 'AM';
      final displayH = hh % 12 == 0 ? 12 : hh % 12;
      return '${displayH.toString().padLeft(2, '0')}:$mm $period';
    }

    try {
      final dateTime = DateTime.parse(timeStr);
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
      return '${formattedHour.toString().padLeft(2, '0')}:$minute $period';
    } catch (_) {
      return timeStr;
    }
  }

  String _getScheduledDeparture(FlightStatusModel status) {
    final sched = status.departure.scheduled;
    if (sched.isNotEmpty) {
      return _formatTime(sched);
    }
    if (widget.trip.timeline.isNotEmpty) {
      final leg = widget.trip.timeline.first;
      if (leg.fromTime != null && leg.fromTime!.isNotEmpty) {
        return _formatTime(leg.fromTime);
      }
    }
    return '—';
  }

  String _getEstimatedDeparture(FlightStatusModel status) {
    final timeStr = status.departure.actual ?? status.departure.estimated;
    if (timeStr.isNotEmpty) {
      return _formatTime(timeStr);
    }
    final sched = status.departure.scheduled;
    if (sched.isNotEmpty) {
      return _formatTime(sched);
    }
    if (widget.trip.timeline.isNotEmpty) {
      final leg = widget.trip.timeline.first;
      if (leg.fromTime != null && leg.fromTime!.isNotEmpty) {
        return _formatTime(leg.fromTime);
      }
    }
    return '—';
  }

  String _getScheduledArrival(FlightStatusModel status) {
    final sched = status.arrival.scheduled;
    if (sched.isNotEmpty) {
      return _formatTime(sched);
    }
    if (widget.trip.timeline.isNotEmpty) {
      final leg = widget.trip.timeline.first;
      if (leg.toTime != null && leg.toTime!.isNotEmpty) {
        return _formatTime(leg.toTime);
      }
    }
    return '—';
  }

  String _getEstimatedArrival(FlightStatusModel status) {
    final timeStr = status.arrival.actual ?? status.arrival.estimated;
    if (timeStr.isNotEmpty) {
      return _formatTime(timeStr);
    }
    final sched = status.arrival.scheduled;
    if (sched.isNotEmpty) {
      return _formatTime(sched);
    }
    if (widget.trip.timeline.isNotEmpty) {
      final leg = widget.trip.timeline.first;
      if (leg.toTime != null && leg.toTime!.isNotEmpty) {
        return _formatTime(leg.toTime);
      }
    }
    return '—';
  }

  String _formatDate(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '—';
    try {
      final dateTime = DateTime.parse(timeStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (_) {
      return timeStr;
    }
  }

  String _getDirectionName(double? degrees) {
    if (degrees == null) return '';
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    final index = ((degrees + 22.5) % 360) ~/ 45;
    return directions[index];
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'active_delayed':
        return const Color(0xFF10B981);
      case 'landed':
      case 'landed_estimated':
        return const Color(0xFF6366F1);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'delayed':
        return const Color(0xFFFFC229);
      case 'diverted':
        return const Color(0xFFF59E0B);
      case 'incident':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF9AA5B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Flight Tracker Radar',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: const Color(0xFFFFC229)),
            onPressed: () => _fetchLiveDetails(forceRefresh: true),
          ),
          if (_liveStatus?.live != null)
            IconButton(
              icon: Icon(Icons.map_outlined, color: const Color(0xFFFFC229)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LiveFlightTrackerScreen(trip: widget.trip),
                  ),
                );
              },
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
            ),
            const SizedBox(height: 18),
            Text(
              'Syncing with Radar Systems...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 54),
              const SizedBox(height: 18),
              Text(
                'Sync Failed',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC229),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => _fetchLiveDetails(forceRefresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Search', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final status = _liveStatus!;
    final statusColor = _statusColor(status.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- HEADER CARD (Flight Details, operator, status badge) ---
          _buildHeaderSection(status, statusColor),
          const SizedBox(height: 16),

          // --- ROUTE & AIRPORT BLOCK ---
          _buildRouteSection(status),
          const SizedBox(height: 16),

          // --- SCHEDULE TIMELINE & RUNWAYS ---
          _buildTimelineSection(status),
          const SizedBox(height: 16),

          // --- LIVE TELEMETRY (if available) ---
          if (status.live != null) ...[
            _buildTelemetrySection(status.live!),
            const SizedBox(height: 16),
          ],

          // --- AIRCRAFT DETAILS ---
          if (status.aircraft != null) ...[
            _buildAircraftSection(status.aircraft!),
            const SizedBox(height: 16),
          ],

          // --- CODESHARE INFO ---
          if (status.codeshare != null) ...[
            _buildCodeshareSection(status.codeshare!),
            const SizedBox(height: 16),
          ],

          // --- SENTINEL MONITOR ACTIVE CARD ---
          _buildSentinelSection(),
          const SizedBox(height: 16),

          // --- DISRUPTION & CLAIM RESOLUTION MODULES ---
          if (status.isDelayed || status.isCancelled) ...[
            _buildDisruptionSection(status),
            const SizedBox(height: 16),
            _buildResolutionSection(status),
            const SizedBox(height: 16),
          ],

          // --- BORDER READY MODULE ---
          _buildBorderReadySection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(FlightStatusModel status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.airline.name.isEmpty ? 'Unknown Airline' : status.airline.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          status.flightNumber.isEmpty ? 'N/A' : status.flightNumber,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (status.flightIcao != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '/ ${status.flightIcao}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status.isActive) ...[
                      _PulsingDot(color: statusColor),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      status.statusLabel.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (status.callsign != null) ...[
            const SizedBox(height: 10),
            Divider(color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.radar_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                const SizedBox(width: 6),
                Text(
                  'Callsign: ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
                Text(
                  status.callsign!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRouteSection(FlightStatusModel status) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.departure.iata.isEmpty ? 'N/A' : status.departure.iata,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status.departure.icao.isNotEmpty)
                      Text(
                        status.departure.icao,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      status.departure.airport,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Transform.rotate(
                  angle: 1.5708, // Pointing right
                  child: const Icon(
                    Icons.flight,
                    color: Color(0xFFFFC229),
                    size: 32,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      status.arrival.iata.isEmpty ? 'N/A' : status.arrival.iata,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status.arrival.icao.isNotEmpty)
                      Text(
                        status.arrival.icao,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      status.arrival.airport,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLocationDetailColumn('Terminal', status.departure.terminal ?? '—'),
              _buildVerticalDivider(),
              _buildLocationDetailColumn('Gate', status.departure.gate ?? '—'),
              _buildVerticalDivider(),
              _buildLocationDetailColumn('Baggage', status.arrival.baggage ?? '—'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetailColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Theme.of(context).colorScheme.outline,
    );
  }

  Widget _buildTimelineSection(FlightStatusModel status) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
              const SizedBox(width: 8),
              Text(
                'Flight Timeline & Runways',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                status.durationLabel,
                style: const TextStyle(
                  color: Color(0xFFFFC229),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimeRow('Date', _formatDate(status.flightDate), isDate: true),
          const SizedBox(height: 10),
          _buildTimeRow('Scheduled Departure', _getScheduledDeparture(status)),
          _buildTimeRow('Estimated Departure', _getEstimatedDeparture(status)),
          if (status.departure.actual != null)
            _buildTimeRow('Actual Departure', _formatTime(status.departure.actual), highlightColor: const Color(0xFF10B981)),
          if (status.departure.actualRunway != null)
            _buildTimeRow('Runway Takeoff', _formatTime(status.departure.actualRunway)),
          const SizedBox(height: 6),
          Divider(color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 6),
          _buildTimeRow('Scheduled Arrival', _getScheduledArrival(status)),
          _buildTimeRow('Estimated Arrival', _getEstimatedArrival(status)),
          if (status.arrival.actual != null)
            _buildTimeRow('Actual Arrival', _formatTime(status.arrival.actual), highlightColor: const Color(0xFF6366F1)),
          if (status.arrival.actualRunway != null)
            _buildTimeRow('Runway Landing', _formatTime(status.arrival.actualRunway)),
          const SizedBox(height: 10),
          _buildTimeRow('Airport Timezones', '${status.departure.timezone} / ${status.arrival.timezone}', isMuted: true),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, String value, {Color? highlightColor, bool isDate = false, bool isMuted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(isMuted ? 0.35 : 0.5),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlightColor ?? (isDate ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.onSurface),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetrySection(FlightLiveTelemetry live) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFC229).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.radar, size: 16, color: const Color(0xFFFFC229)),
              const SizedBox(width: 8),
              const Text(
                'Live Telemetry Radar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'RADAR SYNCED',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryBlock('Altitude', '${live.altitude ?? 0} ft', Icons.height),
              ),
              Expanded(
                child: _buildTelemetryBlock('Speed', '${live.speedHorizontal ?? 0} kts', Icons.speed),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryBlock(
                  'Heading',
                  '${live.direction != null ? live.direction!.toInt() : 0}° ${_getDirectionName(live.direction)}',
                  Icons.explore_outlined,
                ),
              ),
              Expanded(
                child: _buildTelemetryBlock('Vertical Speed', '${live.speedVertical ?? 0} ft/m', Icons.unfold_more),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTelemetryDetailRow('Coordinates', '${live.latitude?.toStringAsFixed(4) ?? '0.0000'}°, ${live.longitude?.toStringAsFixed(4) ?? '0.0000'}°'),
          _buildTelemetryDetailRow('Ground Status', live.isGround ? 'On Ground' : 'In Flight'),
          _buildTelemetryDetailRow('Radar Updated', _formatTime(live.updated)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveFlightTrackerScreen(trip: widget.trip),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC229).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFC229).withOpacity(0.3)),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, color: const Color(0xFFFFC229), size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Track Real-Time Flight Path Map',
                    style: TextStyle(
                      color: Color(0xFFFFC229),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryBlock(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAircraftSection(FlightAircraft aircraft) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.flight_class_outlined, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
              const SizedBox(width: 8),
              Text(
                'Aircraft Equipment Details',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAircraftRow('Model (IATA/ICAO)', '${aircraft.iata ?? '—'} / ${aircraft.icao ?? '—'}'),
          _buildAircraftRow('Registration Tail Number', aircraft.registration ?? '—'),
          _buildAircraftRow('ICAO24 Mode-S Address', aircraft.icao24 ?? '—'),
        ],
      ),
    );
  }

  Widget _buildAircraftRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeshareSection(FlightCodeshare codeshare) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: const Color(0xFFFFC229).withOpacity(0.8), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Codeshared Flight: operated by ${codeshare.airlineName ?? 'partner'} (${codeshare.flightIata ?? codeshare.flightNumber ?? '—'})',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentinelSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFC229).withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: Color(0xFFFFC229),
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sentinel™ Active Monitoring',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time monitoring is active. Sentinel tracks gate, schedule, and delay updates directly.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SentinelMonitorScreen(initialTrip: widget.trip),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: const Text(
                      'View Monitoring Dashboard',
                      style: TextStyle(
                        color: Color(0xFFFFC229),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisruptionSection(FlightStatusModel status) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.red.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.isCancelled ? 'Flight Cancelled' : 'Flight Delayed',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.isCancelled 
                      ? 'Your flight has been cancelled. You may claim compensation.' 
                      : 'Flight delay exceeds threshold. Status checked via Radar.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 12),
                _buildTimeRow('Departure Delay', '${status.departure.delay ?? 0} mins'),
                _buildTimeRow('Arrival Delay', '${status.arrival.delay ?? 0} mins'),
                _buildTimeRow('Status', status.statusLabel.toUpperCase(), highlightColor: const Color(0xFFFFC229)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionSection(FlightStatusModel status) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                color: Color(0xFFFFC229),
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Resolution Assistant™',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Flight ${status.flightNumber} eligible for EU261 Resolution',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your flight interruption qualifies for compensation up to \$600 under EU261/2004 regulations. Use the Resolution Assistant to instantly file a claim.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC229).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFC229).withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: const Color(0xFFFFC229).withOpacity(0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Compensation Estimate',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Text(
                  '\$600',
                  style: TextStyle(
                    color: Color(0xFFFFC229),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FlightDetailsScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC229),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Start AI Claim Process',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Get AI Assistance',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBorderReadySection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BorderReadyScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 16),
            const SizedBox(width: 8),
            Text(
              'Check BorderReady™ Status',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.35, end: 1.0).animate(_ctrl);
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
