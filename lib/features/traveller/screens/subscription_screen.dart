import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../presentation/providers/profile_provider.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.user;
    final isPro = profile?.plan == 'Pro';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Subscription',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Current Plan Card ──
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isPro
                      ? const Color(0xFFFFC229).withOpacity(0.3)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  width: 1,
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
                          Text(
                            'Current Plan',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isPro ? 'Traveler Pro' : 'Free Plan',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (isPro)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFC229)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.workspace_premium_outlined,
                                color: Color(0xFFFFC229),
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'PRO',
                                style: TextStyle(
                                  color: Color(0xFFFFC229),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    height: 1,
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(context, 'Price', isPro ? '\$9/month' : '\$0/month', valueBold: true),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, isPro ? 'Next billing date' : 'Status', isPro ? 'June 15, 2026' : 'Active'),
                  if (isPro) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(context, 'Payment method', '•••• 4242'),
                  ],
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      if (profile != null) {
                        final targetPlan = isPro ? 'Free' : 'Pro';
                        final profileProvider = context.read<ProfileProvider>();
                        final success = await profileProvider.updateProfile(plan: targetPlan);
                        if (success && context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isPro ? Theme.of(context).colorScheme.surface : const Color(0xFFFFC229),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isPro ? Theme.of(context).colorScheme.onSurface.withOpacity(0.1) : Colors.transparent,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isPro ? 'Cancel Subscription' : 'Upgrade to Pro',
                        style: TextStyle(
                          color: isPro ? Theme.of(context).colorScheme.onSurface : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Pro Benefits ──
            Text(
              'Pro Benefits',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBenefitItem(context, 'Unlimited flight monitoring'),
            _buildBenefitItem(context, 'Real-time WhatsApp alerts'),
            _buildBenefitItem(context, 'Unlimited claims & AI letters'),
            _buildBenefitItem(context, 'Advanced compensation estimates'),
            _buildBenefitItem(context, 'PDF export & smart reminders'),
            _buildBenefitItem(context, 'Priority support access'),

            const SizedBox(height: 32),

            // ── Billing Management ──
            if (isPro) ...[
              Text(
                'Billing Management',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildMenuItem(context, Icons.credit_card_outlined, 'Payment Methods'),
              _buildMenuItem(context, Icons.receipt_long_outlined, 'Billing History'),
              GestureDetector(
                onTap: () async {
                  if (profile != null) {
                    final profileProvider = context.read<ProfileProvider>();
                    final success = await profileProvider.updateProfile(plan: 'Free');
                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: _buildMenuItem(
                  context,
                  Icons.event_busy_outlined,
                  'Cancel Subscription',
                  isDestructive: true,
                ),
              ),
              const SizedBox(height: 32),
            ],

            // ── Need Help ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need help?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Contact our support team for any billing questions',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool valueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
            fontSize: 15,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check,
            color: Color(0xFF10B981), // Emerald green
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String text, {
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? const Color(0xFFEF4444) // Red
        : Theme.of(context).colorScheme.onSurface;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(isDestructive ? 1.0 : 0.6), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: color.withOpacity(0.4),
            size: 22,
          ),
        ],
      ),
    );
  }
}
