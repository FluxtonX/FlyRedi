import 'package:flutter/material.dart';
import '../screens/border_ready_screen.dart';
import '../models/trip_model.dart';

class BorderReadySection extends StatelessWidget {
  final TripModel? activeTrip;

  const BorderReadySection({
    super.key,
    this.activeTrip,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = activeTrip == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            if (!isEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BorderReadyScreen()),
              );
            }
          },
          child: _buildCard(context, isEmpty),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF2DD4BF).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.flight_takeoff,
            color: Color(0xFF2DD4BF),
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BorderReady™',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Travel document verification',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, bool isEmpty) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFFFC229).withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEmpty ? 'No Destination Active' : activeTrip!.destination,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    isEmpty ? '--' : activeTrip!.departureDate,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.38),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (!isEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFFC229),
                    size: 24,
                  ),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(context, isEmpty ? '--' : '3', 'Ready', false),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isEmpty
                      ? Colors.transparent
                      : const Color(0xFFFFC229).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildStat(
                    context, isEmpty ? '--' : '1', 'Warnings', false),
              ),
              _buildStat(context, isEmpty ? '--' : '0', 'Missing', false),
            ],
          ),
          if (!isEmpty) ...[
            SizedBox(height: 8),
            _buildChecklistItem(
              context,
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFF22C55E),
              title: 'Passport Validity',
              subtitle: 'Valid until 2028',
            ),
            SizedBox(height: 8),
            _buildChecklistItem(
              context,
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFF22C55E),
              title: 'Visa Requirements',
              subtitle: 'Visa-free for 180 days',
            ),
            SizedBox(height: 8),
            _buildChecklistItem(
              context,
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFFFC229),
              title: 'Travel Advisory',
              subtitle: 'Check latest COVID requirements',
            ),
            Divider(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View full checklist',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ] else ...[
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'No travel documents to verify.\nAdd a flight to monitor border readiness.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(
      BuildContext context, String value, String label, bool isWarning) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 22,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.54),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
