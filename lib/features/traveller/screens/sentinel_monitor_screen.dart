import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../models/alert_model.dart';
import '../presentation/providers/trips_provider.dart';
import '../presentation/providers/alert_provider.dart';
import '../widgets/traveller_bottom_nav.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import '../data/datasources/flight_remote_datasource.dart';

class SentinelMonitorScreen extends StatefulWidget {
  final TripModel? initialTrip;

  const SentinelMonitorScreen({
    super.key,
    this.initialTrip,
  });

  @override
  State<SentinelMonitorScreen> createState() => _SentinelMonitorScreenState();
}

class _SentinelMonitorScreenState extends State<SentinelMonitorScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _whatsappMessages = true;
  bool _isLoading = true;
  List<TripModel> _trips = [];
  List<AlertModel> _dbAlerts = [];
  TripModel? _selectedTrip;
  String? _errorMessage;
  StreamSubscription<RemoteMessage>? _fcmSubscription;
  FlightStatusModel? _liveStatus;

  @override
  void initState() {
    super.initState();
    _selectedTrip = widget.initialTrip;
    
    // Listen for incoming FCM messages to instantly refresh the dashboard
    _fcmSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (mounted) {
        _loadTrips();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrips();
    });
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
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

  Future<void> _loadTrips({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tripsProvider = context.read<TripsProvider>();
      final alertProvider = context.read<AlertProvider>();

      await Future.wait([
        tripsProvider.loadTrips(),
      ]);

      if (!mounted) return;

      final trips = tripsProvider.trips;
      final alerts = alertProvider.alerts;

      final monitoredTrips =
          trips.where((trip) => trip.trackingEnabled).toList();
      final selected = _selectedTrip == null
          ? (monitoredTrips.isNotEmpty
              ? monitoredTrips.first
              : trips.isNotEmpty
                  ? trips.first
                  : null)
          : trips.firstWhere(
              (trip) => trip.id == _selectedTrip!.id,
              orElse: () => _selectedTrip!,
            );

      _trips = monitoredTrips.isNotEmpty ? monitoredTrips : trips;
      _dbAlerts = alerts;
      _selectedTrip = selected;

      if (selected != null && selected.flightNumber.isNotEmpty) {
        try {
          final dateParam = _toYMD(selected.departureDate);
          final live = await FlightRemoteDatasource.fetchFlightStatus(
            selected.flightNumber,
            flightDate: dateParam,
            forceRefresh: forceRefresh,
          );
          _liveStatus = live;
        } catch (e) {
          debugPrint('[SentinelMonitorScreen] Realtime status fetch failed: $e');
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  TripTimelineItem? get _firstLeg =>
      _selectedTrip?.timeline.isNotEmpty == true
          ? _selectedTrip!.timeline.first
          : null;

  String get _flightLabel {
    final trip = _selectedTrip;
    if (trip == null) return 'No flight selected';
    return _readable(trip.flightNumber, fallback: trip.tripName);
  }

  String get _routeLabel {
    final trip = _selectedTrip;
    if (trip == null) return 'Add a flight to start monitoring';
    final origin = _readable(trip.origin, fallback: _firstLeg?.from ?? 'Origin');
    final destination =
        _readable(trip.destination, fallback: _firstLeg?.to ?? 'Destination');
    return '$origin -> $destination';
  }

  int get _activeAlerts {
    final trip = _selectedTrip;
    if (trip == null) return 0;
    
    // Sum of timeline active alerts and unread DB alerts for this flight
    final timelineAlertsCount = trip.timeline.fold<int>(
      0,
      (total, item) => total + (item.activeAlerts ?? 0),
    );
    
    final unreadDbAlertsCount = _dbAlerts
        .where((a) => a.flightCode == trip.flightNumber && !a.isRead)
        .length;
        
    final liveAlertsCount = (_liveStatus != null && (_liveStatus!.isDelayed || _liveStatus!.isCancelled)) ? 1 : 0;
        
    return timelineAlertsCount + unreadDbAlertsCount + liveAlertsCount;
  }

  String _getDepartureTime(TripModel trip) {
    if (_liveStatus != null) {
      final timeStr = _liveStatus!.departure.actual ?? _liveStatus!.departure.estimated;
      if (timeStr.isNotEmpty) {
        return _timeLabel(timeStr, 'Monitoring');
      }
      final sched = _liveStatus!.departure.scheduled;
      if (sched.isNotEmpty) {
        return _timeLabel(sched, 'Monitoring');
      }
    }
    return _timeLabel(_firstLeg?.fromTime, 'Monitoring');
  }

  String _getArrivalTime(TripModel trip) {
    if (_liveStatus != null) {
      final timeStr = _liveStatus!.arrival.actual ?? _liveStatus!.arrival.estimated;
      if (timeStr.isNotEmpty) {
        return _timeLabel(timeStr, 'Monitoring');
      }
      final sched = _liveStatus!.arrival.scheduled;
      if (sched.isNotEmpty) {
        return _timeLabel(sched, 'Monitoring');
      }
    }
    return _timeLabel(_firstLeg?.toTime, 'Monitoring');
  }

  String _readable(String? value, {String fallback = '-'}) {
    if (value == null) return fallback;
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String _statusLabel(String status) {
    final readable = status.replaceAll('_', ' ').trim();
    if (readable.isEmpty) return 'Planned';
    return readable[0].toUpperCase() + readable.substring(1);
  }

  /// Extracts HH:mm from an ISO-8601 string without applying any timezone
  /// conversion. AirLabs embeds the local airport time in the string
  /// itself (e.g. "2026-06-19T16:15:00+00:00" where 16:15 IS the local time),
  /// so calling DateTime.parse().toLocal() would shift the value a second time
  /// (e.g. +5 h on a PKT device → 21:15).  We avoid that by reading the
  /// time component directly.
  String _timeLabel(String? isoLike, String fallback) {
    if (isoLike == null || isoLike.trim().isEmpty) return fallback;
    
    String _to12Hour(String hh, String mm) {
      int hour = int.parse(hh);
      String amPm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '${hour.toString().padLeft(2, '0')}:$mm $amPm';
    }

    // ISO string with a 'T' separator — extract the HH:mm after the T.
    final isoMatch = RegExp(r'T(\d{2}):(\d{2})').firstMatch(isoLike);
    if (isoMatch != null) return _to12Hour(isoMatch.group(1)!, isoMatch.group(2)!);
    
    // Plain HH:mm (no date prefix) — return as-is after validation.
    final plainMatch = RegExp(r'^(\d{2}):(\d{2})').firstMatch(isoLike.trim());
    if (plainMatch != null) return _to12Hour(plainMatch.group(1)!, plainMatch.group(2)!);
    
    // Unrecognised format — show the raw string so no data is lost.
    return isoLike;
  }

  Color _riskColor(String? risk) {
    switch ((risk ?? '').toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFFFC229);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = _selectedTrip;
    final risk = _firstLeg?.riskLevel ?? 'Low';
    final riskColor = _riskColor(risk);

    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sentinel™ Monitor',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              trip == null ? 'No monitored flight yet' : '$_flightLabel · ${(_liveStatus != null && _liveStatus!.departure.iata.isNotEmpty) ? "${_liveStatus!.departure.iata} -> ${_liveStatus!.arrival.iata}" : _routeLabel}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 24, top: 12, bottom: 12),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (_liveStatus != null || trip?.trackingEnabled == true)
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.outline.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ((_liveStatus != null || trip?.trackingEnabled == true)
                        ? const Color(0xFF10B981)
                        : Theme.of(context).colorScheme.onSurface)
                    .withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: (_liveStatus != null || trip?.trackingEnabled == true)
                        ? const Color(0xFF10B981)
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  (_liveStatus != null || trip?.trackingEnabled == true) ? 'Active' : 'Idle',
                  style: TextStyle(
                    color: (_liveStatus != null || trip?.trackingEnabled == true)
                        ? const Color(0xFF10B981)
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildBody(trip, risk, riskColor),
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 1),
    );
  }

  Widget _buildBody(TripModel? trip, String risk, Color riskColor) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildMessageState(
        icon: Icons.error_outline,
        title: 'Could not load Sentinel data',
        message: _errorMessage!,
        actionLabel: 'Retry',
        onAction: _loadTrips,
      );
    }

    if (trip == null) {
      return _buildMessageState(
        icon: Icons.flight_takeoff,
        title: 'No monitored flights yet',
        message:
            'Add a flight to monitor and its flight number, route, date, status, and live details will appear here.',
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFFFC229),
      backgroundColor: Theme.of(context).colorScheme.surface,
      onRefresh: () => _loadTrips(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFlightSummaryCard(trip, risk, riskColor),
            SizedBox(height: 22),
            if (_trips.length > 1) ...[
              _buildTripSelector(),
              SizedBox(height: 22),
            ],
            _buildProtectionCard(trip),
            SizedBox(height: 28),
            _buildAlertsSection(trip),
            SizedBox(height: 28),
            Text(
              'Monitoring Metrics',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildMetricBox(
                  label: 'Delay Status',
                  value: _liveStatus != null 
                      ? (_liveStatus!.delayMinutes > 0 ? '+${_liveStatus!.delayMinutes}m' : 'On Time')
                      : (_firstLeg?.delayProb ?? 'Monitoring'),
                  icon: _activeAlerts > 0
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  iconColor: _activeAlerts > 0
                      ? const Color(0xFFFFC229)
                      : const Color(0xFF10B981),
                ),
                _buildMetricBox(
                  label: 'Flight Status',
                  value: _liveStatus != null ? _liveStatus!.statusLabel : _statusLabel(trip.status),
                  icon: Icons.radar_outlined,
                  iconColor: riskColor,
                ),
                _buildMetricBox(
                  label: 'Risk Level',
                  value: _liveStatus != null 
                      ? (_liveStatus!.isCancelled ? 'Critical' : (_liveStatus!.isDelayed ? 'High' : 'Low'))
                      : risk,
                  icon: Icons.shield_outlined,
                  iconColor: riskColor,
                ),
                _buildMetricBox(
                  label: 'Active Alerts',
                  value: '$_activeAlerts',
                  icon: Icons.notifications_none,
                  iconColor: _activeAlerts > 0
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                ),
              ],
            ),
            SizedBox(height: 28),
            _buildNotificationSettings(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightSummaryCard(
    TripModel trip,
    String risk,
    Color riskColor,
  ) {
    final origin = _readable(trip.origin, fallback: _firstLeg?.from ?? '-');
    final destination =
        _readable(trip.destination, fallback: _firstLeg?.to ?? '-');

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Color(0xFFFFC229).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _flightLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      _liveStatus != null ? _liveStatus!.statusLabel : _statusLabel(trip.status),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: (_liveStatus != null && (_liveStatus!.isDelayed || _liveStatus!.isCancelled) ? Colors.red.withOpacity(0.12) : riskColor.withOpacity(0.12)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _liveStatus != null 
                      ? (_liveStatus!.isCancelled ? 'CRITICAL RISK' : (_liveStatus!.isDelayed ? 'HIGH RISK' : 'LOW RISK'))
                      : '${risk.toUpperCase()} RISK',
                  style: TextStyle(
                    color: _liveStatus != null 
                        ? (_liveStatus!.isCancelled ? Colors.red : (_liveStatus!.isDelayed ? const Color(0xFFFFC229) : const Color(0xFF10B981)))
                        : riskColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 22),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(child: _buildRoutePoint((_liveStatus != null && _liveStatus!.departure.iata.isNotEmpty) ? _liveStatus!.departure.iata : origin, 'Departure')),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.flight,
                    color: Color(0xFFFFC229),
                    size: 30,
                  ),
                ),
                Expanded(child: _buildRoutePoint((_liveStatus != null && _liveStatus!.arrival.iata.isNotEmpty) ? _liveStatus!.arrival.iata : destination, 'Arrival')),
              ],
            ),
          ),
          SizedBox(height: 18),
          _buildDetailRow(Icons.calendar_today_outlined, 'Departure Date',
              _readable(trip.departureDate)),
          _buildDetailRow(Icons.access_time, 'Departure Time',
              _getDepartureTime(trip)),
          _buildDetailRow(Icons.schedule, 'Arrival Time',
              _getArrivalTime(trip)),
          _buildDetailRow(Icons.confirmation_number_outlined,
              'Booking Reference', _readable(trip.bookingReference)),
          _buildDetailRow(Icons.radar_outlined, 'Last Checked',
              _liveStatus != null ? _timeLabel(DateTime.now().toIso8601String(), 'Just now') : _timeLabel(trip.lastTrackedAt, 'Pending first check')),
        ],
      ),
    );
  }

  Widget _buildRoutePoint(String code, String label) {
    return Column(
      children: [
        Text(
          code,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), size: 17),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.42),
                fontSize: 12,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripSelector() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _trips.length,
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemBuilder: (context, index) {
          final trip = _trips[index];
          final selected = trip.id == _selectedTrip?.id;
          return GestureDetector(
            onTap: () async {
              if (trip.id == _selectedTrip?.id) return;
              setState(() {
                _selectedTrip = trip;
                _liveStatus = null;
                _isLoading = true;
              });
              if (trip.flightNumber.isNotEmpty) {
                try {
                  final dateParam = _toYMD(trip.departureDate);
                  final live = await FlightRemoteDatasource.fetchFlightStatus(
                    trip.flightNumber,
                    flightDate: dateParam,
                  );
                  if (mounted && _selectedTrip?.id == trip.id) {
                    setState(() {
                      _liveStatus = live;
                    });
                  }
                } catch (e) {
                  debugPrint('[SentinelMonitorScreen] Realtime status selector fetch failed: $e');
                }
              }
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFFC229)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
              ),
              child: Text(
                _readable(trip.flightNumber, fallback: trip.tripName),
                style: TextStyle(
                  color: selected ? Colors.black : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProtectionCard(TripModel trip) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: Color(0xFFFFC229),
            size: 22,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Real-Time Protection Active',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Monitoring $_flightLabel for delays, cancellations, route updates, gate changes, and disruption signals.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(TripModel trip) {
    final timelineAlerts = trip.timeline
        .where((item) => (item.activeAlerts ?? 0) > 0 || item.info != null)
        .toList();

    final dbAlertsForFlight = _dbAlerts
        .where((a) => a.flightCode == trip.flightNumber)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Alerts',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (_activeAlerts > 0
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981))
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_activeAlerts Alerts',
                style: TextStyle(
                  color: _activeAlerts > 0
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14),
        if (timelineAlerts.isEmpty && dbAlertsForFlight.isEmpty)
          _buildAlertCard(
            icon: Icons.check_circle_outline,
            color: const Color(0xFF10B981),
            title: 'No disruption detected',
            message:
                'Sentinel is watching ${_flightLabel} and will show delay, cancellation, gate, or route alerts here.',
            time: 'Live',
          )
        else ...[
          ...dbAlertsForFlight.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _buildAlertCard(
                icon: item.priority == 'CRITICAL' || item.priority == 'HIGH'
                    ? Icons.error_outline
                    : Icons.info_outline,
                color: item.priority == 'CRITICAL' || item.priority == 'HIGH' 
                    ? const Color(0xFFEF4444)
                    : (item.priority == 'MEDIUM' ? const Color(0xFFFFC229) : const Color(0xFF10B981)),
                title: '${item.eventType} Alert',
                message: item.message,
                time: _timeLabel(item.createdAt, 'Recent'),
              ),
            ),
          ),
          ...timelineAlerts.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _buildAlertCard(
                icon: (item.riskLevel ?? '').toLowerCase() == 'high'
                    ? Icons.error_outline
                    : Icons.info_outline,
                color: _riskColor(item.riskLevel),
                title: item.riskLevel == null
                    ? 'Flight update'
                    : '${item.riskLevel} risk update',
                message: _readable(item.info, fallback: 'Monitoring update'),
                time: _readable(item.date, fallback: 'Live'),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                      fontSize: 9,
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

  Widget _buildMetricBox({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                    fontSize: 11,
                  ),
                ),
              ),
              Icon(icon, color: iconColor, size: 15),
            ],
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_none,
                color: Color(0xFFFFC229),
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                'Notification Settings',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildSwitchRow(
            label: 'Push Notifications',
            value: _pushNotifications,
            onChanged: (val) {
              setState(() {
                _pushNotifications = val;
              });
            },
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          _buildSwitchRow(
            label: 'Email Alerts',
            value: _emailAlerts,
            onChanged: (val) {
              setState(() {
                _emailAlerts = val;
              });
            },
          ),
          Divider(color: Theme.of(context).colorScheme.outline),
          _buildSwitchRow(
            label: 'WhatsApp Messages',
            value: _whatsappMessages,
            onChanged: (val) {
              setState(() {
                _whatsappMessages = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFFC229),
          activeTrackColor: Color(0xFFFFC229).withOpacity(0.3),
          inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
          inactiveTrackColor: Colors.white10,
        ),
      ],
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFFFC229), size: 42),
            SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.48),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 20),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    color: Color(0xFFFFC229),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
