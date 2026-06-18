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
  bool _isManualMode = true; // true: Manual Entry, false: Upload Booking
  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _bookingRefController = TextEditingController();
  final TripRepository _tripRepository = TripRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  bool _isUploading = false;
  bool _isSavingTrip = false;
  bool _isLookingUpFlight = false;
  double _uploadProgress = 0.0;
  String? _uploadedFileName;
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
            content: const Text(
              'Flight details found and added.',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF10B981),
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

  void _simulateUpload() {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadedFileName = null;
    });

    // Simulate progress updates
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return false;
      setState(() {
        _uploadProgress += 0.2;
      });
      if (_uploadProgress >= 1.0) {
        setState(() {
          _uploadProgress = 1.0;
          _isUploading = false;
          _uploadedFileName = "Booking_Confirmation_BA112.pdf";
        });
        return false;
      }
      return true;
    });
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
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC229), // Yellow
              onPrimary: Colors.black,
              surface: Color(0xFF0C162A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0C162A),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Flight',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Start Sentinel™ monitoring',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sentinel Protection Info Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0C162A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC229).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFFFFC229),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sentinel™ Protection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Real-time monitoring for delays, cancellations, gate changes, and disruptions',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
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

            const SizedBox(height: 24),

            // Segmented Switcher Tab
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF0C162A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isManualMode = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isManualMode
                              ? const Color(0xFF08101E)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isManualMode
                                ? Colors.white.withOpacity(0.08)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flight_takeoff,
                              color: _isManualMode
                                  ? const Color(0xFFFFC229)
                                  : Colors.white60,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Manual Entry',
                              style: TextStyle(
                                color: _isManualMode
                                    ? Colors.white
                                    : Colors.white60,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isManualMode = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isManualMode
                              ? const Color(0xFF08101E)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: !_isManualMode
                                ? Colors.white.withOpacity(0.08)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_file_outlined,
                              color: !_isManualMode
                                  ? const Color(0xFFFFC229)
                                  : Colors.white60,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Upload Booking',
                              style: TextStyle(
                                color: !_isManualMode
                                    ? Colors.white
                                    : Colors.white60,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form container depending on selection
            _isManualMode ? _buildManualForm() : _buildUploadForm(),

            const SizedBox(height: 28),

            // Sentinel Checklist monitor
            const Text(
              'Sentinel™ will monitor for:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildCheckItem('Flight delays'),
                      const SizedBox(height: 10),
                      _buildCheckItem('Gate changes'),
                      const SizedBox(height: 10),
                      _buildCheckItem('Airport disruptions'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _buildCheckItem('Cancellations'),
                      const SizedBox(height: 10),
                      _buildCheckItem('Weather alerts'),
                      const SizedBox(height: 10),
                      _buildCheckItem('Connection risks'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 36),

            // Start Monitoring Button
            GestureDetector(
              onTap: _isSavingTrip
                  ? null
                  : () async {
                if (_isManualMode &&
                    _flightNumberController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Please enter a valid Flight Number.',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  return;
                }
                if (_isManualMode && _dateController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Please select a Departure Date.',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  return;
                }
                if (!_isManualMode && _uploadedFileName == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Please upload your booking confirmation first.',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
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

                  final lookupResult = _isManualMode
                      ? await _lookupFlightDetails()
                      : null;
                  final resolvedOrigin =
                      lookupResult?.origin ?? _originController.text.trim();
                  final resolvedDestination = lookupResult?.destination ??
                      _destinationController.text.trim();

                  if (_isManualMode &&
                      lookupResult == null &&
                      (resolvedOrigin.isEmpty || resolvedDestination.isEmpty)) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Flight not found automatically. Please enter origin and destination to save it manually.',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    return;
                  }

                  final trip = await _tripRepository.createTrip(
                    flightNumber:
                        _normalizeFlightNumber(_flightNumberController.text),
                    origin: resolvedOrigin,
                    destination: resolvedDestination,
                    departureDate: _dateController.text.trim(),
                    bookingReference:
                        _bookingRefController.text.trim().isEmpty
                            ? null
                            : _bookingRefController.text.trim(),
                    stops: 0,
                    timeline: const [],
                  );
                  await _tripRepository.enableTripLiveTracking(trip.id, true);

                  if (!mounted) return;
                  _showSuccessDialog(trip);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to save trip: $e',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
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
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC229), // Yellow
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isSavingTrip
                    ? const Center(
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
                    : const Row(
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
        const Text(
          'Flight Number',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _flightNumberController,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) {
            setState(() {
              _flightLookup = null;
              _flightLookupMessage = null;
            });
          },
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g., UA 2847',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
            fillColor: const Color(0xFF0C162A),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),

        const SizedBox(height: 20),

        // Origin
        const Text(
          'Origin (Optional)',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _originController,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g., SFO',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
            fillColor: const Color(0xFF0C162A),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),

        const SizedBox(height: 20),

        // Destination
        const Text(
          'Destination (Optional)',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _destinationController,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g., JFK',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
            fillColor: const Color(0xFF0C162A),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),

        const SizedBox(height: 20),

        // Departure Date
        const Text(
          'Departure Date',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _dateController,
          readOnly: true,
          onTap: () => _selectDate(context),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Select Date',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
            fillColor: const Color(0xFF0C162A),
            filled: true,
            suffixIcon: const Icon(Icons.calendar_today_outlined,
                color: Colors.white30, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),

        const SizedBox(height: 14),

        GestureDetector(
          onTap: (_isLookingUpFlight || _isSavingTrip)
              ? null
              : () async {
                  if (_flightNumberController.text.trim().isEmpty ||
                      _dateController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Enter flight number and departure date first.',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    return;
                  }
                  await _lookupFlightDetails(showSuccessSnack: true);
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _flightLookup != null
                    ? const Color(0xFF10B981).withOpacity(0.45)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            child: Row(
              children: [
                _isLookingUpFlight
                    ? const SizedBox(
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
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isLookingUpFlight
                        ? 'Finding flight details...'
                        : (_flightLookupMessage ?? 'Find flight details'),
                    style: TextStyle(
                      color: _flightLookup != null
                          ? const Color(0xFF10B981)
                          : Colors.white70,
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

        const SizedBox(height: 20),

        // Booking Reference (Optional)
        const Text(
          'Booking Reference (Optional)',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bookingRefController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g., ABC123',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
            fillColor: const Color(0xFF0C162A),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),

        const SizedBox(height: 18),

        // Tip Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0C162A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFFFC229),
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tip: Flight number and date let us find route details automatically. Add origin and destination if the provider cannot resolve the flight.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
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

  Widget _buildUploadForm() {
    return GestureDetector(
      onTap: _isUploading ? null : _simulateUpload,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF0C162A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _uploadedFileName != null
                ? const Color(0xFF10B981)
                : Colors.white.withOpacity(0.08),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            if (_isUploading) ...[
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Uploading... ${(_uploadProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else if (_uploadedFileName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F2D24),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _uploadedFileName!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap to upload a different file',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: Colors.white60,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload your booking confirmation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'PDF, email, or screenshot',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Color(0xFF10B981), // Green
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.black,
            size: 10,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog(TripModel trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF0C162A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F2D24),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF10B981),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sentinel™ Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'We are now actively monitoring your flight for delays, cancellations, and disruptions 24/7.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC229),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
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
