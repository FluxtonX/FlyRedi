import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config/app_providers.dart';
import 'core/logging/app_logger.dart';
import 'core/services/notification_service.dart';
import 'core/storage/storage_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ───────────────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogger.info('Firebase initialized');


  final storageService = StorageService();
  await storageService.init();
  AppLogger.info('StorageService initialized');

  // ── Notifications (FCM) ───────────────────────────────────────────────────
  await NotificationService.instance.init();
  AppLogger.info('NotificationService (FCM) initialized');

  runApp(
    AppProviders(storageService: storageService),
  );
}

