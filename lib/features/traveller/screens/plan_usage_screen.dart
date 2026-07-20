import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../../auth/data/models/user_profile.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../models/trip_model.dart';
import '../presentation/providers/trips_provider.dart';
import '../presentation/providers/profile_provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final uid = auth.user?.id;
    if (uid == null) return;

    try {
      await Future.wait([
        context.read<TripsProvider>().loadTrips(),
        context.read<ProfileProvider>().loadStats(uid),
      ]);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tripsProvider = context.watch<TripsProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    final plan = auth.user?.plan;
    final isFree = plan == null || plan.trim().isEmpty || plan.contains('Free');
    final planName = isFree ? 'Free Plan' : (plan.endsWith('Plan') || plan.endsWith('Pass') ? plan : '$plan Plan');

    final stats = profileProvider.stats;
    final trips = tripsProvider.trips;
    final usedFlights = stats?.flightsMonitored ?? trips.length;

    final maxFlights = isFree ? freeFlightLimit : (stats?.flightsMonitoredMax ?? freeFlightLimit);
    final maxClaims = isFree ? 1 : (stats?.claimsFiledMax ?? 1);
    final maxAiComplaintLetters = isFree ? 1 : (stats?.aiComplaintLettersMax ?? 1);
    final maxAiAssistantQuestions = isFree ? 5 : (stats?.aiAssistantQuestionsMax ?? 5);
    final maxDocumentUploads = isFree ? 5 : (stats?.documentUploadsMax ?? 5);

    final usedClaims = stats?.claimsFiled ?? 0;
    final usedAiComplaintLetters = stats?.aiComplaintLetters ?? 0;
    final usedAiAssistantQuestions = stats?.aiAssistantQuestions ?? 0;
    final usedDocumentUploads = stats?.documentUploads ?? 0;

    final flightProgress = (usedFlights / maxFlights).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF9AA8BD),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan & Usage',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Monitor limits and plan resources',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC229).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium_outlined,
                            color: Color(0xFFFFC229),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                planName,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isFree ? 'Basic Traveler Protection' : 'Premium Traveler Protection',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        _buildUsageRow(
                          icon: Icons.shield_outlined,
                          title: 'Flight Sentinel™ Active',
                          used: usedFlights,
                          max: maxFlights,
                        ),
                        const SizedBox(height: 18),
                        _buildUsageRow(
                          icon: Icons.description_outlined,
                          title: 'Compensation Claims',
                          used: usedClaims,
                          max: maxClaims,
                        ),
                        const SizedBox(height: 18),
                        _buildUsageRow(
                          icon: Icons.email_outlined,
                          title: 'AI Complaint Letters',
                          used: usedAiComplaintLetters,
                          max: maxAiComplaintLetters,
                        ),
                        const SizedBox(height: 18),
                        _buildUsageRow(
                          icon: Icons.question_answer_outlined,
                          title: 'AI Assistant Questions',
                          used: usedAiAssistantQuestions,
                          max: maxAiAssistantQuestions,
                        ),
                        const SizedBox(height: 18),
                        _buildUsageRow(
                          icon: Icons.upload_file_outlined,
                          title: 'Document Uploads',
                          used: usedDocumentUploads,
                          max: maxDocumentUploads,
                        ),
                      ],
                    ),
                    if (isFree) ...[
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          final upgraded = await showUpgradeToProDialog(context);
                          if (upgraded == true && mounted) {
                            _loadData();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC229),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.workspace_premium_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Upgrade Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (isFree)
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Color(0xFFFFC229)),
                  title: const Text('Compare Pro Plan benefits', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProBenefitsScreen(),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageRow({
    required IconData icon,
    required String title,
    required int used,
    required int max,
  }) {
    final double progress = (used / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            Text('$used / $max', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.outline,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? Colors.red : const Color(0xFFFFC229),
          ),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
