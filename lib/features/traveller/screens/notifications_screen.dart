import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../models/alert_model.dart';
import '../repositories/alert_repository.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AlertRepository _repository = AlertRepository();

  int _selectedTab = 0; // 0: Alerts, 1: New & Updates
  int _selectedFilterIndex = 0; // 0: All, 1: Critical, 2: High, 3: Medium, 4: Low

  bool _isLoading = true;
  String? _errorMessage;
  List<AlertModel> _alerts = [];

  final List<String> _filters = const ['All', 'Critical', 'High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _repository.fetchAlerts();
      setState(() {
        _alerts = result.alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _repository.markAllAsRead();
      setState(() {
        _alerts = _alerts.map((a) {
          return AlertModel(
            id: a.id,
            userId: a.userId,
            flightCode: a.flightCode,
            airline: a.airline,
            priority: a.priority,
            eventType: a.eventType,
            message: a.message,
            isRead: true,
            source: a.source,
            guardId: a.guardId,
            createdAt: a.createdAt,
          );
        }).toList();
      });
    } catch (_) {}
  }

  List<AlertModel> get _filteredAlerts {
    List<AlertModel> base =
        _selectedTab == 0 ? _alerts.where((a) => a.priority != 'INFO').toList() : _alerts;

    if (_selectedFilterIndex == 0) return base;

    final filterMap = {1: 'CRITICAL', 2: 'HIGH', 3: 'MEDIUM', 4: 'LOW'};
    final target = filterMap[_selectedFilterIndex] ?? '';
    return base.where((a) => a.priority.toUpperCase() == target).toList();
  }

  int _countBySeverity(String severity) =>
      _alerts.where((a) => a.priority.toUpperCase() == severity).length;

  int get _unreadCount => _alerts.where((a) => !a.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFC229)))
            : _errorMessage != null
                ? _buildErrorState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 28),
                        _buildStatCards(),
                        const SizedBox(height: 28),
                        _buildTabSelector(),
                        const SizedBox(height: 24),
                        if (_selectedTab == 0) ...[
                          _buildFilterBar(),
                          const SizedBox(height: 24),
                        ],
                        _buildPublishButton(),
                        const SizedBox(height: 8),
                        _buildBody(),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: const TravellerBottomNav(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load alerts:\n$_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAlerts,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Real-time disruption detection and\nmonitoring',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (_unreadCount > 0)
          TextButton(
            onPressed: _markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Color(0xFFFFC229), fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: '${_countBySeverity('CRITICAL')}',
            label: 'Critical',
            borderColor: const Color(0xFFE11D48),
            backgroundColor: const Color(0xFF2B161E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            value: '${_countBySeverity('HIGH')}',
            label: 'High',
            borderColor: const Color(0xFFFFC229).withOpacity(0.8),
            backgroundColor: const Color(0xFF2A2416),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            value: '$_unreadCount',
            label: 'Unread',
            borderColor: const Color(0xFF2563EB),
            backgroundColor: const Color(0xFF16203A),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color borderColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF101B30),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Alerts tab
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
                      color:
                          _selectedTab == 0 ? Colors.white : Colors.white54,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Alerts',
                      style: TextStyle(
                        color: _selectedTab == 0
                            ? Colors.white
                            : Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (_unreadCount > 0)
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFC229),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _unreadCount > 9 ? '9+' : '$_unreadCount',
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
          // Updates tab
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
                    color:
                        _selectedTab == 1 ? Colors.white : Colors.white54,
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
        color: const Color(0xFF101B30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (index) {
            final isSelected = index == _selectedFilterIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                    color: isSelected ? Colors.white : Colors.white54,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPublishButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 28),
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Updates publishing form initiated.',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF0C162A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
          );
        },
        icon: const Icon(Icons.campaign_outlined,
            color: Color(0xFFFFC229), size: 18),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedTab == 1) {
      return _buildEmptyState('No updates yet');
    }

    final filtered = _filteredAlerts;
    if (filtered.isEmpty) {
      return _buildEmptyState('No alerts yet');
    }

    return Column(
      children: filtered.map((alert) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildAlertCard(alert),
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
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildAlertCard(AlertModel alert) {
    final priorityMeta = _getPriorityMeta(alert.priority);

    return Opacity(
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
            : () async {
                await _repository.markAsRead(alert.id);
                await _loadAlerts();
              },
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
