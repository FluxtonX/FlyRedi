import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import 'package:sky_rightz_360/features/traveller/repositories/trip_repository.dart';
import '../models/trip_model.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../utils/add_flight_navigation.dart';
import '../widgets/traveller_bottom_nav.dart';
import '../widgets/upgrade_to_pro_dialog.dart';
import 'sentinel_monitor_screen.dart';

class AddFlightScreen extends StatefulWidget {
  const AddFlightScreen({super.key});

  @override
  State<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _bookingRefController = TextEditingController();
  final TripRepository _tripRepository = TripRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  bool _isSavingTrip = false;
  bool _isLookingUpFlight = false;
  FlightLookupResult? _flightLookup;
  String? _flightLookupMessage;

  @override
  void dispose() {
    _flightNumberController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _bookingRefController.dispose();
    super.dispose();
  }

  String _normalizeFlightNumber(String value) {
    return value.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }

  Future<FlightLookupResult?> _lookupFlightDetails({
    bool showSuccessSnack = false,
  }) async {
    final flightNumber = _normalizeFlightNumber(_flightNumberController.text);
    final departureDate = _dateController.text.trim();

    if (flightNumber.isEmpty || departureDate.isEmpty) {
      setState(() {
        _flightLookup = null;
        _flightLookupMessage = null;
      });
      return null;
    }

    setState(() {
      _isLookingUpFlight = true;
      _flightLookupMessage = null;
    });

    try {
      final result = await _tripRepository.lookupFlight(
        flightNumber: flightNumber,
        departureDate: departureDate,
      );
      final airlinePrefix =
          result.airline.isNotEmpty ? '${result.airline} ' : '';

      if (!mounted) return result;
      setState(() {
        _flightLookup = result;
        _flightNumberController.text = result.flightNumber;
        if (result.flightDate.isNotEmpty) {
          _dateController.text = result.flightDate;
        }
        if (result.origin.isNotEmpty) {
          _originController.text = result.origin;
        }
        if (result.destination.isNotEmpty) {
          _destinationController.text = result.destination;
        }
        _flightLookupMessage =
            '$airlinePrefix${result.origin} → ${result.destination} found via Aviationstack';
      });

      if (showSuccessSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Flight details found and added.',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      return result;
    } catch (e) {
      if (mounted) {
        setState(() {
          _flightLookup = null;
          _flightLookupMessage =
              'Could not find this flight automatically. You can still enter origin and destination manually.';
        });
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isLookingUpFlight = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day);
    final lastDate = DateTime(today.year + 5, today.month, today.day);
    final selectedDate = DateTime.tryParse(_dateController.text);
    final initialDate =
        selectedDate != null && !selectedDate.isBefore(firstDate)
            ? selectedDate
            : firstDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _flightLookup = null;
        _flightLookupMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Flight',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Start Sentinel™ monitoring',
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sentinel Protection Info Card
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
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFC229).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: Color(0xFFFFC229),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sentinel™ Protection',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Real-time monitoring for delays, cancellations, gate changes, and disruptions',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Form container
            _buildManualForm(),

            SizedBox(height: 28),

            // Sentinel Checklist monitor
            Text(
              'Sentinel™ will monitor for:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildCheckItem('Flight delays'),
                      SizedBox(height: 10),
                      _buildCheckItem('Gate changes'),
                      SizedBox(height: 10),
                      _buildCheckItem('Airport disruptions'),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _buildCheckItem('Cancellations'),
                      SizedBox(height: 10),
                      _buildCheckItem('Weather alerts'),
                      SizedBox(height: 10),
                      _buildCheckItem('Connection risks'),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 36),

            // Start Monitoring Button
            GestureDetector(
              onTap: _isSavingTrip
                  ? null
                  : () async {
                      if (_flightNumberController.text.trim().isEmpty) {
                        _showCustomSnackBar(
                            'Please enter a valid Flight Number.');
                        return;
                      }
                      if (_dateController.text.trim().isEmpty) {
                        _showCustomSnackBar('Please select a Departure Date.');
                        return;
                      }

                      setState(() {
                        _isSavingTrip = true;
                      });

                      try {
                        final results = await Future.wait([
                          _tripRepository.fetchUserTrips(),
                          _profileRepository.getProfile(),
                        ]);
                        final trips = results[0] as List;
                        final profile = results[1] as UserProfile;

                        if (!profile.hasUnlimitedFlightMonitoring &&
                            trips.length >= freeFlightLimit) {
                          if (!mounted) return;
                          showUpgradeToProDialog(context);
                          return;
                        }

                        // Always fetch flight details from radar to guarantee accuracy
                        // This prevents user typos or OCR errors from overriding the real route
                        final lookupResult = await _lookupFlightDetails();

                        if (lookupResult == null) {
                          if (!mounted) return;
                          _showCustomSnackBar(
                              'Flight record not found on live radar networks. Please verify the flight number.',
                              isError: true);
                          setState(() {
                            _isSavingTrip = false;
                          });
                          return;
                        }

                        final resolvedOrigin = lookupResult.origin.isNotEmpty
                            ? lookupResult.origin
                            : _originController.text.trim();
                        final resolvedDestination =
                            lookupResult.destination.isNotEmpty
                                ? lookupResult.destination
                                : _destinationController.text.trim();

                        final trip = await _tripRepository.createTrip(
                          flightNumber: _normalizeFlightNumber(
                              _flightNumberController.text),
                          origin: resolvedOrigin,
                          destination: resolvedDestination,
                          departureDate: _dateController.text.trim(),
                          status: lookupResult.status,
                          bookingReference:
                              _bookingRefController.text.trim().isEmpty
                                  ? null
                                  : _bookingRefController.text.trim(),
                          stops: 0,
                          timeline: const [],
                        );
                        await _tripRepository.enableTripLiveTracking(
                            trip.id, true);

                        if (!mounted) return;
                        _showSuccessDialog(trip);
                      } catch (e) {
                        if (!mounted) return;
                        _showCustomSnackBar('Failed to save trip: $e');
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isSavingTrip = false;
                          });
                        }
                      }
                    },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC229), // Yellow
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isSavingTrip
                    ? Center(
                        child: SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: Colors.black,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Start Monitoring',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
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
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 1),
    );
  }

  Widget _buildManualForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Flight Number
        Text(
          'Flight Number',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _flightNumberController,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) {
            setState(() {
              _flightLookup = null;
              _flightLookupMessage = null;
            });
          },
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g., UA 2847',
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                fontSize: 14),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),

        SizedBox(height: 20),

        // Origin
        Text(
          'Origin (Optional)',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _originController,
          textCapitalization: TextCapitalization.characters,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g., SFO',
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                fontSize: 14),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),

        SizedBox(height: 20),

        // Destination
        Text(
          'Destination (Optional)',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _destinationController,
          textCapitalization: TextCapitalization.characters,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g., JFK',
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                fontSize: 14),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),

        SizedBox(height: 20),

        // Departure Date
        Text(
          'Departure Date',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _dateController,
          readOnly: true,
          onTap: () => _selectDate(context),
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Select Date',
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                fontSize: 14),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            suffixIcon: Icon(Icons.calendar_today_outlined,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),

        SizedBox(height: 14),

        GestureDetector(
          onTap: (_isLookingUpFlight || _isSavingTrip)
              ? null
              : () async {
                  if (_flightNumberController.text.trim().isEmpty ||
                      _dateController.text.trim().isEmpty) {
                    _showCustomSnackBar(
                        'Enter flight number and departure date first.');
                    return;
                  }
                  await _lookupFlightDetails(showSuccessSnack: true);
                },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _flightLookup != null
                    ? Color(0xFF10B981).withOpacity(0.45)
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            child: Row(
              children: [
                _isLookingUpFlight
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
                        ),
                      )
                    : Icon(
                        _flightLookup != null
                            ? Icons.check_circle_outline
                            : Icons.travel_explore,
                        color: _flightLookup != null
                            ? const Color(0xFF10B981)
                            : const Color(0xFFFFC229),
                        size: 18,
                      ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isLookingUpFlight
                        ? 'Finding flight details...'
                        : (_flightLookupMessage ?? 'Find flight details'),
                    style: TextStyle(
                      color: _flightLookup != null
                          ? const Color(0xFF10B981)
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 20),

        // Booking Reference (Optional)
        Text(
          'Booking Reference (Optional)',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _bookingRefController,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g., ABC123',
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                fontSize: 14),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),

        SizedBox(height: 18),

        // Tip Info card
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFFFC229),
                size: 16,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tip: Flight number and date let us find route details automatically. Add origin and destination if the provider cannot resolve the flight.',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildCheckItem(String label) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Color(0xFF10B981), // Green
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: Colors.black,
            size: 10,
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showCustomSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline,
              color:
                  isError ? const Color(0xFFE11D48) : const Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            const Color(0xFF1E293B), // Premium dark theme background
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog(TripModel trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF10B981),
                    size: 48,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Sentinel™ Active',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'We are now actively monitoring your flight for delays, cancellations, and disruptions 24/7.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 28),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Pop dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SentinelMonitorScreen(
                          initialTrip: trip,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC229),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
