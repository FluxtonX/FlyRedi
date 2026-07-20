import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../models/trip_model.dart';
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
import '../presentation/providers/trips_provider.dart';
import '../presentation/providers/alert_provider.dart';
import '../presentation/providers/claim_provider.dart';
import '../presentation/providers/dashboard_provider.dart';
import '../presentation/providers/profile_provider.dart';
import '../utils/add_flight_navigation.dart';
import 'plan_usage_screen.dart';

class TravellerDashboardFreeScreen extends StatefulWidget {
  final bool showBottomNav;

  const TravellerDashboardFreeScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<TravellerDashboardFreeScreen> createState() =>
      _TravellerDashboardFreeScreenState();
}

class _TravellerDashboardFreeScreenState
    extends State<TravellerDashboardFreeScreen> {
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final uid = auth.user?.id;
    if (uid == null) return;

    try {
      await Future.wait([
        context.read<DashboardProvider>().loadDashboard(),
        context.read<TripsProvider>().loadTrips(),
        context.read<ProfileProvider>().loadStats(uid),
      ]);
    } catch (e) {
      if (mounted && !_isFirstLoad) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update dashboard: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFirstLoad = false;
        });
      }
    }
  }

  Future<void> _handleAddFlightTap() async {
    final tripsProvider = context.read<TripsProvider>();
    final auth = context.read<AuthProvider>();

    await openAddFlightWithLimit(
      context: context,
      currentTrips: tripsProvider.trips.length,
      hasUnlimitedFlights: auth.user?.hasUnlimitedFlightMonitoring ?? false,
      onReturn: () async {
        if (!mounted) return;
        await _loadDashboardData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final displayName = auth.user?.displayName ?? 'Traveller';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: const Color(0xFFFFC229),
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: _buildBody(displayName),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? const TravellerBottomNav(activeIndex: 0)
          : null,
    );
  }

  Widget _buildBody(String displayName) {
    final dashboard = context.watch<DashboardProvider>();
    final tripsProvider = context.watch<TripsProvider>();
    final alertProvider = context.watch<AlertProvider>();
    final profile = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();

    final planLabel = _planLabel(auth.user?.plan);
    final isFree = planLabel.contains('Free');

    final summary = dashboard.summary;
    final stats = profile.stats;
    final trips = tripsProvider.trips;
    final alerts = alertProvider.alerts;

    // Check loading states
    final isSummaryLoading = dashboard.isLoading && _isFirstLoad;
    final isAlertsLoading = alertProvider.isLoading && _isFirstLoad;
    final isTripsLoading = tripsProvider.isLoading && _isFirstLoad;
    final isProfileLoading = auth.isLoading && _isFirstLoad;
    final isStatsLoading = profile.isLoading && _isFirstLoad;

    if (dashboard.state == DashboardState.error && _isFirstLoad) {
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
              Text(
                'Something went wrong',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dashboard.errorMessage ?? 'Failed to load dashboard data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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

    final usedFlights = stats?.flightsMonitored ?? trips.length;
    final maxFlights = isFree ? freeFlightLimit : (stats?.flightsMonitoredMax ?? freeFlightLimit);
    final usedClaims = stats?.claimsFiled ?? (summary?.casesCount ?? 0);
    final maxClaims = isFree ? 1 : (stats?.claimsFiledMax ?? 1);
    final usedAiQuestions = stats?.aiAssistantQuestions ?? 0;
    final maxAiQuestions = isFree ? 5 : (stats?.aiAssistantQuestionsMax ?? 5);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardHeader(
            displayName: displayName,
            planLabel: isProfileLoading ? 'Free Plan' : planLabel,
            notificationCount: alertProvider.unreadCount,
          ),
          _buildAlertBanner(usedClaims >= maxClaims && planLabel.contains('Free')),
          const SizedBox(height: 18),
          if (isStatsLoading || isProfileLoading || isTripsLoading || isSummaryLoading)
            const SkeletonBox(height: 128, radius: 22)
          else
            MonthlyUsageCard(
              usedFlights: usedFlights,
              maxFlights: maxFlights,
              usedClaims: usedClaims,
              maxClaims: maxClaims,
              usedAiQuestions: usedAiQuestions,
              maxAiQuestions: maxAiQuestions,
              onViewDetails: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlanUsageScreen(),
                  ),
                );
              },
              onLimitTap: () async {
                final upgraded = await showUpgradeToProDialog(context);
                if (upgraded == true && mounted) {
                  _loadDashboardData();
                }
              },
            ),
          const SizedBox(height: 18),
          if (isTripsLoading)
            const SkeletonBox(height: 82, radius: 20)
          else
            AddFlightCard(
              usedFlights: trips.length,
              maxFlights: freeFlightLimit,
              onTap: _handleAddFlightTap,
            ),
          const SizedBox(height: 24),
          if (isSummaryLoading)
            const SkeletonBox(height: 190, radius: 28)
          else
            SentinelMonitoringSection(
              alertsCount: summary?.alertsCount ?? 0,
              delayRisk: (summary?.alertsCount ?? 0) > 0 ? '68%' : '12%',
              monitoredCount: trips.where((t) => t.trackingEnabled).length,
              activeTrip: trips.cast<TripModel?>().firstWhere((t) => t != null && t.trackingEnabled, orElse: () => null),
              onUpgrade: () async {
                final upgraded = await showUpgradeToProDialog(context);
                if (upgraded == true && mounted) {
                  _loadDashboardData();
                }
              },
            ),
          const SizedBox(height: 24),
          if (dashboard.isLoading && _isFirstLoad) ...[
            Row(
              children: [
                const SkeletonBox(width: 54, height: 54, radius: 18),
                const SizedBox(width: 16),
                Expanded(child: const SkeletonBox(height: 42, radius: 14)),
              ],
            ),
            const SizedBox(height: 24),
            const SkeletonBox(height: 220, radius: 28),
          ] else ...[
            BorderReadySection(
              activeTrip: trips.cast<TripModel?>().firstWhere((t) => t != null && t.trackingEnabled, orElse: () => null) ?? 
                  (trips.isNotEmpty ? trips.first : null),
            ),
          ],
          const SizedBox(height: 24),
          if (isSummaryLoading)
            const SkeletonBox(height: 140, radius: 24)
          else ...[
            RecommendedActionsCard(
              isEmpty: (summary?.alertsCount ?? 0) == 0 && (summary?.casesCount ?? 0) == 0,
            ),
            const SizedBox(height: 24),
            ActiveIssuesSection(
              isEmpty: (summary?.alertsCount ?? 0) == 0 && (summary?.casesCount ?? 0) == 0,
            ),
          ],
          const SizedBox(height: 24),
          if (isAlertsLoading)
            const SkeletonBox(height: 140, radius: 24)
          else
            DashboardNotificationsSection(alerts: alerts),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _planLabel(String? plan) {
    if (plan == null || plan.trim().isEmpty) return 'Free Plan';
    return plan.endsWith('Plan') || plan.endsWith('Pass') ? plan : '$plan Plan';
  }

  Widget _buildAlertBanner(bool showBanner) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      child: !showBanner
          ? const SizedBox.shrink()
          : Container(
              margin: const EdgeInsets.only(top: 18),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.error, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "ALERT: Your claim for Flight BA 082 has updated to 'PENDING'. Action required.",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () async {
                      final upgraded = await showUpgradeToProDialog(context);
                      if (upgraded == true && mounted) {
                        _loadDashboardData();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                      ),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 18),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
