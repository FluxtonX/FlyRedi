import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../widgets/traveller_bottom_nav.dart';
import 'email_preview_screen.dart';
import 'add_authorities_screen.dart';

import '../models/alert_model.dart';

class ComplaintReadyScreen extends StatefulWidget {
  final AlertModel? alert;

  const ComplaintReadyScreen({super.key, this.alert});

  @override
  State<ComplaintReadyScreen> createState() => _ComplaintReadyScreenState();
}

class _ComplaintReadyScreenState extends State<ComplaintReadyScreen> {
  String? _generatedEmailBody;
  bool _isLoading = false;

  late String _airline;
  late String _flightCode;
  late String _route;
  late String _dateStr;
  late String _timeStr;
  late String _ref;
  late String _issue;
  late String _refundText;
  late String _compText;
  late String _totalText;
  late String _userName;
  late String _userEmail;
  late String _userPhone;

  @override
  void initState() {
    super.initState();
    final alert = widget.alert;
    _airline =
        alert != null && alert.airline.isNotEmpty ? alert.airline : 'Air Peace';
    _flightCode = alert != null && alert.flightCode.isNotEmpty
        ? alert.flightCode
        : 'W3 205';

    _route = 'Lagos (LOS) → Abuja (ABV)';
    if (alert != null &&
        alert.message.contains('(') &&
        alert.message.contains(')')) {
      final startIndex = alert.message.indexOf('(');
      final endIndex = alert.message.indexOf(')');
      if (endIndex > startIndex) {
        final content = alert.message.substring(startIndex + 1, endIndex);
        if (content.contains('→')) {
          _route = content;
        } else if (content.contains('to')) {
          _route = content.replaceAll('to', '→');
        } else if (content.contains('-')) {
          _route = content.replaceAll('-', '→');
        }
      }
    }

    _dateStr = 'April 27, 2026';
    _timeStr = '14:00 WAT';
    if (alert != null && alert.createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(alert.createdAt).toLocal();
        final months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        _dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        _timeStr = '$hour:$minute WAT';
      } catch (_) {}
    }

    _issue = alert != null && alert.eventType.isNotEmpty
        ? alert.eventType
        : 'Flight Cancellation';

    final isDelay = _issue.toLowerCase().contains('delay');
    _ref = isDelay ? 'ABC456' : 'ABC123';

    _refundText = isDelay
        ? 'Delay care allowance (₦15,000)'
        : 'Full refund of ticket fare (₦85,000)';
    _compText = isDelay
        ? 'Statutory compensation (₦30,000)'
        : 'Statutory compensation (₦45,000)';
    _totalText = isDelay ? 'Total Amount: ₦45,000' : 'Total Amount: ₦130,000';

    final auth = context.read<AuthProvider>();
    final user = auth.user;
    _userName = user != null && user.displayName.isNotEmpty
        ? user.displayName
        : 'Rahmat Ullah';
    _userEmail = user != null && user.email.isNotEmpty
        ? user.email
        : 'rahmat@skyrightz360.com';
    _userPhone = user != null && user.phoneNumber.isNotEmpty
        ? user.phoneNumber
        : '+234 801 234 5678';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateEmailWithGemini();
    });
  }

  Future<void> _generateEmailWithGemini() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String prompt = """
Write a professional, concise, and short complaint email to $_airline Customer Service regarding a flight disruption.
Use these flight details:
- Passenger Name: $_userName
- Flight Number: $_flightCode
- Route: $_route
- Scheduled Date: $_dateStr
- Scheduled Time: $_timeStr
- Booking Reference: $_ref
- Disruption Type: $_issue

Include a clear but brief request for $_refundText and $_compText for a total of $_totalText under Nigerian Civil Aviation Regulations (NCAA Part 19).
Mention that the required supporting documents (ticket, cancellation notice, passport ID) are attached.
The tone must be professional, demanding but polite. Keep it short, clean, and directly to the point.
Do not include any subject line or placeholders like [Your Name] in the email body, start directly with "Dear $_airline Customer Service," and end with the passenger's details:
Sincerely,
$_userName
$_userEmail
$_userPhone
""";

      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyA0TdiAQhzaEyndq_gznLcuI-Ib5ofYJkQ');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ]
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final firstCand = candidates.first as Map<String, dynamic>;
          final content = firstCand['content'] as Map<String, dynamic>?;
          if (content != null) {
            final parts = content['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final firstPart = parts.first as Map<String, dynamic>;
              final replyText = firstPart['text'] as String?;
              if (replyText != null && replyText.trim().isNotEmpty) {
                String cleanReply = replyText.trim();

                // Strip subject line if AI added it
                if (cleanReply.toLowerCase().startsWith('subject:')) {
                  final lines = cleanReply.split('\n');
                  if (lines.isNotEmpty) {
                    lines.removeAt(0); // remove subject line
                    if (lines.isNotEmpty && lines.first.trim().isEmpty) {
                      lines.removeAt(0); // remove empty line
                    }
                    cleanReply = lines.join('\n').trim();
                  }
                }

                // Strip markdown backticks block if AI wrapped it in ```
                if (cleanReply.startsWith('```')) {
                  final lines = cleanReply.split('\n');
                  if (lines.isNotEmpty && lines.first.startsWith('```')) {
                    lines.removeAt(0);
                  }
                  if (lines.isNotEmpty && lines.last.startsWith('```')) {
                    lines.removeLast();
                  }
                  cleanReply = lines.join('\n').trim();
                }

                if (mounted) {
                  setState(() {
                    _generatedEmailBody = cleanReply;
                  });
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[ComplaintReadyScreen] Failed to generate AI email: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    final airline =
        alert != null && alert.airline.isNotEmpty ? alert.airline : 'Air Peace';
    final emailTo =
        'complaints@${airline.toLowerCase().replaceAll(' ', '')}.com';

    final flightCode = alert != null && alert.flightCode.isNotEmpty
        ? alert.flightCode
        : 'W3 205';

    String dateStr = '27 Apr 2026';
    if (alert != null && alert.createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(alert.createdAt).toLocal();
        final monthsAbbr = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        dateStr = '${dt.day} ${monthsAbbr[dt.month - 1]} ${dt.year}';
      } catch (_) {}
    }

    final issue = alert != null && alert.eventType.isNotEmpty
        ? alert.eventType
        : 'Flight Cancellation';

    final subject = '$issue Complaint - $flightCode ($dateStr)';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Green Gradient Header Banner
            Container(
              padding: const EdgeInsets.only(
                  top: 60, bottom: 32, left: 24, right: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF10B981), // Emerald green
                    Color(0xFF059669), // Muted green
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Circular Check Icon
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.24),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your Complaint is Ready',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We've prepared a professional email\nbased on your case",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.85),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email Generated Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Card Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFB47C1C).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Color(0xFFFFC229)),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFFFFC229),
                                      size: 18,
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isLoading
                                        ? 'Generating Email...'
                                        : 'Email Generated',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _isLoading
                                        ? 'Drafting professional email with Gemini...'
                                        : 'Ready to review and send',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.38),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Nested Email Details Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.38),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                emailTo,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Subject',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.38),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subject,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Attachments',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.38),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildAttachmentChip(context, 'Ticket.pdf'),
                                  const SizedBox(width: 8),
                                  _buildAttachmentChip(context, 'Passport.pdf'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EmailPreviewScreen(
                                        alert: alert,
                                        pregeneratedEmailBody:
                                            _generatedEmailBody,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit_note,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.8),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Preview Email',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Edit Details',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // What Happens Next Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What Happens Next',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildStepRow(
                          context,
                          stepNumber: '1',
                          title: 'Review Your Email',
                          subtitle:
                              'Check the details and make any necessary edits',
                          isActive: true,
                        ),
                        const SizedBox(height: 18),
                        _buildStepRow(
                          context,
                          stepNumber: '2',
                          title: 'Send from Your Email',
                          subtitle:
                              'You remain in full control of this communication',
                          isActive: false,
                        ),
                        const SizedBox(height: 18),
                        _buildStepRow(
                          context,
                          stepNumber: '3',
                          title: 'Track Follow-ups',
                          subtitle:
                              "We'll remind you if no response is received",
                          isActive: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Note Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFC229).withOpacity(0.15),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          fontSize: 13,
                          height: 1.45,
                        ),
                        children: [
                          TextSpan(
                            text: 'Note: ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text:
                                "We've prepared your complaint. Review and send when ready. You can optionally include regulatory authorities for better response likelihood.",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bottom Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmailPreviewScreen(
                            alert: alert,
                            pregeneratedEmailBody: _generatedEmailBody,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC229), // Yellow button
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.black,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 3),
    );
  }

  Widget _buildAttachmentChip(BuildContext context, String filename) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface
            .withOpacity(0.4), // Blue tint chip
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.description_outlined,
            color: Color(0xFF60A5FA),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            filename,
            style: const TextStyle(
              color: Color(0xFF93C5FD),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context, {
    required String stepNumber,
    required String title,
    required String subtitle,
    bool isActive = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFFFC229)
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: TextStyle(
              color: isActive
                  ? Colors.black
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
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
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
