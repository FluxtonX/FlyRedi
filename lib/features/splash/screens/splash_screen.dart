import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../authentication/screens/sign_in_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../onboarding/repositories/onboarding_repository.dart';
import '../../traveller/screens/traveller_tabs_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final OnboardingRepository _onboardingRepository = OnboardingRepository();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for splash logo display
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ),
      );
      return;
    }

    try {
      final isCompleted = await _onboardingRepository.getOnboardingStatus();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isCompleted
              ? const TravellerTabsScreen()
              : const OnboardingScreen(),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      // Fallback safely to OnboardingScreen on network/server errors
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071B3A),
      body: Center(
        child: Image.asset(
          'assets/images/flyredilogo.png',
          width: 300,
        ),
      ),
    );
  }
}
