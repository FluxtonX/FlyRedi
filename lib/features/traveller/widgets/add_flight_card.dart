import 'package:flutter/material.dart';

class AddFlightCard extends StatelessWidget {
  final VoidCallback onTap;
  final int usedFlights;
  final int maxFlights;

  const AddFlightCard({
    super.key,
    required this.onTap,
    required this.usedFlights,
    required this.maxFlights,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1D3A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFC229).withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFFFFC229),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Flight to Monitor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$usedFlights/$maxFlights used this month',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
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
