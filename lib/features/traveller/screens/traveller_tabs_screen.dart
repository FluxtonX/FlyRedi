import 'package:flutter/material.dart';
import 'ai_assistant_screen.dart';
import 'profile_screen.dart';
import 'resolve_dashboard_screen.dart';
import 'traveller_dashboard_screen.dart';
import 'trips_overview_screen.dart';
import '../widgets/traveller_bottom_nav.dart';

class TravellerTabsScreen extends StatefulWidget {
  final int initialIndex;

  const TravellerTabsScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<TravellerTabsScreen> createState() => _TravellerTabsScreenState();
}

class _TravellerTabsScreenState extends State<TravellerTabsScreen> {
  late int _activeIndex;
  late final List<Widget?> _tabs;

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return const TravellerDashboardScreen(showBottomNav: false);
      case 1:
        return const TripsOverviewScreen(showBottomNav: false);
      case 2:
        return const ResolveDashboardScreen(showBottomNav: false);
      case 3:
        return const AiAssistantScreen(showBottomNav: false);
      case 4:
        return const ProfileScreen(showBottomNav: false);
      default:
        return const TravellerDashboardScreen(showBottomNav: false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabs = List<Widget?>.filled(5, null);
    _activeIndex = widget.initialIndex.clamp(0, _tabs.length - 1).toInt();
    _tabs[_activeIndex] = _buildTab(_activeIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _activeIndex,
        children: List.generate(
          _tabs.length,
          (index) => _tabs[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: TravellerBottomNav(
        activeIndex: _activeIndex,
        onTabSelected: (index) {
          if (index == _activeIndex) return;
          setState(() {
            _tabs[index] ??= _buildTab(index);
            _activeIndex = index;
          });
        },
      ),
    );
  }
}
