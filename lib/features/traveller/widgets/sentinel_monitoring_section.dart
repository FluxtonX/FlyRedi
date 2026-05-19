import 'package:flutter/material.dart';
import 'flight_monitor_card.dart';
import 'monitoring_stats_row.dart';
import 'sentinel_header.dart';
import 'demo_state.dart';

class SentinelMonitoringSection extends StatelessWidget {
  const SentinelMonitoringSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DemoState.isEmptyState,
      builder: (context, isEmpty, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SentinelHeader(),
            const SizedBox(height: 24),
            if (!isEmpty) ...[
              const FlightMonitorCard(),
              const SizedBox(height: 24),
            ],
            const MonitoringStatsRow(),
          ],
        );
      },
    );
  }
}
