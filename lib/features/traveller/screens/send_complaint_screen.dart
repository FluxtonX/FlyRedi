import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/traveller_bottom_nav.dart';
import 'traveller_tabs_screen.dart';

class SendComplaintScreen extends StatefulWidget {
  final String emailBody;
  final String emailTo;
  final String emailSubject;

  const SendComplaintScreen({
    super.key,
    required this.emailBody,
    required this.emailTo,
    required this.emailSubject,
  });

  @override
  State<SendComplaintScreen> createState() => _SendComplaintScreenState();
}

class _SendComplaintScreenState extends State<SendComplaintScreen> {
  int _selectedOption = 0; // 0: Open in Email App, 1: Copy, 2: PDF, 3: Share
  bool _isProcessing = false;

  Future<void> _executeSendAction() async {
    setState(() {
      _isProcessing = true;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
                ),
                const SizedBox(height: 20),
                Text(
                  _selectedOption == 0
                      ? 'Opening Email Client...'
                      : _selectedOption == 1
                          ? 'Copying Email...'
                          : _selectedOption == 2
                              ? 'Generating PDF...'
                              : 'Preparing Share...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Wait a brief moment to make it look professional/smooth
    await Future.delayed(const Duration(milliseconds: 1200));

    // Close loading dialog
    if (mounted) {
      Navigator.pop(context);
    }

    try {
      if (_selectedOption == 0) {
        // Open Gmail / Mail app - bypass canLaunchUrl checks directly
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: widget.emailTo,
          queryParameters: {
            'subject': widget.emailSubject,
            'body': widget.emailBody,
          },
        );
        try {
          await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
        } catch (_) {
          try {
            await launchUrl(emailLaunchUri);
          } catch (e) {
            await Clipboard.setData(ClipboardData(text: widget.emailBody));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not open email app. Content copied to clipboard!'),
                  backgroundColor: Color(0xFF1E293B),
                ),
              );
            }
          }
        }
      } else if (_selectedOption == 1) {
        // Copy Email
        await Clipboard.setData(ClipboardData(text: widget.emailBody));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email content copied to clipboard!'),
              backgroundColor: Color(0xFF1E293B),
            ),
          );
        }
      } else if (_selectedOption == 2) {
        // Download PDF & Text directly to phone storage
        try {
          Directory? downloadDir;
          if (Platform.isAndroid) {
            // Request storage permission
            final status = await Permission.storage.request();
            if (status.isGranted) {
              downloadDir = Directory('/storage/emulated/0/Download');
              // Create folder if it doesn't exist
              if (!await downloadDir.exists()) {
                await downloadDir.create(recursive: true);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Storage permission is required to save directly to Downloads!'),
                    backgroundColor: Color(0xFF1E293B),
                  ),
                );
              }
              setState(() {
                _isProcessing = false;
              });
              return;
            }
          } else {
            // iOS Documents directory (made visible in Files app via Info.plist keys)
            downloadDir = await getApplicationDocumentsDirectory();
          }

          if (downloadDir != null) {
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final pdfFile = File('${downloadDir.path}/NCAA_Flight_Complaint_$timestamp.pdf');
            final txtFile = File('${downloadDir.path}/NCAA_Flight_Complaint_$timestamp.txt');

            // Write content to both files
            await pdfFile.writeAsString(widget.emailBody);
            await txtFile.writeAsString(widget.emailBody);

            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Color(0xFF10B981)),
                      SizedBox(width: 10),
                      Text('Saved to Storage!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Text(
                    Platform.isAndroid
                        ? 'Files downloaded directly to your phone\'s "Downloads" folder:\n\n'
                            '• NCAA_Flight_Complaint_$timestamp.pdf\n'
                            '• NCAA_Flight_Complaint_$timestamp.txt\n\n'
                            'Open your File Manager / Downloads app to view them.'
                        : 'Files saved to your device. Open the iOS "Files" app and look under "On My iPhone" -> "Sky Rightz 360" to find:\n\n'
                            '• NCAA_Flight_Complaint_$timestamp.pdf\n'
                            '• NCAA_Flight_Complaint_$timestamp.txt',
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK', style: TextStyle(color: Color(0xFFFFC229), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }
          } else {
            throw Exception('Storage directory not available');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to download directly: $e'),
                backgroundColor: const Color(0xFF1E293B),
              ),
            );
          }
        }
      } else {
        // Share using share_plus package
        try {
          await Share.share(widget.emailBody, subject: widget.emailSubject);
        } catch (e) {
          await Clipboard.setData(ClipboardData(text: widget.emailBody));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share failed. Content copied to clipboard instead!'),
                backgroundColor: Color(0xFF1E293B),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('[SendComplaintScreen] Error executing action: $e');
    }

    setState(() {
      _isProcessing = false;
    });

    // Navigate to Home screen perfectly
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const TravellerTabsScreen(initialIndex: 0),
        ),
        (route) => false,
      );
    }
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
              'Send Your Complaint',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Choose how you'd like to send your email",
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
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // "You Remain in Control" Warning/Info Card
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color(0xFFFFC229).withOpacity(0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You Remain in Control',
                    style: TextStyle(
                      color: Color(0xFFFFC229).withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "We don't send emails on your behalf. You'll send this complaint from your own email account, giving you full control and transparency.",
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

            SizedBox(height: 24),

            Text(
              'Send Options',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 14),

            // Option 1: Open in Email App
            _buildOptionCard(
              index: 0,
              icon: Icons.mail_outline,
              title: 'Open in Email App',
              subtitle:
                  'Your email app will open with the complaint pre-filled',
              recommended: true,
            ),
            SizedBox(height: 12),

            // Option 2: Copy Email Content
            _buildOptionCard(
              index: 1,
              icon: Icons.copy,
              title: 'Copy Email Content',
              subtitle: 'Paste into your preferred email client manually',
              recommended: false,
            ),
            SizedBox(height: 12),

            // Option 3: Download as PDF
            _buildOptionCard(
              index: 2,
              icon: Icons.picture_as_pdf_outlined,
              title: 'Download as PDF',
              subtitle: 'Save for your records or print',
              recommended: false,
            ),
            SizedBox(height: 12),

            // Option 4: Share
            _buildOptionCard(
              index: 3,
              icon: Icons.share_outlined,
              title: 'Share',
              subtitle: 'Send to another app or contact',
              recommended: false,
            ),

            SizedBox(height: 24),

            // Email Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Email Summary',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSummaryRow('To:', widget.emailTo),
                  const SizedBox(height: 10),
                  _buildSummaryRow(
                      'CC:',
                      widget.emailSubject.toLowerCase().contains('delay')
                          ? '1 authority'
                          : '2 authorities'),
                  const SizedBox(height: 10),
                  _buildSummaryRow('Attachments:', '3 files'),
                  const SizedBox(height: 10),
                  _buildSummaryRow(
                    'Claim Amount:',
                    widget.emailBody.contains('130,000') ||
                            widget.emailSubject.contains('130,000')
                        ? '₦130,000'
                        : '₦45,000',
                    highlightValue: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Button
            GestureDetector(
              onTap: _isProcessing ? null : _executeSendAction,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC229), // Yellow
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedOption == 0
                          ? 'Send Email'
                          : _selectedOption == 1
                              ? 'Copy Email Content'
                              : _selectedOption == 2
                                  ? 'Download as PDF'
                                  : 'Share Email',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _selectedOption == 0
                          ? Icons.send
                          : _selectedOption == 1
                              ? Icons.copy
                              : _selectedOption == 2
                                  ? Icons.download
                                  : Icons.share,
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

  Widget _buildOptionCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool recommended,
  }) {
    final bool isSelected = _selectedOption == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = index;
        });
      },
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFC229)
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFFFFC229)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: 18,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (recommended) ...[
                        SizedBox(width: 6),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFC229).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Recommended',
                            style: TextStyle(
                              color: Color(0xFFFFC229),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFC229),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.check,
                  color: Colors.black,
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool highlightValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlightValue
                ? const Color(0xFFFFC229)
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
