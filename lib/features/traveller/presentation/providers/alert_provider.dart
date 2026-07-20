import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/repositories/alert_repository_impl.dart';
import '../../models/alert_model.dart';

enum AlertState { idle, loading, loaded, error, empty }

/// Manages real-time alerts via Firestore stream.
/// Replaces direct AlertRepository instantiation in screens.
class AlertProvider extends ChangeNotifier {
  final AlertRepositoryImpl _repository;
  String? _uid;
  StreamSubscription<List<AlertModel>>? _subscription;

  AlertProvider(this._repository);

  AlertState _state = AlertState.idle;
  List<AlertModel> _alerts = [];
  String? _errorMessage;

  AlertState get state => _state;
  List<AlertModel> get alerts => _alerts;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AlertState.loading;
  int get unreadCount => _alerts.where((a) => !a.isRead).length;

  // ── Auth Changed ───────────────────────────────────────────────────────────

  void onAuthChanged(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _subscription?.cancel();
    _subscription = null;

    if (uid != null) {
      _startListening(uid);
    } else {
      _alerts = [];
      _state = AlertState.idle;
      notifyListeners();
    }
  }

  // ── Real-time Listener ─────────────────────────────────────────────────────

  void _startListening(String uid) {
    _state = AlertState.loading;
    notifyListeners();
    AppLogger.provider('AlertProvider', 'starting stream uid=$uid');

    _subscription = _repository.alertsStream(uid).listen(
      (alerts) {
        _alerts = alerts;
        _state = alerts.isEmpty ? AlertState.empty : AlertState.loaded;
        AppLogger.provider('AlertProvider', 'stream update (${alerts.length} alerts)');
        notifyListeners();
      },
      onError: (e) {
        AppLogger.error('AlertProvider stream', e);
        _errorMessage = ErrorHandler.handle(e);
        _state = AlertState.error;
        notifyListeners();
      },
    );
  }

  // ── Mark As Read ───────────────────────────────────────────────────────────

  Future<void> markAsRead(String alertId) async {
    if (_uid == null) return;
    try {
      await _repository.markAsRead(_uid!, alertId);
      // Stream will automatically update the list
      AppLogger.provider('AlertProvider', 'marked $alertId as read');
    } catch (e) {
      AppLogger.error('AlertProvider.markAsRead', e);
    }
  }

  // ── Mark All Read ──────────────────────────────────────────────────────────

  Future<void> markAllAsRead() async {
    if (_uid == null) return;
    try {
      await _repository.markAllAsRead(_uid!);
      AppLogger.provider('AlertProvider', 'marked all as read');
    } catch (e) {
      AppLogger.error('AlertProvider.markAllAsRead', e);
      _errorMessage = ErrorHandler.handle(e);
      notifyListeners();
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteAlert(String alertId) async {
    if (_uid == null) return;
    try {
      await _repository.deleteAlert(_uid!, alertId);
      AppLogger.provider('AlertProvider', 'deleted $alertId');
    } catch (e) {
      AppLogger.error('AlertProvider.deleteAlert', e);
    }
  }

  Future<void> addAlert({
    required String flightCode,
    required String airline,
    required String priority,
    required String eventType,
    required String message,
    required String source,
  }) async {
    if (_uid == null) return;
    try {
      await _repository.createAlert(
        _uid!,
        flightCode: flightCode,
        airline: airline,
        priority: priority,
        eventType: eventType,
        message: message,
        source: source,
      );
      AppLogger.provider('AlertProvider', 'created alert for flightCode=$flightCode');
    } catch (e) {
      AppLogger.error('AlertProvider.addAlert', e);
    }
  }

  // ── Filtered Views ─────────────────────────────────────────────────────────

  List<AlertModel> getByPriority(String priority) {
    if (priority == 'All') return _alerts;
    return _alerts.where((a) => a.priority.toUpperCase() == priority.toUpperCase()).toList();
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
