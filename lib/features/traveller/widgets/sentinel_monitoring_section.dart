import 'package:flutter/material.dart';
import 'flight_monitor_card.dart';
import 'monitoring_stats_row.dart';
import 'sentinel_header.dart';

class SentinelMonitoringSection extends StatelessWidget {
  final int alertsCount;
  final int casesCount;
  final String totalSavings;

  const SentinelMonitoringSection({
    super.key,
    required this.alertsCount,
    required this.casesCount,
    required this.totalSavings,
  });

  @override
  Widget build(BuildContext context) {
    final hasAlerts = alertsCount > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SentinelHeader(isEmpty: alertsCount == 0 && casesCount == 0),
        const SizedBox(height: 24),
        if (hasAlerts) ...[
          const FlightMonitorCard(),
          const SizedBox(height: 24),
        ],
        MonitoringStatsRow(
          alertsCount: alertsCount,
          casesCount: casesCount,
          totalSavings: totalSavings,
        ),
      ],
    );
  }
}
