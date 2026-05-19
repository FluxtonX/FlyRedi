import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import 'package:sky_rightz_360/features/traveller/widgets/demo_state.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0; // 0: Alerts, 1: New & Updates
  int _selectedFilterIndex =
      0; // 0: All, 1: Critical, 2: High, 3: Medium, 4: Low

  final List<String> _filters = const [
    'All',
    'Critical',
    'High',
    'Medium',
    'Low'
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DemoState.isEmptyState,
      builder: (context, isEmpty, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Header Row with double tap for state toggling
                  GestureDetector(
                    onDoubleTap: () {
                      DemoState.toggle();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            DemoState.isEmptyState.value
                                ? 'Switched to Initial Empty Demo State!'
                                : 'Switched to Sarah Johnson Demo State!',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: const Color(0xFF0C162A),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.08)),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white70,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifications',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Real-time disruption detection and\nmonitoring',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Three Metrics Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          value: isEmpty ? '0' : '4',
                          label: 'Critical',
                          borderColor: const Color(0xFFE11D48),
                          backgroundColor: const Color(0xFF2B161E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          value: isEmpty ? '0' : '6',
                          label: 'High',
                          borderColor: const Color(0xFFFFC229).withOpacity(0.8),
                          backgroundColor: const Color(0xFF2A2416),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          value: '0',
                          label: 'Updates',
                          borderColor: const Color(0xFF2563EB),
                          backgroundColor: const Color(0xFF16203A),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Dual Tabs Capsule Selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101B30),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Left Tab: Alerts
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTab = 0;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0
                                    ? const Color(0xFF1D4ED8)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_none,
                                    color: _selectedTab == 0
                                        ? Colors.white
                                        : Colors.white54,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Alerts',
                                    style: TextStyle(
                                      color: _selectedTab == 0
                                          ? Colors.white
                                          : Colors.white54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFC229),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '9',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Right Tab: New & Updates
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTab = 1;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1
                                    ? const Color(0xFF1D4ED8)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'New & Updates',
                                style: TextStyle(
                                  color: _selectedTab == 1
                                      ? Colors.white
                                      : Colors.white54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Capsule Filter Pill Bar (Visible only when Alerts tab is active)
                  if (_selectedTab == 0)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101B30),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_filters.length, (index) {
                            final isSelected = index == _selectedFilterIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilterIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1D4ED8)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _filters[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white54,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // Publish New Update megalink button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 28),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Updates publishing form initiated.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: const Color(0xFF0C162A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.08)),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.campaign_outlined,
                          color: Color(0xFFFFC229), size: 18),
                      label: const Text(
                        'Publish New Update',
                        style: TextStyle(
                          color: Color(0xFFFFC229),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                            color: Color(0xFFFFC229), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  // Alert Body Render
                  if (isEmpty || _selectedTab == 1) ...[
                    // Empty State matching screenshot
                    const SizedBox(height: 48),
                    const Center(
                      child: Text(
                        'No Update yet',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ] else ...[
                    // Populate alerts state matched by filter severity
                    _buildFilteredAlerts(),
                  ],
                ],
              ),
            ),
          ),
          bottomNavigationBar: const TravellerBottomNav(),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color borderColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredAlerts() {
    final Map<int, List<Widget>> severityAlertMap = {
      // 1: Critical
      1: [
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
          rightsDescription: 'Full refund or rebooking + ₦45,000 compensation',
        ),
      ],
      // 2: High
      2: [
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
      ],
      // 3: Medium
      3: [
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
      ],
      // 4: Low
      4: [
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
          issueDescription: 'Boarding gate changed from D12 to D18.',
          rightsDescription: 'Informational only',
        ),
      ],
    };

    if (_selectedFilterIndex == 0) {
      // All Selected
      return Column(
        children: [
          ...severityAlertMap[1]!,
          const SizedBox(height: 16),
          ...severityAlertMap[2]!,
          const SizedBox(height: 16),
          ...severityAlertMap[3]!,
          const SizedBox(height: 16),
          ...severityAlertMap[4]!,
        ],
      );
    } else {
      final list = severityAlertMap[_selectedFilterIndex];
      if (list == null || list.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Text(
              'No Update yet',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
      return Column(children: list);
    }
  }
}
