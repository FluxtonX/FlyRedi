import 'package:flutter/material.dart';

class SentinelHeader extends StatelessWidget {
  final bool isEmpty;

  const SentinelHeader({
    super.key,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
        return Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.shield_outlined,
                color: Color(0xFFFFC229),
                size: 30,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sentinel™ Monitoring',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundColor: isEmpty ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3) : const Color(0xFF22C55E),
                ),
                SizedBox(width: 8),
                Text(
                  isEmpty ? 'Idle' : 'Active',
                  style: TextStyle(
                    color: isEmpty ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3) : const Color(0xFF22C55E),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        );
  }
}
