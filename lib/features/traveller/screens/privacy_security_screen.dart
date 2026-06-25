import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricUnlock = true;
  bool _securityAlerts = true;
  bool _shareAnalytics = false;

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
          'Privacy & Security',
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
            _sectionLabel('Security'),
            SizedBox(height: 14),
            _settingSwitch(
              icon: Icons.fingerprint,
              title: 'Biometric Unlock',
              subtitle: 'Use device lock for sensitive profile actions',
              value: _biometricUnlock,
              onChanged: (value) => setState(() => _biometricUnlock = value),
            ),
            SizedBox(height: 10),
            _settingSwitch(
              icon: Icons.notifications_active_outlined,
              title: 'Security Alerts',
              subtitle: 'Get notified about sign-ins and account changes',
              value: _securityAlerts,
              onChanged: (value) => setState(() => _securityAlerts = value),
            ),
            SizedBox(height: 22),
            _sectionLabel('Privacy'),
            SizedBox(height: 14),
            _settingSwitch(
              icon: Icons.insights_outlined,
              title: 'Product Analytics',
              subtitle: 'Share anonymous app usage to improve FlyRedi',
              value: _shareAnalytics,
              onChanged: (value) => setState(() => _shareAnalytics = value),
            ),
            SizedBox(height: 10),
            _actionRow(
              icon: Icons.password_outlined,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () => _showComingSoon('Password changes'),
            ),
            SizedBox(height: 10),
            _actionRow(
              icon: Icons.devices_outlined,
              title: 'Trusted Devices',
              subtitle: 'Review devices with access to your account',
              onTap: () => _showComingSoon('Trusted devices'),
            ),
            SizedBox(height: 10),
            _actionRow(
              icon: Icons.download_outlined,
              title: 'Download My Data',
              subtitle: 'Request a copy of your profile and trip data',
              onTap: () => _showComingSoon('Data export'),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be available soon.'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _sectionLabel(String text) {
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

  Widget _settingSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: _cardDecoration(),
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
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFFFFC229),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: _cardDecoration(),
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    );
  }
}
