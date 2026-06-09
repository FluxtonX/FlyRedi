import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import 'package:sky_rightz_360/features/onboarding/widgets/plan_selection_page.dart';
import '../widgets/upgrade_to_pro_dialog.dart';

class ProBenefitsScreen extends StatelessWidget {
  const ProBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PlanSelectionPage(
        onBack: () => Navigator.pop(context),
        onContinueFree: () => Navigator.pop(context),
        onUpgradeToPro: () => showUpgradeToProDialog(context),
      ),
    );
  }
}
