import 'package:flutter/material.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/repositories/claim_repository_impl.dart';
import '../../models/claim_model.dart';

enum ClaimState { idle, loading, success, error, empty, submitting }

class ClaimProvider extends ChangeNotifier {
  final ClaimRepositoryImpl _repository;
  String? _uid;

  ClaimProvider(this._repository);

  ClaimState _state = ClaimState.idle;
  List<ClaimModel> _claims = [];
  String? _errorMessage;

  ClaimState get state => _state;
  List<ClaimModel> get claims => _claims;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ClaimState.loading;
  bool get isSubmitting => _state == ClaimState.submitting;

  void onAuthChanged(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    if (uid != null) {
      loadClaims();
    } else {
      _claims = [];
      _state = ClaimState.idle;
      notifyListeners();
    }
  }

  Future<void> loadClaims() async {
    if (_uid == null) return;
    _set(ClaimState.loading);
    AppLogger.provider('ClaimProvider', 'loading');

    try {
      _claims = await _repository.getUserClaims(_uid!);
      _set(_claims.isEmpty ? ClaimState.empty : ClaimState.success);
    } catch (e) {
      AppLogger.error('ClaimProvider.loadClaims', e);
      _errorMessage = ErrorHandler.handle(e);
      _set(ClaimState.error);
    }
  }

  Future<ClaimModel?> submitClaim({
    required String flightCode,
    required String airline,
    required String disruptionType,
    Map<String, dynamic>? booking,
  }) async {
    if (_uid == null) return null;

    _set(ClaimState.submitting);
    AppLogger.provider('ClaimProvider', 'submitting claim');

    try {
      final claim = await _repository.submitClaim(
        uid: _uid!,
        flightCode: flightCode,
        airline: airline,
        disruptionType: disruptionType,
        booking: booking,
      );
      _claims.insert(0, claim);
      _set(ClaimState.success);
      AppLogger.provider('ClaimProvider', 'claim submitted ${claim.id}');
      return claim;
    } catch (e) {
      AppLogger.error('ClaimProvider.submitClaim', e);
      _errorMessage = ErrorHandler.handle(e);
      _set(ClaimState.error);
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _set(ClaimState s) {
    _state = s;
    notifyListeners();
  }
}
