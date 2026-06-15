import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sky_rightz_360/shared/services/api_service.dart';
import 'package:sky_rightz_360/features/traveller/models/trip_model.dart';

class TripRepository {
  static final ValueNotifier<int> tripsVersion = ValueNotifier<int>(0);

  static void notifyTripsChanged() {
    tripsVersion.value++;
  }

  Future<List<TripModel>> fetchUserTrips() async {
    final response = await ApiService.get('/api/trips');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => TripModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to load trips');
  }

  Future<TripModel> createTrip({
    required String flightNumber,
    required String origin,
    required String destination,
    required String departureDate,
    String? bookingReference,
    int stops = 0,
    List<TripTimelineItem> timeline = const [],
  }) async {
    final response = await ApiService.post(
      '/api/trips',
      body: {
        'tripName': flightNumber,
        'origin': origin,
        'destination': destination,
        'bookingReference': bookingReference,
        'totalDuration': departureDate,
        'stops': stops,
        'timeline': timeline.map((e) => e.toJson()).toList(),
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final trip = TripModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      notifyTripsChanged();
      return trip;
    }

    throw Exception('Failed to create trip: ${response.body}');
  }

  Future<void> deleteTrip(String tripId) async {
    final response = await ApiService.delete('/api/trips/$tripId');

    if (response.statusCode == 200) {
      notifyTripsChanged();
      return;
    }

    throw Exception('Failed to delete trip: ${response.body}');
  }

  Future<void> enableTripLiveTracking(
    String tripId,
    bool enabled,
  ) async {
    final response = await ApiService.post(
      '/api/trips/$tripId/track-live',
      body: {
        'enabled': enabled,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle tracking');
    }

    notifyTripsChanged();
  }
}
