import 'package:flutter/material.dart';
import 'package:sky_rightz_360/features/splash/screens/splash_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
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
