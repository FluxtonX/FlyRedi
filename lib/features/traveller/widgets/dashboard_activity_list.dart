import 'package:flutter/material.dart';
import '../models/dashboard_activity.dart';
import '../screens/trips_overview_screen.dart';
import '../screens/expense_tracker_screen.dart';
import '../screens/notifications_screen.dart';

class DashboardActivityList extends StatelessWidget {
  final List<DashboardActivity> activities;

  const DashboardActivityList({
    super.key,
    required this.activities,
  });

  IconData _getIcon(String type) {
    switch (type) {
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'claim':
        return Icons.gavel_outlined;
      case 'expense':
        return Icons.receipt_long_outlined;
      case 'trip':
        return Icons.flight_takeoff_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getColor(BuildContext context, String type) {
    switch (type) {
      case 'alert':
        return const Color(0xFFE11D48); // Rose
      case 'claim':
        return const Color(0xFFFFC229); // Amber
      case 'expense':
        return const Color(0xFF10B981); // Emerald
      case 'trip':
        return const Color(0xFF3B82F6); // Blue
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.54);
    }
  }

  void _onTapActivity(BuildContext context, DashboardActivity activity) {
    Widget? target;
    switch (activity.type) {
      case 'alert':
        target = const NotificationsScreen();
        break;
      case 'claim':
      case 'trip':
        target = const TripsOverviewScreen();
        break;
      case 'expense':
        target = const ExpenseTrackerScreen();
        break;
    }

    if (target != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => target!),
      );
    }
  }

  String _formatTime(String rawDate) {
    try {
      final date = DateTime.parse(rawDate).toLocal();
      final difference = DateTime.now().difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (_) {
      return '';
    }
  }

  bool _hasReadableText(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'unknown' &&
        normalized != '--' &&
        normalized != 'unknown → unknown' &&
        normalized != 'unknown - unknown';
  }

  String _activityTitle(DashboardActivity activity) {
    if (_hasReadableText(activity.title)) return activity.title;
    return activity.type == 'trip' ? 'Trip added' : 'Activity';
  }

  String _activitySubtitle(DashboardActivity activity) {
    if (_hasReadableText(activity.subtitle)) return activity.subtitle;
    return activity.type == 'trip' ? 'Trip saved' : '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (activities.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
                child: Text(
                  'View all',
                  style: TextStyle(
                    color: Color(0xFFFFC229),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 14),
        if (activities.isEmpty)
          Container(
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history_outlined,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    size: 40,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No recent activity found.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => Divider(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                height: 1,
                indent: 64,
              ),
              itemBuilder: (context, index) {
                final activity = activities[index];
                final icon = _getIcon(activity.type);
                final color = _getColor(context, activity.type);
                final subtitle = _activitySubtitle(activity);

                return ListTile(
                  onTap: () => _onTapActivity(context, activity),
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    _activityTitle(activity),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: subtitle.isEmpty
                      ? null
                      : Text(
                          subtitle,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                            fontSize: 14,
                          ),
                    ),
                  trailing: Text(
                    _formatTime(activity.createdAt),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
