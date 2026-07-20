import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_router.dart';
import '../../../core/logging/app_logger.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _onboardingKey = 'local_onboarding_completed';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    AppLogger.nav('SplashScreen → initializing');
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final hasSeenOnboarding = await _getLocalOnboardingStatus();
    if (!mounted) return;

    if (!hasSeenOnboarding) {
      AppLogger.nav('SplashScreen → /onboarding (first launch)');
      Navigator.pushReplacementNamed(context, AppRouter.onboarding);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      AppLogger.nav('SplashScreen → /login (not authenticated)');
      Navigator.pushReplacementNamed(context, AppRouter.login);
      return;
    }

    AppLogger.nav('SplashScreen → /home (authenticated)');
    Navigator.pushReplacementNamed(context, AppRouter.home);
  }

  Future<bool> _getLocalOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/flyredilogo.png',
          width: 300,
        ),
      ),
    );
  }
}
