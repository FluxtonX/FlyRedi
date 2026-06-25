import 'package:flutter/material.dart';

class MonitoringStatsRow extends StatelessWidget {
  final int alertsCount;
  final int casesCount;
  final String totalSavings;

  const MonitoringStatsRow({
    super.key,
    required this.alertsCount,
    required this.casesCount,
    required this.totalSavings,
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
              totalSavings,
              'Total\nSavings',
              const Color(0xFF2DD4BF),
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: _buildStatCard(context, 
              casesCount.toString(),
              'Active\nClaims',
              Theme.of(context).colorScheme.onSurface,
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
        vertical: 26,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
              fontSize: 18,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
