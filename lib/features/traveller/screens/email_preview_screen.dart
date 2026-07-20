import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../widgets/traveller_bottom_nav.dart';
import 'send_complaint_screen.dart';
import 'add_authorities_screen.dart';

import '../models/alert_model.dart';

class EmailPreviewScreen extends StatefulWidget {
  final AlertModel? alert;
  final String? pregeneratedEmailBody;

  const EmailPreviewScreen({super.key, this.alert, this.pregeneratedEmailBody});

  @override
  State<EmailPreviewScreen> createState() => _EmailPreviewScreenState();
}

class _EmailPreviewScreenState extends State<EmailPreviewScreen> {
  late TextEditingController _emailBodyController;
  bool _isEditing = false;
  bool _isLoadingAiEmail = false;

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

    final emailBody = "Dear $_airline Customer Service,\n\n"
        "I am writing to formally lodge a complaint regarding the disruption of my flight and to request appropriate compensation as stipulated under Nigerian Civil Aviation Regulations (NCAA Part 19).\n\n"
        "FLIGHT DETAILS:\n"
        "Flight Number: $_flightCode\n"
        "Route: $_route\n"
        "Scheduled Date: $_dateStr\n"
        "Scheduled Time: $_timeStr\n"
        "Booking Reference: $_ref\n"
        "Passenger Name: $_userName\n\n"
        "ISSUE SUMMARY:\n"
        "My flight was disrupted (${_issue.toLowerCase()}) without prior notice, causing significant inconvenience and disruption to my travel plans.\n\n"
        "PASSENGER RIGHTS REFERENCE:\n"
        "According to NCAA Regulation Part 19, I am entitled to:\n"
        "• Accommodation, care, and assistance where applicable\n"
        "• Statutory compensation for domestic flight disruptions\n\n"
        "REQUESTED RESOLUTION:\n"
        "I kindly request the following:\n"
        "1. $_refundText\n"
        "2. $_compText\n"
        "$_totalText\n\n"
        "I have attached supporting documents including:\n"
        "• Flight ticket/booking confirmation\n"
        "• Disruptions notice\n"
        "• Valid ID/Passport\n\n"
        "I would appreciate a response within 14 business days. Should this matter not be resolved satisfactorily, I may be required to escalate to the Nigerian Civil Aviation Authority (NCAA).\n\n"
        "Thank you for your prompt attention to this matter.\n\n"
        "Sincerely,\n"
        "$_userName\n"
        "$_userEmail\n"
        "$_userPhone";

    if (widget.pregeneratedEmailBody != null) {
      _emailBodyController =
          TextEditingController(text: widget.pregeneratedEmailBody);
    } else {
      _emailBodyController = TextEditingController(text: emailBody);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateEmailWithGemini();
      });
    }
  }

  Future<void> _generateEmailWithGemini() async {
    setState(() {
      _isLoadingAiEmail = true;
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

                setState(() {
                  _emailBodyController.text = cleanReply;
                });
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[EmailPreviewScreen] Failed to generate AI email: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAiEmail = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailBodyController.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _emailBodyController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981)),
            const SizedBox(width: 10),
            Text(
              'Email copied to clipboard!',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email Preview',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Review your complaint email before sending',
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Master Container for Email Preview Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Email Header Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
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
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'complaints@${(widget.alert?.airline.isNotEmpty == true ? widget.alert!.airline : "Air Peace").toLowerCase().replaceAll(" ", "")}.com',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 13,
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
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (() {
                            final alert = widget.alert;
                            final flightCode =
                                alert != null && alert.flightCode.isNotEmpty
                                    ? alert.flightCode
                                    : 'W3 205';

                            String dateStr = '27 Apr 2026';
                            if (alert != null && alert.createdAt.isNotEmpty) {
                              try {
                                final dt =
                                    DateTime.parse(alert.createdAt).toLocal();
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
                                dateStr =
                                    '${dt.day} ${monthsAbbr[dt.month - 1]} ${dt.year}';
                              } catch (_) {}
                            }

                            final issue =
                                alert != null && alert.eventType.isNotEmpty
                                    ? alert.eventType
                                    : 'Flight Cancellation';

                            return '$issue Complaint - $flightCode ($dateStr)';
                          })(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Attachments',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.38),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildAttachmentChip('Ticket.pdf'),
                              const SizedBox(width: 8),
                              _buildAttachmentChip('Passport.pdf'),
                              const SizedBox(width: 8),
                              _buildAttachmentChip('Notice.pdf'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Email Body Text Container (Scrollable)
                  if (_isLoadingAiEmail)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 22, right: 22, top: 16),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFFC229)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Gemini is drafting a short, professional email...',
                              style: TextStyle(
                                color:
                                    const Color(0xFFFFC229).withOpacity(0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: _isEditing
                        ? TextField(
                            controller: _emailBodyController,
                            maxLines: null,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                              fontSize: 13,
                              height: 1.45,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          )
                        : Text(
                            _emailBodyController.text,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons: Copy & Edit
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _copyToClipboard,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.copy,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Copy',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
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
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                      if (!_isEditing) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check,
                                    color: Color(0xFF10B981)),
                                const SizedBox(width: 10),
                                Text(
                                  'Changes saved successfully!',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isEditing ? Icons.save : Icons.edit,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEditing ? 'Save' : 'Edit',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tip Container
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFC229).withOpacity(0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFFFFC229),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tip:',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You can edit any part of this email. Dynamic fields like flight numbers and dates are highlighted for easy identification.',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.55),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bottom Continue to Send Options Button
            GestureDetector(
              onTap: () {
                final String emailTo =
                    'complaints@${(widget.alert?.airline.isNotEmpty == true ? widget.alert!.airline : "Air Peace").toLowerCase().replaceAll(" ", "")}.com';
                final alert = widget.alert;
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
                    dateStr =
                        '${dt.day} ${monthsAbbr[dt.month - 1]} ${dt.year}';
                  } catch (_) {}
                }

                final issue = alert != null && alert.eventType.isNotEmpty
                    ? alert.eventType
                    : 'Flight Cancellation';

                final String emailSubject =
                    '$issue Complaint - $flightCode ($dateStr)';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAuthoritiesScreen(
                      emailBody: _emailBodyController.text,
                      emailTo: emailTo,
                      emailSubject: emailSubject,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC229), // Yellow
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue to Send Options',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
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
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 3),
    );
  }

  Widget _buildAttachmentChip(String filename) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.link,
            color: Color(0xFF60A5FA),
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            filename,
            style: const TextStyle(
              color: Color(0xFF93C5FD),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
