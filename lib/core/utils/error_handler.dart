import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Typed exception hierarchy for the app.
/// Throw these from repositories; catch and map them in [ErrorHandler].
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Authentication-related errors (sign-in, sign-up, token expiry).
class AuthException extends AppException {
  const AuthException(super.message);
}

/// Network connectivity errors (no internet, timeout).
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Server / backend errors (Firestore permission, Functions error).
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Requested resource was not found.
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Validation / bad input errors.
class ValidationException extends AppException {
  const ValidationException(super.message);
}

// ─────────────────────────────────────────────────────────────────────────────
// Centralised error handler
// ─────────────────────────────────────────────────────────────────────────────

class ErrorHandler {
  ErrorHandler._();

  /// Maps any thrown object to a human-readable error string.
  static String handle(dynamic error) {
    if (error is FirebaseAuthException) return _handleFirebaseAuth(error);
    if (error is FirebaseException) return _handleFirebase(error);
    if (error is AppException) return error.message;
    if (error is Exception) {
      final msg = error.toString().replaceAll('Exception: ', '');
      if (msg.toLowerCase().contains('socketexception') ||
          msg.toLowerCase().contains('no internet')) {
        return 'No internet connection. Please check your network.';
      }
      if (msg.toLowerCase().contains('timeout')) {
        return 'Request timed out. Please try again.';
      }
      return msg;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  // ── Firebase Auth ──────────────────────────────────────────────────────────
  static String _handleFirebaseAuth(FirebaseAuthException e) {
    return switch (e.code) {
      'wrong-password' || 'invalid-credential' =>
        'Invalid email or password. Please try again.',
      'user-not-found' => 'No account found with this email address.',
      'email-already-in-use' =>
        'This email is already registered. Please sign in instead.',
      'weak-password' => 'Password must be at least 6 characters.',
      'invalid-email' => 'Please enter a valid email address.',
      'network-request-failed' =>
        'Network error. Please check your internet connection.',
      'too-many-requests' =>
        'Too many failed attempts. Please try again later.',
      'user-disabled' =>
        'This account has been disabled. Please contact support.',
      'requires-recent-login' =>
        'This action requires recent authentication. Please sign in again.',
      'operation-not-allowed' =>
        'This sign-in method is not enabled. Please contact support.',
      _ => e.message ?? 'An authentication error occurred.',
    };
  }

  // ── Firestore / Firebase Core ─────────────────────────────────────────────
  static String _handleFirebase(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' =>
        'You do not have permission to perform this action.',
      'unavailable' =>
        'Service is temporarily unavailable. Please try again.',
      'not-found' => 'The requested data was not found.',
      'already-exists' => 'This record already exists.',
      'resource-exhausted' => 'Quota exceeded. Please try again later.',
      'cancelled' => 'The operation was cancelled.',
      'deadline-exceeded' => 'Request timed out. Please try again.',
      'unauthenticated' => 'You are not signed in. Please sign in again.',
      'data-loss' => 'Data error occurred. Please try again.',
      _ => e.message ?? 'A service error occurred. Please try again.',
    };
  }
}
