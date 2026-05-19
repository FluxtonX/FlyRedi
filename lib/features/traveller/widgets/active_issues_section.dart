import 'package:flutter/material.dart';
import '../screens/expenses_screen.dart';
import '../screens/expense_tracker_screen.dart';
import '../screens/resolution_workflow_screen.dart';
import '../screens/resolve_dashboard_screen.dart';
import '../screens/trips_overview_screen.dart';
import 'demo_state.dart';

class ActiveIssuesSection extends StatelessWidget {
  const ActiveIssuesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DemoState.isEmptyState,
      builder: (context, isEmpty, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTotalExpensesHeader(context),
            const SizedBox(height: 14),
            _buildTotalExpensesCard(context, isEmpty),
            if (!isEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'Active Issues',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildIssueCard(
                context: context,
                flightCode: 'W3 205',
                severity: 'CRITICAL',
                severityColor: const Color(0xFFE11D48),
                timeAgo: '2 hours ago',
                airline: 'Air Peace',
                issueDescription: 'Flight Cancelled',
              ),
              const SizedBox(height: 16),
              _buildIssueCard(
                context: context,
                flightCode: 'AA 301',
                severity: 'HIGH',
                severityColor: const Color(0xFFFFC229),
                timeAgo: '5 hours ago',
                airline: 'Arik Air',
                issueDescription: '4 Hour Delay',
              ),
            ],
            const SizedBox(height: 32),
            _buildActiveClaimsHeader(context),
            const SizedBox(height: 20),
            _buildActiveClaimsCard(context, isEmpty),
          ],
        );
      },
    );
  }

  Widget _buildTotalExpensesHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Expenses',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExpenseTrackerScreen()),
            );
          },
          child: const Text(
            'View all',
            style: TextStyle(
              color: Color(0xFFFFC229),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalExpensesCard(BuildContext context, bool isEmpty) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExpenseTrackerScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1931),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFC229).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Expenses',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEmpty ? '\$00.00' : '\$290.00',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'View all',
                style: TextStyle(
                  color: Color(0xFFFFC229),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueCard({
    required BuildContext context,
    required String flightCode,
    required String severity,
    required Color severityColor,
    required String timeAgo,
    required String airline,
    required String issueDescription,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF101B30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
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
                  Text(
                    flightCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: severityColor.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      severity,
                      style: TextStyle(
                        color: severityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                timeAgo,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            airline,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2F4D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              issueDescription,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResolveDashboardScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC229),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Start Resolution',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveClaimsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.task_outlined,
                color: Colors.white54,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Active Claims',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TripsOverviewScreen()),
            );
          },
          child: const Text(
            'View all',
            style: TextStyle(
              color: Color(0xFFFFC229),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveClaimsCard(BuildContext context, bool isEmpty) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TripsOverviewScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF101B30),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: isEmpty
            ? const Center(
                child: Text(
                  'No active claims for now',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2 claims in progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Est. \$1,240 compensation',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ExpensesScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B2F1F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'In Review',
                        style: TextStyle(
                          color: Color(0xFFFFC229),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
