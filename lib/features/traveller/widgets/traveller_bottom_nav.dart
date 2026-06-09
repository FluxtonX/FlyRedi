import 'package:flutter/material.dart';
import '../screens/traveller_tabs_screen.dart';

class TravellerBottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int>? onTabSelected;

  const TravellerBottomNav({
    super.key,
    this.activeIndex = 0,
    this.onTabSelected,
  });

  Route _createInstantRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  void _selectTab(BuildContext context, int index) {
    if (activeIndex == index) return;

    if (onTabSelected != null) {
      onTabSelected!(index);
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      _createInstantRoute(TravellerTabsScreen(initialIndex: index)),
      (route) => false,
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
              onTap: () => _selectTab(context, 0),
              child: _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: activeIndex == 0,
              ),
            ),
            // Trips Tab
            GestureDetector(
              onTap: () => _selectTab(context, 1),
              child: _buildNavItem(
                icon: Icons.flight_outlined,
                label: 'Trips',
                isActive: activeIndex == 1,
              ),
            ),
            // Resolution Tab
            GestureDetector(
              onTap: () => _selectTab(context, 2),
              child: _buildNavItem(
                icon: Icons.description_outlined,
                label: 'Resolution',
                isActive: activeIndex == 2,
              ),
            ),
            // Assistant Tab
            GestureDetector(
              onTap: () => _selectTab(context, 3),
              child: _buildNavItem(
                icon: Icons.auto_awesome_outlined,
                label: 'Assistant',
                isActive: activeIndex == 3,
              ),
            ),
            // Profile Tab
            GestureDetector(
              onTap: () => _selectTab(context, 4),
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
