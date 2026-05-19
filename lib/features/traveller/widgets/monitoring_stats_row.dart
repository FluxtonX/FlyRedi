import 'package:flutter/material.dart';
import 'demo_state.dart';

class MonitoringStatsRow extends StatelessWidget {
  const MonitoringStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DemoState.isEmptyState,
      builder: (context, isEmpty, child) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildStatCard(
                  isEmpty ? '--' : '2',
                  'Active\nAlerts',
                  const Color(0xFFFFC229),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _buildStatCard(
                  isEmpty ? '--' : '68%',
                  'Delay Risk',
                  Colors.white,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _buildStatCard(
                  isEmpty ? '--' : '2',
                  'Monitored',
                  const Color(0xFF2DD4BF),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String number,
    String title,
    Color numberColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 26,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF10284F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
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
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 18,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
