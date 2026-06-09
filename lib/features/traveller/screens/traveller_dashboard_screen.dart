import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/add_flight_card.dart';
import '../widgets/monthly_usage_card.dart';
import '../widgets/sentinel_monitoring_section.dart';
import '../widgets/border_ready_section.dart';
import '../widgets/recommended_actions_card.dart';
import '../widgets/active_issues_section.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../widgets/dashboard_activity_list.dart';
import '../widgets/dashboard_notifications_section.dart';
import '../widgets/upgrade_to_pro_dialog.dart';
import '../widgets/skeleton_box.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/alert_repository.dart';
import '../models/dashboard_summary.dart';
import '../models/dashboard_activity.dart';
import '../models/alert_model.dart';
import 'plan_usage_screen.dart';

class TravellerDashboardScreen extends StatefulWidget {
  final bool showBottomNav;

  const TravellerDashboardScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<TravellerDashboardScreen> createState() =>
      _TravellerDashboardScreenState();
}

class _TravellerDashboardScreenState extends State<TravellerDashboardScreen> {
  final DashboardRepository _repository = DashboardRepository();
  final AlertRepository _alertRepository = AlertRepository();
  bool _isLoading = true;
  bool _hasLoadedData = false;
  String? _errorMessage;

  DashboardSummary? _summary;
  List<DashboardActivity> _activities = [];
  List<AlertModel> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = !_hasLoadedData;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _repository.getSummary(),
        _repository.getActivities(),
        _alertRepository.fetchAlerts(limit: 5),
      ]);

      if (mounted) {
        setState(() {
          _summary = results[0] as DashboardSummary;
          _activities = results[1] as List<DashboardActivity>;
          _alerts = (results[2] as AlertListResponse).alerts;
          _isLoading = false;
          _hasLoadedData = true;
        });
      }
    } catch (e) {
      if (mounted) {
        if (_hasLoadedData) {
          setState(() {
            _errorMessage = null;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not refresh dashboard data.'),
              backgroundColor: Color(0xFFE11D48),
            ),
          );
          return;
        }
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? 'Traveller';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: const Color(0xFFFFC229),
          backgroundColor: const Color(0xFF10284F),
          child: _buildBody(displayName),
        ),
      ),
      bottomNavigationBar:
          widget.showBottomNav ? const TravellerBottomNav(activeIndex: 0) : null,
    );
  }

  Widget _buildBody(String displayName) {
    if (_isLoading) {
      return _buildDashboardSkeleton(displayName);
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE11D48),
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh_rounded, color: Colors.black),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC229),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final summary = _summary!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardHeader(
            displayName: displayName,
            notificationCount: summary.alertsCount,
          ),
          const SizedBox(height: 18),
          MonthlyUsageCard(
            onViewDetails: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlanUsageScreen(),
                ),
              );
            },
            onLimitTap: () => showUpgradeToProDialog(context),
          ),
          const SizedBox(height: 18),
          AddFlightCard(
            onTap: () => showUpgradeToProDialog(context),
          ),
          const SizedBox(height: 24),
          SentinelMonitoringSection(
            alertsCount: summary.alertsCount,
            casesCount: summary.casesCount,
            totalSavings: summary.totalSavings,
            onUpgrade: () => showUpgradeToProDialog(context),
          ),
          const SizedBox(height: 24),
          BorderReadySection(isEmpty: _activities.isEmpty),
          const SizedBox(height: 24),
          if (_activities.isNotEmpty) ...[
            DashboardActivityList(activities: _activities),
            const SizedBox(height: 32),
          ],
          RecommendedActionsCard(
            isEmpty: summary.alertsCount == 0 && summary.casesCount == 0,
            onUpgrade: () => showUpgradeToProDialog(context),
          ),
          const SizedBox(height: 24),
          ActiveIssuesSection(
            isEmpty: summary.alertsCount == 0 && summary.casesCount == 0,
          ),
          const SizedBox(height: 24),
          DashboardNotificationsSection(alerts: _alerts),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDashboardSkeleton(String displayName) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardHeader(displayName: displayName, notificationCount: 0),
          const SizedBox(height: 18),
          const SkeletonBox(height: 128, radius: 22),
          const SizedBox(height: 18),
          const SkeletonBox(height: 82, radius: 20),
          const SizedBox(height: 24),
          Row(
            children: const [
              SkeletonBox(width: 54, height: 54, radius: 18),
              SizedBox(width: 16),
              Expanded(child: SkeletonBox(height: 42, radius: 14)),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonBox(height: 190, radius: 28),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 112, radius: 24)),
              SizedBox(width: 18),
              Expanded(child: SkeletonBox(height: 112, radius: 24)),
              SizedBox(width: 18),
              Expanded(child: SkeletonBox(height: 112, radius: 24)),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonBox(height: 220, radius: 28),
          const SizedBox(height: 24),
          const SkeletonBox(height: 140, radius: 24),
        ],
      ),
    );
  }
}
