import 'package:flutter/material.dart';
import '../screens/flight_detail_screen.dart';
import '../models/trip_model.dart';

class FlightMonitorCard extends StatelessWidget {
  final TripModel? activeTrip;

  const FlightMonitorCard({super.key, this.activeTrip});

  @override
  Widget build(BuildContext context) {
    if (activeTrip == null) return const SizedBox.shrink();

    final timelineFirst =
        activeTrip!.timeline.isNotEmpty ? activeTrip!.timeline.first : null;
    final riskLevel = timelineFirst?.riskLevel?.toUpperCase() ?? 'LOW RISK';
    final riskColor = riskLevel.contains('HIGH')
        ? const Color(0xFFEF4444)
        : riskLevel.contains('MEDIUM')
            ? const Color(0xFFFFC229)
            : const Color(0xFF10B981);
    final delayProb = timelineFirst?.delayProb ?? '0%';
    final activeAlerts = timelineFirst?.activeAlerts?.toString() ?? '0';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FlightDetailScreen(trip: activeTrip!)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP ROW
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sentinel™ Monitoring',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.38),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        activeTrip!.flightNumber.isEmpty
                            ? 'Flight'
                            : activeTrip!.flightNumber,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Color(0xFFFFC229),
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        activeTrip!.status.toUpperCase(),
                        style: TextStyle(
                          color: riskColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            /// FLIGHT ROUTE
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        activeTrip!.origin.isEmpty ? 'N/A' : activeTrip!.origin,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 25,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Departure',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.54),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Transform.rotate(
                    angle: -0.8,
                    child: const Icon(
                      Icons.flight,
                      color: Color(0xFFFFC229),
                      size: 34,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        activeTrip!.destination.isEmpty
                            ? 'N/A'
                            : activeTrip!.destination,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 25,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Arrival',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.54),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            /// STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delay Probability',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.54),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 120,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 68,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFC229,
                                ),
                                borderRadius: BorderRadius.circular(
                                  20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        Text(
                          delayProb,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Active Alerts',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.54),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      activeAlerts,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 2),

            Text(
              activeTrip!.departureDate.isEmpty
                  ? 'Date not set'
                  : activeTrip!.departureDate,
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
