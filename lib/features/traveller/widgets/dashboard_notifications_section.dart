import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../screens/notifications_screen.dart';
import 'notification_card.dart';

class DashboardNotificationsSection extends StatelessWidget {
  final List<AlertModel> alerts;

  const DashboardNotificationsSection({
    super.key,
    this.alerts = const [],
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = alerts.isEmpty;
    final int criticalCount =
        alerts.where((a) => a.priority.toUpperCase() == 'CRITICAL').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Disruption Alerts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                if (criticalCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$criticalCount',
                      style: const TextStyle(
                        color: Color(0xFFE11D48),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsScreen()),
                );
              },
              child: const Text(
                'View all',
                style: TextStyle(
                  color: Color(0xFFFFC229),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36),
            decoration: BoxDecoration(
              color: const Color(0xFF0C162A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            alignment: Alignment.center,
            child: Text(
              'No disruption alerts',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          // Show up to 2 most recent alerts on the dashboard
          ...alerts.take(2).map((alert) {
            final icon = _getIcon(alert.priority);
            final color = _getColor(alert.priority);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NotificationCard(
                mainIcon: icon,
                mainIconColor: color,
                flightCode: alert.flightCode.isNotEmpty
                    ? alert.flightCode
                    : 'ALERT',
                severityText: alert.severityLabel,
                severityColor: color,
                timeAgo: _formatTime(alert.createdAt),
                airline:
                    alert.airline.isNotEmpty ? alert.airline : 'System',
                issueIcon: _getEventIcon(alert.eventType),
                issueTitle: alert.eventType,
                issueDescription: alert.message,
                rightsDescription:
                    _getRightsText(alert.priority, alert.eventType),
              ),
            );
          }).toList(),
      ],
    );
  }

  IconData _getIcon(String priority) {
    switch (priority.toUpperCase()) {
      case 'CRITICAL':
        return Icons.warning_amber_rounded;
      case 'HIGH':
        return Icons.access_time_filled;
      case 'MEDIUM':
        return Icons.info_outline;
      default:
        return Icons.check_circle_outline;
    }
  }

  Color _getColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFFE11D48);
      case 'HIGH':
        return const Color(0xFFFFC229);
      case 'MEDIUM':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData _getEventIcon(String eventType) {
    final t = eventType.toLowerCase();
    if (t.contains('cancel')) return Icons.airplanemode_inactive;
    if (t.contains('delay')) return Icons.flight_takeoff;
    if (t.contains('gate')) return Icons.meeting_room;
    if (t.contains('baggage') || t.contains('luggage')) return Icons.luggage;
    return Icons.notifications_none;
  }

  String _getRightsText(String priority, String eventType) {
    final t = eventType.toLowerCase();
    if (t.contains('cancel')) {
      return 'You are entitled to a full refund or rebooking on the next available flight.';
    }
    if (t.contains('delay')) {
      return 'Delays over 2 hours entitle you to refreshments and potentially compensation.';
    }
    return 'Contact the airline for your passenger rights.';
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}
