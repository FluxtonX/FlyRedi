import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../../auth/data/models/user_profile.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../models/trip_model.dart';
import '../repositories/trip_repository.dart';
import '../repositories/profile_repository.dart';
import '../utils/add_flight_navigation.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../widgets/upgrade_to_pro_dialog.dart';
import 'pro_benefits_screen.dart';

class PlanUsageScreen extends StatefulWidget {
  const PlanUsageScreen({super.key});

  @override
  State<PlanUsageScreen> createState() => _PlanUsageScreenState();
}

class _PlanUsageScreenState extends State<PlanUsageScreen> {
  final TripRepository _tripRepository = TripRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final AuthController _authController = Get.find<AuthController>();

  List<TripModel> _trips = [];
  ProfileStats? _stats;

  int get _usedFlights => _trips.length;
  double get _flightProgress =>
      (_usedFlights / freeFlightLimit).clamp(0.0, 1.0).toDouble();

  @override
  void initState() {
    super.initState();
    TripRepository.tripsVersion.addListener(_onTripsChanged);
    _loadData();
  }

  @override
  void dispose() {
    TripRepository.tripsVersion.removeListener(_onTripsChanged);
    super.dispose();
  }

  void _onTripsChanged() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _tripRepository.fetchUserTrips(),
        _profileRepository.getStats(),
      ]);
      if (!mounted) return;
      setState(() {
        _trips = results[0] as List<TripModel>;
        _stats = results[1] as ProfileStats;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Color(0xFF9AA8BD),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Plan Usage',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26),
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).colorScheme.surface),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Plan',
                            style: TextStyle(
                              color: Color(0xFF9AA5B8),
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Traveler Basic',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Theme.of(context).colorScheme.surface),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bolt_outlined,
                            color: Color(0xFF9AA5B8),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'FREE',
                            style: TextStyle(
                              color: Color(0xFF9AA5B8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Monthly Usage',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 18),
              _PlanUsageRow(
                icon: Icons.flight_takeoff,
                label: 'Flights Monitored',
                value: '${_stats?.flightsMonitored ?? _usedFlights}/${_stats?.flightsMonitoredMax ?? freeFlightLimit}',
                progress: _stats != null
                    ? (_stats!.flightsMonitored / _stats!.flightsMonitoredMax).clamp(0.0, 1.0)
                    : _flightProgress,
                warning: (_stats?.flightsMonitored ?? _usedFlights) >= (_stats?.flightsMonitoredMax ?? freeFlightLimit),
                onTap: () async {
                  final upgraded = await showUpgradeToProDialog(context);
                  if (upgraded == true && mounted) {
                    _loadData();
                  }
                },
              ),
              _PlanUsageRow(
                icon: Icons.fact_check_outlined,
                label: 'Claims Filed',
                value: '${_stats?.claimsFiled ?? 0}/${_stats?.claimsFiledMax ?? 1}',
                progress: _stats != null && _stats!.claimsFiledMax > 0
                    ? (_stats!.claimsFiled / _stats!.claimsFiledMax).clamp(0.0, 1.0)
                    : 0,
                warning: (_stats?.claimsFiled ?? 0) >= (_stats?.claimsFiledMax ?? 1),
                onTap: () async {
                  final upgraded = await showUpgradeToProDialog(context);
                  if (upgraded == true && mounted) {
                    _loadData();
                  }
                },
              ),
              _PlanUsageRow(
                icon: Icons.auto_awesome,
                label: 'AI Complaint Letters',
                value: '${_stats?.aiComplaintLetters ?? 0}/${_stats?.aiComplaintLettersMax ?? 1}',
                progress: _stats != null && _stats!.aiComplaintLettersMax > 0
                    ? (_stats!.aiComplaintLetters / _stats!.aiComplaintLettersMax).clamp(0.0, 1.0)
                    : 0,
                warning: (_stats?.aiComplaintLetters ?? 0) >= (_stats?.aiComplaintLettersMax ?? 1),
                onTap: () async {
                  final upgraded = await showUpgradeToProDialog(context);
                  if (upgraded == true && mounted) {
                    _loadData();
                  }
                },
              ),
              _PlanUsageRow(
                icon: Icons.chat_bubble_outline,
                label: 'AI Assistant Questions',
                value: '${_stats?.aiAssistantQuestions ?? 0}/${_stats?.aiAssistantQuestionsMax ?? 5}',
                progress: _stats != null && _stats!.aiAssistantQuestionsMax > 0
                    ? (_stats!.aiAssistantQuestions / _stats!.aiAssistantQuestionsMax).clamp(0.0, 1.0)
                    : 0,
                warning: (_stats?.aiAssistantQuestions ?? 0) >= (_stats?.aiAssistantQuestionsMax ?? 5),
                onTap: () async {
                  final upgraded = await showUpgradeToProDialog(context);
                  if (upgraded == true && mounted) {
                    _loadData();
                  }
                },
              ),
              _PlanUsageRow(
                icon: Icons.upload_outlined,
                label: 'Document Uploads',
                value: '${_stats?.documentUploads ?? 0}/${_stats?.documentUploadsMax ?? 5}',
                progress: _stats != null && _stats!.documentUploadsMax > 0
                    ? (_stats!.documentUploads / _stats!.documentUploadsMax).clamp(0.0, 1.0)
                    : 0,
                warning: false,
                onTap: () {},
              ),
              SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProBenefitsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFFFC229)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.workspace_premium_outlined,
                            color: Color(0xFFFFC229),
                            size: 34,
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upgrade to Pro',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Unlimited everything for \$9/month',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC943),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.workspace_premium_outlined,
                              color: Colors.black,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'See All Pro Benefits',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanUsageRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final bool warning;
  final VoidCallback onTap;

  const _PlanUsageRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    required this.warning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = warning ? const Color(0xFFFF4D5E) : const Color(0xFF23C78A);
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Theme.of(context).colorScheme.surface),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFFFC229), size: 22),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: Color(0xFF9AA5B8),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          value,
                          style: TextStyle(
                            color: color,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (warning) ...[
                          SizedBox(width: 8),
                          Icon(
                            Icons.error_outline,
                            color: Color(0xFFFF4D5E),
                            size: 17,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
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
