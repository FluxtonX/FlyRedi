// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../screens/resolve_dashboard_screen.dart';
import '../screens/ai_assistant_screen.dart';

class RecommendedActionsCard extends StatelessWidget {
  final bool isEmpty;

  const RecommendedActionsCard({
    super.key,
    this.isEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        SizedBox(height: 24),
        _buildMainCard(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Color(0xFFFFC229),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommended Actions',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'AI-powered guidance',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE11D48).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFFC229),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Resolution Assistant™',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 4,
                          backgroundColor: Color(0xFFE11D48),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Flight UA 2847 delayed by 2h 30m',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.54),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Your flight delay qualifies for compensation under EU261. We recommend contacting the airline desk for immediate rebooking options and filing a compensation claim.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(0xFFFFC229).withOpacity(0.2),
              ),
            ),
             child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: Color(0xFFFFC229),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Compensation Eligible',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '\$600',
                  style: TextStyle(
                    color: Color(0xFFFFC229),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Recommended Next Steps:',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          _buildStepItem(context, '1', 'Contact airline customer service desk'),
          SizedBox(height: 8),
          _buildStepItem(
              context, '2', 'Request meal vouchers if delay exceeds 3 hours'),
          SizedBox(height: 8),
          _buildStepItem(
              context, '3', 'File compensation claim within 6 months'),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Color(0xFFFFC229).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(text: 'We recommend starting a claim for '),
                      TextSpan(
                        text: 'W3 205',
                        style: TextStyle(color: Color(0xFFFFC229)),
                      ),
                      TextSpan(
                          text:
                              '. You\'re entitled to ₦45,000 compensation under NCAA regulations.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              color: Color(0xFFFFC229),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
