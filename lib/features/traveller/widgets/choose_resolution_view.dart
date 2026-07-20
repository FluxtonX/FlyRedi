import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChooseResolutionView extends StatefulWidget {
  final VoidCallback onContinue;

  const ChooseResolutionView({
    super.key,
    required this.onContinue,
  });

  @override
  State<ChooseResolutionView> createState() => _ChooseResolutionViewState();
}

class _ChooseResolutionViewState extends State<ChooseResolutionView> {
  int _selectedOption = 3; // Refund + Compensation is selected by default

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title & Subtitle
        Text(
          'Step 4: Choose Resolution',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Select how you'd like to resolve this disruption",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 28),

        // Options List
        _buildOptionCard(
          optionId: 1,
          title: 'Full Refund Only',
          subtitle: 'Get a complete refund of your ticket cost',
          amount: '₦85,000',
          processingTime: '7-14 business days',
          svgPath: 'assets/icons/refund.svg',
          iconBgColor: Theme.of(context).colorScheme.outline,
          iconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        _buildOptionCard(
          optionId: 2,
          title: 'Rebooking',
          subtitle: 'Free rebooking on next available flight',
          amount: 'No cost',
          processingTime: 'Immediate',
          svgPath: 'assets/icons/rebooking.svg',
          iconBgColor: const Color(0xFF10B981).withOpacity(0.12),
          iconColor: const Color(0xFF10B981),
        ),
        _buildOptionCard(
          optionId: 3,
          title: 'Refund + Compensation',
          subtitle: 'Full refund plus NCAA mandated compensation',
          amount: '₦130,000',
          processingTime: '14-21 business days',
          svgPath: 'assets/icons/refund+compensation.svg',
          iconBgColor: const Color(0xFFF97316).withOpacity(0.12), // Orange tinted bg
          iconColor: const Color(0xFFF97316),
          isRecommended: true,
        ),

        SizedBox(height: 24),

        // Why We Recommend Section (Only visible or relevant to option 3)
        if (_selectedOption == 3) ...[
          Container(
            padding: EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why We Recommend This',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "This option maximizes your compensation under NCAA regulations. You'll receive both your full ticket refund and the legally mandated compensation for flight cancellation.",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
        ],

        // Bottom Button
        GestureDetector(
          onTap: widget.onContinue,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC229), // Yellow button
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              'Continue',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required int optionId,
    required String title,
    required String subtitle,
    required String amount,
    required String processingTime,
    IconData? icon,
    String? svgPath,
    required Color iconBgColor,
    required Color iconColor,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedOption == optionId;
    final activeYellow = const Color(0xFFFFC229);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = optionId;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? activeYellow : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (svgPath != null)
                  SvgPicture.asset(
                    svgPath,
                    width: 44,
                    height: 44,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isRecommended)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: activeYellow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Recommended',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.check,
                                    color: Colors.black,
                                    size: 11,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                // Custom Radio Button
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? activeYellow : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? activeYellow : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(color: Theme.of(context).colorScheme.outline, height: 1),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      amount,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Processing',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      processingTime,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
