import 'package:flutter/material.dart';
import '../screens/add_flight_screen.dart';

class AddFlightCard extends StatelessWidget {
  const AddFlightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddFlightScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1D3A),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFFFC229).withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFFFFC229),
                size: 36,
              ),
            ),
            const SizedBox(width: 22),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Flight to\nMonitor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Start Sentinel™\nmonitoring',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC229),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
