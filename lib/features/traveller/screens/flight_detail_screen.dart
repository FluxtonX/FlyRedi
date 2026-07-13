import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../models/trip_model.dart';
import 'flight_details_screen.dart';
import 'border_ready_screen.dart';
import 'sentinel_monitor_screen.dart';
import 'ai_assistant_screen.dart';
import 'live_flight_tracker_screen.dart';

class FlightDetailScreen extends StatelessWidget {
  final TripModel trip;

  const FlightDetailScreen({super.key, required this.trip});

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
          'Flight Details',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 24, top: 12, bottom: 12),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF10B981).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, color: Color(0xFF10B981), size: 12),
                SizedBox(width: 4),
                Text(
                  'Protected',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // UA 2847 Flight Information Card
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.timeline.isNotEmpty ? (trip.timeline.first.airlineCode ?? 'Airline') : 'Airline',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            trip.flightNumber.isEmpty ? 'N/A' : trip.flightNumber,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: trip.status.toLowerCase() == 'delayed' ? Color(0xFFFFC229).withOpacity(0.1) : Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trip.status.toUpperCase(),
                          style: TextStyle(
                            color: trip.status.toLowerCase() == 'delayed' ? Color(0xFFFFC229) : Color(0xFF10B981),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.origin.isEmpty ? 'N/A' : trip.origin,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Departure',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.swap_horiz,
                        color: Color(0xFFFFC229).withOpacity(0.8),
                        size: 28,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            trip.destination.isEmpty ? 'N/A' : trip.destination,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Arrival',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Divider(color: Theme.of(context).colorScheme.outline),
                  SizedBox(height: 16),
                  _buildFlightDetailRow(context, Icons.calendar_today_outlined, 'Date', trip.departureDate.isEmpty ? 'TBD' : trip.departureDate),
                  SizedBox(height: 12),
                  _buildFlightDetailRow(context, Icons.access_time_outlined, 'Duration', trip.timeline.isNotEmpty ? (trip.timeline.first.duration ?? '—') : '—'),
                  SizedBox(height: 12),
                  _buildFlightDetailRow(context, Icons.domain_outlined, 'Terminal', '—'),
                  SizedBox(height: 12),
                  _buildFlightDetailRow(context, Icons.door_sliding_outlined, 'Gate', '—'),
                ],
              ),
            ),

            SizedBox(height: 16),



            // Sentinel™ Active Status Box
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Color(0xFFFFC229).withOpacity(0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: Color(0xFFFFC229),
                    size: 22,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sentinel™ Active',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Real-time monitoring enabled with instant alerts for any changes',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SentinelMonitorScreen()),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                              ),
                            ),
                            child: Text(
                              'View Monitoring Dashboard',
                              style: TextStyle(
                                color: Color(0xFFFFC229),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            if (trip.status.toLowerCase() == 'delayed' || trip.status.toLowerCase() == 'cancelled') ...[
              // Flight Delayed Box
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.red.withOpacity(0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flight Delayed',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your flight status has changed',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                        SizedBox(height: 16),
                        Divider(color: Theme.of(context).colorScheme.outline),
                        SizedBox(height: 12),
                        _buildDelayRow(context, 'Departure', trip.timeline.isNotEmpty ? (trip.timeline.first.fromTime ?? 'TBD') : 'TBD'),
                        SizedBox(height: 8),
                        _buildDelayRow(context, 'Arrival', trip.timeline.isNotEmpty ? (trip.timeline.first.toTime ?? 'TBD') : 'TBD'),
                        SizedBox(height: 8),
                        _buildDelayRow(context, 'Status', trip.status.toUpperCase(), valueColor: const Color(0xFFFFC229)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Resolution Assistant™ Box
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        color: Color(0xFFFFC229),
                        size: 22,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Resolution Assistant™',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Flight ${trip.flightNumber} ${trip.status.toLowerCase()}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your flight delay may qualify for compensation under EU261/2004. We recommend contacting the airline for immediate rebooking options and filing a compensation claim within 6 months.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 18),

                  // Compensation Eligible Gold Box
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFC229).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFFFFC229).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: Color(0xFFFFC229).withOpacity(0.8),
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Compensation Eligible',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\$600',
                          style: TextStyle(
                            color: Color(0xFFFFC229),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  Text(
                    'Recommended Next Steps:',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 14),
                  _buildStepRow(context, 1, 'Contact airline customer service desk'),
                  SizedBox(height: 12),
                  _buildStepRow(context, 2, 'Request meal vouchers (delay exceeds 2 hours)'),
                  SizedBox(height: 12),
                  _buildStepRow(context, 3, 'File compensation claim for EU261 eligibility'),

                  SizedBox(height: 24),

                  // Button 1: Start Claim Process
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FlightDetailsScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC229),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Start Claim Process',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Button 2: Get AI Assistance
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Get AI Assistance',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ],

            SizedBox(height: 16),

            // Check BorderReady™ Status Box
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BorderReadyScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Check BorderReady™ Status',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 1),
    );
  }

  Widget _buildFlightDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), size: 15),
        SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDelayRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Row(
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
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(BuildContext context, int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Color(0xFFFFC229),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
