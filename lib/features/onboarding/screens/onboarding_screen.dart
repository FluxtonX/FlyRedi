import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../widgets/plan_selection_page.dart';
import '../../../config/app_router.dart';
import '../presentation/providers/onboarding_provider.dart';
import '../../../core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  int get _planPageIndex => onboardingData.length;
  int get _totalPages => onboardingData.length + 1;

  final List<Map<String, dynamic>> onboardingData = [
    {
      'icon': Icons.shield,
      'title': 'Sentinel™ Monitoring',
      'description':
          'Real-time flight monitoring with instant alerts for delays, cancellations, and disruptions',
    },
    {
      'icon': Icons.check_circle_outline,
      'title': 'BorderReady™',
      'description':
          'Never miss travel requirements - passport, visa, and entry document verification',
    },
    {
      'icon': Icons.description_outlined,
      'title': 'Claim Compensation',
      'description':
          'AI-powered claim generation and tracking for disrupted flights',
    },
    {
      'icon': Icons.attach_money,
      'title': 'Manage Expenses',
      'description': 'Track travel expenses effortlessly during your journey',
    },
    {
      'icon': Icons.auto_awesome,
      'title': 'Resolution Assistant™',
      'description':
          'AI-powered guidance on what to do when disruptions happen',
    },
    {
      'icon': Icons.notifications_none,
      'title': 'Smart Notifications',
      'description':
          'Get alerted via push, email, and WhatsApp the moment something changes',
    },
  ];

  Future<void> _finishOnboarding() async {
    final onboardingProvider = context.read<OnboardingProvider>();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await onboardingProvider.completeOnboarding(
          role: 'User',
          notificationsEnabled: true,
          displayName: user.displayName ?? user.email?.split('@').first ?? 'User',
        );
      } else {
        await onboardingProvider.completeLocalOnly();
      }
    } catch (e) {
      debugPrint('Failed to complete onboarding: $e');
    } finally {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        Navigator.pushReplacementNamed(context, user == null ? AppRouter.login : AppRouter.home);
      }
    }
  }

  void nextPage() {
    if (currentIndex < _totalPages - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      _finishOnboarding();
    }
  }

  void skipToLastPage() {
    setState(() {
      currentIndex = _planPageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlanPage = currentIndex == _planPageIndex;
    final isLoading = context.select<OnboardingProvider, bool>((p) => p.isLoading);

    return Scaffold(
      body: Stack(
        children: [
          // Show plan selection page or onboarding content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: isPlanPage
                ? PlanSelectionPage(
                    key: const ValueKey('plan_page'),
                    onBack: () {
                      setState(() {
                        currentIndex = _planPageIndex - 1;
                      });
                    },
                    onContinueFree: _finishOnboarding,
                    onUpgradeToPro: _finishOnboarding,
                  )
                : _buildOnboardingContent(),
          ),
          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Saving your preferences...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOnboardingContent() {
    final item = onboardingData[currentIndex];
    final bool isLastContentPage = currentIndex == onboardingData.length - 1;

    return Padding(
      key: const ValueKey('onboarding_content'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          // Only this part crossfades — icon, title, description
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: Column(
              key: ValueKey<int>(currentIndex),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: 76,
                  color: const Color(0xFFFFC229),
                ),
                const SizedBox(height: 40),
                Text(
                  item['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  item['description'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Dots — stay in place, just animate width/color smoothly
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              final bool isActive = index == currentIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFFFC229) : Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),

          const Spacer(),

          // Button — stays in place, only text changes
          CustomButton(
            title: isLastContentPage ? 'Get Started' : 'Next',
            onTap: nextPage,
          ),
          const SizedBox(height: 18),

          // Skip link — stays in place, hidden on last page
          if (!isLastContentPage)
            GestureDetector(
              onTap: skipToLastPage,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
