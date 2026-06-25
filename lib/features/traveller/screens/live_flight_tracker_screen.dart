import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import 'dart:math';
import 'dart:async';

class LiveFlightTrackerScreen extends StatefulWidget {
  final String flightCode;
  final String airline;

  const LiveFlightTrackerScreen({
    super.key,
    this.flightCode = 'BA 117',
    this.airline = 'British Airways',
  });

  @override
  State<LiveFlightTrackerScreen> createState() => _LiveFlightTrackerScreenState();
}

class _LiveFlightTrackerScreenState extends State<LiveFlightTrackerScreen>
    with TickerProviderStateMixin {
  late final AnimationController _planeController;
  late final Animation<double> _planeAnimation;

  final ValueNotifier<int> _speedNotifier = ValueNotifier<int>(850);
  final ValueNotifier<int> _etaNotifier = ValueNotifier<int>(135);
  Timer? _telemetryTimer;

  @override
  void initState() {
    super.initState();

    _telemetryTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      _speedNotifier.value = 845 + Random().nextInt(11);
      // Simulate ETA ticking down frequently for visual effect
      if (_etaNotifier.value > 0) {
        _etaNotifier.value--;
      }
    });

    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _planeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _planeController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _speedNotifier.dispose();
    _etaNotifier.dispose();
    _planeController.dispose();
    super.dispose();
  }

  String _formatEta(int totalMinutes) {
    int h = totalMinutes ~/ 60;
    int m = totalMinutes % 60;
    return '${h}h ${m}m';
  }

  double _bezierPoint(double p0, double p1, double p2, double t) {
    return (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2;
  }

  double _bezierTangent(double p0, double p1, double p2, double t) {
    return 2 * (1 - t) * (p1 - p0) + 2 * t * (p2 - p1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          // 1. Premium Satellite Map Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/map_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Animated Airplane Marker
          AnimatedBuilder(
            animation: _planeAnimation,
            builder: (context, child) {
              final size = MediaQuery.of(context).size;
              // Adjusted coordinates to fit the static image better
              final lhrX = size.width * 0.46;
              final lhrY = size.height * 0.38;
              final jfkX = size.width * 0.20;
              final jfkY = size.height * 0.42;
              final controlX = (lhrX + jfkX) / 2;
              final controlY = min(lhrY, jfkY) - size.height * 0.15;
              
              final t = _planeAnimation.value;
              final planeX = _bezierPoint(lhrX, controlX, jfkX, t);
              final planeY = _bezierPoint(lhrY, controlY, jfkY, t);

              final dx = _bezierTangent(lhrX, controlX, jfkX, t);
              final dy = _bezierTangent(lhrY, controlY, jfkY, t);
              final angle = atan2(dy, dx);

              return Positioned(
                left: planeX - 12,
                top: planeY - 12,
                child: Transform.rotate(
                  angle: angle + pi / 2, // +90 deg because flight icon points up
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC229).withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(Icons.flight, color: const Color(0xFFFFC229), size: 24),
                  ),
                ),
              );
            },
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
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
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
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flight, color: Color(0xFFFFC229), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'LHR → JFK',
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
              padding: EdgeInsets.all(20),
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
                            widget.flightCode,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.airline,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFF10B981).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.sensors, color: Color(0xFF10B981), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Color(0xFF10B981),
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
                  SizedBox(height: 20),
                  Divider(color: Colors.white10, height: 1),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: _speedNotifier,
                        builder: (context, speed, child) {
                          return _buildStatItem('Speed', '$speed', 'km/h', Icons.speed);
                        },
                      ),
                      _buildStatItem('Altitude', '36,000', 'ft', Icons.height),
                      ValueListenableBuilder<int>(
                        valueListenable: _etaNotifier,
                        builder: (context, eta, child) {
                          return _buildStatItem('ETA', _formatEta(eta), '', Icons.schedule);
                        },
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
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
        SizedBox(height: 4),
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
            if (unit.isNotEmpty) ...[
              SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
