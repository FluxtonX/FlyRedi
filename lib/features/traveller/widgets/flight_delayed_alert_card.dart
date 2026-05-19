import 'package:flutter/material.dart';

class FlightDelayedAlertCard extends StatelessWidget {
  const FlightDelayedAlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1931),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE11D48).withOpacity(0.4),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFE11D48), // Red
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Flight Delayed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your flight has been delayed by 2h 30m',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Original Departure', '8:15 AM', Colors.white),
          const SizedBox(height: 12),
          _buildInfoRow('New Departure', '10:45 AM', const Color(0xFFFFC229)),
          const SizedBox(height: 12),
          _buildInfoRow('Reason', 'Air traffic congestion', Colors.white),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: valueColor == Colors.white ? FontWeight.normal : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
