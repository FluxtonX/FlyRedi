import 'package:flutter/material.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../models/trip_model.dart';
import '../../models/flight_lookup_result.dart';

enum TripsState { idle, loading, success, error, empty }

/// Manages trips state for the entire app.
/// Replaces direct TripRepository instantiation inside screens.
class TripsProvider extends ChangeNotifier {
  final TripRepositoryImpl _repository;
  String? _uid;

  TripsProvider(this._repository);

  TripsState _state = TripsState.idle;
  List<TripModel> _trips = [];
  String? _errorMessage;

  TripsState get state => _state;
  List<TripModel> get trips => _trips;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TripsState.loading;

  // ── Auth Changed ───────────────────────────────────────────────────────────

  void onAuthChanged(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    if (uid != null) {
      loadTrips();
    } else {
      _trips = [];
      _state = TripsState.idle;
      notifyListeners();
    }
  }

  // ── Load Trips ─────────────────────────────────────────────────────────────

  Future<void> loadTrips() async {
    if (_uid == null) return;

    _set(TripsState.loading);
    AppLogger.provider('TripsProvider', 'loading');

    try {
      _trips = await _repository.fetchUserTrips(uid: _uid);
      _set(_trips.isEmpty ? TripsState.empty : TripsState.success);
      AppLogger.provider('TripsProvider', 'success (${_trips.length} trips)');
    } catch (e) {
      AppLogger.error('TripsProvider.loadTrips', e);
      _errorMessage = ErrorHandler.handle(e);
      _set(TripsState.error);
    }
  }

  // ── Flight Lookup ──────────────────────────────────────────────────────────

  Future<FlightLookupResult?> lookupFlight({
    required String flightNumber,
    String? departureDate,
  }) async {
    try {
      return await _repository.lookupFlight(
        flightNumber: flightNumber,
        departureDate: departureDate,
      );
    } catch (e) {
      AppLogger.error('TripsProvider.lookupFlight', e);
      _errorMessage = ErrorHandler.handle(e);
      notifyListeners();
      return null;
    }
  }

  // ── Create Trip ────────────────────────────────────────────────────────────

  Future<TripModel?> createTrip({
    required String flightNumber,
    required String origin,
    required String destination,
    required String departureDate,
    String? bookingReference,
    String? status,
    int stops = 0,
    List<TripTimelineItem> timeline = const [],
  }) async {
    if (_uid == null) return null;

    AppLogger.provider('TripsProvider', 'creating trip $flightNumber');

    try {
      final trip = await _repository.createTrip(
        uid: _uid!,
        flightNumber: flightNumber,
        origin: origin,
        destination: destination,
        departureDate: departureDate,
        bookingReference: bookingReference,
        status: status,
        stops: stops,
        timeline: timeline,
      );

      _trips.insert(0, trip);
      _set(TripsState.success);
      AppLogger.provider('TripsProvider', 'trip created ${trip.id}');
      return trip;
    } catch (e) {
      AppLogger.error('TripsProvider.createTrip', e);
      _errorMessage = ErrorHandler.handle(e);
      notifyListeners();
      return null;
    }
  }

  // ── Delete Trip ────────────────────────────────────────────────────────────

  Future<bool> deleteTrip(String tripId) async {
    if (_uid == null) return false;

    try {
      await _repository.deleteTrip(_uid!, tripId);
      _trips.removeWhere((t) => t.id == tripId);
      _set(_trips.isEmpty ? TripsState.empty : TripsState.success);
      AppLogger.provider('TripsProvider', 'trip deleted $tripId');
      return true;
    } catch (e) {
      AppLogger.error('TripsProvider.deleteTrip', e);
      _errorMessage = ErrorHandler.handle(e);
      notifyListeners();
      return false;
    }
  }

  // ── Live Tracking ──────────────────────────────────────────────────────────

  Future<void> setLiveTracking(String tripId, bool enabled) async {
    if (_uid == null) return;

    try {
      await _repository.setTripLiveTracking(_uid!, tripId, enabled);

      // Update local state
      final idx = _trips.indexWhere((t) => t.id == tripId);
      if (idx >= 0) {
        _trips = List.from(_trips);
        notifyListeners();
      }
      AppLogger.provider('TripsProvider', 'tracking $tripId → $enabled');
    } catch (e) {
      AppLogger.error('TripsProvider.setLiveTracking', e);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _set(TripsState s) {
    _state = s;
    notifyListeners();
  }
}
