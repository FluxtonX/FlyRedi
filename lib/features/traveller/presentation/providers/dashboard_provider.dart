import 'package:flutter/material.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../models/dashboard_activity.dart';
import '../../models/dashboard_module.dart';
import '../../models/dashboard_summary.dart';

enum DashboardState { idle, loading, success, error }

class DashboardProvider extends ChangeNotifier {
  final DashboardRepositoryImpl _repository;
  String? _uid;

  DashboardProvider(this._repository);

  DashboardState _state = DashboardState.idle;
  DashboardSummary? _summary;
  List<DashboardActivity> _activities = [];
  List<DashboardModule> _modules = [];
  String? _errorMessage;

  DashboardState get state => _state;
  DashboardSummary? get summary => _summary;
  List<DashboardActivity> get activities => _activities;
  List<DashboardModule> get modules => _modules;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == DashboardState.loading;

  void onAuthChanged(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    if (uid != null) {
      loadDashboard();
    } else {
      _summary = null;
      _activities = [];
      _modules = [];
      _state = DashboardState.idle;
      notifyListeners();
    }
  }

  Future<void> loadDashboard() async {
    if (_uid == null) return;
    _set(DashboardState.loading);
    AppLogger.provider('DashboardProvider', 'loading');

    try {
      final results = await Future.wait([
        _repository.getSummary(_uid!),
        _repository.getActivities(_uid!),
        _repository.getModules(),
      ]);

      _summary = results[0] as DashboardSummary;
      _activities = results[1] as List<DashboardActivity>;
      _modules = results[2] as List<DashboardModule>;
      _set(DashboardState.success);
      AppLogger.provider('DashboardProvider', 'success');
    } catch (e) {
      AppLogger.error('DashboardProvider.loadDashboard', e);
      _errorMessage = ErrorHandler.handle(e);
      _set(DashboardState.error);
    }
  }

  Future<void> refresh() => loadDashboard();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _set(DashboardState s) {
    _state = s;
    notifyListeners();
  }
}
