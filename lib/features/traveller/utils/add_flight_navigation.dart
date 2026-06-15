import 'package:flutter/material.dart';

import '../screens/add_flight_screen.dart';
import '../widgets/upgrade_to_pro_dialog.dart';

const int freeFlightLimit = 2;

Future<void> openAddFlightWithLimit({
  required BuildContext context,
  required int currentTrips,
  required bool hasUnlimitedFlights,
  Future<void> Function()? onReturn,
}) async {
  if (!hasUnlimitedFlights && currentTrips >= freeFlightLimit) {
    showUpgradeToProDialog(context);
    return;
  }

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AddFlightScreen(),
    ),
  );

  await onReturn?.call();
}
