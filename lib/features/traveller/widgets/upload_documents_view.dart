import 'package:flutter/material.dart';

class UploadDocumentsView extends StatefulWidget {
  final VoidCallback onContinue;

  const UploadDocumentsView({
    super.key,
    required this.onContinue,
  });

  @override
  State<UploadDocumentsView> createState() => _UploadDocumentsViewState();
}

class _UploadDocumentsViewState extends State<UploadDocumentsView> {
  // Simulating states for high fidelity interactivity
  bool _isTicketUploaded = true;
  bool _isPassportUploaded = false;
  bool _isBoardingPassUploaded = false;
  bool _isNoticeUploaded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title & Subtitle
        Text(
          'Step 3: Upload Documents',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Provide evidence to support your claim",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 28),

        // Required Documents Section
        Row(
          children: [
            Text(
              'Required Documents',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Color(0xFFE11D48).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Color(0xFFE11D48).withOpacity(0.3),
                ),
              ),
              child: Text(
                'Required',
                style: TextStyle(
                  color: Color(0xFFE11D48),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Required Cards
        _buildDocCard(
          title: 'Flight Ticket / Booking Confirmation',
          subtitle: _isTicketUploaded ? 'Uploaded' : 'PDF, JPG, PNG (Max 5MB)',
          isUploaded: _isTicketUploaded,
          icon: Icons.flight_takeoff,
          iconColor: const Color(0xFF10B981),
          onUploadPressed: () {
            setState(() {
              _isTicketUploaded = !_isTicketUploaded;
            });
          },
        ),
        _buildDocCard(
          title: 'Passport / ID',
          subtitle: _isPassportUploaded ? 'Uploaded' : 'PDF, JPG, PNG (Max 5MB)',
          isUploaded: _isPassportUploaded,
          icon: Icons.person_outline,
          iconColor: const Color(0xFF3B82F6),
          onUploadPressed: () {
            setState(() {
              _isPassportUploaded = !_isPassportUploaded;
            });
          },
        ),

        SizedBox(height: 24),

        // Optional Documents Section
        Row(
          children: [
            Text(
              'Optional Documents',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                ),
              ),
              child: Text(
                'Optional',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Optional Cards
        _buildDocCard(
          title: 'Boarding Pass',
          subtitle: _isBoardingPassUploaded ? 'Uploaded' : 'Strengthens your claim',
          isUploaded: _isBoardingPassUploaded,
          icon: Icons.description_outlined,
          iconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          onUploadPressed: () {
            setState(() {
              _isBoardingPassUploaded = !_isBoardingPassUploaded;
            });
          },
        ),
        _buildDocCard(
          title: 'Cancellation Notice',
          subtitle: _isNoticeUploaded ? 'Uploaded' : 'PDF, JPG, PNG (Max 5MB)',
          isUploaded: _isNoticeUploaded,
          icon: Icons.description_outlined,
          iconColor: const Color(0xFF10B981),
          onUploadPressed: () {
            setState(() {
              _isNoticeUploaded = !_isNoticeUploaded;
            });
          },
        ),

        SizedBox(height: 24),

        // Tip Info Box
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tip',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "While optional documents aren't required, they significantly increase your claim's success rate. Consider uploading all available documentation.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32),

        // Bottom Button
        GestureDetector(
          onTap: widget.onContinue,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC229), // Brand yellow
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              'Continue',
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

  Widget _buildDocCard({
    required String title,
    required String subtitle,
    required bool isUploaded,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onUploadPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // Dark blue
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUploaded ? Color(0xFF10B981).withOpacity(0.3) : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUploaded 
                  ? Color(0xFF10B981).withOpacity(0.12)
                  : iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUploaded ? const Color(0xFF10B981) : iconColor,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    if (isUploaded) ...[
                      Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF10B981),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                    ],
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isUploaded ? const Color(0xFF10B981) : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 13,
                        fontWeight: isUploaded ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: onUploadPressed,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUploaded ? Theme.of(context).colorScheme.onSurface.withOpacity(0.05) : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUploaded ? Icons.cached_outlined : Icons.upload_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    isUploaded ? 'Re-upload' : 'Upload',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
