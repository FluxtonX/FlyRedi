import 'dart:convert';
import 'package:sky_rightz_360/shared/services/api_service.dart';
import 'package:sky_rightz_360/features/traveller/models/trip_model.dart';

class TripRepository {
  Future<List<TripModel>> fetchUserTrips() async {
    try {
      final response = await ApiService.get('/api/trips');

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => TripModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trips');
      }
    } catch (e) {
      throw Exception('Error fetching trips: $e');
    }
  }

  Future<void> enableTripLiveTracking(String tripId, bool enabled) async {
    try {
      final response = await ApiService.post(
        '/api/trips/$tripId/track-live',
        body: {'enabled': enabled},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle tracking');
      }
    } catch (e) {
      throw Exception('Error toggling tracking: $e');
    }
  }
}
