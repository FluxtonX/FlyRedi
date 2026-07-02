import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import 'package:get/get.dart';
import 'package:sky_rightz_360/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sky_rightz_360/features/onboarding/widgets/plan_selection_page.dart';
import 'traveller_tabs_screen.dart';

class ProBenefitsScreen extends StatelessWidget {
  const ProBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      body: PlanSelectionPage(
        onBack: () => Navigator.pop(context),
        onContinueFree: () async {
          final profile = authController.userProfile.value;
          if (profile != null) {
            await authController.updateProfileState(profile.copyWith(plan: 'Free'));
          }
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const TravellerTabsScreen()),
              (Route<dynamic> route) => false,
            );
          }
        },
        onUpgradeToPro: () async {
          final profile = authController.userProfile.value;
          if (profile != null) {
            await authController.updateProfileState(profile.copyWith(plan: 'Pro'));
          }
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const TravellerTabsScreen()),
              (Route<dynamic> route) => false,
            );
          }
        },
      ),
    );
  }
}
