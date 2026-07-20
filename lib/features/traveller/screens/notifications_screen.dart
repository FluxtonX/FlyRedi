import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../models/alert_model.dart';
import '../presentation/providers/alert_provider.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../widgets/notification_card.dart';
import 'resolution_workflow_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0; // 0: Alerts, 1: New & Updates
  int _selectedFilterIndex = 0; // 0: All, 1: Critical, 2: High, 3: Medium, 4: Low

  final List<String> _filters = const ['All', 'Critical', 'High', 'Medium', 'Low'];

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();
    final isLoading = alertProvider.isLoading && alertProvider.alerts.isEmpty;
    final errorMessage = alertProvider.errorMessage;

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC229)))
            : errorMessage != null && alertProvider.alerts.isEmpty
                ? _buildErrorState(errorMessage)
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(alertProvider),
                        const SizedBox(height: 28),
                        _buildStatCards(alertProvider),
                        const SizedBox(height: 28),
                        _buildTabSelector(alertProvider),
                        const SizedBox(height: 24),
                        if (_selectedTab == 0) ...[
                          _buildFilterBar(),
                          const SizedBox(height: 24),
                        ],
                        _buildPublishButton(alertProvider),
                        const SizedBox(height: 8),
                        _buildBody(alertProvider),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: const TravellerBottomNav(),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load alerts:\n$error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Real-time listener will auto-restart when initialized
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AlertProvider alertProvider) {
    final unreadCount = alertProvider.unreadCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time disruption detection and\nmonitoring',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (unreadCount > 0)
          TextButton(
            onPressed: () => alertProvider.markAllAsRead(),
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Color(0xFFFFC229), fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCards(AlertProvider alertProvider) {
    int countBySeverity(String severity) =>
        alertProvider.alerts.where((a) => a.priority.toUpperCase() == severity.toUpperCase()).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: '${countBySeverity('CRITICAL')}',
            label: 'Critical',
            borderColor: const Color(0xFFE11D48),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            value: '${countBySeverity('HIGH')}',
            label: 'High',
            borderColor: const Color(0xFFFFC229).withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            value: '${alertProvider.unreadCount}',
            label: 'Unread',
            borderColor: const Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color borderColor,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(AlertProvider alertProvider) {
    final unreadCount = alertProvider.unreadCount;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? const Color(0xFF1D4ED8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: _selectedTab == 0 ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Alerts',
                      style: TextStyle(
                        color: _selectedTab == 0 ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (unreadCount > 0)
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFC229),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? const Color(0xFF1D4ED8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  'New & Updates',
                  style: TextStyle(
                    color: _selectedTab == 1 ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (index) {
            final isSelected = index == _selectedFilterIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1D4ED8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPublishButton(AlertProvider alertProvider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 28),
      child: OutlinedButton.icon(
        onPressed: () async {
          // Dev-only feature, can use AlertProvider helper if implemented.
          // Since it's for demo, we'll notify users.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Demo feature: Alert added locally in Firestore console.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFFFC229)),
              ),
            ),
          );
        },
        icon: const Icon(Icons.bug_report_outlined, color: Color(0xFFFFC229), size: 18),
        label: const Text(
          'Publish New Update',
          style: TextStyle(
            color: Color(0xFFFFC229),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFFFFC229), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget _buildBody(AlertProvider alertProvider) {
    if (_selectedTab == 1) {
      return _buildEmptyState('No updates yet');
    }

    final filtered = alertProvider.getByPriority(_filters[_selectedFilterIndex]);
    if (filtered.isEmpty) {
      return _buildEmptyState('No alerts yet');
    }

    return Column(
      children: filtered.map((alert) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildAlertCard(alert, alertProvider),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Column(
      children: [
        const SizedBox(height: 48),
        Center(
          child: Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
      AlertModel alert, AlertProvider alertProvider) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48), size: 22),
            SizedBox(width: 10),
            Text(
              'Delete Notification',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this notification? This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.54),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx, true);
              await alertProvider.deleteAlert(alert.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(AlertModel alert, AlertProvider alertProvider) {
    final priorityMeta = _getPriorityMeta(alert.priority);

    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFE11D48).withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE11D48).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(
              Icons.delete_forever_rounded,
              color: Color(0xFFE11D48),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                color: const Color(0xFFE11D48),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog(alert, alertProvider);
      },
      child: Opacity(
        opacity: alert.isRead ? 0.65 : 1.0,
        child: NotificationCard(
          mainIcon: priorityMeta['icon'] as IconData,
          mainIconColor: priorityMeta['color'] as Color,
          flightCode: alert.flightCode.isNotEmpty ? alert.flightCode : 'ALERT',
          severityText: alert.severityLabel,
          severityColor: priorityMeta['color'] as Color,
          timeAgo: _formatTime(alert.createdAt),
          airline: alert.airline.isNotEmpty ? alert.airline : 'System',
          issueIcon: _getEventIcon(alert.eventType),
          issueTitle: alert.eventType,
          issueDescription: alert.message,
          rightsDescription: _getRightsText(alert.priority, alert.eventType),
          onMarkRead: alert.isRead
              ? null
              : () => alertProvider.markAsRead(alert.id),
          onStartResolution: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResolutionWorkflowScreen(alert: alert),
              ),
            );
          },
        ),
      ),
    );
  }

  Map<String, dynamic> _getPriorityMeta(String priority) {
    switch (priority.toUpperCase()) {
      case 'CRITICAL':
        return {
          'icon': Icons.warning_amber_rounded,
          'color': const Color(0xFFE11D48),
        };
      case 'HIGH':
        return {
          'icon': Icons.access_time_filled,
          'color': const Color(0xFFFFC229),
        };
      case 'MEDIUM':
        return {
          'icon': Icons.info_outline,
          'color': const Color(0xFF3B82F6),
        };
      case 'LOW':
        return {
          'icon': Icons.check_circle_outline,
          'color': const Color(0xFF9CA3AF),
        };
      default:
        return {
          'icon': Icons.notifications_none,
          'color': const Color(0xFF6B7280),
        };
    }
  }

  IconData _getEventIcon(String eventType) {
    final t = eventType.toLowerCase();
    if (t.contains('cancel')) return Icons.airplanemode_inactive;
    if (t.contains('delay')) return Icons.flight_takeoff;
    if (t.contains('gate')) return Icons.meeting_room;
    if (t.contains('baggage') || t.contains('luggage')) return Icons.luggage;
    if (t.contains('monitor')) return Icons.radar;
    return Icons.notifications_none;
  }

  String _getRightsText(String priority, String eventType) {
    final t = eventType.toLowerCase();
    if (t.contains('cancel')) {
      return 'You are entitled to a full refund or rebooking on the next available flight.';
    }
    if (t.contains('delay')) {
      return 'Delays over 2 hours entitle you to refreshments and potentially compensation.';
    }
    if (t.contains('gate')) return 'Gate changes are informational only.';
    if (t.contains('baggage')) {
      return 'You may claim emergency supplies reimbursement for delayed baggage.';
    }
    return 'Contact the airline for your passenger rights.';
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}
