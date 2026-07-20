import '../../models/alert_model.dart';

abstract class IAlertRepository {
  /// Real-time stream of user alerts from Firestore.
  Stream<List<AlertModel>> alertsStream(String uid);
  Future<void> markAsRead(String uid, String alertId);
  Future<void> markAllAsRead(String uid);
  Future<void> deleteAlert(String uid, String alertId);
  Future<void> createAlert(
    String uid, {
    required String flightCode,
    required String airline,
    required String priority,
    required String eventType,
    required String message,
    required String source,
  });
}
