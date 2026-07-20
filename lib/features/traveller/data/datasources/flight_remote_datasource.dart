import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FlightStatusEndpoint {
  final String airport;
  final String iata;
  final String icao;
  final String? terminal;
  final String? gate;
  final String? baggage;
  final int? delay;
  final String scheduled;
  final String estimated;
  final String? actual;
  final String? estimatedRunway;
  final String? actualRunway;
  final String timezone;

  const FlightStatusEndpoint({
    required this.airport,
    required this.iata,
    required this.icao,
    this.terminal,
    this.gate,
    this.baggage,
    this.delay,
    required this.scheduled,
    required this.estimated,
    this.actual,
    this.estimatedRunway,
    this.actualRunway,
    required this.timezone,
  });

  factory FlightStatusEndpoint.fromJson(Map<String, dynamic> json) {
    return FlightStatusEndpoint(
      airport: json['airport'] as String? ?? '',
      iata: json['iata'] as String? ?? '',
      icao: json['icao'] as String? ?? '',
      terminal: json['terminal'] as String?,
      gate: json['gate'] as String?,
      baggage: json['baggage'] as String?,
      delay: (json['delay'] as num?)?.toInt(),
      scheduled: json['scheduled'] as String? ?? '',
      estimated: json['estimated'] as String? ?? json['scheduled'] as String? ?? '',
      actual: json['actual'] as String?,
      estimatedRunway: json['estimated_runway'] as String?,
      actualRunway: json['actual_runway'] as String?,
      timezone: json['timezone'] as String? ?? 'UTC',
    );
  }
}

class FlightAirline {
  final String name;
  final String iata;
  final String icao;

  const FlightAirline({
    required this.name,
    required this.iata,
    required this.icao,
  });

  factory FlightAirline.fromJson(Map<String, dynamic> json) {
    return FlightAirline(
      name: json['name'] as String? ?? '',
      iata: json['iata'] as String? ?? '',
      icao: json['icao'] as String? ?? '',
    );
  }
}

class FlightAircraft {
  final String? registration;
  final String? iata;
  final String? icao;
  final String? icao24;

  const FlightAircraft({
    this.registration,
    this.iata,
    this.icao,
    this.icao24,
  });

  factory FlightAircraft.fromJson(Map<String, dynamic> json) {
    return FlightAircraft(
      registration: json['registration'] as String?,
      iata: json['iata'] as String?,
      icao: json['icao'] as String?,
      icao24: json['icao24'] as String?,
    );
  }
}

class FlightCodeshare {
  final String? airlineName;
  final String? airlineIata;
  final String? airlineIco;
  final String? flightNumber;
  final String? flightIata;
  final String? flightIco;

  const FlightCodeshare({
    this.airlineName,
    this.airlineIata,
    this.airlineIco,
    this.flightNumber,
    this.flightIata,
    this.flightIco,
  });

  factory FlightCodeshare.fromJson(Map<String, dynamic> json) {
    return FlightCodeshare(
      airlineName: json['airline_name'] as String?,
      airlineIata: json['airline_iata'] as String?,
      airlineIco: json['airline_icao'] as String?,
      flightNumber: json['flight_number'] as String?,
      flightIata: json['flight_iata'] as String?,
      flightIco: json['flight_icao'] as String?,
    );
  }
}

class FlightLiveTelemetry {
  final String? updated;
  final double? latitude;
  final double? longitude;
  final int? altitude;
  final int? speedHorizontal;
  final int? speedVertical;
  final double? direction;
  final bool isGround;

  const FlightLiveTelemetry({
    this.updated,
    this.latitude,
    this.longitude,
    this.altitude,
    this.speedHorizontal,
    this.speedVertical,
    this.direction,
    required this.isGround,
  });

  factory FlightLiveTelemetry.fromJson(Map<String, dynamic> json) {
    return FlightLiveTelemetry(
      updated: json['updated'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toInt(),
      speedHorizontal: (json['speed_horizontal'] as num?)?.toInt(),
      speedVertical: (json['speed_vertical'] as num?)?.toInt(),
      direction: (json['direction'] as num?)?.toDouble(),
      isGround: json['is_ground'] as bool? ?? true,
    );
  }
}

class FlightStatusModel {
  final String flightNumber;
  final String flightDate;
  final String status;
  final int delayMinutes;
  final FlightStatusEndpoint departure;
  final FlightStatusEndpoint arrival;
  final FlightAirline airline;
  final FlightAircraft? aircraft;
  final FlightCodeshare? codeshare;
  final FlightLiveTelemetry? live;
  final String? flightIcao;
  final String? callsign;

  const FlightStatusModel({
    required this.flightNumber,
    required this.flightDate,
    required this.status,
    required this.delayMinutes,
    required this.departure,
    required this.arrival,
    required this.airline,
    this.aircraft,
    this.codeshare,
    this.live,
    this.flightIcao,
    this.callsign,
  });

  factory FlightStatusModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> flightData;
    if (json.containsKey('response')) {
      final resp = json['response'];
      if (resp is List) {
        if (resp.isEmpty) {
          throw Exception('Flight not found');
        }
        flightData = resp.first as Map<String, dynamic>;
      } else if (resp is Map) {
        flightData = Map<String, dynamic>.from(resp);
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      flightData = json;
    }

    final depTime = (flightData['dep_time'] as String? ?? '').replaceAll(' ', 'T');
    final depEst = (flightData['dep_estimated'] as String? ?? flightData['dep_time'] as String? ?? '').replaceAll(' ', 'T');
    final depAct = (flightData['dep_actual'] as String? ?? '').replaceAll(' ', 'T');

    final arrTime = (flightData['arr_time'] as String? ?? '').replaceAll(' ', 'T');
    final arrEst = (flightData['arr_estimated'] as String? ?? flightData['arr_time'] as String? ?? '').replaceAll(' ', 'T');
    final arrAct = (flightData['arr_actual'] as String? ?? '').replaceAll(' ', 'T');

    final depDelay = (flightData['dep_delayed'] as num?)?.toInt() ?? (flightData['delayed'] as num?)?.toInt() ?? 0;
    final arrDelay = (flightData['arr_delayed'] as num?)?.toInt() ?? 0;

    final departure = FlightStatusEndpoint(
      airport: flightData['dep_name'] as String? ?? flightData['dep_airport'] as String? ?? flightData['dep_iata'] as String? ?? '',
      iata: flightData['dep_iata'] as String? ?? '',
      icao: flightData['dep_icao'] as String? ?? '',
      terminal: flightData['dep_terminal'] as String?,
      gate: flightData['dep_gate'] as String?,
      baggage: null,
      delay: depDelay,
      scheduled: depTime,
      estimated: depEst,
      actual: depAct.isNotEmpty ? depAct : null,
      estimatedRunway: null,
      actualRunway: null,
      timezone: flightData['dep_timezone'] as String? ?? 'UTC',
    );

    final arrival = FlightStatusEndpoint(
      airport: flightData['arr_name'] as String? ?? flightData['arr_airport'] as String? ?? flightData['arr_iata'] as String? ?? '',
      iata: flightData['arr_iata'] as String? ?? '',
      icao: flightData['arr_icao'] as String? ?? '',
      terminal: flightData['arr_terminal'] as String?,
      gate: flightData['arr_gate'] as String?,
      baggage: flightData['arr_baggage'] as String?,
      delay: arrDelay,
      scheduled: arrTime,
      estimated: arrEst,
      actual: arrAct.isNotEmpty ? arrAct : null,
      estimatedRunway: null,
      actualRunway: null,
      timezone: flightData['arr_timezone'] as String? ?? 'UTC',
    );

    final airline = FlightAirline(
      name: flightData['airline_name'] as String? ?? flightData['airline_iata'] as String? ?? '',
      iata: flightData['airline_iata'] as String? ?? '',
      icao: flightData['airline_icao'] as String? ?? '',
    );

    final String? regNumber = flightData['reg_number'] as String?;
    final String? aircraftIcao = flightData['aircraft_icao'] as String?;
    final String? hex = flightData['hex'] as String?;

    final FlightAircraft? aircraft = (regNumber != null || aircraftIcao != null || hex != null)
        ? FlightAircraft(
            registration: regNumber,
            iata: aircraftIcao,
            icao: aircraftIcao,
            icao24: hex,
          )
        : null;

    final double? lat = (flightData['lat'] as num?)?.toDouble();
    final double? lng = (flightData['lng'] as num?)?.toDouble();
    final int? alt = (flightData['alt'] as num?)?.toInt();
    final int? speed = (flightData['speed'] as num?)?.toInt();
    final int? vSpeed = (flightData['v_speed'] as num?)?.toInt();
    final double? dir = (flightData['dir'] as num?)?.toDouble();
    final bool isGround = flightData['is_ground'] as bool? ?? (alt != null && alt <= 0);
    final int? updatedTs = flightData['updated'] as int?;
    final String? updatedStr = updatedTs != null 
        ? DateTime.fromMillisecondsSinceEpoch(updatedTs * 1000).toIso8601String() 
        : null;

    final FlightLiveTelemetry? live = (lat != null && lng != null)
        ? FlightLiveTelemetry(
            updated: updatedStr,
            latitude: lat,
            longitude: lng,
            altitude: alt,
            speedHorizontal: speed,
            speedVertical: vSpeed,
            direction: dir,
            isGround: isGround,
          )
        : null;

    final flightDateRaw = flightData['dep_time'] != null && (flightData['dep_time'] as String).length >= 10 
        ? (flightData['dep_time'] as String).substring(0, 10) 
        : '';

    return FlightStatusModel(
      flightNumber: flightData['flight_iata'] as String? ?? flightData['flight_number'] as String? ?? '',
      flightDate: flightDateRaw,
      status: flightData['status'] as String? ?? 'scheduled',
      delayMinutes: depDelay,
      departure: departure,
      arrival: arrival,
      airline: airline,
      aircraft: aircraft,
      codeshare: null,
      live: live,
      flightIcao: flightData['flight_icao'] as String?,
      callsign: flightData['flight_icao'] as String? ?? flightData['flight_number'] as String?,
    );
  }

  int get scheduledDurationMinutes {
    try {
      final dep = DateTime.parse(departure.scheduled);
      final arr = DateTime.parse(arrival.scheduled);
      return arr.difference(dep).inMinutes;
    } catch (_) {
      return 0;
    }
  }

  String get durationLabel {
    final duration = scheduledDurationMinutes;
    if (duration <= 0) return '—';
    final hours = duration ~/ 60;
    final mins = duration % 60;
    return hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
  }

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

class LiveFlightPositionModel {
  final String flightNumber;
  final String status;
  final double? latitude;
  final double? longitude;
  final int? altitude;
  final int? speed;
  final double? direction;
  final bool isGround;
  final String? updated;
  final String origin;
  final String destination;
  final String originAirport;
  final String destinationAirport;
  final String departureTime;
  final String arrivalTime;
  final String airline;

  const LiveFlightPositionModel({
    required this.flightNumber,
    required this.status,
    this.latitude,
    this.longitude,
    this.altitude,
    this.speed,
    this.direction,
    required this.isGround,
    this.updated,
    required this.origin,
    required this.destination,
    required this.originAirport,
    required this.destinationAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.airline,
  });

  factory LiveFlightPositionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> flightData;
    if (json.containsKey('response')) {
      final resp = json['response'];
      if (resp is List) {
        if (resp.isEmpty) {
          throw Exception('Live flight position not found');
        }
        flightData = resp.first as Map<String, dynamic>;
      } else if (resp is Map) {
        flightData = Map<String, dynamic>.from(resp);
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      flightData = json;
    }

    final depTime = (flightData['dep_time'] as String? ?? '').replaceAll(' ', 'T');
    final arrTime = (flightData['arr_time'] as String? ?? '').replaceAll(' ', 'T');
    final updatedTs = flightData['updated'] as int?;
    final updatedStr = updatedTs != null 
        ? DateTime.fromMillisecondsSinceEpoch(updatedTs * 1000).toIso8601String() 
        : null;

    return LiveFlightPositionModel(
      flightNumber: flightData['flight_iata'] as String? ?? flightData['flight_number'] as String? ?? '',
      status: flightData['status'] as String? ?? 'scheduled',
      latitude: (flightData['lat'] as num?)?.toDouble(),
      longitude: (flightData['lng'] as num?)?.toDouble(),
      altitude: (flightData['alt'] as num?)?.toInt(),
      speed: (flightData['speed'] as num?)?.toInt(),
      direction: (flightData['dir'] as num?)?.toDouble(),
      isGround: flightData['is_ground'] as bool? ?? (flightData['alt'] != null && (flightData['alt'] as num) <= 0),
      updated: updatedStr,
      origin: flightData['dep_iata'] as String? ?? '',
      destination: flightData['arr_iata'] as String? ?? '',
      originAirport: flightData['dep_name'] as String? ?? flightData['dep_airport'] as String? ?? flightData['dep_iata'] as String? ?? '',
      destinationAirport: flightData['arr_name'] as String? ?? flightData['arr_airport'] as String? ?? flightData['arr_iata'] as String? ?? '',
      departureTime: depTime,
      arrivalTime: arrTime,
      airline: flightData['airline_name'] as String? ?? flightData['airline_iata'] as String? ?? '',
    );
  }
}

class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;

  _CacheEntry(this.data) : timestamp = DateTime.now();

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

class FlightRemoteDatasource {
  static const String _baseUrl = 'https://airlabs.co/api/v9/flight';
  static const String _apiKey = 'b0e8d96e-e374-41b5-9e83-4191a2980476';

  static const Duration _cacheTtl = Duration(seconds: 60);

  // Memory Caches
  static final Map<String, _CacheEntry<FlightStatusModel>> _statusCache = {};
  static final Map<String, _CacheEntry<LiveFlightPositionModel>> _positionCache = {};

  // Request Coalescing (In-flight futures)
  static final Map<String, Future<FlightStatusModel>> _statusFutures = {};
  static final Map<String, Future<LiveFlightPositionModel>> _positionFutures = {};

  static Future<http.Response> _getWithRetry(Uri uri) async {
    const int maxAttempts = 3;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http
            .get(uri, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 10));
        return response;
      } catch (e) {
        if (attempt == maxAttempts) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    throw Exception('Failed to connect to AirLabs');
  }

  static Future<FlightStatusModel> fetchFlightStatus(
    String flightNumber, {
    String flightDate = '',
    bool forceRefresh = false,
  }) async {
    final key = '${flightNumber.trim().toUpperCase().replaceAll(' ', '')}_$flightDate';

    if (!forceRefresh) {
      // Check cache first
      final cached = _statusCache[key];
      if (cached != null && !cached.isExpired(_cacheTtl)) {
        debugPrint('[FlightRemoteDatasource] Status cache hit for key: $key');
        return cached.data;
      }

      // Check for in-flight future to avoid duplicate requests
      final pendingFuture = _statusFutures[key];
      if (pendingFuture != null) {
        debugPrint('[FlightRemoteDatasource] Status request coalescing for key: $key');
        return pendingFuture;
      }
    }

    final queryParams = <String, String>{
      'api_key': _apiKey,
      'flight_iata': flightNumber.trim().toUpperCase().replaceAll(' ', ''),
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    debugPrint('[FlightRemoteDatasource] GET Direct lookup (attempt status) $uri');

    final future = () async {
      late final http.Response response;
      try {
        response = await _getWithRetry(uri);
      } catch (e) {
        throw Exception('Could not reach the server. Check your internet connection.');
      }

      debugPrint('[FlightRemoteDatasource] status=${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('[FlightRemoteDatasource] Status JSON response: ${response.body}');

        if (json.containsKey('error')) {
          final err = json['error'] as Map<String, dynamic>? ?? {};
          final code = err['code'] as String? ?? 'unknown';
          final message = err['message'] as String? ?? 'AirLabs API Error';
          throw Exception('[$code] $message');
        }

        final resp = json['response'];
        if (resp == null || (resp is List && resp.isEmpty) || (resp is Map && resp.isEmpty)) {
          throw Exception('Flight $flightNumber not found.');
        }

        try {
          final model = FlightStatusModel.fromJson(json);
          // Store in cache
          _statusCache[key] = _CacheEntry(model);
          return model;
        } catch (e, stackTrace) {
          debugPrint('[FlightRemoteDatasource] FlightStatusModel parsing error: $e\n$stackTrace');
          rethrow;
        }
      }

      throw Exception('Failed to fetch flight status (HTTP ${response.statusCode})');
    }();

    // Register active future
    _statusFutures[key] = future;

    try {
      final result = await future;
      return result;
    } finally {
      // Remove from active futures once done
      _statusFutures.remove(key);
    }
  }

  static Future<LiveFlightPositionModel> fetchLiveFlightPosition(
    String flightNumber, {
    String flightDate = '',
    bool forceRefresh = false,
  }) async {
    final key = '${flightNumber.trim().toUpperCase().replaceAll(' ', '')}_$flightDate';

    if (!forceRefresh) {
      // Check cache first
      final cached = _positionCache[key];
      if (cached != null && !cached.isExpired(_cacheTtl)) {
        debugPrint('[FlightRemoteDatasource] Position cache hit for key: $key');
        return cached.data;
      }

      // Check for in-flight future to avoid duplicate requests
      final pendingFuture = _positionFutures[key];
      if (pendingFuture != null) {
        debugPrint('[FlightRemoteDatasource] Position request coalescing for key: $key');
        return pendingFuture;
      }
    }

    final queryParams = <String, String>{
      'api_key': _apiKey,
      'flight_iata': flightNumber.trim().toUpperCase().replaceAll(' ', ''),
    };

    final uri = Uri.parse('https://airlabs.co/api/v9/flights').replace(queryParameters: queryParams);

    debugPrint('[FlightRemoteDatasource] GET Direct lookup (attempt live position) $uri');

    final future = () async {
      late final http.Response response;
      try {
        response = await _getWithRetry(uri);
      } catch (e) {
        throw Exception('Could not reach the server. Check your internet connection.');
      }

      debugPrint('[FlightRemoteDatasource] status=${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('[FlightRemoteDatasource] Live Position JSON response: ${response.body}');

        if (json.containsKey('error')) {
          final err = json['error'] as Map<String, dynamic>? ?? {};
          final code = err['code'] as String? ?? 'unknown';
          final message = err['message'] as String? ?? 'AirLabs API Error';
          throw Exception('[$code] $message');
        }

        final resp = json['response'];
        if (resp == null || (resp is List && resp.isEmpty) || (resp is Map && resp.isEmpty)) {
          throw Exception('Flight $flightNumber not found.');
        }

        try {
          final model = LiveFlightPositionModel.fromJson(json);
          // Store in cache
          _positionCache[key] = _CacheEntry(model);
          return model;
        } catch (e, stackTrace) {
          debugPrint('[FlightRemoteDatasource] LiveFlightPositionModel parsing error: $e\n$stackTrace');
          rethrow;
        }
      }

      throw Exception('Failed to fetch live flight position (HTTP ${response.statusCode})');
    }();

    // Register active future
    _positionFutures[key] = future;

    try {
      final result = await future;
      return result;
    } finally {
      // Remove from active futures once done
      _positionFutures.remove(key);
    }
  }
}
