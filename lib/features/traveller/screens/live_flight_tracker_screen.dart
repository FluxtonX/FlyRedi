import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import 'dart:math';

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
  late final AnimationController _pulseController;
  late final AnimationController _planeController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _planeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _planeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _planeController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _planeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Dynamic Map Placeholder
          Positioned.fill(
            child: CustomPaint(
              painter: _DarkMapPainter(
                pulseAnimation: _pulseAnimation,
                planeAnimation: _planeAnimation,
              ),
              child: Container(),
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
                  color: const Color(0xFF0C162A).withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
                color: const Color(0xFF0C162A).withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flight, color: Color(0xFFFFC229), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'LHR → JFK',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
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
                color: const Color(0xFF0C162A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.airline,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                        ),
                        child: const Row(
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
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Speed', '850', 'km/h', Icons.speed),
                      _buildStatItem('Altitude', '36,000', 'ft', Icons.height),
                      _buildStatItem('ETA', '2h 15m', '', Icons.schedule),
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
            color: Colors.white.withOpacity(0.5),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
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

// =============================================================================
// Custom Painter: Dynamic Dark-Theme Map Placeholder
// =============================================================================
class _DarkMapPainter extends CustomPainter {
  final Animation<double> pulseAnimation;
  final Animation<double> planeAnimation;

  _DarkMapPainter({
    required this.pulseAnimation,
    required this.planeAnimation,
  }) : super(repaint: Listenable.merge([pulseAnimation, planeAnimation]));

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Background gradient (deep ocean blue)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF071B3A),
          Color(0xFF051329),
          Color(0xFF040E1F),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Grid lines
    _drawGrid(canvas, size);

    // 3. Simplified continent outlines
    _drawContinents(canvas, size);

    // 4. Flight path (LHR to JFK arc)
    _drawFlightPath(canvas, size);

    // 5. Animated plane dot
    _drawPlaneDot(canvas, size);

    // 6. Airport markers
    _drawAirportMarkers(canvas, size);

    // 7. Subtle vignette overlay
    _drawVignette(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF0E2447).withOpacity(0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Vertical grid lines
    for (double x = 0; x < size.width; x += size.width / 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal grid lines
    for (double y = 0; y < size.height; y += size.height / 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw slightly brighter "equator" and "prime meridian"
    final majorGridPaint = Paint()
      ..color = const Color(0xFF153060).withOpacity(0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      majorGridPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.55, 0),
      Offset(size.width * 0.55, size.height),
      majorGridPaint,
    );
  }

  void _drawContinents(Canvas canvas, Size size) {
    final landPaint = Paint()
      ..color = const Color(0xFF102B5C).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final landStroke = Paint()
      ..color = const Color(0xFF1A3D6E).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // North America (simplified polygon)
    final northAmerica = Path();
    northAmerica.moveTo(size.width * 0.10, size.height * 0.22);
    northAmerica.lineTo(size.width * 0.12, size.height * 0.18);
    northAmerica.lineTo(size.width * 0.18, size.height * 0.15);
    northAmerica.lineTo(size.width * 0.25, size.height * 0.14);
    northAmerica.lineTo(size.width * 0.30, size.height * 0.16);
    northAmerica.lineTo(size.width * 0.32, size.height * 0.20);
    northAmerica.lineTo(size.width * 0.35, size.height * 0.22);
    northAmerica.lineTo(size.width * 0.36, size.height * 0.28);
    northAmerica.lineTo(size.width * 0.34, size.height * 0.32);
    northAmerica.lineTo(size.width * 0.30, size.height * 0.38);
    northAmerica.lineTo(size.width * 0.28, size.height * 0.42);
    northAmerica.lineTo(size.width * 0.22, size.height * 0.44);
    northAmerica.lineTo(size.width * 0.18, size.height * 0.46);
    northAmerica.lineTo(size.width * 0.15, size.height * 0.43);
    northAmerica.lineTo(size.width * 0.12, size.height * 0.38);
    northAmerica.lineTo(size.width * 0.08, size.height * 0.32);
    northAmerica.lineTo(size.width * 0.06, size.height * 0.28);
    northAmerica.close();
    canvas.drawPath(northAmerica, landPaint);
    canvas.drawPath(northAmerica, landStroke);

    // Europe (simplified)
    final europe = Path();
    europe.moveTo(size.width * 0.48, size.height * 0.18);
    europe.lineTo(size.width * 0.52, size.height * 0.15);
    europe.lineTo(size.width * 0.58, size.height * 0.14);
    europe.lineTo(size.width * 0.64, size.height * 0.16);
    europe.lineTo(size.width * 0.66, size.height * 0.20);
    europe.lineTo(size.width * 0.62, size.height * 0.26);
    europe.lineTo(size.width * 0.58, size.height * 0.30);
    europe.lineTo(size.width * 0.54, size.height * 0.32);
    europe.lineTo(size.width * 0.50, size.height * 0.30);
    europe.lineTo(size.width * 0.47, size.height * 0.26);
    europe.lineTo(size.width * 0.46, size.height * 0.22);
    europe.close();
    canvas.drawPath(europe, landPaint);
    canvas.drawPath(europe, landStroke);

    // Africa (simplified)
    final africa = Path();
    africa.moveTo(size.width * 0.50, size.height * 0.38);
    africa.lineTo(size.width * 0.54, size.height * 0.36);
    africa.lineTo(size.width * 0.60, size.height * 0.38);
    africa.lineTo(size.width * 0.62, size.height * 0.44);
    africa.lineTo(size.width * 0.64, size.height * 0.52);
    africa.lineTo(size.width * 0.62, size.height * 0.60);
    africa.lineTo(size.width * 0.58, size.height * 0.68);
    africa.lineTo(size.width * 0.55, size.height * 0.72);
    africa.lineTo(size.width * 0.52, size.height * 0.68);
    africa.lineTo(size.width * 0.50, size.height * 0.60);
    africa.lineTo(size.width * 0.48, size.height * 0.50);
    africa.lineTo(size.width * 0.49, size.height * 0.44);
    africa.close();
    canvas.drawPath(africa, landPaint);
    canvas.drawPath(africa, landStroke);

    // South America (simplified)
    final southAmerica = Path();
    southAmerica.moveTo(size.width * 0.22, size.height * 0.48);
    southAmerica.lineTo(size.width * 0.26, size.height * 0.46);
    southAmerica.lineTo(size.width * 0.30, size.height * 0.48);
    southAmerica.lineTo(size.width * 0.32, size.height * 0.54);
    southAmerica.lineTo(size.width * 0.30, size.height * 0.62);
    southAmerica.lineTo(size.width * 0.28, size.height * 0.70);
    southAmerica.lineTo(size.width * 0.24, size.height * 0.76);
    southAmerica.lineTo(size.width * 0.22, size.height * 0.72);
    southAmerica.lineTo(size.width * 0.20, size.height * 0.64);
    southAmerica.lineTo(size.width * 0.18, size.height * 0.56);
    southAmerica.lineTo(size.width * 0.20, size.height * 0.50);
    southAmerica.close();
    canvas.drawPath(southAmerica, landPaint);
    canvas.drawPath(southAmerica, landStroke);

    // Asia (simplified, right side)
    final asia = Path();
    asia.moveTo(size.width * 0.66, size.height * 0.16);
    asia.lineTo(size.width * 0.72, size.height * 0.14);
    asia.lineTo(size.width * 0.80, size.height * 0.16);
    asia.lineTo(size.width * 0.88, size.height * 0.18);
    asia.lineTo(size.width * 0.92, size.height * 0.22);
    asia.lineTo(size.width * 0.90, size.height * 0.30);
    asia.lineTo(size.width * 0.86, size.height * 0.36);
    asia.lineTo(size.width * 0.82, size.height * 0.40);
    asia.lineTo(size.width * 0.76, size.height * 0.42);
    asia.lineTo(size.width * 0.70, size.height * 0.38);
    asia.lineTo(size.width * 0.66, size.height * 0.34);
    asia.lineTo(size.width * 0.64, size.height * 0.28);
    asia.lineTo(size.width * 0.64, size.height * 0.22);
    asia.close();
    canvas.drawPath(asia, landPaint);
    canvas.drawPath(asia, landStroke);

    // Australia (simplified)
    final australia = Path();
    australia.moveTo(size.width * 0.80, size.height * 0.58);
    australia.lineTo(size.width * 0.86, size.height * 0.56);
    australia.lineTo(size.width * 0.92, size.height * 0.58);
    australia.lineTo(size.width * 0.94, size.height * 0.64);
    australia.lineTo(size.width * 0.90, size.height * 0.70);
    australia.lineTo(size.width * 0.84, size.height * 0.72);
    australia.lineTo(size.width * 0.80, size.height * 0.68);
    australia.lineTo(size.width * 0.78, size.height * 0.62);
    australia.close();
    canvas.drawPath(australia, landPaint);
    canvas.drawPath(australia, landStroke);
  }

  void _drawFlightPath(Canvas canvas, Size size) {
    // LHR position (London) and JFK position (New York)
    final lhrX = size.width * 0.50;
    final lhrY = size.height * 0.25;
    final jfkX = size.width * 0.22;
    final jfkY = size.height * 0.30;

    // Great-circle arc (approximation via quadratic bezier)
    final controlX = (lhrX + jfkX) / 2;
    final controlY = min(lhrY, jfkY) - size.height * 0.10;

    // Dashed flight path
    final pathPaint = Paint()
      ..color = const Color(0xFFFFC229).withOpacity(0.4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(lhrX, lhrY);
    path.quadraticBezierTo(controlX, controlY, jfkX, jfkY);

    // Draw dashed path
    _drawDashedPath(canvas, path, pathPaint, dashLength: 8, gapLength: 6);

    // Glow effect on path
    final glowPaint = Paint()
      ..color = const Color(0xFFFFC229).withOpacity(0.08)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glowPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint,
      {double dashLength = 10, double gapLength = 5}) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = min(distance + dashLength, metric.length);
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  void _drawPlaneDot(Canvas canvas, Size size) {
    // LHR and JFK positions
    final lhrX = size.width * 0.50;
    final lhrY = size.height * 0.25;
    final jfkX = size.width * 0.22;
    final jfkY = size.height * 0.30;

    final controlX = (lhrX + jfkX) / 2;
    final controlY = min(lhrY, jfkY) - size.height * 0.10;

    // Position along bezier path
    final t = planeAnimation.value;
    final planeX = _bezierPoint(lhrX, controlX, jfkX, t);
    final planeY = _bezierPoint(lhrY, controlY, jfkY, t);

    // Pulsing glow around the plane position
    final pulseRadius = 12.0 + (pulseAnimation.value * 8.0);
    final glowPaint = Paint()
      ..color = const Color(0xFFFFC229).withOpacity(0.15 * pulseAnimation.value)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(planeX, planeY), pulseRadius, glowPaint);

    // Solid plane dot
    final dotPaint = Paint()
      ..color = const Color(0xFFFFC229)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(planeX, planeY), 5.0, dotPaint);

    // White core
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(planeX, planeY), 2.0, corePaint);

    // Draw tiny plane icon using path
    _drawPlaneIcon(canvas, planeX, planeY, t, lhrX, lhrY, controlX, controlY, jfkX, jfkY);
  }

  void _drawPlaneIcon(Canvas canvas, double px, double py, double t,
      double x0, double y0, double cx, double cy, double x1, double y1) {
    // Calculate tangent angle for rotation
    final dx = _bezierTangent(x0, cx, x1, t);
    final dy = _bezierTangent(y0, cy, y1, t);
    final angle = atan2(dy, dx);

    canvas.save();
    canvas.translate(px, py - 18);
    canvas.rotate(angle);

    // Small plane triangle
    final planePath = Path();
    planePath.moveTo(0, -6);
    planePath.lineTo(-4, 4);
    planePath.lineTo(0, 2);
    planePath.lineTo(4, 4);
    planePath.close();

    final planePaint = Paint()
      ..color = const Color(0xFFFFC229)
      ..style = PaintingStyle.fill;
    canvas.drawPath(planePath, planePaint);

    canvas.restore();
  }

  double _bezierPoint(double p0, double p1, double p2, double t) {
    return (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2;
  }

  double _bezierTangent(double p0, double p1, double p2, double t) {
    return 2 * (1 - t) * (p1 - p0) + 2 * t * (p2 - p1);
  }

  void _drawAirportMarkers(Canvas canvas, Size size) {
    // LHR marker
    _drawMarker(canvas, size.width * 0.50, size.height * 0.25, 'LHR');
    // JFK marker
    _drawMarker(canvas, size.width * 0.22, size.height * 0.30, 'JFK');
  }

  void _drawMarker(Canvas canvas, double x, double y, String label) {
    // Outer ring
    final outerRing = Paint()
      ..color = const Color(0xFFFFC229).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(x, y), 10, outerRing);

    // Inner dot
    final innerDot = Paint()
      ..color = const Color(0xFFFFC229).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 4, innerDot);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y + 14));
  }

  void _drawVignette(Canvas canvas, Size size) {
    final vignetteRect = Offset.zero & size;
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Colors.transparent,
          const Color(0xFF040E1F).withOpacity(0.7),
        ],
        stops: const [0.5, 1.0],
      ).createShader(vignetteRect);
    canvas.drawRect(vignetteRect, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _DarkMapPainter oldDelegate) => true;
}
