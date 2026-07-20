import 'package:flutter/material.dart';
import '../models/alert_model.dart';

class DisruptionDetailsCard extends StatelessWidget {
  final AlertModel? alert;

  const DisruptionDetailsCard({super.key, this.alert});

  @override
  Widget build(BuildContext context) {
    final flightCode = alert != null && alert!.flightCode.isNotEmpty
        ? alert!.flightCode
        : 'W3 205';
    final airline = alert != null && alert!.airline.isNotEmpty
        ? alert!.airline
        : 'Air Peace';
    
    // Status text mapping
    String status = 'CANCELLED';
    if (alert != null) {
      if (alert!.eventType.toLowerCase().contains('cancel')) {
        status = 'CANCELLED';
      } else if (alert!.eventType.toLowerCase().contains('delay')) {
        status = 'DELAYED';
      } else {
        status = alert!.eventType.toUpperCase();
      }
    }

    // Extract route
    String route = 'Lagos (LOS) → Abuja (ABV)';
    if (alert != null && alert!.message.contains('(') && alert!.message.contains(')')) {
      final startIndex = alert!.message.indexOf('(');
      final endIndex = alert!.message.indexOf(')');
      if (endIndex > startIndex) {
        final content = alert!.message.substring(startIndex + 1, endIndex);
        if (content.contains('→')) {
          route = content;
        } else if (content.contains('to')) {
          route = content.replaceAll('to', '→');
        } else if (content.contains('-')) {
          route = content.replaceAll('-', '→');
        }
      }
    }

    // Format date & time
    String dateStr = 'April 27, 2026';
    String timeStr = '14:00 WAT';
    if (alert != null && alert!.createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(alert!.createdAt).toLocal();
        final months = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        timeStr = '$hour:$minute WAT';
      } catch (_) {}
    }

    // Status color mapping
    final isDelay = status == 'DELAYED';
    final statusColor = isDelay ? const Color(0xFFFFC229) : const Color(0xFFE11D48);

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // Dark blue card bg
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDelay ? Icons.access_time_filled : Icons.warning_amber_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Flight $flightCode',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      airline,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24),
          Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05), height: 1),
          SizedBox(height: 24),

          // Row 2: Route details
          _buildDetailRow(context, 
            icon: Icons.flight_takeoff,
            label: 'Route',
            value: route,
          ),
          SizedBox(height: 20),

          // Row 3: Date
          _buildDetailRow(context, 
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: dateStr,
          ),
          SizedBox(height: 20),

          // Row 4: Scheduled time
          _buildDetailRow(context, 
            icon: Icons.access_time,
            label: 'Scheduled Time',
            value: timeStr,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            size: 16,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
