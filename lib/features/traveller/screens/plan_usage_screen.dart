import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../widgets/upgrade_to_pro_dialog.dart';
import 'pro_benefits_screen.dart';

class PlanUsageScreen extends StatelessWidget {
  const PlanUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  const SizedBox(width: 8),
                  const Text(
                    'Plan Usage',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF111F45),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF2B3B68)),
                ),
                child: Row(
                  children: [
                    const Expanded(
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
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFF34466F)),
                      ),
                      child: const Row(
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
              const SizedBox(height: 30),
              const Text(
                'Monthly Usage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              _PlanUsageRow(
                icon: Icons.flight_takeoff,
                label: 'Flights Monitored',
                value: '2/2',
                progress: 1,
                warning: true,
                onTap: () => showUpgradeToProDialog(context),
              ),
              _PlanUsageRow(
                icon: Icons.fact_check_outlined,
                label: 'Claims Filed',
                value: '1/1',
                progress: 1,
                warning: true,
                onTap: () => showUpgradeToProDialog(context),
              ),
              _PlanUsageRow(
                icon: Icons.auto_awesome,
                label: 'AI Complaint Letters',
                value: '1/1',
                progress: 1,
                warning: true,
                onTap: () => showUpgradeToProDialog(context),
              ),
              _PlanUsageRow(
                icon: Icons.chat_bubble_outline,
                label: 'AI Assistant Questions',
                value: '5/5',
                progress: 1,
                warning: true,
                onTap: () => showUpgradeToProDialog(context),
              ),
              _PlanUsageRow(
                icon: Icons.upload_outlined,
                label: 'Document Uploads',
                value: '3/5',
                progress: 0.6,
                warning: false,
                onTap: () {},
              ),
              const SizedBox(height: 14),
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
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101B30),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFFFC229)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
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
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Unlimited everything for \$9/month',
                                  style: TextStyle(
                                    color: Color(0xFF8D99AD),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC943),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Row(
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
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF111F45),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF2B3B68)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF273044),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFFFC229), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
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
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFFF4D5E),
                            size: 17,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: const Color(0xFF475269),
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
