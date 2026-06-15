import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'features/auth/presentation/bindings/auth_binding.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/auth/presentation/screens/reset_password_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/traveller/screens/traveller_tabs_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Auth/Core
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences wrapper service before runApp starts
  await Get.putAsync(() => StorageService().init());

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
      initialRoute: '/splash',
      getPages: [
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
