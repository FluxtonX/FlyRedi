import 'package:flutter/material.dart';
import '../screens/notifications_screen.dart';
import 'notification_card.dart';
import 'demo_state.dart';

class DashboardNotificationsSection extends StatelessWidget {
  const DashboardNotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DemoState.isEmptyState,
      builder: (context, isEmpty, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Disruption Alerts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (!isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '4',
                          style: TextStyle(
                            color: Color(0xFFE11D48),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()),
                    );
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFFFFC229),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C162A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'No disruption alerts',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else ...[
              // W3 205 - Critical - Flight Cancelled
              const NotificationCard(
                mainIcon: Icons.warning_amber_rounded,
                mainIconColor: Color(0xFFE11D48),
                flightCode: 'W3 205',
                severityText: 'CRITICAL',
                severityColor: Color(0xFFE11D48),
                timeAgo: '2 hours ago',
                airline: 'Air Peace',
                issueIcon: Icons.airplanemode_inactive,
                issueTitle: 'Flight Cancelled',
                issueDescription:
                    'Your flight from Lagos to Abuja has been cancelled by the airline.',
                rightsDescription:
                    'Full refund or rebooking + ₦45,000 compensation',
              ),
              const SizedBox(height: 16),

              // AA 301 - High - 4 Hour Delay
              const NotificationCard(
                mainIcon: Icons.access_time_filled,
                mainIconColor: Color(0xFFFFC229),
                flightCode: 'AA 301',
                severityText: 'HIGH',
                severityColor: Color(0xFFFFC229),
                timeAgo: '5 hours ago',
                airline: 'Arik Air',
                issueIcon: Icons.flight_takeoff,
                issueTitle: '4 Hour Delay',
                issueDescription:
                    'Departure delayed from 14:00 to 18:00. Monitor for updates.',
                rightsDescription: 'Refreshments + ₦30,000 compensation',
              ),
              const SizedBox(height: 16),

              // BA 075 - Medium - Baggage Delayed
              const NotificationCard(
                mainIcon: Icons.info_outline,
                mainIconColor: Color(0xFF3B82F6),
                flightCode: 'BA 075',
                severityText: 'MEDIUM',
                severityColor: Color(0xFF3B82F6),
                timeAgo: '1 day ago',
                airline: 'British Airways',
                issueIcon: Icons.luggage,
                issueTitle: 'Baggage Delayed',
                issueDescription:
                    'Checked baggage not loaded on your connecting flight.',
                rightsDescription: 'Emergency supplies reimbursement',
              ),
              const SizedBox(height: 16),

              // EK 783 - Low - Gate Change
              const NotificationCard(
                mainIcon: Icons.check_circle_outline,
                mainIconColor: Color(0xFF9CA3AF),
                flightCode: 'EK 783',
                severityText: 'LOW',
                severityColor: Color(0xFF9CA3AF),
                timeAgo: '3 hours ago',
                airline: 'Emirates',
                issueIcon: Icons.meeting_room,
                issueTitle: 'Gate Change',
                issueDescription:
                    'Boarding gate changed from D12 to D18.',
                rightsDescription: 'Informational only',
              ),
            ],
          ],
        );
      },
    );
  }
}
