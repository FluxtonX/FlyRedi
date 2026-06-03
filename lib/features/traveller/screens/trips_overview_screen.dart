import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import 'package:sky_rightz_360/features/traveller/widgets/demo_state.dart';
import '../widgets/traveller_bottom_nav.dart';
import 'active_disruptions_screen.dart';
import 'upcoming_trips_screen.dart';
import 'add_flight_screen.dart';
import 'border_ready_screen.dart';
import 'flight_detail_screen.dart';

class TripsOverviewScreen extends StatefulWidget {
  const TripsOverviewScreen({super.key});

  @override
  State<TripsOverviewScreen> createState() => _TripsOverviewScreenState();
}

class _TripsOverviewScreenState extends State<TripsOverviewScreen> {
  bool _isAAMonitored = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DemoState.isEmptyState,
      builder: (context, isEmpty, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Row
                  GestureDetector(
                    onDoubleTap: () {
                      DemoState.toggle();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            DemoState.isEmptyState.value
                                ? 'Switched to Initial Empty Demo State!'
                                : 'Switched to Sarah Johnson Demo State!',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: const Color(0xFF0C162A),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.08)),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Trips',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage all your flights',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddFlightScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Overview 3-Card Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.shield_outlined,
                          iconColor: const Color(0xFFFFC229),
                          count: isEmpty ? '--' : '2',
                          label: 'Monitored',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const UpcomingTripsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.error_outline,
                          iconColor: const Color(0xFFEF4444),
                          count: isEmpty ? '--' : '2',
                          label: 'Alerts',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ActiveDisruptionsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle_outline,
                          iconColor: const Color(0xFF10B981),
                          count: isEmpty ? '--' : '1',
                          label: 'Upcoming',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const UpcomingTripsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Sentinel Protected Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sentinel™ Protected',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981), // Green
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Active',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C162A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'We have no sentinel activity',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else ...[
                    // Flight 1: UA 2847
                    _buildProtectedFlightCard(
                      airlineCode: 'UA 2847',
                      risk: 'MEDIUM RISK',
                      riskColor: const Color(0xFFFFC229),
                      from: 'SFO',
                      fromTime: '10:45 AM',
                      to: 'JFK',
                      toTime: '7:15 PM',
                      statusText: 'Monitoring',
                      delayProb: '68%',
                      activeAlerts: 2,
                      date: 'May 15, 2026',
                    ),

                    const SizedBox(height: 12),

                    // Flight 2: DL 1523
                    _buildProtectedFlightCard(
                      airlineCode: 'DL 1523',
                      risk: 'LOW RISK',
                      riskColor: const Color(0xFF10B981),
                      from: 'JFK',
                      fromTime: '2:30 PM',
                      to: 'LAX',
                      toTime: '5:45 PM',
                      statusText: 'On Track',
                      delayProb: '12%',
                      activeAlerts: 0,
                      date: 'May 18, 2026',
                    ),
                  ],

                  const SizedBox(height: 28),                  // ── Upcoming Trips Section ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.flight_takeoff, color: Colors.white.withOpacity(0.5), size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Upcoming Trips',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UpcomingTripsScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'View all',
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

                  if (isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C162A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'No upcoming trip for now',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    // AA 456 Detailed Upcoming Card (Figma-matching)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C162A),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Airline name + On Time badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'American Airlines',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withOpacity(0.4),
                                  ),
                                ),
                                child: const Text(
                                  'On Time',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Flight code
                          const Text(
                            'AA 456',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Route row: LAX → ORD with times and cities
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Departure
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'LAX',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '9:00 AM',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Los Angeles',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.35),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              // Airplane icon
                              Icon(
                                Icons.flight,
                                color: Colors.white.withOpacity(0.2),
                                size: 22,
                              ),
                              // Arrival
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'ORD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '3:15 PM',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Chicago',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.35),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Divider(color: Colors.white.withOpacity(0.04)),
                          const SizedBox(height: 8),
                          // Date
                          Text(
                            'May 22, 2026',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 28),

                  // ── Trips Monitoring Section ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.radar, color: Colors.white.withOpacity(0.5), size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Trips Monitoring',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddFlightScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Add monitoring',
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

                  if (isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C162A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'No trips to monitor',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    // AA 456 Monitoring Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C162A),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AA 456',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'LAX → ORD',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'May 22, 2026',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _isAAMonitored
                                        ? 'Active Sentinel'
                                        : 'Not Monitored',
                                    style: TextStyle(
                                      color: _isAAMonitored
                                          ? const Color(0xFF10B981)
                                          : Colors.white30,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isAAMonitored = !_isAAMonitored;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                _isAAMonitored
                                                    ? Icons.check_circle
                                                    : Icons.info_outline,
                                                color: _isAAMonitored
                                                    ? const Color(0xFF10B981)
                                                    : Colors.white70,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                _isAAMonitored
                                                    ? 'Sentinel™ Protection Enabled!'
                                                    : 'Sentinel™ Protection Disabled.',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: const Color(0xFF0C162A),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(
                                                color: Colors.white.withOpacity(0.08)),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _isAAMonitored
                                            ? const Color(0xFF10B981).withOpacity(0.12)
                                            : const Color(0xFFFFC229).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: _isAAMonitored
                                              ? const Color(0xFF10B981).withOpacity(0.3)
                                              : const Color(0xFFFFC229).withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        _isAAMonitored
                                            ? 'Sentinel™ Enabled'
                                            : 'Enable Sentinel™',
                                        style: TextStyle(
                                          color: _isAAMonitored
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFFFC229),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Add New Flight Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddFlightScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C162A).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add New Flight',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Start Sentinel™ monitoring',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Two Half-Width bottom action cards
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ActiveDisruptionsScreen(),
                                ),
                              );
                            },
                            child: _buildQuickActionButton(
                              icon: Icons.remove_red_eye_outlined,
                              label: 'View\nDisruptions',
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
                                  builder: (context) => const BorderReadyScreen(),
                                ),
                              );
                            },
                            child: _buildQuickActionButton(
                              icon: Icons.verified_user_outlined,
                              label: 'BorderReady™',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const TravellerBottomNav(activeIndex: 1),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0C162A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.04),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectedFlightCard({
    required String airlineCode,
    required String risk,
    required Color riskColor,
    required String from,
    required String fromTime,
    required String to,
    required String toTime,
    required String statusText,
    required String delayProb,
    required int activeAlerts,
    required String date,
  }) {
    return GestureDetector(
      onTap: () {
        if (airlineCode == 'UA 2847') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FlightDetailScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sentinel™ is tracking $airlineCode live. No disruptions reported.',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF0C162A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0C162A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.04),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Sentinel™ Monitoring',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        risk,
                        style: TextStyle(
                          color: riskColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  airlineCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      from,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fromTime,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.swap_horiz,
                  color: Colors.white24,
                  size: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      to,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.04)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Delay Probability: ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      delayProb,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Active Alerts: ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '$activeAlerts',
                      style: TextStyle(
                        color: activeAlerts > 0
                            ? const Color(0xFFEF4444)
                            : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                date,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
