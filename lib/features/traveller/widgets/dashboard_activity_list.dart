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

  Color _getColor(String type) {
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
        return Colors.white54;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: Colors.white,
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
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: Color(0xFFFFC229),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (activities.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF10284F),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history_outlined,
                    color: Colors.white30,
                    size: 40,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No recent activity found.',
                    style: TextStyle(
                      color: Colors.white54,
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
              color: const Color(0xFF10284F),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withOpacity(0.06),
                height: 1,
                indent: 64,
              ),
              itemBuilder: (context, index) {
                final activity = activities[index];
                final icon = _getIcon(activity.type);
                final color = _getColor(activity.type);

                return ListTile(
                  onTap: () => _onTapActivity(context, activity),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
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
                    activity.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    activity.subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Text(
                    _formatTime(activity.createdAt),
                    style: const TextStyle(
                      color: Colors.white30,
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
