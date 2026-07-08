import 'package:flutter/material.dart';

class MonitoringStatsRow extends StatelessWidget {
  final int alertsCount;
  final String delayRisk;
  final int monitoredCount;

  const MonitoringStatsRow({
    super.key,
    required this.alertsCount,
    required this.delayRisk,
    required this.monitoredCount,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildStatCard(context, 
              alertsCount.toString(),
              'Active\nAlerts',
              const Color(0xFFFFC229),
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: _buildStatCard(context, 
              delayRisk,
              'Delay\nRisk',
              Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: _buildStatCard(context, 
              monitoredCount.toString(),
              'Monitored',
              const Color(0xFF2DD4BF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, 
    String number,
    String title,
    Color numberColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              color: numberColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
