import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../core/logging/app_logger.dart';

/// Handles FCM foreground notification display.
/// Extracted from [main.dart] for separation of concerns.
class NotificationService {
  NotificationService._();

  /// Call once after Firebase is initialized.
  static void init(BuildContext Function() contextProvider) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.fcm('Foreground message received: ${message.notification?.title}');

      if (message.notification != null) {
        _showBanner(contextProvider(), message);
      }
    });

    AppLogger.fcm('NotificationService initialized');
  }

  static void _showBanner(BuildContext context, RemoteMessage message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _NotificationBanner(message: message),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 5), () => entry.remove());
  }
}

class _NotificationBanner extends StatelessWidget {
  final RemoteMessage message;
  const _NotificationBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.97),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.flight_takeoff, color: Color(0xFFFFC229), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.notification?.title != null)
                      Text(
                        message.notification!.title!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (message.notification?.body != null)
                      Text(
                        message.notification!.body!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
