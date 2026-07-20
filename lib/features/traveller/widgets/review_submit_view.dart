import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../models/alert_model.dart';

class ReviewSubmitView extends StatelessWidget {
  final VoidCallback onSubmit;
  final AlertModel? alert;

  const ReviewSubmitView({
    super.key,
    required this.onSubmit,
    this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final userEmail = user != null && user.email.isNotEmpty ? user.email : 'rahmat@skyrightz360.com';
    final userPhone = user != null && user.phoneNumber.isNotEmpty ? user.phoneNumber : '+234 801 234 5678';

    final flightCode = alert != null && alert!.flightCode.isNotEmpty
        ? alert!.flightCode
        : 'W3 205';

    String route = 'LOS → ABV';
    if (alert != null && alert!.message.contains('(') && alert!.message.contains(')')) {
      final startIndex = alert!.message.indexOf('(');
      final endIndex = alert!.message.indexOf(')');
      if (endIndex > startIndex) {
        final content = alert!.message.substring(startIndex + 1, endIndex);
        if (content.isNotEmpty) {
          route = content;
        }
      }
    }

    String dateStr = 'April 27, 2026';
    if (alert != null && alert!.createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(alert!.createdAt).toLocal();
        final months = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
      } catch (_) {}
    }

    final issue = alert != null && alert!.eventType.isNotEmpty
        ? alert!.eventType
        : 'Flight Cancellation';

    final isDelay = issue.toLowerCase().contains('delay');
    final claimAmount = isDelay ? '₦45,000' : '₦130,000';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title & Subtitle
        Text(
          'Step 5: Review & Submit',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Verify your claim details before submission",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 28),

        // Claim Auto-Generated Green Banner
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981), // Solid emerald green
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 16,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Claim Auto-Generated',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "We've created your claim based on NCAA regulations",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Claim Summary Card
        Text(
          'Claim Summary',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Column(
            children: [
              _buildSummaryRow(context, 
                icon: Icons.flight_takeoff,
                label: 'Flight',
                value: '$flightCode ($route)',
              ),
              _buildDivider(context),
              _buildSummaryRow(context, 
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: dateStr,
              ),
              _buildDivider(context),
              _buildSummaryRow(context, 
                icon: Icons.description_outlined,
                label: 'Issue',
                value: issue,
              ),
              _buildDivider(context),
              _buildSummaryRow(context, 
                icon: Icons.attach_money,
                label: 'Claim Amount',
                value: claimAmount,
                isAmount: true,
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Contact Information Section
        Text(
          'Contact Information',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "We'll send updates about your claim to:",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
        SizedBox(height: 16),

        // Contact Info Box
        Container(
          padding: EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Column(
            children: [
              _buildContactItem(context, 
                icon: Icons.email_outlined,
                text: userEmail,
              ),
              SizedBox(height: 14),
              _buildContactItem(context, 
                icon: Icons.phone_outlined,
                text: userPhone,
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Authorization Box
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Text(
            'I confirm that all information provided is accurate and I authorize SkyRightz360 to submit this claim on my behalf to the airline.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ),
        SizedBox(height: 32),

        // Bottom Button
        GestureDetector(
          onTap: onSubmit,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC229), // Yellow submit button
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              'Submit Claim',
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

  Widget _buildSummaryRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isAmount = false,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isAmount ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            size: 16,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isAmount ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
            size: 18,
          ),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(
        color: Theme.of(context).colorScheme.outline,
        height: 1,
      ),
    );
  }
}
