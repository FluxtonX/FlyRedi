import 'package:flutter/material.dart';

class MonthlyUsageCard extends StatelessWidget {
  final VoidCallback onViewDetails;
  final VoidCallback onLimitTap;

  const MonthlyUsageCard({
    super.key,
    required this.onViewDetails,
    required this.onLimitTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101B30),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF263657)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Usage',
                style: TextStyle(color: Color(0xFF8D99AD), fontSize: 12),
              ),
              GestureDetector(
                onTap: onViewDetails,
                child: const Text(
                  'View details',
                  style: TextStyle(
                    color: Color(0xFFFFC229),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _UsageMiniRow(
            label: 'Flights',
            value: '2/2',
            locked: true,
            onTap: onLimitTap,
          ),
          const SizedBox(height: 10),
          _UsageMiniRow(
            label: 'Claims',
            value: '1/1',
            locked: true,
            onTap: onLimitTap,
          ),
          const SizedBox(height: 10),
          _UsageMiniRow(
            label: 'AI Questions',
            value: '5/5',
            locked: true,
            onTap: onLimitTap,
          ),
        ],
      ),
    );
  }
}

class _UsageMiniRow extends StatelessWidget {
  final String label;
  final String value;
  final bool locked;
  final VoidCallback onTap;

  const _UsageMiniRow({
    required this.label,
    required this.value,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked ? onTap : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF9CA7BC), fontSize: 12),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFFFF4D5E),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 7),
                  if (locked)
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFFF4D5E),
                      size: 14,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 1,
              minHeight: 5,
              backgroundColor: Color(0xFF38445A),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4D5E)),
            ),
          ),
        ],
      ),
    );
  }
}
