import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Singleton service that manages all notifications in the app using FCM.
///
/// - Background / terminated push: FCM handles automatically.
/// - Foreground FCM push: shown as an in-app overlay banner.
/// - Client-side events (e.g. flight added): shown as an in-app overlay banner.
///
/// Call [init()] once from main() after Firebase is initialized.
/// Set [navigatorKey] on your [MaterialApp] for overlay support.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// Assign this to MaterialApp's navigatorKey.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // ── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    // Allow FCM to show notifications in foreground on iOS
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen to FCM messages while app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundFCM);
  }

  // ── FCM foreground handler ────────────────────────────────────────────────

  void _handleForegroundFCM(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _showOverlay(
      title: n.title ?? 'FlyRedi',
      body: n.body ?? '',
      icon: Icons.notifications_rounded,
      iconColor: const Color(0xFFFFC229),
    );
  }

  // ── Flight Added ──────────────────────────────────────────────────────────

  /// Shows an in-app overlay notification immediately when a flight is added.
  void showFlightAdded({
    required String flightNumber,
    required String origin,
    required String destination,
    required String departureDate,
  }) {
    _showOverlay(
      title: 'Flight $flightNumber Added ✈️',
      body: '$origin → $destination   •   $departureDate\nYour trip is now being tracked.',
      icon: Icons.flight_takeoff_rounded,
      iconColor: const Color(0xFFFFC229),
      duration: const Duration(seconds: 5),
    );
  }

  // ── Overlay engine ────────────────────────────────────────────────────────

  void _showOverlay({
    required String title,
    required String body,
    required IconData icon,
    required Color iconColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    final navigatorState = navigatorKey.currentState;
    if (navigatorState == null) return;

    final overlay = navigatorState.overlay;
    if (overlay == null) return;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (_) => _InAppNotificationBanner(
        title: title,
        body: body,
        icon: icon,
        iconColor: iconColor,
        duration: duration,
        onDismiss: () {
          entry?.remove();
          entry = null;
        },
      ),
    );

    overlay.insert(entry!);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// In-App Notification Banner Widget
// ─────────────────────────────────────────────────────────────────────────────

class _InAppNotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color iconColor;
  final Duration duration;
  final VoidCallback onDismiss;

  const _InAppNotificationBanner({
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<_InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Slide in
    _controller.forward();

    // Auto-dismiss after [duration]
    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final shadowColor =
        isDark ? Colors.black54 : Colors.black.withOpacity(0.12);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: GestureDetector(
            onTap: _dismiss,
            onVerticalDragEnd: (d) {
              if (d.primaryVelocity != null && d.primaryVelocity! < 0) {
                _dismiss();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.iconColor.withOpacity(0.25),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: widget.iconColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F0F23),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            if (widget.body.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                widget.body,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : const Color(0xFF6B6B7B),
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Dismiss X
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _dismiss,
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: isDark
                              ? Colors.white38
                              : Colors.black.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
