import 'package:flutter/foundation.dart';

/// Professional debug logger for the app.
///
/// All methods use [debugPrint], which is automatically a no-op in release
/// mode — no logs leak to production.
///
/// Usage:
/// ```dart
/// AppLogger.auth('User signed in: uid123');
/// AppLogger.firestore('READ', 'users/uid123');
/// AppLogger.provider('TripsProvider', 'loading');
/// AppLogger.error('TripRepository.fetchTrips', e);
/// ```
class AppLogger {
  AppLogger._();

  // ── Navigation ────────────────────────────────────────────────────────────
  static void nav(String route) {
    debugPrint('🧭 [NAV] → $route');
  }

  // ── Authentication ────────────────────────────────────────────────────────
  static void auth(String event) {
    debugPrint('🔐 [AUTH] $event');
  }

  // ── Firestore ─────────────────────────────────────────────────────────────
  static void firestore(String operation, String path) {
    debugPrint('🔥 [FIRESTORE] $operation @ $path');
  }

  static void firestoreResponse(String path, {String? info}) {
    debugPrint('🔥 [FIRESTORE] ← $path${info != null ? " | $info" : ""}');
  }

  // ── Firebase Functions ────────────────────────────────────────────────────
  static void functions(String name, {Map<String, dynamic>? params}) {
    final paramStr =
        params != null ? ' params=${params.toString()}' : '';
    debugPrint('⚡ [FUNCTIONS] calling $name$paramStr');
  }

  static void functionsResponse(String name, {String? info}) {
    debugPrint('⚡ [FUNCTIONS] ← $name${info != null ? " | $info" : ""}');
  }

  // ── FCM Push Notifications ────────────────────────────────────────────────
  static void fcm(String event) {
    debugPrint('📬 [FCM] $event');
  }

  // ── Firebase Storage ──────────────────────────────────────────────────────
  static void storage(String operation, String path) {
    debugPrint('🗂️  [STORAGE] $operation @ $path');
  }

  // ── Provider State Changes ────────────────────────────────────────────────
  static void provider(String providerName, String state, {String? info}) {
    final infoStr = info != null ? ' | $info' : '';
    debugPrint('📦 [PROVIDER] $providerName → $state$infoStr');
  }

  // ── Errors ────────────────────────────────────────────────────────────────
  static void error(String context, dynamic error, {StackTrace? stackTrace}) {
    debugPrint('❌ [ERROR] $context: $error');
    if (stackTrace != null) {
      debugPrint('   StackTrace: $stackTrace');
    }
  }

  // ── Warnings ─────────────────────────────────────────────────────────────
  static void warn(String message) {
    debugPrint('⚠️  [WARN] $message');
  }

  // ── General Info ─────────────────────────────────────────────────────────
  static void info(String message) {
    debugPrint('ℹ️  [INFO] $message');
  }
}
