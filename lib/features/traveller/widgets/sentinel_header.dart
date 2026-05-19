import 'package:flutter/material.dart';
import 'demo_state.dart';

class SentinelHeader extends StatelessWidget {
  const SentinelHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DemoState.isEmptyState,
      builder: (context, isEmpty, child) {
        return Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF10284F),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Color(0xFFFFC229),
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sentinel™ Monitoring',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Real-time flight intelligence',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundColor: isEmpty ? Colors.white30 : const Color(0xFF22C55E),
                ),
                const SizedBox(width: 8),
                Text(
                  isEmpty ? 'Idle' : 'Active',
                  style: TextStyle(
                    color: isEmpty ? Colors.white30 : const Color(0xFF22C55E),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
