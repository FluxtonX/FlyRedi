import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/logging/app_logger.dart';
import '../../models/dashboard_activity.dart';
import '../../models/dashboard_module.dart';
import '../../models/dashboard_summary.dart';

/// Firestore-backed dashboard repository.
/// Summary and activity are computed from Firestore collections.
/// Modules are read from the app-wide config collection.
class DashboardRepositoryImpl {
  final FirebaseFirestore _db;

  DashboardRepositoryImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ── Summary — computed from Firestore subcollection counts ─────────────────

  Future<DashboardSummary> getSummary(String uid) async {
    AppLogger.firestore('COUNT', '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.alertsCollection}');

    final results = await Future.wait([
      _db.collection(FirestoreConstants.usersCollection)
          .doc(uid).collection(FirestoreConstants.alertsCollection)
          .count().get(),
      _db.collection(FirestoreConstants.usersCollection)
          .doc(uid).collection(FirestoreConstants.claimsCollection)
          .count().get(),
      _db.collection(FirestoreConstants.usersCollection)
          .doc(uid).collection(FirestoreConstants.tripsCollection)
          .count().get(),
    ]);

    final alertsCount = results[0].count ?? 0;
    final claimsCount = results[1].count ?? 0;

    AppLogger.firestoreResponse(
      'dashboard summary',
      info: 'alerts=$alertsCount claims=$claimsCount',
    );

    return DashboardSummary.fromJson({
      'alertsCount': alertsCount,
      'casesCount': claimsCount,
      'totalSavings': '₦0',
      'unreadAlerts': 0, // will be computed by AlertProvider
    });
  }

  // ── Activity — read from activity subcollection ────────────────────────────

  Future<List<DashboardActivity>> getActivities(String uid, {int limit = 20}) async {
    AppLogger.firestore('QUERY', '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.activityCollection}');

    final snap = await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.activityCollection)
        .orderBy(FirestoreConstants.fieldCreatedAt, descending: true)
        .limit(limit)
        .get();

    AppLogger.firestoreResponse(FirestoreConstants.activityCollection, info: '${snap.docs.length} items');

    return snap.docs
        .map((d) => DashboardActivity.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  // ── Modules — read from global config collection ───────────────────────────

  Future<List<DashboardModule>> getModules() async {
    AppLogger.firestore('READ', '${FirestoreConstants.configCollection}/${FirestoreConstants.docTravellerModules}');

    try {
      final doc = await _db
          .collection(FirestoreConstants.configCollection)
          .doc(FirestoreConstants.docTravellerModules)
          .get();

      if (doc.exists && doc.data() != null) {
        final rawModules = doc.data()!['modules'] as List<dynamic>? ?? [];
        return rawModules
            .map((m) => DashboardModule.fromJson(m as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      AppLogger.error('DashboardRepository.getModules', e);
    }

    // Fallback: return static default modules
    return _defaultModules;
  }

  static final List<DashboardModule> _defaultModules = [
    DashboardModule(key: 'flights', name: 'Flight Monitor', available: true, requiredPlan: 'Free'),
    DashboardModule(key: 'claims', name: 'Claim Centre', available: true, requiredPlan: 'Free'),
    DashboardModule(key: 'alerts', name: 'Smart Alerts', available: true, requiredPlan: 'Free'),
    DashboardModule(key: 'concierge', name: 'Concierge', available: false, requiredPlan: 'Concierge Pass'),
    DashboardModule(key: 'academy', name: 'FlyRedi Academy', available: false, requiredPlan: 'Plus'),
  ];
}
