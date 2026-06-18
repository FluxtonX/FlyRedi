import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';
import '../widgets/traveller_bottom_nav.dart';

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
  final TripRepository _tripRepository = TripRepository();
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _whatsappMessages = true;
  bool _isLoading = true;
  List<TripModel> _trips = [];
  TripModel? _selectedTrip;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedTrip = widget.initialTrip;
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final trips = await _tripRepository.fetchUserTrips();
      if (!mounted) return;

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

      setState(() {
        _trips = monitoredTrips.isNotEmpty ? monitoredTrips : trips;
        _selectedTrip = selected;
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
    return trip.timeline.fold<int>(
      0,
      (total, item) => total + (item.activeAlerts ?? 0),
    );
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

  String _timeLabel(String? isoLike, String fallback) {
    if (isoLike == null || isoLike.trim().isEmpty) return fallback;
    final parsed = DateTime.tryParse(isoLike);
    if (parsed == null) return isoLike;
    final local = parsed.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sentinel™ Monitor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              trip == null ? 'No monitored flight yet' : '$_flightLabel · $_routeLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 24, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: trip?.trackingEnabled == true
                  ? const Color(0xFF0F2D24)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (trip?.trackingEnabled == true
                        ? const Color(0xFF10B981)
                        : Colors.white)
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
                    color: trip?.trackingEnabled == true
                        ? const Color(0xFF10B981)
                        : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  trip?.trackingEnabled == true ? 'Active' : 'Idle',
                  style: TextStyle(
                    color: trip?.trackingEnabled == true
                        ? const Color(0xFF10B981)
                        : Colors.white54,
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
      return const Center(
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
      backgroundColor: const Color(0xFF0C162A),
      onRefresh: _loadTrips,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFlightSummaryCard(trip, risk, riskColor),
            const SizedBox(height: 22),
            if (_trips.length > 1) ...[
              _buildTripSelector(),
              const SizedBox(height: 22),
            ],
            _buildProtectionCard(trip),
            const SizedBox(height: 28),
            _buildAlertsSection(trip),
            const SizedBox(height: 28),
            const Text(
              'Monitoring Metrics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
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
                  value: _firstLeg?.delayProb ?? 'Monitoring',
                  icon: _activeAlerts > 0
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  iconColor: _activeAlerts > 0
                      ? const Color(0xFFFFC229)
                      : const Color(0xFF10B981),
                ),
                _buildMetricBox(
                  label: 'Flight Status',
                  value: _statusLabel(trip.status),
                  icon: Icons.radar_outlined,
                  iconColor: riskColor,
                ),
                _buildMetricBox(
                  label: 'Risk Level',
                  value: risk,
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
            const SizedBox(height: 28),
            _buildNotificationSettings(),
            const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFC229).withOpacity(0.2),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _statusLabel(trip.status),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${risk.toUpperCase()} RISK',
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF071B3A),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(child: _buildRoutePoint(origin, 'Departure')),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.flight,
                    color: Color(0xFFFFC229),
                    size: 30,
                  ),
                ),
                Expanded(child: _buildRoutePoint(destination, 'Arrival')),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildDetailRow(Icons.calendar_today_outlined, 'Departure Date',
              _readable(trip.departureDate)),
          _buildDetailRow(Icons.access_time, 'Departure Time',
              _timeLabel(_firstLeg?.fromTime, 'Monitoring')),
          _buildDetailRow(Icons.schedule, 'Arrival Time',
              _timeLabel(_firstLeg?.toTime, 'Monitoring')),
          _buildDetailRow(Icons.confirmation_number_outlined,
              'Booking Reference', _readable(trip.bookingReference)),
          _buildDetailRow(Icons.radar_outlined, 'Last Checked',
              _timeLabel(trip.lastTrackedAt, 'Pending first check')),
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.42),
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
              style: const TextStyle(
                color: Colors.white,
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
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final trip = _trips[index];
          final selected = trip.id == _selectedTrip?.id;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTrip = trip;
              });
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFFC229)
                    : const Color(0xFF0C162A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Text(
                _readable(trip.flightNumber, fallback: trip.tripName),
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white70,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
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
                const Text(
                  'Real-Time Protection Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Monitoring $_flightLabel for delays, cancellations, route updates, gate changes, and disruption signals.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Alerts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        const SizedBox(height: 14),
        if (timelineAlerts.isEmpty)
          _buildAlertCard(
            icon: Icons.check_circle_outline,
            color: const Color(0xFF10B981),
            title: 'No disruption detected',
            message:
                'Sentinel is watching ${_flightLabel} and will show delay, cancellation, gate, or route alerts here.',
            time: 'Live',
          )
        else
          ...timelineAlerts.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
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
                    color: Colors.white.withOpacity(0.35),
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
            style: const TextStyle(
              color: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
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
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSwitchRow(
            label: 'Push Notifications',
            value: _pushNotifications,
            onChanged: (val) {
              setState(() {
                _pushNotifications = val;
              });
            },
          ),
          Divider(color: Colors.white.withOpacity(0.04)),
          _buildSwitchRow(
            label: 'Email Alerts',
            value: _emailAlerts,
            onChanged: (val) {
              setState(() {
                _emailAlerts = val;
              });
            },
          ),
          Divider(color: Colors.white.withOpacity(0.04)),
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFFC229),
          activeTrackColor: const Color(0xFFFFC229).withOpacity(0.3),
          inactiveThumbColor: Colors.white24,
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
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFFFC229), size: 42),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.48),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel,
                  style: const TextStyle(
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
