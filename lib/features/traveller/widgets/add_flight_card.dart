import 'package:flutter/material.dart';

class AddFlightCard extends StatelessWidget {
  final VoidCallback onTap;
  final int usedFlights;
  final int maxFlights;
  final bool isPro;

  const AddFlightCard({
    super.key,
    required this.onTap,
    required this.usedFlights,
    required this.maxFlights,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(0xFFFFC229).withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.add,
                color: Color(0xFFFFC229),
                size: 26,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Flight to Monitor',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5),
                  isPro
                      ? Row(
                          children: [
                            const Text(
                              '∞ ',
                              style: TextStyle(
                                color: Color(0xFFFFC229),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Unlimited flights',
                              style: TextStyle(
                                color: Color(0xFFFFC229),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          '$usedFlights/$maxFlights used this month',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                            fontSize: 12,
                          ),
                        ),
                ],
              ),
            ),
            if (!isPro)
              Icon(
                Icons.workspace_premium_outlined,
                color: Color(0xFFFFC229),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
