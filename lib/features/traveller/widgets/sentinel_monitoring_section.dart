import 'package:flutter/material.dart';
import 'flight_monitor_card.dart';
import 'monitoring_stats_row.dart';
import 'sentinel_header.dart';

class SentinelMonitoringSection extends StatelessWidget {
  final int alertsCount;
  final int casesCount;
  final String totalSavings;
  final VoidCallback? onUpgrade;

  const SentinelMonitoringSection({
    super.key,
    required this.alertsCount,
    required this.casesCount,
    required this.totalSavings,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = alertsCount == 0 && casesCount == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SentinelHeader(isEmpty: isEmpty),
        const SizedBox(height: 16),
        if (!isEmpty) ...[
          const FlightMonitorCard(),
          const SizedBox(height: 16),
        ],
        MonitoringStatsRow(
          alertsCount: alertsCount,
          casesCount: casesCount,
          totalSavings: totalSavings,
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: onUpgrade,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0C162A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: const Row(
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
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Upgrade for WhatsApp alerts',
                        style: TextStyle(
                          color: Color(0xFF8D99AD),
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
