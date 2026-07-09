import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'dart:async';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../models/trip_model.dart';
import '../repositories/flight_api_service.dart';

class LiveFlightTrackerScreen extends StatefulWidget {
  final TripModel? trip;

  const LiveFlightTrackerScreen({
    super.key,
    this.trip,
  });

  @override
  State<LiveFlightTrackerScreen> createState() => _LiveFlightTrackerScreenState();
}

class _LiveFlightTrackerScreenState extends State<LiveFlightTrackerScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _pollingTimer;

  // Plane state variables (animated smoothly)
  LatLng? _currentPlanePos;
  double _currentBearing = 0.0;
  int _currentSpeed = 0;
  int _currentAltitude = 0;
  int _remainingMinutes = 0;
  String _flightStatus = 'scheduled';
  String _airline = 'Airline';

  // Animation controller for smooth transitions between updates
  AnimationController? _transitionController;

  // Coordinates
  late final LatLng _originLatLng;
  late final LatLng _destLatLng;
  late final String _flightNumber;
  late final String _originCode;
  late final String _destCode;

  // Common airport coordinates map
  static const Map<String, LatLng> _airportCoords = {
    'ISB': LatLng(33.5492, 72.8278), // Islamabad
    'KHI': LatLng(24.9065, 67.1608), // Karachi
    'LHE': LatLng(31.5216, 74.4036), // Lahore
    'JED': LatLng(21.6796, 39.1565), // Jeddah
    'DXB': LatLng(25.2532, 55.3657), // Dubai
    'LHR': LatLng(51.4700, -0.4543), // London Heathrow
    'JFK': LatLng(40.6413, -73.7781), // New York JFK
    'SFO': LatLng(37.6213, -122.3790), // San Francisco
  };

  @override
  void initState() {
    super.initState();

    // Extract basic details
    _flightNumber = widget.trip?.flightNumber ?? 'SV727';
    _airline = widget.trip?.timeline.isNotEmpty == true
        ? (widget.trip!.timeline.first.airlineCode ?? 'Saudi Arabian')
        : 'Saudi Arabian';
    _originCode = widget.trip?.origin ?? 'ISB';
    _destCode = widget.trip?.destination ?? 'JED';

    _originLatLng = _airportCoords[_originCode] ?? const LatLng(33.5492, 72.8278);
    _destLatLng = _airportCoords[_destCode] ?? const LatLng(21.6796, 39.1565);

    // Initial position on ground at origin
    _currentPlanePos = _originLatLng;

    // Fetch initial live data
    _fetchLivePosition();

    // Set up polling timer to retrieve live coordinates from backend every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchLivePosition();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _transitionController?.dispose();
    super.dispose();
  }

  Future<void> _fetchLivePosition() async {
    try {
      final data = await FlightApiService.fetchLiveFlightPosition(
        _flightNumber,
        flightDate: widget.trip?.departureDate ?? '',
      );

      if (mounted) {
        setState(() {
          _airline = data.airline.isNotEmpty ? data.airline : _airline;
          _flightStatus = data.status.isNotEmpty ? data.status : _flightStatus;
          _isLoading = false;
        });
        _updatePositionFromData(data);
      }
    } catch (e) {
      debugPrint('[LiveFlightTracker] Error fetching position: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final dy = end.latitude - start.latitude;
    final dx = end.longitude - start.longitude;
    final angleDegrees = atan2(dy, dx) * (180 / pi);
    return 90 - angleDegrees;
  }

  void _updatePositionFromData(LiveFlightPositionModel data) {
    LatLng targetPos;
    double bearing;
    int speed;
    int altitude;
    int remainingMinutes;

    if (data.latitude != null && data.longitude != null) {
      // 1. Live coordinates are available from API (Flight is actively flying)
      targetPos = LatLng(data.latitude!, data.longitude!);
      bearing = data.direction ?? _calculateBearing(_originLatLng, _destLatLng);
      speed = data.speed ?? 850;
      altitude = data.altitude ?? 36000;

      try {
        final arrTime = DateTime.parse(data.arrivalTime);
        remainingMinutes = arrTime.difference(DateTime.now()).inMinutes;
        if (remainingMinutes < 0) remainingMinutes = 0;
      } catch (_) {
        remainingMinutes = 45;
      }
    } else {
      // 2. Fallback to scheduled timeline progress interpolation
      try {
        final depTime = DateTime.parse(data.departureTime);
        final arrTime = DateTime.parse(data.arrivalTime);
        final now = DateTime.now();

        if (now.isBefore(depTime)) {
          // Flight has not departed yet (Scheduled)
          targetPos = _originLatLng;
          bearing = _calculateBearing(_originLatLng, _destLatLng);
          speed = 0;
          altitude = 0;
          remainingMinutes = arrTime.difference(depTime).inMinutes;
        } else if (now.isAfter(arrTime)) {
          // Flight has already landed
          targetPos = _destLatLng;
          bearing = _calculateBearing(_originLatLng, _destLatLng);
          speed = 0;
          altitude = 0;
          remainingMinutes = 0;
        } else {
          // Active flight: interpolate position based on current time
          final totalSec = arrTime.difference(depTime).inSeconds;
          final elapsedSec = now.difference(depTime).inSeconds;
          final t = (elapsedSec / totalSec).clamp(0.0, 1.0);

          final lat = _originLatLng.latitude + (_destLatLng.latitude - _originLatLng.latitude) * t;
          final lng = _originLatLng.longitude + (_destLatLng.longitude - _originLatLng.longitude) * t;
          targetPos = LatLng(lat, lng);

          bearing = _calculateBearing(_originLatLng, _destLatLng);
          speed = 850;
          altitude = 36000;
          remainingMinutes = arrTime.difference(now).inMinutes;
        }
      } catch (_) {
        // Default midpoint position if parsing fails
        targetPos = LatLng(
          (_originLatLng.latitude + _destLatLng.latitude) / 2,
          (_originLatLng.longitude + _destLatLng.longitude) / 2,
        );
        bearing = _calculateBearing(_originLatLng, _destLatLng);
        speed = 850;
        altitude = 36000;
        remainingMinutes = 60;
      }
    }

    _animatePlane(targetPos, bearing, speed, altitude, remainingMinutes);
  }

  void _animatePlane(LatLng targetPos, double targetBearing, int targetSpeed, int targetAltitude, int targetRemaining) {
    if (_currentPlanePos == null) {
      setState(() {
        _currentPlanePos = targetPos;
        _currentBearing = targetBearing;
        _currentSpeed = targetSpeed;
        _currentAltitude = targetAltitude;
        _remainingMinutes = targetRemaining;
      });
      return;
    }

    final startPos = _currentPlanePos!;
    final startBearing = _currentBearing;
    final startSpeed = _currentSpeed;
    final startAltitude = _currentAltitude;
    final startRemaining = _remainingMinutes;

    _transitionController?.dispose();
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 2-second smooth slide transition
    );

    final animation = CurvedAnimation(
      parent: _transitionController!,
      curve: Curves.easeInOut,
    );

    _transitionController!.addListener(() {
      final t = animation.value;
      if (!mounted) return;
      setState(() {
        final lat = startPos.latitude + (targetPos.latitude - startPos.latitude) * t;
        final lng = startPos.longitude + (targetPos.longitude - startPos.longitude) * t;
        _currentPlanePos = LatLng(lat, lng);

        _currentBearing = startBearing + (targetBearing - startBearing) * t;
        _currentSpeed = (startSpeed + (targetSpeed - startSpeed) * t).round();
        _currentAltitude = (startAltitude + (targetAltitude - startAltitude) * t).round();
        _remainingMinutes = (startRemaining + (targetRemaining - startRemaining) * t).round();
      });
    });

    _transitionController!.forward();
  }

  String _formatEta(int totalMinutes) {
    if (totalMinutes <= 0) return 'Landed';
    int h = totalMinutes ~/ 60;
    int m = totalMinutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFC229),
          ),
        ),
      );
    }

    final mapCenter = LatLng(
      (_originLatLng.latitude + _destLatLng.latitude) / 2,
      (_originLatLng.longitude + _destLatLng.longitude) / 2,
    );

    // Generate surrounding yellow flights based on flight number hash
    final List<Marker> surroundingMarkers = [];
    final random = Random(_flightNumber.hashCode);
    for (int i = 0; i < 15; i++) {
      final latOffset = (random.nextDouble() - 0.5) * 15.0;
      final lngOffset = (random.nextDouble() - 0.5) * 15.0;
      final heading = random.nextDouble() * 360.0;
      surroundingMarkers.add(
        Marker(
          point: LatLng(mapCenter.latitude + latOffset, mapCenter.longitude + lngOffset),
          width: 25,
          height: 25,
          child: Transform.rotate(
            angle: (heading - 90.0) * (pi / 180),
            child: const Icon(
              Icons.flight,
              color: Color(0xFFEAB308), // Flightradar24 Yellow Plane
              size: 16,
            ),
          ),
        ),
      );
    }

    final isAirborne = _currentAltitude > 0;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Interactive Terrain Map
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _currentPlanePos ?? mapCenter,
                initialZoom: 5.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.flyredi.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_originLatLng, _destLatLng],
                      color: const Color(0xFF7C3AED), // Flightradar24 Purple Path
                      strokeWidth: 4,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Surrounding Airspace Flights
                    ...surroundingMarkers,

                    // Departure Pin
                    Marker(
                      point: _originLatLng,
                      width: 45,
                      height: 45,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF7C3AED), width: 2),
                        ),
                        child: const Icon(Icons.flight_takeoff, color: Color(0xFF7C3AED), size: 18),
                      ),
                    ),

                    // Arrival Pin
                    Marker(
                      point: _destLatLng,
                      width: 45,
                      height: 45,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF10B981), width: 2),
                        ),
                        child: const Icon(Icons.flight_land, color: Color(0xFF10B981), size: 18),
                      ),
                    ),

                    // Target Airplane
                    if (_currentPlanePos != null)
                      Marker(
                        point: _currentPlanePos!,
                        width: 55,
                        height: 55,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Radar Pulse Effect
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isAirborne
                                    ? const Color(0xFFEF4444).withOpacity(0.25)
                                    : Colors.grey.withOpacity(0.25),
                              ),
                            ),
                            // Red Active Plane
                            Transform.rotate(
                              angle: (_currentBearing - 90.0) * (pi / 180),
                              child: Icon(
                                Icons.flight,
                                color: isAirborne ? const Color(0xFFEF4444) : Colors.grey,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Gradient overlay at top for status bar area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top + 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // 2. Custom Back Button Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface, size: 20),
              ),
            ),
          ),

          // Flight Route Label
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flight, color: Color(0xFFFFC229), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '$_originCode → $_destCode',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Stats Overlay Card
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _flightNumber,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _airline,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isAirborne
                              ? const Color(0xFF10B981).withOpacity(0.1)
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isAirborne
                                ? const Color(0xFF10B981).withOpacity(0.3)
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isAirborne ? Icons.sensors : Icons.info_outline,
                              color: isAirborne
                                  ? const Color(0xFF10B981)
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAirborne ? 'LIVE' : _flightStatus.toUpperCase(),
                              style: TextStyle(
                                color: isAirborne
                                    ? const Color(0xFF10B981)
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Speed',
                        _currentSpeed > 0 ? '$_currentSpeed' : '—',
                        'km/h',
                        Icons.speed,
                      ),
                      _buildStatItem(
                        'Altitude',
                        _currentAltitude > 0
                            ? '${_currentAltitude.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
                            : '—',
                        'ft',
                        Icons.height,
                      ),
                      _buildStatItem(
                        'ETA',
                        _remainingMinutes > 0 ? _formatEta(_remainingMinutes) : '—',
                        '',
                        Icons.schedule,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFFC229), size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty && value != '—') ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ],
    );
  }
}
