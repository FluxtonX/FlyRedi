import 'package:flutter/material.dart';
import '../screens/resolution_workflow_screen.dart';

class NotificationCard extends StatelessWidget {
  final IconData mainIcon;
  final Color mainIconColor;
  final String flightCode;
  final String severityText;
  final Color severityColor;
  final String timeAgo;
  final String airline;
  final IconData issueIcon;
  final String issueTitle;
  final String issueDescription;
  final String rightsDescription;
  final VoidCallback? onMarkRead;
  final VoidCallback? onStartResolution;

  const NotificationCard({
    super.key,
    required this.mainIcon,
    required this.mainIconColor,
    required this.flightCode,
    required this.severityText,
    required this.severityColor,
    required this.timeAgo,
    required this.airline,
    required this.issueIcon,
    required this.issueTitle,
    required this.issueDescription,
    required this.rightsDescription,
    this.onMarkRead,
    this.onStartResolution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Reduced outer padding
      decoration: BoxDecoration(
        color: const Color(0xFF102246), // Deep navy blue matching screenshot
        borderRadius: BorderRadius.circular(20), // Slightly smaller border radius
        border: Border.all(
          color: Colors.white.withOpacity(0.08), // Extremely subtle light border
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reduced icon padding
                decoration: BoxDecoration(
                  color: mainIconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  mainIcon,
                  color: mainIconColor,
                  size: 18, // Reduced icon size
                ),
              ),
              const SizedBox(width: 12), // Reduced spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              flightCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16, // Slightly smaller font
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8), // Reduced spacing
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Reduced padding
                              decoration: BoxDecoration(
                                color: severityColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: severityColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                severityText.toUpperCase(),
                                style: TextStyle(
                                  color: severityColor,
                                  fontSize: 9, // Slightly smaller font
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11, // Slightly smaller font
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2), // Reduced spacing
                    Text(
                      airline,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13, // Slightly smaller font
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14), // Reduced spacing (from 20)
          // Issue Container
          Container(
            padding: const EdgeInsets.all(12), // Reduced padding (from 16)
            decoration: BoxDecoration(
              color: const Color(0xFF162B4E), // Lighter card/container background inside deep navy card
              borderRadius: BorderRadius.circular(12), // Slightly smaller border radius
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      issueIcon,
                      color: Colors.white,
                      size: 14, // Reduced icon size
                    ),
                    const SizedBox(width: 6),
                    Text(
                      issueTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Slightly smaller font
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  issueDescription,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12, // Slightly smaller font
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10), // Reduced spacing (from 16)
          // Your Rights Container (Yellow/gold outline, transparent background)
          Container(
            padding: const EdgeInsets.all(12), // Reduced padding (from 16)
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12), // Slightly smaller border radius
              border: Border.all(
                color: const Color(0xFFFFC229).withOpacity(0.25), // Thin gold outline
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Rights',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11, // Slightly smaller font
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rightsDescription,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13, // Slightly smaller font
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14), // Reduced spacing (from 20)
          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onStartResolution ?? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ResolutionWorkflowScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11), // Reduced padding (from 14)
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC229), // Yellow
                      borderRadius: BorderRadius.circular(14), // Slightly smaller border radius
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Start Resolution',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14, // Slightly smaller font
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8), // Reduced spacing
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: onMarkRead,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11), // Reduced padding (from 14)
                    decoration: BoxDecoration(
                      color: const Color(0xFF101F3D), // Dark blue outline background
                      borderRadius: BorderRadius.circular(14), // Slightly smaller border radius
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12), // Subtle light outline
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Details', // Text changed to match the screenshot
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Slightly smaller font
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
