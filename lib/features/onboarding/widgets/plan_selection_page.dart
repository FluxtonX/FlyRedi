import 'package:flutter/material.dart';

class PlanSelectionPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onContinueFree;
  final VoidCallback onUpgradeToPro;

  const PlanSelectionPage({
    super.key,
    required this.onBack,
    required this.onContinueFree,
    required this.onUpgradeToPro,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 26, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF9AA8BD),
                    size: 26,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 34,
                    minHeight: 34,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Get the protection you need',
                      style: TextStyle(
                        color: Color(0xFF8D99AD),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            _BasicPlanCard(onContinueFree: onContinueFree),
            const SizedBox(height: 18),
            _ProPlanCard(onUpgradeToPro: onUpgradeToPro),
            const SizedBox(height: 36),
            const Center(
              child: Text(
                'Trusted by frequent travelers worldwide',
                style: TextStyle(
                  color: Color(0xFF7C879A),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                '✓ Cancel anytime   ✓ Secure payments',
                style: TextStyle(
                  color: Color(0xFF8D99AD),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasicPlanCard extends StatelessWidget {
  final VoidCallback onContinueFree;

  const _BasicPlanCard({required this.onContinueFree});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF111F45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2B3B68), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bolt_outlined,
                color: Color(0xFF93A2BB),
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Traveler Basic',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF17274F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Current Plan',
                  style: TextStyle(
                    color: Color(0xFF9CA8BC),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Free',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFF29375D), thickness: 1),
          const SizedBox(height: 12),
          const _FeatureRow(text: '2 flights per month'),
          const _FeatureRow(text: 'Basic Sentinel™ monitoring'),
          const _FeatureRow(text: 'Basic BorderReady™ checklist'),
          const _FeatureRow(text: '1 claim per month'),
          const _FeatureRow(text: '1 AI complaint letter/month'),
          const _FeatureRow(text: '5 AI Assistant questions/month'),
          const _FeatureRow(text: 'Email notifications only'),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onContinueFree,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF2B3B68), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Continue Free',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProPlanCard extends StatelessWidget {
  final VoidCallback onUpgradeToPro;

  const _ProPlanCard({required this.onUpgradeToPro});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF08182F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFC229), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC229),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF08182F), size: 14),
                  SizedBox(width: 4),
                  Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: Color(0xFF08182F),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(Icons.workspace_premium_outlined,
                  color: Color(0xFFFFC229), size: 24),
              SizedBox(width: 10),
              Text(
                'Traveler Pro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'N 3,900',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Text(
                  '/month',
                  style: TextStyle(
                    color: Color(0xFF8E98A8),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Cancel anytime',
            style: TextStyle(
              color: Color(0xFF8E98A8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFF564A22), thickness: 1),
          const SizedBox(height: 12),
          const _FeatureRow(text: 'Unlimited flight monitoring', pro: true),
          const _FeatureRow(text: 'Real-time disruption alerts', pro: true),
          const _FeatureRow(text: 'WhatsApp + Email + Push alerts', pro: true),
          const _FeatureRow(
            text: 'Full BorderReady™ with smart guidance',
            pro: true,
          ),
          const _FeatureRow(
            text: 'Unlimited claims & AI letters',
            pro: true,
          ),
          const _FeatureRow(
            text: 'Advanced compensation estimates',
            pro: true,
          ),
          const _FeatureRow(text: 'PDF claim packet export', pro: true),
          const _FeatureRow(text: 'Unlimited AI Assistant', pro: true),
          const _FeatureRow(text: 'Smart follow-up reminders', pro: true),
          const _FeatureRow(text: 'Priority support', pro: true),
          const SizedBox(height: 18),
          SizedBox(
            height: 64,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onUpgradeToPro,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC943),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Row(
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
          const SizedBox(height: 20),
          const Center(
            child: Text(
              '7-day free trial • No credit card required',
              style: TextStyle(
                color: Color(0xFF8E98A8),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  final bool pro;

  const _FeatureRow({
    required this.text,
    this.pro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check,
            color: pro ? const Color(0xFFFFC229) : const Color(0xFF96A4B9),
            size: 18,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: pro ? Colors.white : const Color(0xFF9AA5B8),
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
