import 'package:flutter/material.dart';

enum BorderReadyItemStatus { ready, review, action }

class BorderReadyItemCard extends StatelessWidget {
  final BorderReadyItemStatus status;
  final String title;
  final String description;

  const BorderReadyItemCard({
    super.key,
    required this.status,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case BorderReadyItemStatus.ready:
        statusColor = const Color(0xFF10B981); // Green
        statusIcon = Icons.check_circle_outline;
        break;
      case BorderReadyItemStatus.review:
        statusColor = const Color(0xFFFFC229); // Yellow
        statusIcon = Icons.warning_amber_rounded;
        break;
      case BorderReadyItemStatus.action:
        statusColor = const Color(0xFFE11D48); // Red
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A), // Dark blue
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
