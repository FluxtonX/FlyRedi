import 'package:flutter/material.dart';
import 'package:sky_rightz_360/features/splash/screens/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SkyRightz360App());
}

class SkyRightz360App extends StatelessWidget {
  const SkyRightz360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      title: 'SkyRightz360',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
