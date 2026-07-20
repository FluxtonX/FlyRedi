import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/logging/app_logger.dart';
import '../../models/alert_model.dart';
import '../../domain/repositories/i_alert_repository.dart';

/// Firestore-backed implementation of [IAlertRepository].
/// Uses real-time Firestore snapshots — no more manual HTTP polling.
class AlertRepositoryImpl implements IAlertRepository {
  final FirebaseFirestore _db;

  AlertRepositoryImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ── Real-time Stream ────────────────────────────────────────────────────────

  @override
  Stream<List<AlertModel>> alertsStream(String uid) {
    AppLogger.firestore(
      'STREAM',
      '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.alertsCollection}',
    );

    return _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.alertsCollection)
        .orderBy(FirestoreConstants.fieldCreatedAt, descending: true)
        .snapshots()
        .map((snap) {
      final alerts = snap.docs
          .map((d) => AlertModel.fromJson({'id': d.id, ...d.data()}))
          .toList();

      AppLogger.firestoreResponse(
        FirestoreConstants.alertsCollection,
        info: '${alerts.length} alerts',
      );

      return alerts;
    });
  }

  // ── Mark As Read ───────────────────────────────────────────────────────────

  @override
  Future<void> markAsRead(String uid, String alertId) async {
    AppLogger.firestore(
      'UPDATE isRead',
      '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.alertsCollection}/$alertId',
    );

    await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.alertsCollection)
        .doc(alertId)
        .update({
      FirestoreConstants.fieldIsRead: true,
      FirestoreConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
  }

  // ── Mark All Read ──────────────────────────────────────────────────────────

  @override
  Future<void> markAllAsRead(String uid) async {
    AppLogger.firestore(
      'BATCH UPDATE isRead',
      '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.alertsCollection}',
    );

    final snap = await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.alertsCollection)
        .where(FirestoreConstants.fieldIsRead, isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {
        FirestoreConstants.fieldIsRead: true,
        FirestoreConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    AppLogger.firestoreResponse(
      FirestoreConstants.alertsCollection,
      info: 'marked ${snap.docs.length} alerts as read',
    );
  }

  // ── Delete Alert ───────────────────────────────────────────────────────────

  @override
  Future<void> deleteAlert(String uid, String alertId) async {
    AppLogger.firestore(
      'DELETE',
      '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.alertsCollection}/$alertId',
    );

    await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.alertsCollection)
        .doc(alertId)
        .delete();

    AppLogger.firestoreResponse(
      FirestoreConstants.alertsCollection,
      info: 'deleted $alertId',
    );
  }

  @override
  Future<void> createAlert(
    String uid, {
    required String flightCode,
    required String airline,
    required String priority,
    required String eventType,
    required String message,
    required String source,
  }) async {
    final ref = _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.alertsCollection)
        .doc();

    final data = {
      'id': ref.id,
      'userId': uid,
      'flightCode': flightCode,
      'airline': airline,
      'priority': priority.toUpperCase(),
      'eventType': eventType,
      'message': message,
      'isRead': false,
      'source': source,
      'createdAt': DateTime.now().toIso8601String(),
    };

    AppLogger.firestore(
      'CREATE',
      '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.alertsCollection}/${ref.id}',
    );

    await ref.set(data);

    AppLogger.firestoreResponse(
      FirestoreConstants.alertsCollection,
      info: 'created alert ${ref.id}',
    );
  }
}
