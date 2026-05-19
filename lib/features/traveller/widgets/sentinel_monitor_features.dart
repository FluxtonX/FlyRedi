import 'package:flutter/material.dart';

class SentinelMonitorFeatures extends StatelessWidget {
  const SentinelMonitorFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sentinel™ will monitor for:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem('Flight delays'),
                  const SizedBox(height: 16),
                  _buildFeatureItem('Gate changes'),
                  const SizedBox(height: 16),
                  _buildFeatureItem('Airport disruptions'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem('Cancellations'),
                  const SizedBox(height: 16),
                  _buildFeatureItem('Weather alerts'),
                  const SizedBox(height: 16),
                  _buildFeatureItem('Connection risks'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 3,
          backgroundColor: Color(0xFFFFC229), // Yellow dot
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
