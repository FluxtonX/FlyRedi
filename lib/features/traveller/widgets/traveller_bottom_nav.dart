import 'package:flutter/material.dart';
import '../screens/traveller_dashboard_screen.dart';
import '../screens/expenses_screen.dart';
import '../screens/trips_overview_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/ai_assistant_screen.dart';

class TravellerBottomNav extends StatelessWidget {
  final int activeIndex;

  const TravellerBottomNav({
    super.key,
    this.activeIndex = 0,
  });

  Route _createInstantRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C162A), // Very dark blue for bottom nav
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home Tab
            GestureDetector(
              onTap: () {
                if (activeIndex != 0) {
                  // Push dashboard screen replacement to keep stack clean and transition instantly
                  Navigator.pushAndRemoveUntil(
                    context,
                    _createInstantRoute(const TravellerDashboardScreen()),
                    (route) => false,
                  );
                }
              },
              child: _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: activeIndex == 0,
              ),
            ),
            // Trips Tab
            GestureDetector(
              onTap: () {
                if (activeIndex != 1) {
                  Navigator.pushReplacement(
                    context,
                    _createInstantRoute(const TripsOverviewScreen()),
                  );
                }
              },
              child: _buildNavItem(
                icon: Icons.flight_outlined,
                label: 'Trips',
                isActive: activeIndex == 1,
              ),
            ),
            // Claims Tab
            GestureDetector(
              onTap: () {
                if (activeIndex != 2) {
                  Navigator.pushReplacement(
                    context,
                    _createInstantRoute(const ExpensesScreen()),
                  );
                }
              },
              child: _buildNavItem(
                icon: Icons.description_outlined,
                label: 'Claims',
                isActive: activeIndex == 2,
              ),
            ),
            // Assistant Tab
            GestureDetector(
              onTap: () {
                if (activeIndex != 3) {
                  Navigator.pushReplacement(
                    context,
                    _createInstantRoute(const AiAssistantScreen()),
                  );
                }
              },
              child: _buildNavItem(
                icon: Icons.auto_awesome_outlined,
                label: 'Assistant',
                isActive: activeIndex == 3,
              ),
            ),
            // Profile Tab
            GestureDetector(
              onTap: () {
                if (activeIndex != 4) {
                  Navigator.pushReplacement(
                    context,
                    _createInstantRoute(const ProfileScreen()),
                  );
                }
              },
              child: _buildNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isActive: activeIndex == 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final color = isActive ? const Color(0xFFFFC229) : Colors.white54;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 26,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
