import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _supportCard(context),
            const SizedBox(height: 24),
            _sectionLabel('Support'),
            const SizedBox(height: 14),
            _actionRow(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Contact Support',
              subtitle: 'Send a message to the FlyRedi team',
              message: 'Support chat will be available soon.',
            ),
            const SizedBox(height: 10),
            _actionRow(
              context,
              icon: Icons.bug_report_outlined,
              title: 'Report a Problem',
              subtitle: 'Tell us what went wrong',
              message: 'Issue reporting will be available soon.',
            ),
            const SizedBox(height: 10),
            _actionRow(
              context,
              icon: Icons.description_outlined,
              title: 'Terms & Policies',
              subtitle: 'Review service, privacy, and data policies',
              message: 'Terms and policies will be available soon.',
            ),
            const SizedBox(height: 24),
            _sectionLabel('Frequently Asked'),
            const SizedBox(height: 14),
            _faqItem(
              question: 'Why is flight lookup unavailable?',
              answer:
                  'Flight lookup depends on the configured aviation provider. You can still save a flight by entering origin and destination manually.',
            ),
            const SizedBox(height: 10),
            _faqItem(
              question: 'How do monthly limits work?',
              answer:
                  'Free plans include limited flight monitoring, claims, and assistant usage each month. Upgrade prompts appear when a limit is reached.',
            ),
            const SizedBox(height: 10),
            _faqItem(
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
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC229).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_outlined,
              color: Color(0xFFFFC229),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'We are here to help',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Get help with flights, claims, account access, and app issues.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.46),
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

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.38),
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
          backgroundColor: const Color(0xFF10284F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.42),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.24),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqItem({
    required String question,
    required String answer,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              color: Colors.white.withOpacity(0.48),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF0C162A),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.04)),
    );
  }
}
