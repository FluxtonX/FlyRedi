import 'package:flutter/material.dart';
import '../screens/resolution_workflow_screen.dart';

enum CaseStatus { inProgress, pending, completed }

class CaseCard extends StatelessWidget {
  final String flightCode;
  final String airline;
  final String disruptionType;
  final CaseStatus status;
  final double progress; // 0.0 to 1.0 (for inProgress state)
  final String? stepText; // e.g. "Step 3 of 6"
  final String? compensationAmount; // e.g. "₦25,000"

  const CaseCard({
    super.key,
    required this.flightCode,
    required this.airline,
    required this.disruptionType,
    required this.status,
    this.progress = 0.0,
    this.stepText,
    this.compensationAmount,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color badgeBgColor;
    String badgeText;
    IconData? trailingIcon;

    switch (status) {
      case CaseStatus.inProgress:
        badgeColor = const Color(0xFFFFC229);
        badgeBgColor = const Color(0xFF2A2016);
        badgeText = 'IN PROGRESS';
        trailingIcon = Icons.access_time;
        break;
      case CaseStatus.pending:
        badgeColor = const Color(0xFFF97316); // Orange
        badgeBgColor = const Color(0xFF2D1F17);
        badgeText = 'PENDING';
        trailingIcon = Icons.description_outlined;
        break;
      case CaseStatus.completed:
        badgeColor = const Color(0xFF10B981); // Green
        badgeBgColor = const Color(0xFF0F2D24);
        badgeText = 'COMPLETED';
        trailingIcon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(22),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A), // Dark blue card background
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: badgeColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: badgeColor,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$airline • $disruptionType',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          if (status == CaseStatus.inProgress) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stepText ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFF08101E),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 20),
            _buildButton(
              context,
              'Continue',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResolutionWorkflowScreen()),
                );
              },
            ),
          ] else if (status == CaseStatus.pending) ...[
            _buildButton(
              context,
              'Start Resolution',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResolutionWorkflowScreen()),
                );
              },
            ),
          ] else if (status == CaseStatus.completed) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF08101E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resolution',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Compensation Received',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    compensationAmount ?? '',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, {required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFC229), // Brand yellow
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
