import 'package:flutter/material.dart';
import 'flight_monitor_card.dart';
import 'monitoring_stats_row.dart';
import 'sentinel_header.dart';

class SentinelMonitoringSection extends StatelessWidget {
  final int alertsCount;
  final String delayRisk;
  final int monitoredCount;
  final VoidCallback? onUpgrade;

  const SentinelMonitoringSection({
    super.key,
    required this.alertsCount,
    required this.delayRisk,
    required this.monitoredCount,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = alertsCount == 0 && monitoredCount == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SentinelHeader(isEmpty: isEmpty),
        SizedBox(height: 16),
        if (!isEmpty) ...[
          const FlightMonitorCard(),
          SizedBox(height: 16),
        ],
        MonitoringStatsRow(
          alertsCount: alertsCount,
          delayRisk: delayRisk,
          monitoredCount: monitoredCount,
        ),
        SizedBox(height: 14),
        GestureDetector(
          onTap: onUpgrade,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: Color(0xFF9AA5B8),
                  size: 18,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email Notifications Only',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Upgrade for WhatsApp alerts',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Unlock',
                  style: TextStyle(
                    color: Color(0xFFFFC229),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
