import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../widgets/resolve_header_gradient.dart';
import '../widgets/case_card.dart';
import '../models/claim_model.dart';
import '../presentation/providers/claim_provider.dart';
import '../presentation/providers/trips_provider.dart';
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
  final TextEditingController _flightController = TextEditingController();
  final TextEditingController _baggageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClaims();
    });
  }

  Future<void> _loadClaims() async {
    if (!mounted) return;
    try {
      await context.read<ClaimProvider>().loadClaims();
    } catch (_) {}
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
        return StatefulBuilder(
          builder: (context, setModalState) {
            final claimProvider = context.watch<ClaimProvider>();
            final isSubmitting = claimProvider.isSubmitting;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Report Disruption',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'FLIGHT NUMBER',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _flightController,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          icon: Icon(Icons.flight_takeoff,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 20),
                          hintText: 'e.g., BA 123',
                          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'BAGGAGE TAG NUMBER (OPTIONAL)',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _baggageController,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          icon: Icon(Icons.luggage,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 20),
                          hintText: 'e.g., 1234567890',
                          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: isSubmitting ? null : () async {
                        if (_flightController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Please enter your Flight Number.',
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF1E293B),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 6,
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                          return;
                        }

                        final claim = await context.read<ClaimProvider>().submitClaim(
                          flightCode: _flightController.text.trim().toUpperCase(),
                          airline: 'Pending Airline',
                          disruptionType: 'Reported Disruption',
                          booking: _baggageController.text.trim().isNotEmpty
                              ? {'baggageTag': _baggageController.text.trim()}
                              : null,
                        );

                        if (!mounted) return;

                        if (claim != null) {
                          Navigator.pop(context);
                          _loadClaims();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Complaint submitted successfully.',
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF1E293B),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 6,
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        } else {
                          final error = claimProvider.errorMessage;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error ?? 'Failed to submit complaint.'),
                            ),
                          );
                          claimProvider.clearError();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSubmitting ? Colors.grey : const Color(0xFFFFC229),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSubmitting ? null : [
                            BoxShadow(
                              color: const Color(0xFFFFC229).withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: isSubmitting
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
      },
    );
  }

  CaseStatus _mapClaimStatus(String status) {
    if (status.toUpperCase() == 'PENDING') return CaseStatus.pending;
    if (status.toUpperCase() == 'COMPLETED' || status.toUpperCase() == 'REJECTED') return CaseStatus.completed;
    return CaseStatus.inProgress;
  }

  @override
  Widget build(BuildContext context) {
    final claimProvider = context.watch<ClaimProvider>();
    final claims = claimProvider.claims;
    final isLoading = claimProvider.isLoading && claims.isEmpty;

    // Use user's real trips for Active Cases
    final tripsProvider = context.watch<TripsProvider>();
    final trips = tripsProvider.trips;
    final isTripsLoading = tripsProvider.isLoading;

    final completedCases = claims.where((c) => c.status.toUpperCase() == 'COMPLETED' || c.status.toUpperCase() == 'REJECTED').toList();
    bool isEmptyCompleted = completedCases.isEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadClaims,
          color: const Color(0xFFFFC229),
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ResolveHeaderGradient(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Cases',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            trips.isEmpty
                                ? '0 in progress'
                                : '${trips.length} in progress',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (isTripsLoading)
                        Container(
                          height: 140,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
                          ),
                        )
                      else if (trips.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(Icons.flight_takeoff_rounded,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                                  size: 36),
                              const SizedBox(height: 10),
                              Text(
                                'No flights added yet',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add a trip from the Trips tab',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...trips.map((trip) => CaseCard(
                              flightCode: trip.flightNumber,
                              airline: '${trip.origin} → ${trip.destination}',
                              disruptionType: trip.departureDate,
                              status: CaseStatus.inProgress,
                              progress: 0.0,
                              stepText: 'Flight tracked',
                            )),
                      const SizedBox(height: 32),
                      Text(
                        'Completed Cases',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (isLoading)
                        Container(
                          height: 100,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
                          ),
                        )
                      else if (isEmptyCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'No completed cases yet',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
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
      ),
      bottomNavigationBar: widget.showBottomNav
          ? const TravellerBottomNav(activeIndex: 2)
          : null,
    );
  }
}
