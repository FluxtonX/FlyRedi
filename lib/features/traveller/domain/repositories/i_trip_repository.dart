import '../../models/trip_model.dart';
import '../../models/flight_lookup_result.dart';

abstract class ITripRepository {
  Future<List<TripModel>> fetchUserTrips({String? uid});
  Future<FlightLookupResult> lookupFlight({
    required String flightNumber,
    String? departureDate,
  });
  Future<TripModel> createTrip({
    required String uid,
    required String flightNumber,
    required String origin,
    required String destination,
    required String departureDate,
    String? bookingReference,
    String? status,
    int stops,
    List<TripTimelineItem> timeline,
  });
  Future<void> deleteTrip(String uid, String tripId);
  Future<void> setTripLiveTracking(String uid, String tripId, bool enabled);
}
