import 'package:flutter/material.dart';
import '../widgets/onboarding_page.dart';
import '../../traveller/screens/traveller_dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int currentIndex = 0;

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

  void nextPage() {
    if (currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TravellerDashboardScreen(),
        ),
      );
    }
  }

  void skipToLastPage() {
    _pageController.jumpToPage(
      onboardingData.length - 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemCount: onboardingData.length,
        itemBuilder: (context, index) {
          final item = onboardingData[index];

          return OnboardingPage(
            icon: item['icon'],
            title: item['title'],
            description: item['description'],
            currentIndex: currentIndex,
            totalPages: onboardingData.length,
            isLastPage: currentIndex == onboardingData.length - 1,
            onNext: nextPage,
            onSkip: skipToLastPage,
          );
        },
      ),
    );
  }
}
