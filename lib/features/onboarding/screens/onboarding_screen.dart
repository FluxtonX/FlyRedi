import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/plan_selection_page.dart';
import '../../traveller/screens/traveller_tabs_screen.dart';
import '../repositories/onboarding_repository.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingRepository _onboardingRepository = OnboardingRepository();

  int currentIndex = 0;
  bool _isCompleting = false;
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
    setState(() {
      _isCompleting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      await _onboardingRepository.completeOnboarding(
        role: 'User',
        notificationsEnabled: true,
        displayName: user?.displayName ?? user?.email?.split('@').first,
      );
    } catch (e) {
      debugPrint('Failed to complete onboarding: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TravellerTabsScreen(),
          ),
        );
      }
    }
  }

  void nextPage() {
    if (currentIndex < _planPageIndex) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  void skipToLastPage() {
    _pageController.jumpToPage(
      _planPageIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemCount: _totalPages,
            itemBuilder: (context, index) {
              if (index == _planPageIndex) {
                return PlanSelectionPage(
                  onBack: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  onContinueFree: _finishOnboarding,
                  onUpgradeToPro: _finishOnboarding,
                );
              }

              final item = onboardingData[index];

              return OnboardingPage(
                icon: item['icon'],
                title: item['title'],
                description: item['description'],
                currentIndex: currentIndex,
                totalPages: _totalPages,
                isLastPage: false,
                onNext: nextPage,
                onSkip: skipToLastPage,
              );
            },
          ),
          if (_isCompleting)
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
}
