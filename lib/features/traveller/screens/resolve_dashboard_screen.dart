import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../widgets/resolve_header_gradient.dart';
import '../widgets/case_card.dart';

class ResolveDashboardScreen extends StatefulWidget {
  const ResolveDashboardScreen({super.key});

  @override
  State<ResolveDashboardScreen> createState() => _ResolveDashboardScreenState();
}

class _ResolveDashboardScreenState extends State<ResolveDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    bool isEmpty = true;
    return Scaffold(
      backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Resolve Header with Gradient
                  const ResolveHeaderGradient(),

                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Active Cases Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Active Cases',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isEmpty ? '0 in progress' : '2 in progress',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        if (isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C162A),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.04),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'No active cases',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else ...[
                          // Card 1: W3 205 (In Progress)
                          const CaseCard(
                            flightCode: 'W3 205',
                            airline: 'Air Peace',
                            disruptionType: 'Flight Cancellation',
                            status: CaseStatus.inProgress,
                            progress: 0.5,
                            stepText: 'Step 3 of 6',
                          ),

                          // Card 2: AA 301 (Pending)
                          const CaseCard(
                            flightCode: 'AA 301',
                            airline: 'Arik Air',
                            disruptionType: '4 Hour Delay',
                            status: CaseStatus.pending,
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Completed Cases Section Header
                        const Text(
                          'Completed Cases',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),

                        if (isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C162A),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.04),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'No completed cases yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          // Card 3: LOS 102 (Completed)
                          const CaseCard(
                            flightCode: 'LOS 102',
                            airline: 'Dana Air',
                            disruptionType: 'Baggage Delay',
                            status: CaseStatus.completed,
                            compensationAmount: '₦25,000',
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const TravellerBottomNav(activeIndex: 2),
        );
  }
}
