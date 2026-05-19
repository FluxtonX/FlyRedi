import 'package:flutter/material.dart';

class WorkflowTimelineTracker extends StatelessWidget {
  final int currentStep;

  const WorkflowTimelineTracker({
    super.key,
    this.currentStep = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStepCircle(1, 'Confirm'),
            _buildLine(1),
            _buildStepCircle(2, 'Rights'),
            _buildLine(2),
            _buildStepCircle(3, 'Documents'),
            _buildLine(3),
            _buildStepCircle(4, 'Resolution'),
            _buildLine(4),
            _buildStepCircle(5, 'Submit'),
          ],
        ),
      ],
    );
  }

  Widget _buildStepCircle(int index, String label) {
    final completedColor = const Color(0xFF10B981); // Green
    final activeColor = const Color(0xFFFFC229);    // Yellow
    final inactiveColor = Colors.white.withOpacity(0.3);

    Color circleBgColor;
    Color circleBorderColor;
    Color textColor;
    bool showCheck = false;

    if (index < currentStep) {
      circleBgColor = completedColor;
      circleBorderColor = completedColor;
      textColor = Colors.white70;
      showCheck = true;
    } else if (index == currentStep) {
      circleBgColor = activeColor;
      circleBorderColor = activeColor;
      textColor = activeColor;
      showCheck = true; // Shows white checkmark inside yellow circle as shown in the screenshot
    } else {
      circleBgColor = const Color(0xFF08101E);
      circleBorderColor = inactiveColor;
      textColor = inactiveColor;
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleBgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: circleBorderColor,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: showCheck
              ? const Icon(
                  Icons.check,
                  color: Colors.white, // White checkmark inside circle
                  size: 16,
                )
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: index == currentStep ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(int stepIndex) {
    final completedColor = const Color(0xFF10B981);
    final isLineCompleted = stepIndex < currentStep;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24), // Offset the height of the label
        child: Container(
          height: 1.5,
          color: isLineCompleted ? completedColor : Colors.white.withOpacity(0.12),
        ),
      ),
    );
  }
}
