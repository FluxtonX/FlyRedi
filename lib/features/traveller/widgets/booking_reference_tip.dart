import 'package:flutter/material.dart';

class BookingReferenceTip extends StatelessWidget {
  const BookingReferenceTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1931),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.lightbulb,
                  color: Color(0xFFFDE047), // Light yellow
                  size: 16,
                ),
              ),
            ),
            TextSpan(
              text: 'Tip: Adding your booking reference allows us to monitor your specific seat assignments and automatically check-in when available.',
            ),
          ],
        ),
      ),
    );
  }
}
