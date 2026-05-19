import 'package:flutter/material.dart';
import 'flight_monitor_card.dart';
import 'monitoring_stats_row.dart';
import 'sentinel_header.dart';

class SentinelMonitoringCard extends StatelessWidget {
  const SentinelMonitoringCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SentinelHeader(),
        SizedBox(height: 24),
        FlightMonitorCard(),
        SizedBox(height: 24),
        MonitoringStatsRow(),
      ],
    );
  }
}
