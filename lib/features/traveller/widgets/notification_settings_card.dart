import 'package:flutter/material.dart';

class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A), // Dark blue bg
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08), // Subtle border
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.notifications_none,
                color: Color(0xFFFFC229), // Yellow icon
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Notification Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSwitchRow('Push Notifications', true),
          const SizedBox(height: 24),
          _buildSwitchRow('Email Alerts', true),
          const SizedBox(height: 24),
          _buildSwitchRow('WhatsApp Messages', true),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        SizedBox(
          height: 24,
          child: Switch(
            value: value,
            onChanged: (bool newValue) {},
            activeColor: Colors.white, // Thumb color
            activeTrackColor: const Color(0xFFFFC229), // Track color
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.white.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}
