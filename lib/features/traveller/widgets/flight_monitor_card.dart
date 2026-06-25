import 'package:flutter/material.dart';
import '../screens/flight_detail_screen.dart';

class FlightMonitorCard extends StatelessWidget {
  const FlightMonitorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FlightDetailScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
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
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'UA 2847',
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
                        'MEDIUM RISK',
                        style: TextStyle(
                          color: Color(0xFFFFC229),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 26),

            /// FLIGHT ROUTE
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 24,
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
                        'SFO',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 28,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '10:45 AM',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Transform.rotate(
                    angle: -0.8,
                    child: Icon(
                      Icons.flight,
                      color: Color(0xFFFFC229),
                      size: 34,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'JFK',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 28,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Monitoring',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 28),

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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 14),
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
                          '68%',
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      '2',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 34,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 28),

            Text(
              'May 15, 2026',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
