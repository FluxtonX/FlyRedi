import 'package:flutter/material.dart';

class NotificationsStatsRow extends StatelessWidget {
  const NotificationsStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: '4',
            label: 'Critical',
            borderColor: const Color(0xFFE11D48), // Red
            backgroundColor: const Color(0xFF2B161E), // Dark Reddish
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            value: '6',
            label: 'High',
            borderColor: const Color(0xFFFFC229).withOpacity(0.8), // Yellow
            backgroundColor: const Color(0xFF2A2416), // Dark Yellowish
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            value: '0',
            label: 'Updates',
            borderColor: const Color(0xFF2563EB), // Blue
            backgroundColor: const Color(0xFF16203A), // Dark Blueish
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color borderColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
