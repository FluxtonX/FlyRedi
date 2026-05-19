import 'package:flutter/material.dart';

class ReadinessScoreCard extends StatelessWidget {
  const ReadinessScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A), // Dark blue bg
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFC229).withOpacity(0.2), // Subtle yellow border
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Readiness Score',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '75%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // Dark grey/black bg
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFC229).withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.flight_takeoff,
                  color: Color(0xFFFFC229),
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('9', 'Ready', const Color(0xFF10B981)), // Green
              ),
              Expanded(
                child: _buildStatItem('2', 'Review', const Color(0xFFFFC229)), // Yellow
              ),
              Expanded(
                child: _buildStatItem('1', 'Action Needed', const Color(0xFFE11D48)), // Red
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label, Color color) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
