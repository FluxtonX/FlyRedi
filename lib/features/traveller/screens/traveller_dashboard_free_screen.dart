import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import 'package:sky_rightz_360/features/auth/presentation/controllers/auth_controller.dart';
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
import '../models/user_profile.dart';
import '../utils/add_flight_navigation.dart';
import 'plan_usage_screen.dart';
import '../repositories/trip_repository.dart';
import '../models/trip_model.dart';
import '../repositories/profile_repository.dart';

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
  final DashboardRepository _repository = DashboardRepository();
  final AlertRepository _alertRepository = AlertRepository();
  final TripRepository _tripRepository = TripRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  bool _isSummaryLoading = true;
  bool _isActivitiesLoading = true;
  bool _isAlertsLoading = true;
  bool _isTripsLoading = true;
  bool _isProfileLoading = true;
  bool _isStatsLoading = true;

  bool _hasLoadedData = false;
  String? _errorMessage;
  late final String _displayName;

  DashboardSummary? _summary;
  List<DashboardActivity> _activities = [];
  List<AlertModel> _alerts = [];
  List<TripModel> _trips = [];
  UserProfile? _profile;
  ProfileStats? _stats;

  bool get _anyDataLoaded =>
      _summary != null ||
      _activities.isNotEmpty ||
      _alerts.isNotEmpty ||
      _trips.isNotEmpty ||
      _profile != null ||
      _stats != null;

  @override
  void initState() {
    super.initState();
    // Cache user display name once — avoids FirebaseAuth lookup every rebuild
    final user = FirebaseAuth.instance.currentUser;
    _displayName =
        user?.displayName ?? user?.email?.split('@').first ?? 'Traveller';
    TripRepository.tripsVersion.addListener(_onTripsChanged);
    _loadDashboardData();
  }

  @override
  void dispose() {
    TripRepository.tripsVersion.removeListener(_onTripsChanged);
    super.dispose();
  }

  void _onTripsChanged() {
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _errorMessage = null;
      if (!_hasLoadedData) {
        _isSummaryLoading = true;
        _isActivitiesLoading = true;
        _isAlertsLoading = true;
        _isTripsLoading = true;
        _isProfileLoading = true;
        _isStatsLoading = true;
      }
    });

    // Load components progressively in parallel
    _loadSummary();
    _loadActivities();
    _loadAlerts();
    _loadTrips();
    _loadProfileAndStats();
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await _repository.getSummary(
        onCachedData: (cachedData) {
          if (mounted) {
            setState(() {
              _summary = cachedData;
              _isSummaryLoading = false;
              _checkAllLoaded();
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _summary = summary;
          _isSummaryLoading = false;
          _checkAllLoaded();
        });
      }
    } catch (e) {
      _handleLoadError(e);
      if (mounted) {
        setState(() {
          _isSummaryLoading = false;
          _checkAllLoaded();
        });
      }
    }
  }

  Future<void> _loadActivities() async {
    try {
      final activities = await _repository.getActivities(
        onCachedData: (cachedData) {
          if (mounted) {
            setState(() {
              _activities = cachedData;
              _isActivitiesLoading = false;
              _checkAllLoaded();
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _activities = activities;
          _isActivitiesLoading = false;
          _checkAllLoaded();
        });
      }
    } catch (e) {
      _handleLoadError(e);
      if (mounted) {
        setState(() {
          _isActivitiesLoading = false;
          _checkAllLoaded();
        });
      }
    }
  }

  Future<void> _loadAlerts() async {
    try {
      final response = await _alertRepository.fetchAlerts(limit: 5);
      if (mounted) {
        setState(() {
          _alerts = response.alerts;
          _isAlertsLoading = false;
          _checkAllLoaded();
        });
      }
    } catch (e) {
      _handleLoadError(e);
      if (mounted) {
        setState(() {
          _isAlertsLoading = false;
          _checkAllLoaded();
        });
      }
    }
  }

  Future<void> _loadTrips() async {
    try {
      final trips = await _tripRepository.fetchUserTrips(
        onCachedData: (cachedData) {
          if (mounted) {
            setState(() {
              _trips = cachedData;
              _isTripsLoading = false;
              _checkAllLoaded();
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _trips = trips;
          _isTripsLoading = false;
          _checkAllLoaded();
        });
      }
    } catch (e) {
      _handleLoadError(e);
      if (mounted) {
        setState(() {
          _isTripsLoading = false;
          _checkAllLoaded();
        });
      }
    }
  }

  Future<void> _loadProfileAndStats() async {
    try {
      final results = await Future.wait([
        _profileRepository.getProfile(
          onCachedData: (cachedData) {
            if (mounted) {
              setState(() {
                _profile = cachedData;
                _isProfileLoading = false;
                _checkAllLoaded();
              });
            }
          },
        ),
        _profileRepository.getStats(
          onCachedData: (cachedData) {
            if (mounted) {
              setState(() {
                _stats = cachedData;
                _isStatsLoading = false;
                _checkAllLoaded();
              });
            }
          },
        ),
      ]);
      if (mounted) {
        setState(() {
          _profile = results[0] as UserProfile;
          _stats = results[1] as ProfileStats;
          _isProfileLoading = false;
          _isStatsLoading = false;
          _checkAllLoaded();
        });
      }
    } catch (e) {
      _handleLoadError(e);
      if (mounted) {
        setState(() {
          _isProfileLoading = false;
          _isStatsLoading = false;
          _checkAllLoaded();
        });
      }
    }
  }

  void _handleLoadError(dynamic e) {
    if (_hasLoadedData) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to update dashboard data: ${e.toString().replaceAll('Exception: ', '')}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Called inside setState closures — must NOT call setState itself.
  /// Just mutates fields; the enclosing setState handles the rebuild.
  void _checkAllLoaded() {
    if (!_isSummaryLoading &&
        !_isActivitiesLoading &&
        !_isAlertsLoading &&
        !_isTripsLoading &&
        !_isProfileLoading &&
        !_isStatsLoading) {
      if (_anyDataLoaded) {
        _hasLoadedData = true;
        _errorMessage = null;
      } else {
        _errorMessage =
            'Failed to load dashboard data. Please check your connection.';
      }
    }
  }

  Future<void> _handleAddFlightTap() async {
    await openAddFlightWithLimit(
      context: context,
      currentTrips: _trips.length,
      hasUnlimitedFlights: _profile?.hasUnlimitedFlightMonitoring ?? false,
      onReturn: () async {
        if (!mounted) return;
        await _loadDashboardData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: const Color(0xFFFFC229),
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: _buildBody(_displayName),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? const TravellerBottomNav(activeIndex: 0)
          : null,
    );
  }

  Widget _buildBody(String displayName) {
    if (_errorMessage != null && !_hasLoadedData) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE11D48),
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: Icon(Icons.refresh_rounded, color: Colors.black),
                label: Text(
                  'Try Again',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

    final authController = Get.find<AuthController>();
    final planLabel = _planLabel(authController.userProfile.value?.plan);
    final isFree = planLabel.contains('Free');

    final summary = _summary;
    final stats = _stats;
    final usedFlights = stats?.flightsMonitored ?? _trips.length;
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
            planLabel: _isProfileLoading ? 'Free Plan' : planLabel,
            notificationCount:
                _isSummaryLoading ? 0 : (summary?.alertsCount ?? 0),
          ),
          _buildAlertBanner(
              usedClaims >= maxClaims && planLabel.contains('Free')),
          SizedBox(height: 18),
          if (_isStatsLoading ||
              _isProfileLoading ||
              _isTripsLoading ||
              _isSummaryLoading)
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
          SizedBox(height: 18),
          if (_isTripsLoading)
            const SkeletonBox(height: 82, radius: 20)
          else
            AddFlightCard(
              usedFlights: _trips.length,
              maxFlights: freeFlightLimit,
              onTap: _handleAddFlightTap,
            ),
          SizedBox(height: 24),
          if (_isSummaryLoading)
            const SkeletonBox(height: 190, radius: 28)
          else
            SentinelMonitoringSection(
              alertsCount: summary?.alertsCount ?? 0,
              delayRisk: (summary?.alertsCount ?? 0) > 0 ? '68%' : '12%',
              monitoredCount: _trips.where((t) => t.trackingEnabled).length,
              activeTrip: _trips.firstWhereOrNull((t) => t.trackingEnabled),
              onUpgrade: () async {
                final upgraded = await showUpgradeToProDialog(context);
                if (upgraded == true && mounted) {
                  _loadDashboardData();
                }
              },
            ),
          SizedBox(height: 24),
          if (_isActivitiesLoading) ...[
            Row(
              children: [
                SkeletonBox(width: 54, height: 54, radius: 18),
                SizedBox(width: 16),
                Expanded(child: SkeletonBox(height: 42, radius: 14)),
              ],
            ),
            SizedBox(height: 24),
            const SkeletonBox(height: 220, radius: 28),
          ] else ...[
            BorderReadySection(isEmpty: _activities.isEmpty),
          ],
          SizedBox(height: 24),
          if (_isSummaryLoading)
            const SkeletonBox(height: 140, radius: 24)
          else ...[
            RecommendedActionsCard(
              isEmpty: (summary?.alertsCount ?? 0) == 0 &&
                  (summary?.casesCount ?? 0) == 0,
            ),
            SizedBox(height: 24),
            ActiveIssuesSection(
              isEmpty: (summary?.alertsCount ?? 0) == 0 &&
                  (summary?.casesCount ?? 0) == 0,
            ),
          ],
          SizedBox(height: 24),
          if (_isAlertsLoading)
            const SkeletonBox(height: 140, radius: 24)
          else
            DashboardNotificationsSection(alerts: _alerts),
          SizedBox(height: 24),
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
                    color:
                        Theme.of(context).colorScheme.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.3),
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
                        border: Border.all(
                            color: Theme.of(context).colorScheme.outline),
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
