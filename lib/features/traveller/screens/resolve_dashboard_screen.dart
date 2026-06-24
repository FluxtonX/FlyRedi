import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../widgets/resolve_header_gradient.dart';
import '../widgets/case_card.dart';

class ResolveDashboardScreen extends StatefulWidget {
  final bool showBottomNav;

  const ResolveDashboardScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<ResolveDashboardScreen> createState() => _ResolveDashboardScreenState();
}

class _ResolveDashboardScreenState extends State<ResolveDashboardScreen> {
  final List<Map<String, dynamic>> _activeCases = [
    {
      'flightCode': 'BA 082',
      'airline': 'British Airways',
      'disruptionType': 'Flight Cancellation',
      'status': CaseStatus.pending,
    },
    {
      'flightCode': 'AA 301',
      'airline': 'American Airlines',
      'disruptionType': '4 Hour Delay',
      'status': CaseStatus.inProgress,
      'progress': 0.3,
      'stepText': 'Investigating claim',
    },
  ];

  final TextEditingController _flightController = TextEditingController();
  final TextEditingController _baggageController = TextEditingController();

  @override
  void dispose() {
    _flightController.dispose();
    _baggageController.dispose();
    super.dispose();
  }

  void _showReportDisruptionSheet() {
    _flightController.clear();
    _baggageController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF0C162A), // Dark premium theme match
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Report Disruption',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Flight Number Field
                const Text(
                  'FLIGHT NUMBER',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162544),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _flightController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      icon: const Icon(Icons.flight_takeoff,
                          color: Colors.white54, size: 20),
                      hintText: 'e.g., BA 123',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.3)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Baggage Tag Field
                const Text(
                  'BAGGAGE TAG NUMBER (OPTIONAL)',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162544),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _baggageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      icon: const Icon(Icons.luggage,
                          color: Colors.white54, size: 20),
                      hintText: 'e.g., 1234567890',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.3)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Submit Button
                GestureDetector(
                  onTap: () {
                    if (_flightController.text.trim().isNotEmpty) {
                      setState(() {
                        _activeCases.insert(0, {
                          'flightCode':
                              _flightController.text.trim().toUpperCase(),
                          'airline': 'TBD',
                          'disruptionType': 'Reported Disruption',
                          'status': CaseStatus.pending,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC229),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC229).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Submit Complaint',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEmpty = _activeCases.isEmpty;
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showReportDisruptionSheet,
        backgroundColor: const Color(0xFFFFC229),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Report Disruption',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                          isEmpty
                              ? '0 in progress'
                              : '${_activeCases.length} in progress',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

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
                    else
                      ..._activeCases.map((caseData) => CaseCard(
                            flightCode: caseData['flightCode'],
                            airline: caseData['airline'],
                            disruptionType: caseData['disruptionType'],
                            status: caseData['status'],
                            progress: caseData['progress'] ?? 0.0,
                            stepText: caseData['stepText'],
                          )),

                    const SizedBox(height: 1),

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
      bottomNavigationBar: widget.showBottomNav
          ? const TravellerBottomNav(activeIndex: 2)
          : null,
    );
  }
}
