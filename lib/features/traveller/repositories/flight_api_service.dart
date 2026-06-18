import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FlightStatusModel — mirrors the backend FlightStatusResult interface
// ─────────────────────────────────────────────────────────────────────────────

class FlightStatusEndpoint {
  final String airport;
  final String iata;
  final String? terminal;
  final String? gate;
  final String scheduled;
  final String estimated;

  const FlightStatusEndpoint({
    required this.airport,
    required this.iata,
    this.terminal,
    this.gate,
    required this.scheduled,
    required this.estimated,
  });

  factory FlightStatusEndpoint.fromJson(Map<String, dynamic> json) {
    return FlightStatusEndpoint(
      airport: json['airport'] as String? ?? '',
      iata: json['iata'] as String? ?? '',
      terminal: json['terminal'] as String?,
      gate: json['gate'] as String?,
      scheduled: json['scheduled'] as String? ?? '',
      estimated: json['estimated'] as String? ?? '',
    );
  }
}

class FlightAirline {
  final String name;
  final String iata;

  const FlightAirline({required this.name, required this.iata});

  factory FlightAirline.fromJson(Map<String, dynamic> json) {
    return FlightAirline(
      name: json['name'] as String? ?? '',
      iata: json['iata'] as String? ?? '',
    );
  }
}

class FlightStatusModel {
  final String flightNumber;
  final String flightDate;

  /// Raw status from Aviationstack: "scheduled" | "active" | "delayed" |
  /// "cancelled" | "landed" | "incident" | "diverted"
  final String status;

  final int delayMinutes;
  final FlightStatusEndpoint departure;
  final FlightStatusEndpoint arrival;
  final FlightAirline airline;

  const FlightStatusModel({
    required this.flightNumber,
    required this.flightDate,
    required this.status,
    required this.delayMinutes,
    required this.departure,
    required this.arrival,
    required this.airline,
  });

  factory FlightStatusModel.fromJson(Map<String, dynamic> json) {
    return FlightStatusModel(
      flightNumber: json['flightNumber'] as String? ?? '',
      flightDate: json['flightDate'] as String? ?? '',
      status: json['status'] as String? ?? 'scheduled',
      delayMinutes: (json['delayMinutes'] as num?)?.toInt() ?? 0,
      departure: FlightStatusEndpoint.fromJson(
        json['departure'] as Map<String, dynamic>? ?? {},
      ),
      arrival: FlightStatusEndpoint.fromJson(
        json['arrival'] as Map<String, dynamic>? ?? {},
      ),
      airline: FlightAirline.fromJson(
        json['airline'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Friendly label shown in the UI badge
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'active':
        return 'In Flight';
      case 'active_delayed':
        return 'Active (Delayed)';
      case 'landed':
        return 'Landed';
      case 'landed_estimated':
        return 'Landed (Est.)';
      case 'cancelled':
        return 'Cancelled';
      case 'delayed':
        return 'Delayed';
      case 'diverted':
        return 'Diverted';
      case 'incident':
        return 'Incident';
      case 'scheduled':
      default:
        return 'Scheduled';
    }
  }

  bool get isDelayed =>
      delayMinutes > 0 ||
      status.toLowerCase() == 'delayed' ||
      status.toLowerCase() == 'active_delayed';

  bool get isCancelled => status.toLowerCase() == 'cancelled';

  bool get isActive =>
      status.toLowerCase() == 'active' ||
      status.toLowerCase() == 'active_delayed';

  bool get isLanded =>
      status.toLowerCase() == 'landed' ||
      status.toLowerCase() == 'landed_estimated';

}

// ─────────────────────────────────────────────────────────────────────────────
// FlightApiService — calls /api/flights/status (no auth required)
// ─────────────────────────────────────────────────────────────────────────────

class FlightApiService {
  static final String _baseUrl = ApiConstants.baseUrl;
  static const String _endpoint = ApiConstants.flightStatus;

  /// Fetch real-time flight status from the Flyredi backend.
  ///
  /// [flightNumber] — IATA code, e.g. "EK203"
  /// [flightDate]  — optional, YYYY-MM-DD, e.g. "2026-06-18"
  ///
  /// Throws an [Exception] with a human-readable message on failure.
  static Future<FlightStatusModel> fetchFlightStatus(
    String flightNumber, {
    String flightDate = '',
  }) async {
    final queryParams = <String, String>{
      'flightNumber': flightNumber.trim().toUpperCase(),
      if (flightDate.isNotEmpty) 'flightDate': flightDate.trim(),
    };

    final uri = Uri.parse('$_baseUrl$_endpoint')
        .replace(queryParameters: queryParams);

    debugPrint('[FlightApiService] GET $uri');

    late final http.Response response;
    try {
      response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception(
        'Could not reach the server. Check your internet connection.',
      );
    }

    debugPrint('[FlightApiService] status=${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return FlightStatusModel.fromJson(json);
    }

    // Parse backend error message when available
    String errorMessage = 'Failed to fetch flight status';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      errorMessage = body['message'] as String? ?? errorMessage;
    } catch (_) {}

    if (response.statusCode == 404) {
      throw Exception(
        'Flight $flightNumber not found.'
        '${flightDate.isNotEmpty ? ' Try without a date filter.' : ''}',
      );
    }

    if (response.statusCode == 503) {
      throw Exception(
        'Flight data provider is unavailable. Try again in a moment.',
      );
    }

    throw Exception(errorMessage);
  }
}
