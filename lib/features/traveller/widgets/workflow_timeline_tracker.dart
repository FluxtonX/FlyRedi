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
            _buildStepCircle(context, 1, 'Confirm'),
            _buildLine(context, 1),
            _buildStepCircle(context, 2, 'Rights'),
            _buildLine(context, 2),
            _buildStepCircle(context, 3, 'Documents'),
            _buildLine(context, 3),
            _buildStepCircle(context, 4, 'Resolution'),
            _buildLine(context, 4),
            _buildStepCircle(context, 5, 'Submit'),
          ],
        ),
      ],
    );
  }

  Widget _buildStepCircle(BuildContext context, int index, String label) {
    final completedColor = const Color(0xFF10B981); // Green
    final activeColor = const Color(0xFFFFC229);    // Yellow
    final inactiveColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.3);

    Color circleBgColor;
    Color circleBorderColor;
    Color textColor;
    bool showCheck = false;

    if (index < currentStep) {
      circleBgColor = completedColor;
      circleBorderColor = completedColor;
      textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
      showCheck = true;
    } else if (index == currentStep) {
      circleBgColor = activeColor;
      circleBorderColor = activeColor;
      textColor = activeColor;
      showCheck = true; // Shows white checkmark inside yellow circle as shown in the screenshot
    } else {
      circleBgColor = Theme.of(context).colorScheme.surface;
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
              ? Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onSurface, // White checkmark inside circle
                  size: 16,
                )
              : null,
        ),
        SizedBox(height: 10),
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

  Widget _buildLine(BuildContext context, int stepIndex) {
    final completedColor = const Color(0xFF10B981);
    final isLineCompleted = stepIndex < currentStep;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: 24), // Offset the height of the label
        child: Container(
          height: 1.5,
          color: isLineCompleted ? completedColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        ),
      ),
    );
  }
}
