import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/logging/app_logger.dart';
import '../datasources/flight_remote_datasource.dart';
import '../../models/trip_model.dart';
import '../../models/flight_lookup_result.dart';
import '../../domain/repositories/i_trip_repository.dart';

/// Firestore-backed implementation replacing the HTTP [TripRepository].
class TripRepositoryImpl implements ITripRepository {
  final FirebaseFirestore _db;

  TripRepositoryImpl({
    FirebaseFirestore? db,
  })  : _db = db ?? FirebaseFirestore.instance;

  // ── Fetch Trips ────────────────────────────────────────────────────────────

  @override
  Future<List<TripModel>> fetchUserTrips({String? uid}) async {
    if (uid == null) return [];

    AppLogger.firestore('QUERY', '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.tripsCollection}');

    final snap = await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.tripsCollection)
        .orderBy(FirestoreConstants.fieldCreatedAt, descending: true)
        .get();

    AppLogger.firestoreResponse(
      '${FirestoreConstants.tripsCollection}',
      info: '${snap.docs.length} trips',
    );

    return snap.docs
        .map((d) => TripModel.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  // ── Flight Lookup (Direct frontend HTTP lookup) ───────────────────────────

  @override
  Future<FlightLookupResult> lookupFlight({
    required String flightNumber,
    String? departureDate,
  }) async {
    AppLogger.auth('Direct AirLabs lookup: $flightNumber');

    final status = await FlightRemoteDatasource.fetchFlightStatus(
      flightNumber,
      flightDate: departureDate ?? '',
    );

    return FlightLookupResult(
      flightNumber: status.flightNumber.isNotEmpty ? status.flightNumber : flightNumber,
      flightDate: status.flightDate,
      status: status.status,
      origin: status.departure.iata,
      originAirport: status.departure.airport,
      destination: status.arrival.iata,
      destinationAirport: status.arrival.airport,
      airline: status.airline.name,
      departureScheduled: status.departure.scheduled,
      arrivalScheduled: status.arrival.scheduled,
      departureDelay: status.delayMinutes,
      arrivalDelay: 0,
    );
  }

  // ── Create Trip ────────────────────────────────────────────────────────────

  @override
  Future<TripModel> createTrip({
    required String uid,
    required String flightNumber,
    required String origin,
    required String destination,
    required String departureDate,
    String? bookingReference,
    String? status,
    int stops = 0,
    List<TripTimelineItem> timeline = const [],
  }) async {
    final data = {
      'userId': uid,
      'tripName': flightNumber,
      'flightNumber': flightNumber,
      'origin': origin,
      'destination': destination,
      'departureDate': departureDate,
      if (bookingReference != null && bookingReference.isNotEmpty)
        'bookingReference': bookingReference,
      'status': status ?? 'scheduled',
      'stops': stops,
      'timeline': timeline.map((e) => e.toJson()).toList(),
      'trackingEnabled': false,
      'isShared': false,
      FirestoreConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
      FirestoreConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
    };

    AppLogger.firestore('CREATE', '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.tripsCollection}');

    final docRef = await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.tripsCollection)
        .add(data);

    AppLogger.firestoreResponse('trips', info: 'created ${docRef.id}');

    return TripModel.fromJson({'id': docRef.id, 'userId': uid, ...data});
  }

  // ── Delete Trip ────────────────────────────────────────────────────────────

  @override
  Future<void> deleteTrip(String uid, String tripId) async {
    AppLogger.firestore('DELETE', '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.tripsCollection}/$tripId');

    await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.tripsCollection)
        .doc(tripId)
        .delete();

    AppLogger.firestoreResponse('trips', info: 'deleted $tripId');
  }

  // ── Live Tracking ──────────────────────────────────────────────────────────

  @override
  Future<void> setTripLiveTracking(String uid, String tripId, bool enabled) async {
    AppLogger.firestore('UPDATE tracking', '${FirestoreConstants.usersCollection}/$uid/${FirestoreConstants.tripsCollection}/$tripId');

    await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection(FirestoreConstants.tripsCollection)
        .doc(tripId)
        .update({
      FirestoreConstants.fieldTrackingEnabled: enabled,
      FirestoreConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
  }
}
