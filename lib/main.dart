import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'features/auth/presentation/bindings/auth_binding.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/auth/presentation/screens/reset_password_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/traveller/screens/traveller_tabs_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart'; // TODO: Remove after testing

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Auth/Core
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences wrapper service before runApp starts
  await Get.putAsync(() => StorageService().init());

  // Listen for FCM messages in the foreground and show a top banner
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      Get.snackbar(
        message.notification!.title ?? 'New Alert',
        message.notification!.body ?? '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF0F2D24).withOpacity(0.95),
        colorText: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 12,
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.flight_takeoff, color: Color(0xFFFFC229)),
        isDismissible: true,
      );
    }
  });

  runApp(const SkyRightz360App());
}

class SkyRightz360App extends StatelessWidget {
  const SkyRightz360App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SkyRightz360',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialBinding: AuthBinding(),
      // initialRoute: '/splash', // TODO: Restore after testing
      initialRoute: '/onboarding', // TEMP: Force onboarding for testing
      getPages: [
        // TEMP: Onboarding route for direct testing
        GetPage(
          name: '/onboarding',
          page: () => const OnboardingScreen(),
        ),
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: '/login',
          page: () => const SignInScreen(),
        ),
        GetPage(
          name: '/register',
          page: () => const SignUpScreen(),
        ),
        GetPage(
          name: '/forgot-password',
          page: () => const ResetPasswordScreen(),
        ),
        GetPage(
          name: '/home',
          page: () => const TravellerTabsScreen(),
        ),
      ],
    );
  }
}
