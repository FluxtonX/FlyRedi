import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/profile_provider.dart';

Future<bool?> showUpgradeToProDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.58),
    builder: (context) => const UpgradeToProDialog(),
  );
}

class UpgradeToProDialog extends StatefulWidget {
  const UpgradeToProDialog({super.key});

  @override
  State<UpgradeToProDialog> createState() => _UpgradeToProDialogState();
}

class _UpgradeToProDialogState extends State<UpgradeToProDialog> {
  bool _isLoading = false;

  Future<void> _handleUpgrade() async {
    setState(() => _isLoading = true);
    try {
      // Send request to update plan to Plus via ProfileProvider
      final profileProvider = context.read<ProfileProvider>();
      final success = await profileProvider.updateProfile(plan: 'Plus');

      if (!mounted) return;
      if (success) {
        Navigator.pop(context, true); // Return true indicating success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully upgraded to Pro! Welcome aboard.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upgrade: ${profileProvider.errorMessage}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upgrade: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(32, 28, 32, 28),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Theme.of(context).colorScheme.surface),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close,
                      color: Theme.of(context).colorScheme.onSurface, size: 24),
                ),
              ),
              SizedBox(height: 2),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flight_takeoff,
                        color: Color(0xFFFFC943),
                        size: 54,
                      ),
                    ),
                    const Positioned(
                      right: 12,
                      top: 10,
                      child: Icon(
                        Icons.workspace_premium_outlined,
                        color: Color(0xFFFFC943),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Add More Flights',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 14),
              Text(
                "You've reached your monthly\nlimit of 2 flights",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Included in Pro:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 10),
              const _DialogFeature(text: 'Monitor unlimited flights'),
              const _DialogFeature(text: 'Real-time disruption alerts'),
              const _DialogFeature(
                  text: 'WhatsApp + Email + Push\nnotifications'),
              const _DialogFeature(text: 'Advanced flight risk analysis'),
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF5A4D25)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Traveler Pro',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$9',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 30,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  '/month',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.workspace_premium_outlined,
                      color: Color(0xFFFFC943),
                      size: 24,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpgrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC229),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.workspace_premium_outlined, size: 19),
                            SizedBox(width: 12),
                            Text(
                              'Upgrade to Pro',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Maybe Later',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogFeature extends StatelessWidget {
  final String text;

  const _DialogFeature({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(Icons.check, color: Color(0xFFFFC943), size: 20),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
