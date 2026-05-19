import 'package:flutter/material.dart';

class EntryMethodTabs extends StatelessWidget {
  final bool isManualEntryActive;
  final VoidCallback onManualEntryTap;
  final VoidCallback onUploadBookingTap;

  const EntryMethodTabs({
    super.key,
    required this.isManualEntryActive,
    required this.onManualEntryTap,
    required this.onUploadBookingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onManualEntryTap,
            child: _buildTab(
              icon: Icons.flight_takeoff,
              label: 'Manual Entry',
              isActive: isManualEntryActive,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: onUploadBookingTap,
            child: _buildTab(
              icon: Icons.upload_file,
              label: 'Upload Booking',
              isActive: !isManualEntryActive,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0C1931) : const Color(0xFF101B30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive 
              ? const Color(0xFFFFC229) 
              : Colors.white.withOpacity(0.08),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFFFC229) : Colors.white54,
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
