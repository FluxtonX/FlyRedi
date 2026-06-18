import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sky_rightz_360/shared/services/api_service.dart';
import 'package:sky_rightz_360/features/traveller/models/trip_model.dart';

class FlightLookupResult {
  final String flightNumber;
  final String flightDate;
  final String status;
  final String origin;
  final String originAirport;
  final String destination;
  final String destinationAirport;
  final String airline;
  final String departureScheduled;
  final String arrivalScheduled;
  final int departureDelay;
  final int arrivalDelay;

  FlightLookupResult({
    required this.flightNumber,
    required this.flightDate,
    required this.status,
    required this.origin,
    required this.originAirport,
    required this.destination,
    required this.destinationAirport,
    required this.airline,
    required this.departureScheduled,
    required this.arrivalScheduled,
    required this.departureDelay,
    required this.arrivalDelay,
  });

  factory FlightLookupResult.fromJson(Map<String, dynamic> json) {
    return FlightLookupResult(
      flightNumber: json['flightNumber'] ?? '',
      flightDate: json['flightDate'] ?? '',
      status: json['status'] ?? 'planned',
      origin: json['origin'] ?? '',
      originAirport: json['originAirport'] ?? '',
      destination: json['destination'] ?? '',
      destinationAirport: json['destinationAirport'] ?? '',
      airline: json['airline'] ?? '',
      departureScheduled: json['departureScheduled'] ?? '',
      arrivalScheduled: json['arrivalScheduled'] ?? '',
      departureDelay: json['departureDelay'] ?? 0,
      arrivalDelay: json['arrivalDelay'] ?? 0,
    );
  }
}

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

  Future<FlightLookupResult> lookupFlight({
    required String flightNumber,
    String? departureDate,
  }) async {
    final response = await ApiService.post(
      '/api/trips/flight-lookup',
      body: {
        'flightNumber': flightNumber,
        if (departureDate != null && departureDate.isNotEmpty)
          'departureDate': departureDate,
      },
    );

    if (response.statusCode == 200) {
      return FlightLookupResult.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    final Map<String, dynamic> errorBody;
    try {
      errorBody = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Flight lookup failed');
    }

    throw Exception(errorBody['message'] ?? 'Flight lookup failed');
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
        'flightNumber': flightNumber,
        'origin': origin,
        'destination': destination,
        'departureDate': departureDate,
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
