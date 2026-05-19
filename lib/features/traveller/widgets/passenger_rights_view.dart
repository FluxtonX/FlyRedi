import 'package:flutter/material.dart';

class PassengerRightsView extends StatelessWidget {
  final VoidCallback onContinue;

  const PassengerRightsView({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title & Subtitle
        const Text(
          'Step 2: Your Passenger Rights',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "You're protected under Nigerian aviation law",
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),

        // Legal Protection Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB47C1C), // Warm bronze/peach
                Color(0xFF0C2B5C), // Dark blue/indigo
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFFFC229), // Gold/yellow shield
                  size: 24,
                ),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Legal Protection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your rights are enforced by the Nigerian Civil Aviation Authority (NCAA) and aligned with ICAO standards',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Rights List
        _buildRightCard(
          title: 'Full Refund',
          description: 'Get a complete refund of your ticket cost within 7-14 days',
          regulation: 'NCAA Regulation Part 19.2.1',
          icon: Icons.description_outlined,
        ),
        _buildRightCard(
          title: 'Alternative Flight',
          description: 'Free rebooking on the next available flight to your destination',
          regulation: 'NCAA Regulation Part 19.2.2',
          icon: Icons.description_outlined,
        ),
        _buildRightCard(
          title: 'Compensation',
          description: '₦45,000 compensation for domestic flight cancellation',
          regulation: 'NCAA Regulation Part 19.2.5',
          icon: Icons.balance,
          isRecommended: true,
        ),
        _buildRightCard(
          title: 'Care & Assistance',
          description: 'Meals, refreshments, and accommodation if overnight stay required',
          regulation: 'NCAA Regulation Part 19.2.3',
          icon: Icons.description_outlined,
        ),
        const SizedBox(height: 16),

        // Why This Matters Section
        const Text(
          'Why This Matters',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Understanding your rights ensures you receive fair compensation and treatment. The NCAA requires airlines to comply with these regulations or face penalties.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),

        // Bottom Button
        GestureDetector(
          onTap: onContinue,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC229), // Yellow button
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text(
              'I Understand, Continue',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightCard({
    required String title,
    required String description,
    required String regulation,
    required IconData icon,
    bool isRecommended = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A), // Dark blue
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecommended ? const Color(0xFFFFC229) : Colors.white.withOpacity(0.05),
          width: isRecommended ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFC229),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isRecommended)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC229), // Solid yellow
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Recommended',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white.withOpacity(0.3),
                        size: 18,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      color: Colors.white.withOpacity(0.3),
                      size: 12,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      regulation,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
