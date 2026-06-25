import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _supportCard(context),
            SizedBox(height: 24),
            _sectionLabel(context, 'Support'),
            SizedBox(height: 14),
            _actionRow(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Contact Support',
              subtitle: 'Send a message to the FlyRedi team',
              message: 'Support chat will be available soon.',
            ),
            SizedBox(height: 10),
            _actionRow(
              context,
              icon: Icons.bug_report_outlined,
              title: 'Report a Problem',
              subtitle: 'Tell us what went wrong',
              message: 'Issue reporting will be available soon.',
            ),
            SizedBox(height: 10),
            _actionRow(
              context,
              icon: Icons.description_outlined,
              title: 'Terms & Policies',
              subtitle: 'Review service, privacy, and data policies',
              message: 'Terms and policies will be available soon.',
            ),
            SizedBox(height: 24),
            _sectionLabel(context, 'Frequently Asked'),
            SizedBox(height: 14),
            _faqItem(context, 
              question: 'Why is flight lookup unavailable?',
              answer:
                  'Flight lookup depends on the configured aviation provider. You can still save a flight by entering origin and destination manually.',
            ),
            SizedBox(height: 10),
            _faqItem(context, 
              question: 'How do monthly limits work?',
              answer:
                  'Free plans include limited flight monitoring, claims, and assistant usage each month. Upgrade prompts appear when a limit is reached.',
            ),
            SizedBox(height: 10),
            _faqItem(context, 
              question: 'Where do I manage notifications?',
              answer:
                  'Use the Push Notifications switch on your Profile screen to enable or disable travel alerts.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFFFC229).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_outlined,
              color: Color(0xFFFFC229),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We are here to help',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Get help with flights, claims, account access, and app issues.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.46),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _actionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String message,
  }) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: _cardDecoration(context),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 20),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.42),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.48),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    );
  }
}
