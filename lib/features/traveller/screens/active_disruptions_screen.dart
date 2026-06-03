import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';
import 'flight_details_screen.dart';
import 'ai_assistant_screen.dart';

class ActiveDisruptionsScreen extends StatelessWidget {
  const ActiveDisruptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disruptions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Sentinel™ detected issues',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Potential Compensation Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0C162A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Potential Compensation',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '\$1,800',
                        style: TextStyle(
                          color: Color(0xFFFFC229), // Gold/Yellow
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sentinel™ detected 2 disruptions',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_outlined,
                      color: Color(0xFFEF4444),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Two Indicators Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C162A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Color(0xFFEF4444),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Need Action',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C162A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF10B981),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Handled',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Active Issues Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Issues',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'History is empty.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  child: const Text(
                    'View history',
                    style: TextStyle(
                      color: Color(0xFFFFC229),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Disruption 1: UA 2847
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0C162A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Sentinel™ Alert',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC229).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Delayed',
                              style: TextStyle(
                                color: Color(0xFFFFC229),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'UA 2847',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SFO → JFK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFFFFC229), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Delayed by 2h 30m',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(color: Colors.white.withOpacity(0.04)),
                  const SizedBox(height: 10),
                  _buildDetailsRow('Reason:', 'Air traffic congestion'),
                  const SizedBox(height: 8),
                  _buildDetailsRow('Est. Compensation:', '\$600', highlightValue: true),
                  const SizedBox(height: 8),
                  _buildDetailsRow('Date:', 'May 15, 2026'),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FlightDetailsScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC229),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.assignment_outlined, color: Colors.black, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'File Claim',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AiAssistantScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.8), size: 14),
                                const SizedBox(width: 6),
                                const Text(
                                  'Get AI Guidance',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Disruption 2: BA 112
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0C162A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Sentinel™ Alert',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Cancelled',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'BA 112',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'LHR → SFO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Flight cancelled',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(color: Colors.white.withOpacity(0.04)),
                  const SizedBox(height: 10),
                  _buildDetailsRow('Reason:', 'Technical issue'),
                  const SizedBox(height: 8),
                  _buildDetailsRow('Est. Compensation:', '\$1,200', highlightValue: true),
                  const SizedBox(height: 8),
                  _buildDetailsRow('Date:', 'May 10, 2026'),
                  const SizedBox(height: 18),
                  // Green Handled Claim Filed badge
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 14),
                        SizedBox(width: 8),
                        Text(
                          'Claim filed',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer protection card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0C162A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sentinel™ Protection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We're monitoring all your flights 24/7 and will alert you instantly if any issues are detected.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 1),
    );
  }

  Widget _buildDetailsRow(String label, String value, {bool highlightValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlightValue ? const Color(0xFFFFC229) : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
