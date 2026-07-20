/// Firestore collection and field name constants.
/// Using constants avoids typos and makes refactoring safe.
class FirestoreConstants {
  FirestoreConstants._();

  // ── Top-level collections ────────────────────────────────────────────────
  static const String usersCollection = 'users';
  static const String configCollection = 'config';

  // ── User sub-collections ─────────────────────────────────────────────────
  static const String tripsCollection = 'trips';
  static const String alertsCollection = 'alerts';
  static const String claimsCollection = 'claims';
  static const String activityCollection = 'activity';

  // ── User document fields ─────────────────────────────────────────────────
  static const String fieldEmail = 'email';
  static const String fieldDisplayName = 'displayName';
  static const String fieldPhoneNumber = 'phoneNumber';
  static const String fieldPhotoURL = 'photoURL';
  static const String fieldRole = 'role';
  static const String fieldPlan = 'plan';
  static const String fieldNotificationsEnabled = 'notificationsEnabled';
  static const String fieldOnboardingCompleted = 'onboardingCompleted';
  static const String fieldFcmToken = 'fcmToken';
  static const String fieldSettings = 'settings';
  static const String fieldAlertPreferences = 'alertPreferences';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';

  // ── Alert fields ─────────────────────────────────────────────────────────
  static const String fieldIsRead = 'isRead';
  static const String fieldPriority = 'priority';

  // ── Trip fields ──────────────────────────────────────────────────────────
  static const String fieldFlightNumber = 'flightNumber';
  static const String fieldTrackingEnabled = 'trackingEnabled';
  static const String fieldStatus = 'status';

  // ── Config doc keys ──────────────────────────────────────────────────────
  static const String docTravellerModules = 'traveller_modules';

  // ── Firebase Functions callable names ────────────────────────────────────
  static const String fnGetFlightStatus = 'getFlightStatus';
  static const String fnGetLiveFlightPosition = 'getLiveFlightPosition';
}
