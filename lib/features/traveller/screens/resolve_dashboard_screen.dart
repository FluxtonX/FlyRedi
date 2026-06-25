import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../widgets/resolve_header_gradient.dart';
import '../widgets/case_card.dart';
import '../models/claim_model.dart';
import '../repositories/claim_repository.dart';
import '../widgets/skeleton_box.dart';

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
  List<ClaimModel> _claims = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  final TextEditingController _flightController = TextEditingController();
  final TextEditingController _baggageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  Future<void> _loadClaims() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final claims = await ClaimRepository.getUserClaims();
      if (!mounted) return;
      setState(() {
        _claims = claims;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

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
                  onTap: _isSubmitting ? null : () async {
                    if (_flightController.text.trim().isNotEmpty) {
                      setState(() {
                        _isSubmitting = true;
                      });
                      try {
                        await ClaimRepository.submitClaim(
                          flightCode: _flightController.text.trim().toUpperCase(),
                          airline: 'Pending Airline',
                          disruptionType: 'Reported Disruption',
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          _loadClaims();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to submit: $e')),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isSubmitting = false;
                          });
                        }
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _isSubmitting ? Colors.grey : const Color(0xFFFFC229),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isSubmitting ? null : [
                        BoxShadow(
                          color: const Color(0xFFFFC229).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                          )
                        : const Text(
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

  CaseStatus _mapClaimStatus(String status) {
    if (status == 'PENDING') return CaseStatus.pending;
    if (status == 'COMPLETED' || status == 'REJECTED') return CaseStatus.completed;
    return CaseStatus.inProgress;
  }

  @override
  Widget build(BuildContext context) {
    final activeCases = _claims.where((c) => c.status != 'COMPLETED' && c.status != 'REJECTED').toList();
    final completedCases = _claims.where((c) => c.status == 'COMPLETED' || c.status == 'REJECTED').toList();
    bool isEmptyActive = activeCases.isEmpty;
    bool isEmptyCompleted = completedCases.isEmpty;

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
                          isEmptyActive
                              ? '0 in progress'
                              : '${activeCases.length} in progress',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_isLoading)
                      const SkeletonBox(height: 140, radius: 24)
                    else if (isEmptyActive)
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
                      ...activeCases.map((claim) => CaseCard(
                            flightCode: claim.flightCode,
                            airline: claim.airline,
                            disruptionType: claim.disruptionType,
                            status: _mapClaimStatus(claim.status),
                            progress: claim.progress,
                            stepText: 'Processing claim',
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

                    if (_isLoading)
                      const SkeletonBox(height: 100, radius: 24)
                    else if (isEmptyCompleted)
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
                      ...completedCases.map((claim) => CaseCard(
                            flightCode: claim.flightCode,
                            airline: claim.airline,
                            disruptionType: claim.disruptionType,
                            status: CaseStatus.completed,
                            compensationAmount: claim.compensationAmount ?? 'N/A',
                          )),
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
