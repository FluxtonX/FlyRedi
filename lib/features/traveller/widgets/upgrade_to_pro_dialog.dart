import 'package:flutter/material.dart';

void showUpgradeToProDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.58),
    builder: (context) => const UpgradeToProDialog(),
  );
}

class UpgradeToProDialog extends StatelessWidget {
  const UpgradeToProDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
        decoration: BoxDecoration(
          color: const Color(0xFF111F45),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF34466F)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2B3348),
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
              const SizedBox(height: 28),
              const Text(
                'Add More Flights',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "You've reached your monthly\nlimit of 2 flights",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9CA7BC),
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Included in Pro:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9CA7BC),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              const _DialogFeature(text: 'Monitor unlimited flights'),
              const _DialogFeature(text: 'Real-time disruption alerts'),
              const _DialogFeature(text: 'WhatsApp + Email + Push\nnotifications'),
              const _DialogFeature(text: 'Advanced flight risk analysis'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF202837),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF5A4D25)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Traveler Pro',
                            style: TextStyle(
                              color: Color(0xFF9CA7BC),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$9',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  '/month',
                                  style: TextStyle(
                                    color: Color(0xFF9CA7BC),
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
              const SizedBox(height: 26),
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(
                    color: Colors.white,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF343946),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.check, color: Color(0xFFFFC943), size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
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
