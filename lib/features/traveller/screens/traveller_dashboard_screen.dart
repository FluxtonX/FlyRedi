import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
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
    final AuthController authController = Get.find<AuthController>();
    
    return Obx(() {
      final profile = authController.userProfile.value;
      final plan = profile?.plan ?? 'Free';
      final isFree = plan == 'Free' || plan.trim().isEmpty;

      if (isFree) {
        return TravellerDashboardFreeScreen(showBottomNav: showBottomNav);
      } else {
        return TravellerDashboardProScreen(showBottomNav: showBottomNav);
      }
    });
  }
}
