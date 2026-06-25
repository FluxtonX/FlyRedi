import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';

class ClaimStatusScreen extends StatelessWidget {
  final String flightCode;
  final String route;
  final String date;
  final String submittedDate;
  final String amount;
  final String status;

  const ClaimStatusScreen({
    super.key,
    required this.flightCode,
    required this.route,
    required this.date,
    required this.submittedDate,
    required this.amount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Claim Status',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Main Info Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Claim #1',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            flightCode,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            route,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  Divider(color: Theme.of(context).colorScheme.outline),
                  SizedBox(height: 12),
                  _buildStatusRow(context, 'Flight Date', date),
                  SizedBox(height: 8),
                  _buildStatusRow(context, 'Submitted', submittedDate),
                  SizedBox(height: 8),
                  _buildStatusRow(context, 'Claim Amount', amount, isGold: true),
                ],
              ),
            ),

            SizedBox(height: 28),

            // Claim Progress Section Header
            Text(
              'Claim Progress',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Progress Node timeline
            Container(
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                children: [
                  _buildTimelineNode(context, 
                    title: 'Claim Submitted',
                    date: submittedDate,
                    isCompleted: true,
                    isLast: false,
                  ),
                  _buildTimelineNode(context, 
                    title: 'Under Review',
                    date: 'May 17, 2026',
                    isCompleted: true,
                    isLast: false,
                  ),
                  _buildTimelineNode(context, 
                    title: 'Awaiting Response',
                    date: 'Pending',
                    isCompleted: false,
                    isLast: false,
                  ),
                  _buildTimelineNode(context, 
                    title: 'Payment Processed',
                    date: 'Pending',
                    isCompleted: false,
                    isLast: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // View Documents Card
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
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
                      Icons.description_outlined,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View Documents',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Boarding pass, complaint letter',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 2),
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, String value, {bool isGold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isGold ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(BuildContext context, {
    required String title,
    required String date,
    required bool isCompleted,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? Color(0xFFFFC229).withOpacity(0.12) : Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? Icon(Icons.check, size: 12, color: Color(0xFFFFC229))
                    : Icon(Icons.access_time, size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: isCompleted ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isCompleted ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: isCompleted ? Theme.of(context).colorScheme.onSurface.withOpacity(0.54) : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
