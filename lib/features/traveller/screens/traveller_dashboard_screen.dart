import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/demo_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/add_flight_card.dart';
import '../widgets/sentinel_monitoring_section.dart';
import '../widgets/border_ready_section.dart';
import '../widgets/recommended_actions_card.dart';
import '../widgets/dashboard_notifications_section.dart';
import '../widgets/active_issues_section.dart';
import '../widgets/traveller_bottom_nav.dart';

class TravellerDashboardScreen extends StatelessWidget {
  const TravellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DemoState.isEmptyState,
      builder: (context, isEmpty, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Welcome Row wrapper with double tap to toggle state
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
                    child: const DashboardHeader(),
                  ),
                  const SizedBox(height: 28),
                  const AddFlightCard(),
                  const SizedBox(height: 32),
                  const SentinelMonitoringSection(),
                  const SizedBox(height: 32),
                  const BorderReadySection(),
                  const SizedBox(height: 32),
                  const RecommendedActionsCard(),
                  const SizedBox(height: 32),
                  const DashboardNotificationsSection(),
                  const SizedBox(height: 32),
                  const ActiveIssuesSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const TravellerBottomNav(activeIndex: 0),
        );
      },
    );
  }
}
