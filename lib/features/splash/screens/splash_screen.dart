import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../onboarding/repositories/onboarding_repository.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final OnboardingRepository _onboardingRepository = OnboardingRepository();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for splash logo display
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final hasSeenOnboarding =
        await _onboardingRepository.getLocalOnboardingStatus();
    if (!mounted) return;

    if (!hasSeenOnboarding) {
      Get.off(() => const OnboardingScreen());
      return;
    }

    if (!_authController.isAuthenticated) {
      Get.offAllNamed('/login');
      return;
    }

    Get.offAllNamed('/home');
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
