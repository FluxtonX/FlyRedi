import 'package:flutter/material.dart';

class ExpensesHeader extends StatelessWidget {
  final bool showAddIcon;
  final VoidCallback? onAddPressed;

  const ExpensesHeader({
    super.key,
    this.showAddIcon = true,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white70,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
            const Text(
              'Expenses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (showAddIcon)
          IconButton(
            onPressed: onAddPressed,
            icon: const Icon(
              Icons.add,
              color: Colors.white70,
              size: 28,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}
