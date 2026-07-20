import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_rightz_360/features/auth/presentation/providers/auth_provider.dart';
import 'package:sky_rightz_360/features/traveller/presentation/providers/profile_provider.dart';
import 'package:sky_rightz_360/features/onboarding/widgets/plan_selection_page.dart';
import 'traveller_tabs_screen.dart';

class ProBenefitsScreen extends StatelessWidget {
  const ProBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.user;

    return Scaffold(
      body: PlanSelectionPage(
        onBack: () => Navigator.pop(context),
        onContinueFree: () async {
          if (profile != null) {
            final profileProvider = context.read<ProfileProvider>();
            await profileProvider.updateProfile(plan: 'Free');
          }
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const TravellerTabsScreen()),
              (Route<dynamic> route) => false,
            );
          }
        },
        onUpgradeToPro: () async {
          if (profile != null) {
            final profileProvider = context.read<ProfileProvider>();
            await profileProvider.updateProfile(plan: 'Pro');
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
