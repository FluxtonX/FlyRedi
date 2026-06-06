import 'dart:convert';
import 'package:sky_rightz_360/shared/services/api_service.dart';
import 'package:sky_rightz_360/features/traveller/models/alert_model.dart';

class AlertRepository {
  /// Fetch all user alerts from backend (paginated).
  Future<AlertListResponse> fetchAlerts({int page = 1, int limit = 50}) async {
    try {
      final response =
          await ApiService.get('/api/alerts?page=$page&limit=$limit');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return AlertListResponse.fromJson(decoded);
      } else {
        throw Exception('Failed to load alerts (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching alerts: $e');
    }
  }

  /// Mark a single alert as read.
  Future<void> markAsRead(String alertId) async {
    try {
      final response =
          await ApiService.post('/api/alerts/$alertId/read', body: {});
      if (response.statusCode != 200) {
        throw Exception('Failed to mark alert as read');
      }
    } catch (e) {
      throw Exception('Error marking alert as read: $e');
    }
  }

  /// Mark all alerts as read.
  Future<void> markAllAsRead() async {
    try {
      final response = await ApiService.patch('/api/alerts/read-all', body: {});
      if (response.statusCode != 200) {
        throw Exception('Failed to mark all alerts as read');
      }
    } catch (e) {
      throw Exception('Error marking all as read: $e');
    }
  }

  /// Delete a single alert.
  Future<void> deleteAlert(String alertId) async {
    try {
      final response = await ApiService.delete('/api/alerts/$alertId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete alert');
      }
    } catch (e) {
      throw Exception('Error deleting alert: $e');
    }
  }

  /// Generate test alerts (dev/QA only).
  Future<void> generateTestAlerts() async {
    try {
      await ApiService.post('/api/alerts/generate-test', body: {});
    } catch (_) {}
  }
}
