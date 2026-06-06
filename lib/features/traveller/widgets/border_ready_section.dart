import 'package:flutter/material.dart';
import '../screens/border_ready_screen.dart';

class BorderReadySection extends StatelessWidget {
  final bool isEmpty;

  const BorderReadySection({
    super.key,
    this.isEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                if (!isEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BorderReadyScreen()),
                  );
                }
              },
              child: _buildCard(isEmpty),
            ),
          ],
        );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF0F3B4A),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.flight_takeoff,
            color: Color(0xFF2DD4BF),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BorderReady™',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Travel document verification',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(bool isEmpty) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF10284F),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
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
                  const Text(
                    'BorderReady™',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEmpty ? 'No Destination Active' : 'United Kingdom',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEmpty ? '--' : 'May 15, 2026',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (!isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B2F1F),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFFC229),
                    size: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(isEmpty ? '--' : '3', 'Ready', false),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isEmpty ? Colors.transparent : const Color(0xFF3B3322),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildStat(isEmpty ? '--' : '1', 'Warnings', !isEmpty),
              ),
              _buildStat(isEmpty ? '--' : '0', 'Missing', false),
            ],
          ),
          if (!isEmpty) ...[
            const SizedBox(height: 24),
            _buildChecklistItem(
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFF22C55E),
              title: 'Passport Validity',
              subtitle: 'Valid until 2028',
            ),
            const SizedBox(height: 12),
            _buildChecklistItem(
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFF22C55E),
              title: 'Visa Requirements',
              subtitle: 'Visa-free for 180 days',
            ),
            const SizedBox(height: 12),
            _buildChecklistItem(
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFFFC229),
              title: 'Travel Advisory',
              subtitle: 'Check latest COVID requirements',
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View full checklist',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white60,
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0C1D38),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'No travel documents to verify.\nAdd a flight to monitor border readiness.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
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

  Widget _buildStat(String value, String label, bool isWarning) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: isWarning ? const Color(0xFFFFC229) : Colors.white,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isWarning ? const Color(0xFFFFC229).withOpacity(0.7) : Colors.white54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1D38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
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
