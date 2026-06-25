import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';
import 'follow_up_tracker_screen.dart';

class SetRemindersScreen extends StatefulWidget {
  const SetRemindersScreen({super.key});

  @override
  State<SetRemindersScreen> createState() => _SetRemindersScreenState();
}

class _SetRemindersScreenState extends State<SetRemindersScreen> {
  bool _enableReminders = true;
  int _selectedInterval = 7; // 3, 7, 14, 21

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Follow-Up Reminders',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "We'll remind you if you don't receive a response",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Enable Reminders Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFC229).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFFFFC229),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable Follow-Up Reminders',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Get notified if no response is received',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enableReminders,
                    activeColor: const Color(0xFFFFC229),
                    activeTrackColor: Color(0xFFFFC229).withOpacity(0.3),
                    inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                    inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                    onChanged: (bool value) {
                      setState(() {
                        _enableReminders = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Smart Suggestion Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color(0xFF10B981).withOpacity(0.15), // Green border tint
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Suggestion',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Most cases are resolved within 7–14 days. We recommend setting a 7-day reminder for optimal follow-up timing.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Text(
              'Select Reminder Interval',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 14),

            // Grid of intervals
            Row(
              children: [
                Expanded(
                  child: _buildIntervalCard(
                    days: 3,
                    label: '3 Days',
                    description: 'Quick follow-up',
                    hasStar: false,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildIntervalCard(
                    days: 7,
                    label: '7 Days',
                    description: 'Standard timeline',
                    hasStar: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildIntervalCard(
                    days: 14,
                    label: '14 Days',
                    description: 'Extended period',
                    hasStar: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildIntervalCard(
                    days: 21,
                    label: '21 Days',
                    description: 'Maximum wait time',
                    hasStar: false,
                  ),
                ),
              ],
            ),

            SizedBox(height: 28),

            // Reminder Schedule Card
            if (_enableReminders) ...[
              Text(
                'Reminder Schedule',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 14),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Column(
                  children: [
                    _buildScheduleStep(
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF10B981),
                      title: 'Email Sent',
                      subtitle: 'Today',
                      isLast: false,
                    ),
                    _buildScheduleStep(
                      icon: Icons.access_time,
                      iconColor: const Color(0xFFFFC229),
                      title: 'First Reminder',
                      subtitle: 'In $_selectedInterval days',
                      isLast: false,
                    ),
                    _buildScheduleStep(
                      icon: Icons.notifications_none,
                      iconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      title: 'Follow-Up Alert',
                      subtitle: 'If no response after $_selectedInterval days',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],

            // "How it works" Info Card
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(
                      text: 'How it works: ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "We'll send you a notification if you haven't received a response within your selected timeframe. You can then send a follow-up email or escalate the case.",
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),

            // Complete Setup Action Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FollowUpTrackerScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC229), // Yellow
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Complete Setup',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 3),
    );
  }

  Widget _buildIntervalCard({
    required int days,
    required String label,
    required String description,
    required bool hasStar,
  }) {
    final bool isSelected = _selectedInterval == days;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedInterval = days;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.outline,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            if (hasStar)
              Positioned(
                right: 0,
                top: 0,
                child: Icon(
                  Icons.star,
                  color: Color(0xFFFFC229).withOpacity(0.8),
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.white10,
                    margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
                if (!isLast) SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
