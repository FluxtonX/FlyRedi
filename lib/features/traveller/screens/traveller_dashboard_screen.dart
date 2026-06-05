import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/add_flight_card.dart';
import '../widgets/sentinel_monitoring_section.dart';
import '../widgets/border_ready_section.dart';
import '../widgets/recommended_actions_card.dart';
import '../widgets/active_issues_section.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../widgets/dashboard_modules_grid.dart';
import '../widgets/dashboard_activity_list.dart';
import '../repositories/dashboard_repository.dart';
import '../models/dashboard_summary.dart';
import '../models/dashboard_activity.dart';
import '../models/dashboard_module.dart';

class TravellerDashboardScreen extends StatefulWidget {
  const TravellerDashboardScreen({super.key});

  @override
  State<TravellerDashboardScreen> createState() =>
      _TravellerDashboardScreenState();
}

class _TravellerDashboardScreenState extends State<TravellerDashboardScreen> {
  final DashboardRepository _repository = DashboardRepository();
  bool _isLoading = true;
  String? _errorMessage;

  DashboardSummary? _summary;
  List<DashboardActivity> _activities = [];
  List<DashboardModule> _modules = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _repository.getSummary(),
        _repository.getActivities(),
        _repository.getModules(),
      ]);

      if (mounted) {
        setState(() {
          _summary = results[0] as DashboardSummary;
          _activities = results[1] as List<DashboardActivity>;
          _modules = results[2] as List<DashboardModule>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
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
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'Traveller';

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
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 0),
    );
  }

  Widget _buildBody(String displayName) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading dashboard data...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
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
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC229),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          const SizedBox(height: 28),
          const AddFlightCard(),
          const SizedBox(height: 32),
          SentinelMonitoringSection(
            alertsCount: summary.alertsCount,
            casesCount: summary.casesCount,
            totalSavings: summary.totalSavings,
          ),
          const SizedBox(height: 32),
          const BorderReadySection(),
          const SizedBox(height: 32),
          if (_modules.isNotEmpty) ...[
            DashboardModulesGrid(modules: _modules),
            const SizedBox(height: 32),
          ],
          if (_activities.isNotEmpty) ...[
            DashboardActivityList(activities: _activities),
            const SizedBox(height: 32),
          ],
          const RecommendedActionsCard(),
          const SizedBox(height: 32),
          const ActiveIssuesSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
