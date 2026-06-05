import 'package:flutter/material.dart';
import '../models/dashboard_module.dart';
import '../screens/sentinel_monitor_screen.dart';
import '../screens/border_ready_screen.dart';
import '../screens/expense_tracker_screen.dart';
import '../screens/resolve_dashboard_screen.dart';
import '../screens/trips_overview_screen.dart';

class DashboardModulesGrid extends StatelessWidget {
  final List<DashboardModule> modules;

  const DashboardModulesGrid({
    super.key,
    required this.modules,
  });

  IconData _getIconForModule(String key) {
    switch (key) {
      case 'sentinel':
        return Icons.shield_outlined;
      case 'ticketGuard':
        return Icons.confirmation_number_outlined;
      case 'borderReady':
        return Icons.airplane_ticket_outlined;
      case 'resolveFlow':
        return Icons.auto_awesome_outlined;
      case 'vault':
        return Icons.folder_zip_outlined;
      case 'bagTrack':
        return Icons.luggage_outlined;
      case 'tripVisualizer':
        return Icons.map_outlined;
      case 'expenseTracker':
        return Icons.account_balance_wallet_outlined;
      case 'claimSubmission':
        return Icons.description_outlined;
      case 'claimIntelligence':
        return Icons.psychology_outlined;
      default:
        return Icons.grid_view_outlined;
    }
  }

  Color _getColorForModule(String key) {
    switch (key) {
      case 'sentinel':
        return const Color(0xFF3B82F6);
      case 'ticketGuard':
        return const Color(0xFF10B981);
      case 'borderReady':
        return const Color(0xFFF59E0B);
      case 'resolveFlow':
        return const Color(0xFFEC4899);
      case 'vault':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _onModuleTap(BuildContext context, DashboardModule module) {
    if (!module.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${module.name} requires a ${module.requiredPlan} subscription.'),
          backgroundColor: const Color(0xFFE11D48),
        ),
      );
      return;
    }

    // Navigate based on module key
    Widget? targetScreen;
    switch (module.key) {
      case 'sentinel':
        targetScreen = const SentinelMonitorScreen();
        break;
      case 'borderReady':
        targetScreen = const BorderReadyScreen();
        break;
      case 'expenseTracker':
        targetScreen = const ExpenseTrackerScreen();
        break;
      case 'resolveFlow':
        targetScreen = const ResolveDashboardScreen();
        break;
      case 'tripVisualizer':
      case 'claimSubmission':
        targetScreen = const TripsOverviewScreen();
        break;
    }

    if (targetScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${module.name} loaded successfully.'),
          backgroundColor: const Color(0xFF10284F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services & Modules',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) {
            final module = modules[index];
            final icon = _getIconForModule(module.key);
            final color = _getColorForModule(module.key);

            return InkWell(
              onTap: () => _onModuleTap(context, module),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10284F),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: module.available
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.03),
                  ),
                ),
                child: Opacity(
                  opacity: module.available ? 1.0 : 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            icon,
                            color: color,
                            size: 28,
                          ),
                          if (!module.available)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE11D48).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                module.requiredPlan,
                                style: const TextStyle(
                                  color: Color(0xFFE11D48),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        module.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
