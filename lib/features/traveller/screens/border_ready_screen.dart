import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../../../../core/constants/countries_data.dart';
import '../../../../core/constants/airlines_data.dart';
import '../../../../core/widgets/searchable_bottom_sheet.dart';
import '../widgets/traveller_bottom_nav.dart';

class BorderReadyScreen extends StatefulWidget {
  BorderReadyScreen({super.key});

  @override
  State<BorderReadyScreen> createState() => _BorderReadyScreenState();
}

class _BorderReadyScreenState extends State<BorderReadyScreen> {
  // Existing Documents switches
  bool _hasReturnTicket = false;
  bool _hasProofOfFunds = false;
  bool _travellingWithMinor = false;
  bool _alreadyHasVisa = false;

  // Pet Travel switch
  bool _travellingWithPet = false;
  bool _hasRequiredVaccinations = false;
  bool _hasMicrochip = false;

  // Form Field State
  Map<String, String>? _nationality;
  bool _isChecking = false;
  Map<String, String>? _residence;
  Map<String, String>? _destination;
  List<Map<String, String>> _transitCountries = [];
  Map<String, String>? _airline;
  DateTime? _passportExpiry;

  final TextEditingController _stayDurationController = TextEditingController();
  final TextEditingController _petTypeController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _petAgeController = TextEditingController();

  @override
  void dispose() {
    _stayDurationController.dispose();
    _petTypeController.dispose();
    _breedController.dispose();
    _petAgeController.dispose();
    super.dispose();
  }

  void _showCountrySelection(String title, Function(Map<String, String>) onSelected) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchableBottomSheet(
        title: title,
        hintText: 'Search countries...',
        items: CountriesData.countries,
        onSelected: onSelected,
      ),
    );
  }

  void _showAirlineSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchableBottomSheet(
        title: 'Select Airline',
        hintText: 'Search airlines...',
        items: AirlinesData.airlines,
        onSelected: (item) {
          setState(() {
            _airline = item;
          });
        },
      ),
    );
  }

  void _showTransitCountriesSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchableBottomSheet(
        title: 'Select Transit Countries',
        hintText: 'Search countries...',
        items: CountriesData.countries,
        isMultiSelect: true,
        initialSelectedItems: _transitCountries,
        onSelected: (_) {}, // Handled on pop
      ),
    ).then((selected) {
      if (selected != null && selected is List<Map<String, String>>) {
        setState(() {
          _transitCountries = selected;
        });
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _passportExpiry ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _passportExpiry) {
      setState(() {
        _passportExpiry = picked;
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
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BorderReady™',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'IATA Timatic-grade AI — visa, transit, health &\npassport compliance.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
        toolbarHeight: 90,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Grid
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildGridItem(
                          icon: Icons.language,
                          title: 'Visa Requirements',
                          subtitle: 'Real-time eligibility',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildGridItem(
                          icon: Icons.flight_takeoff,
                          title: 'Transit Compliance',
                          subtitle: 'Layover permissions',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildGridItem(
                          icon: Icons.shield_outlined,
                          title: 'Health Checks',
                          subtitle: 'COVID & vaccination',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildGridItem(
                          icon: Icons.description_outlined,
                          title: 'Document Checklist',
                          subtitle: 'Entry requirements',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Action Cards
            _buildActionCard(
              icon: Icons.mail_outline,
              title: 'Forward confirmation email to\nauto-fill',
              subtitle: 'Send booking to ai@borderready.app',
              onTap: () => _showEmailDialog(context),
            ),
            SizedBox(height: 12),
            _buildActionCard(
              icon: Icons.document_scanner_outlined,
              title: 'Scan passport or visa',
              subtitle: 'Instant OCR extraction',
              onTap: () => _showScanDialog(context),
            ),

            SizedBox(height: 32),

            // TRIP DETAILS SECTION
            _buildSectionTitle('TRIP DETAILS'),
            SizedBox(height: 16),
            _buildDropdownField(
              label: 'NATIONALITY',
              hint: 'Select country',
              icon: Icons.language,
              value: _nationality?['name'],
              onTap: () => _showCountrySelection('Select Nationality', (val) => setState(() => _nationality = val)),
            ),
            SizedBox(height: 16),
            _buildDropdownField(
              label: 'COUNTRY OF RESIDENCE',
              hint: 'Where you live',
              icon: Icons.location_on_outlined,
              value: _residence?['name'],
              onTap: () => _showCountrySelection('Select Residence', (val) => setState(() => _residence = val)),
            ),
            SizedBox(height: 16),
            _buildDropdownField(
              label: 'DESTINATION',
              hint: 'Final destination',
              icon: Icons.location_on_outlined,
              value: _destination?['name'],
              onTap: () => _showCountrySelection('Select Destination', (val) => setState(() => _destination = val)),
            ),
            SizedBox(height: 16),
            _buildMultiSelectDropdownField(
              label: 'TRANSIT COUNTRIES',
              hint: 'Add layover countries',
              icon: Icons.flight_takeoff,
              selectedItems: _transitCountries,
              onTap: _showTransitCountriesSelection,
              onRemove: (item) {
                setState(() {
                  _transitCountries.removeWhere((e) => e['code'] == item['code']);
                });
              },
            ),
            SizedBox(height: 16),
            _buildDropdownField(
              label: 'AIRLINE / CARRIER',
              hint: 'e.g., Emirates, Lufthansa',
              icon: Icons.flight_takeoff,
              value: _airline?['name'],
              onTap: _showAirlineSelection,
            ),
            SizedBox(height: 16),
            _buildDropdownField(
              label: 'PASSPORT EXPIRY',
              hint: 'MM/YYYY',
              icon: Icons.calendar_today_outlined,
              value: _passportExpiry != null 
                  ? "${_passportExpiry!.month.toString().padLeft(2, '0')}/${_passportExpiry!.year}"
                  : null,
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16),
            _buildTextField(
              label: 'STAY DURATION',
              hint: 'Number of days',
              icon: Icons.calendar_today_outlined,
              controller: _stayDurationController,
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 32),

            // EXISTING DOCUMENTS SECTION
            _buildSectionTitle('EXISTING DOCUMENTS'),
            SizedBox(height: 16),
            _buildSwitchRow('Has return ticket', _hasReturnTicket, (val) => setState(() => _hasReturnTicket = val)),
            SizedBox(height: 12),
            _buildSwitchRow('Has proof of funds', _hasProofOfFunds, (val) => setState(() => _hasProofOfFunds = val)),
            SizedBox(height: 12),
            _buildSwitchRow('Travelling with a minor', _travellingWithMinor, (val) => setState(() => _travellingWithMinor = val)),
            SizedBox(height: 12),
            _buildSwitchRow('Already has visa', _alreadyHasVisa, (val) => setState(() => _alreadyHasVisa = val)),

            SizedBox(height: 32),

            // PET TRAVEL SECTION
            _buildSectionTitle('PET TRAVEL'),
            SizedBox(height: 16),
            _buildSwitchRow(
              'Travelling with pet',
              _travellingWithPet,
              (val) => setState(() => _travellingWithPet = val),
              activeTrackColor: const Color(0xFF10B981), // Green track
            ),
            if (_travellingWithPet) ...[
              SizedBox(height: 16),
              _buildTextField(
                label: 'PET TYPE',
                hint: 'Dog, Cat, etc.',
                icon: Icons.favorite_border,
                controller: _petTypeController,
              ),
              SizedBox(height: 16),
              _buildTextField(
                label: 'BREED',
                hint: 'Breed name',
                icon: Icons.favorite_border,
                controller: _breedController,
              ),
              SizedBox(height: 16),
              _buildTextField(
                label: 'PET AGE',
                hint: 'Age in years',
                icon: Icons.calendar_today_outlined,
                controller: _petAgeController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              _buildSwitchRow('Has required vaccinations', _hasRequiredVaccinations, (val) => setState(() => _hasRequiredVaccinations = val)),
              SizedBox(height: 12),
              _buildSwitchRow('Has microchip', _hasMicrochip, (val) => setState(() => _hasMicrochip = val)),
            ],

            SizedBox(height: 40),

            // Run Check Button
            GestureDetector(
              onTap: _isChecking
                  ? null
                  : () async {
                      if (_nationality == null || _destination == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Please fill in Nationality and Destination.',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Color(0xFF1E293B),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 6,
                            margin: EdgeInsets.all(16),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isChecking = true;
                      });

                      await Future.delayed(const Duration(seconds: 2));

                      if (mounted) {
                        setState(() {
                          _isChecking = false;
                        });
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                              side: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, shape: BoxShape.circle),
                                    child: Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 48),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    'BorderReady™ Check Complete',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'You have the required documents to travel to ${_destination!['name']}. Have a safe flight!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 13, height: 1.45),
                                  ),
                                  SizedBox(height: 28),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(color: Color(0xFFFFC229), borderRadius: BorderRadius.circular(14)),
                                      alignment: Alignment.center,
                                      child: Text('Done', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: _isChecking ? Theme.of(context).colorScheme.surface : const Color(0xFFFFC229),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!_isChecking)
                      BoxShadow(
                        color: Color(0xFFFFC229).withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isChecking)
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onSurface)),
                      )
                    else ...[
                      Icon(Icons.search, color: Colors.black, size: 20),
                      SizedBox(width: 8),
                      Text('Run BorderReady™ Check', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const TravellerBottomNav(),
    );
  }

  Widget _buildGridItem({required IconData icon, required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF3B82F6), size: 22), 
        SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required String subtitle, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFFFC229).withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFFFC229), size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.auto_awesome, color: Color(0xFFFFC229), size: 16),
        ],
      ),
    ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 20),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      color: value != null ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required List<Map<String, String>> selectedItems,
    required VoidCallback onTap,
    required Function(Map<String, String>) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 20),
                SizedBox(width: 16),
                Expanded(
                  child: selectedItems.isEmpty
                      ? Text(
                          hint,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                            fontSize: 14,
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedItems.map((item) {
                            return Chip(
                              label: Text(
                                item['name'] ?? '',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
                              ),
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              deleteIconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                              onDeleted: () => onRemove(item),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                ),
                Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
            decoration: InputDecoration(
              icon: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 20),
              hintText: hint,
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged, {Color? activeColor, Color? activeTrackColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor ?? Theme.of(context).colorScheme.onSurface,
            activeTrackColor: activeTrackColor ?? Theme.of(context).colorScheme.onSurface,
            inactiveThumbColor: Theme.of(context).colorScheme.onSurface,
            inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paste flight confirmation email',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 20),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: 160,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: TextFormField(
                    maxLines: null,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Copy and paste your airline confirmation\nemail here (subject line + full body)...',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), fontSize: 14, height: 1.4),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC229),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFFC229).withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.black, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Extract & Auto-Fill',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showScanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SCAN TRAVEL DOCUMENT',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 20),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFFFFC229).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.upload_file, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 24),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tap or drag passport/visa image',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'JPG, PNG, or PDF — max 10MB',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC229),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFFC229).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Scan & Auto-Fill',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Uses AI to extract name, dates, and passport info — data is not stored',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 10,
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
