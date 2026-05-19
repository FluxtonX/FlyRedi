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
        const Text(
          'Step 3: Upload Documents',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Provide evidence to support your claim",
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 28),

        // Required Documents Section
        Row(
          children: [
            const Text(
              'Required Documents',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFE11D48).withOpacity(0.3),
                ),
              ),
              child: const Text(
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
        const SizedBox(height: 16),

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

        const SizedBox(height: 24),

        // Optional Documents Section
        Row(
          children: [
            const Text(
              'Optional Documents',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              child: Text(
                'Optional',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Optional Cards
        _buildDocCard(
          title: 'Boarding Pass',
          subtitle: _isBoardingPassUploaded ? 'Uploaded' : 'Strengthens your claim',
          isUploaded: _isBoardingPassUploaded,
          icon: Icons.description_outlined,
          iconColor: Colors.white70,
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

        const SizedBox(height: 24),

        // Tip Info Box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0C162A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "While optional documents aren't required, they significantly increase your claim's success rate. Consider uploading all available documentation.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Bottom Button
        GestureDetector(
          onTap: widget.onContinue,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC229), // Brand yellow
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text(
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
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A), // Dark blue
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUploaded ? const Color(0xFF10B981).withOpacity(0.3) : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUploaded 
                  ? const Color(0xFF10B981).withOpacity(0.12)
                  : iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUploaded ? const Color(0xFF10B981) : iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (isUploaded) ...[
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF10B981),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isUploaded ? const Color(0xFF10B981) : Colors.white.withOpacity(0.4),
                        fontSize: 13,
                        fontWeight: isUploaded ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onUploadPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUploaded ? Colors.white.withOpacity(0.05) : const Color(0xFF08101E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUploaded ? Icons.cached_outlined : Icons.upload_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isUploaded ? 'Re-upload' : 'Upload',
                    style: const TextStyle(
                      color: Colors.white,
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
