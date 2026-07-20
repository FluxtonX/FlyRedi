import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/sign_in_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/traveller/screens/traveller_tabs_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../core/logging/app_logger.dart';

/// Centralised named-route definitions.
/// Replaces GetX route pages — uses pure Flutter [Navigator].
class AppRouter {
  AppRouter._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    AppLogger.nav(settings.name ?? 'unknown');

    switch (settings.name) {
      case splash:
        return _fade(const SplashScreen());
      case onboarding:
        return _fade(const OnboardingScreen());
      case login:
        return _fade(const SignInScreen());
      case register:
        return _fade(const SignUpScreen());
      case forgotPassword:
        return _slide(const ResetPasswordScreen());
      case home:
        return _fade(const TravellerTabsScreen());
      default:
        return _fade(const SplashScreen());
    }
  }

  // ── Page transition helpers ────────────────────────────────────────────────

  static PageRoute<T> _fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRoute<T> _slide<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
