import 'package:flutter/material.dart';

class TravelerProActiveCard extends StatelessWidget {
  final VoidCallback? onManageTap;

  const TravelerProActiveCard({
    super.key,
    this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onManageTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFC229).withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              color: const Color(0xFFFFC229),
              size: 26,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Traveler Pro Active',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Unlimited access to all features',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Manage',
              style: TextStyle(
                color: const Color(0xFFFFC229),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
