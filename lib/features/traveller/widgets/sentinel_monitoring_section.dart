import 'package:flutter/material.dart';
import 'flight_monitor_card.dart';
import 'monitoring_stats_row.dart';
import 'sentinel_header.dart';
import '../models/trip_model.dart';

class SentinelMonitoringSection extends StatelessWidget {
  final int alertsCount;
  final String delayRisk;
  final int monitoredCount;
  final VoidCallback? onUpgrade;
  final TripModel? activeTrip;

  const SentinelMonitoringSection({
    super.key,
    required this.alertsCount,
    required this.delayRisk,
    required this.monitoredCount,
    this.onUpgrade,
    this.activeTrip,
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
          FlightMonitorCard(activeTrip: activeTrip),
          SizedBox(height: 16),
        ],
        MonitoringStatsRow(
          alertsCount: alertsCount,
          delayRisk: delayRisk,
          monitoredCount: monitoredCount,
        ),

      ],
    );
  }
}
