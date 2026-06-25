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
        Text(
          'Step 2: Your Passenger Rights',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "You're protected under Nigerian aviation law",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 24),

        // Legal Protection Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB47C1C), // Warm bronze/peach
                Theme.of(context).colorScheme.surface, // Dark blue/indigo
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
                  ),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFFFC229), // Gold/yellow shield
                  size: 24,
                ),
              ),
              SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Legal Protection',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your rights are enforced by the Nigerian Civil Aviation Authority (NCAA) and aligned with ICAO standards',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
        SizedBox(height: 24),

        // Rights List
        _buildRightCard(context, 
          title: 'Full Refund',
          description: 'Get a complete refund of your ticket cost within 7-14 days',
          regulation: 'NCAA Regulation Part 19.2.1',
          icon: Icons.description_outlined,
        ),
        _buildRightCard(context, 
          title: 'Alternative Flight',
          description: 'Free rebooking on the next available flight to your destination',
          regulation: 'NCAA Regulation Part 19.2.2',
          icon: Icons.description_outlined,
        ),
        _buildRightCard(context, 
          title: 'Compensation',
          description: '₦45,000 compensation for domestic flight cancellation',
          regulation: 'NCAA Regulation Part 19.2.5',
          icon: Icons.balance,
          isRecommended: true,
        ),
        _buildRightCard(context, 
          title: 'Care & Assistance',
          description: 'Meals, refreshments, and accommodation if overnight stay required',
          regulation: 'NCAA Regulation Part 19.2.3',
          icon: Icons.description_outlined,
        ),
        SizedBox(height: 16),

        // Why This Matters Section
        Text(
          'Why This Matters',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Understanding your rights ensures you receive fair compensation and treatment. The NCAA requires airlines to comply with these regulations or face penalties.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        SizedBox(height: 32),

        // Bottom Button
        GestureDetector(
          onTap: onContinue,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC229), // Yellow button
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
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

  Widget _buildRightCard(BuildContext context, {
    required String title,
    required String description,
    required String regulation,
    required IconData icon,
    bool isRecommended = false,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // Dark blue
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecommended ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          width: isRecommended ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFC229),
              size: 18,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isRecommended)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC229), // Solid yellow
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        size: 18,
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      size: 12,
                    ),
                    SizedBox(width: 6),
                    Text(
                      regulation,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
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
