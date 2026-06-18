import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../repositories/flight_api_service.dart';
import '../widgets/traveller_bottom_nav.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FlightStatusScreen
// Accepts an optional flightNumber + flightDate to pre-fill the search.
// When navigated from TripOverview or FlightDetailScreen you can pass the
// values directly; the user can also search manually from within this screen.
// ─────────────────────────────────────────────────────────────────────────────

class FlightStatusScreen extends StatefulWidget {
  final String? initialFlightNumber;
  final String? initialFlightDate;

  const FlightStatusScreen({
    super.key,
    this.initialFlightNumber,
    this.initialFlightDate,
  });

  @override
  State<FlightStatusScreen> createState() => _FlightStatusScreenState();
}

class _FlightStatusScreenState extends State<FlightStatusScreen>
    with SingleTickerProviderStateMixin {
  final _flightNumberController = TextEditingController();
  final _flightDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  FlightStatusModel? _result;
  bool _isLoading = false;
  String? _error;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.initialFlightNumber != null) {
      _flightNumberController.text = widget.initialFlightNumber!;
    }
    if (widget.initialFlightDate != null) {
      _flightDateController.text = widget.initialFlightDate!;
    }

    // Auto-fetch if pre-filled
    if (widget.initialFlightNumber != null &&
        widget.initialFlightNumber!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchStatus());
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flightNumberController.dispose();
    _flightDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await FlightApiService.fetchFlightStatus(
        _flightNumberController.text,
        flightDate: _flightDateController.text,
      );
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: Color(0xFF102B5C),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _flightDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
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
        title: const Text(
          'Live Flight Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
        actions: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, __) => Container(
              margin: const EdgeInsets.only(right: 20, top: 14, bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2D24),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color.lerp(
                    const Color(0xFF10B981).withOpacity(0.2),
                    const Color(0xFF10B981).withOpacity(0.6),
                    _pulseAnimation.value,
                  )!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        const Color(0xFF10B981).withOpacity(0.5),
                        const Color(0xFF10B981),
                        _pulseAnimation.value,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Live',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Search Card ──────────────────────────────────────────────
            _SearchCard(
              formKey: _formKey,
              flightNumberController: _flightNumberController,
              flightDateController: _flightDateController,
              isLoading: _isLoading,
              onPickDate: _pickDate,
              onSearch: _fetchStatus,
            ),

            const SizedBox(height: 20),

            // ── Loading ──────────────────────────────────────────────────
            if (_isLoading) const _LoadingCard(),

            // ── Error ────────────────────────────────────────────────────
            if (_error != null) _ErrorCard(message: _error!),

            // ── Result ───────────────────────────────────────────────────
            if (_result != null) ...[
              _StatusBadgeCard(result: _result!),
              const SizedBox(height: 16),
              _RouteCard(result: _result!),
              const SizedBox(height: 16),
              _TimeCard(result: _result!),
              const SizedBox(height: 16),
              if (_result!.isDelayed) ...[
                _DelayAlertCard(result: _result!),
                const SizedBox(height: 16),
              ],
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const TravellerBottomNav(activeIndex: 1),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SearchCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController flightNumberController;
  final TextEditingController flightDateController;
  final bool isLoading;
  final VoidCallback onPickDate;
  final VoidCallback onSearch;

  const _SearchCard({
    required this.formKey,
    required this.flightNumberController,
    required this.flightDateController,
    required this.isLoading,
    required this.onPickDate,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.flight_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Track a Flight',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Real-time data via Aviationstack',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Flight Number Field
            TextFormField(
              controller: flightNumberController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              decoration: _inputDecoration(
                label: 'Flight Number',
                hint: 'e.g. EK203',
                icon: Icons.confirmation_number_outlined,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Flight number is required'
                  : null,
            ),

            const SizedBox(height: 12),

            // Date Field (optional)
            TextFormField(
              controller: flightDateController,
              readOnly: true,
              onTap: onPickDate,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDecoration(
                label: 'Flight Date (optional)',
                hint: 'YYYY-MM-DD',
                icon: Icons.calendar_today_outlined,
                suffixIcon: flightDateController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white38, size: 16),
                        onPressed: () => flightDateController.clear(),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 18),

            // Search Button
            GestureDetector(
              onTap: isLoading ? null : onSearch,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: isLoading
                      ? AppColors.primary.withOpacity(0.5)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, color: Colors.black, size: 17),
                          SizedBox(width: 8),
                          Text(
                            'Check Status',
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
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.white30, size: 16),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE11D48)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFE11D48), width: 1.5),
      ),
      errorStyle:
          const TextStyle(color: Color(0xFFE11D48), fontSize: 11),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 16),
          Text(
            'Fetching live flight data…',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error card ────────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A0A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE11D48).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFE11D48), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Badge Card ─────────────────────────────────────────────────────────
class _StatusBadgeCard extends StatelessWidget {
  final FlightStatusModel result;
  const _StatusBadgeCard({required this.result});

  (Color bg, Color text, IconData icon) get _statusTheme {
    switch (result.status.toLowerCase()) {
      case 'active':
        return (
          const Color(0xFF0F2D24),
          const Color(0xFF10B981),
          Icons.flight_takeoff_rounded
        );
      case 'active_delayed':
        return (
          const Color(0xFF1E1A00),
          const Color(0xFFFFAB40),
          Icons.flight_takeoff_rounded
        );
      case 'landed_estimated':
        return (
          const Color(0xFF002929),
          const Color(0xFF2DD4BF),   // teal — estimated, not confirmed
          Icons.flight_land_rounded
        );
      case 'landed':
        return (
          const Color(0xFF0F2030),
          const Color(0xFF3B82F6),
          Icons.flight_land_rounded
        );
      case 'cancelled':
        return (
          const Color(0xFF1A0A0A),
          const Color(0xFFE11D48),
          Icons.cancel_outlined
        );
      case 'delayed':
        return (
          const Color(0xFF1E1400),
          const Color(0xFFFFC229),
          Icons.access_time_filled_rounded
        );
      case 'diverted':
        return (
          const Color(0xFF1A1000),
          const Color(0xFFFF8C00),
          Icons.alt_route_rounded
        );
      default: // scheduled
        return (
          const Color(0xFF0C1830),
          const Color(0xFF818CF8),
          Icons.schedule_rounded
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    final (bg, accent, icon) = _statusTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Flight number + status badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.airline.name.isEmpty
                        ? result.airline.iata
                        : result.airline.name,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.flightNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: accent, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      result.statusLabel,
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (result.flightDate.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              result.flightDate,
              style: const TextStyle(color: Colors.white30, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Route Card ────────────────────────────────────────────────────────────────
class _RouteCard extends StatelessWidget {
  final FlightStatusModel result;
  const _RouteCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Origin → Destination
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.departure.iata,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    result.departure.airport,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primary.withOpacity(0.7),
                size: 26,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    result.arrival.iata,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    result.arrival.airport,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ],
          ),

          Divider(
              color: Colors.white.withOpacity(0.04),
              height: 28),

          // Terminal / Gate rows
          if (result.departure.terminal != null)
            _row(Icons.domain_outlined, 'Terminal (Dep)',
                result.departure.terminal!),
          if (result.departure.gate != null) ...[
            const SizedBox(height: 8),
            _row(Icons.door_sliding_outlined, 'Gate (Dep)',
                result.departure.gate!),
          ],
          if (result.arrival.terminal != null) ...[
            const SizedBox(height: 8),
            _row(Icons.domain_outlined, 'Terminal (Arr)',
                result.arrival.terminal!),
          ],
          if (result.arrival.gate != null) ...[
            const SizedBox(height: 8),
            _row(Icons.door_sliding_outlined, 'Gate (Arr)',
                result.arrival.gate!),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white30, size: 14),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.35), fontSize: 12)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ── Time Card ─────────────────────────────────────────────────────────────────
class _TimeCard extends StatelessWidget {
  final FlightStatusModel result;
  const _TimeCard({required this.result});

  String _formatTime(String iso) {
    if (iso.isEmpty) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _timeBlock(
                  label: 'Departure',
                  scheduled: _formatTime(result.departure.scheduled),
                  estimated: _formatTime(result.departure.estimated),
                  isDelayed: result.isDelayed,
                ),
              ),
              Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withOpacity(0.06)),
              Expanded(
                child: _timeBlock(
                  label: 'Arrival',
                  scheduled: _formatTime(result.arrival.scheduled),
                  estimated: _formatTime(result.arrival.estimated),
                  isDelayed: false,
                  align: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBlock({
    required String label,
    required String scheduled,
    required String estimated,
    required bool isDelayed,
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    final showEstimated =
        estimated.isNotEmpty && estimated != '—' && estimated != scheduled;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            scheduled,
            style: TextStyle(
              color: (isDelayed && showEstimated)
                  ? Colors.white30
                  : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              decoration: (isDelayed && showEstimated)
                  ? TextDecoration.lineThrough
                  : null,
              decorationColor: Colors.white38,
            ),
          ),
          if (showEstimated) ...[
            const SizedBox(height: 4),
            Text(
              estimated,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Delay Alert Card ──────────────────────────────────────────────────────────
class _DelayAlertCard extends StatelessWidget {
  final FlightStatusModel result;
  const _DelayAlertCard({required this.result});

  String get _delayText {
    final h = result.delayMinutes ~/ 60;
    final m = result.delayMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m delay';
    if (h > 0) return '${h}h delay';
    return '${m}m delay';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.access_time_filled_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flight Delayed — $_delayText',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.delayMinutes >= 180
                      ? 'Your delay may qualify for compensation under passenger rights regulations.'
                      : 'Monitor for further updates. Contact the airline for rebooking options.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                if (result.delayMinutes >= 180) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: AppColors.primary.withOpacity(0.8),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Compensation may apply',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
