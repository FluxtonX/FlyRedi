import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'traveller_dashboard_free_screen.dart';
import 'traveller_dashboard_pro_screen.dart';

class TravellerDashboardScreen extends StatelessWidget {
  final bool showBottomNav;

  const TravellerDashboardScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.user;
    final plan = profile?.plan ?? 'Free';
    final isFree = plan == 'Free' || plan.trim().isEmpty;

    if (isFree) {
      return TravellerDashboardFreeScreen(showBottomNav: showBottomNav);
    } else {
      return TravellerDashboardProScreen(showBottomNav: showBottomNav);
    }
  }
}
