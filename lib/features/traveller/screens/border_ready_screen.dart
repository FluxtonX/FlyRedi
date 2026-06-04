import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';

class BorderReadyScreen extends StatefulWidget {
  const BorderReadyScreen({super.key});

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BorderReady™',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'IATA Timatic-grade AI — visa, transit, health &\npassport compliance.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Grid
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0C162A),
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGridItem(
                          icon: Icons.flight_takeoff,
                          title: 'Transit Compliance',
                          subtitle: 'Layover permissions',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                      const SizedBox(width: 16),
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

            const SizedBox(height: 24),

            // Action Cards
            _buildActionCard(
              icon: Icons.mail_outline,
              title: 'Forward confirmation email to\nauto-fill',
              subtitle: 'Send booking to ai@borderready.app',
              onTap: () => _showEmailDialog(context),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              icon: Icons.document_scanner_outlined,
              title: 'Scan passport or visa',
              subtitle: 'Instant OCR extraction',
              onTap: () => _showScanDialog(context),
            ),

            const SizedBox(height: 32),

            // TRIP DETAILS SECTION
            _buildSectionTitle('TRIP DETAILS'),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'NATIONALITY',
              hint: 'Select country',
              icon: Icons.language,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'COUNTRY OF RESIDENCE',
              hint: 'Where you live',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'DESTINATION',
              hint: 'Final destination',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'TRANSIT COUNTRIES',
              hint: 'Add layover countries',
              icon: Icons.flight_takeoff,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'AIRLINE / CARRIER',
              hint: 'e.g., Emirates, Lufthansa',
              icon: Icons.flight_takeoff,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'PASSPORT EXPIRY',
              hint: 'MM/YYYY',
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'STAY DURATION',
              hint: 'Number of days',
              icon: Icons.calendar_today_outlined,
            ),

            const SizedBox(height: 32),

            // EXISTING DOCUMENTS SECTION
            _buildSectionTitle('EXISTING DOCUMENTS'),
            const SizedBox(height: 16),
            _buildSwitchRow('Has return ticket', _hasReturnTicket, (val) => setState(() => _hasReturnTicket = val)),
            const SizedBox(height: 12),
            _buildSwitchRow('Has proof of funds', _hasProofOfFunds, (val) => setState(() => _hasProofOfFunds = val)),
            const SizedBox(height: 12),
            _buildSwitchRow('Travelling with a minor', _travellingWithMinor, (val) => setState(() => _travellingWithMinor = val)),
            const SizedBox(height: 12),
            _buildSwitchRow('Already has visa', _alreadyHasVisa, (val) => setState(() => _alreadyHasVisa = val)),

            const SizedBox(height: 32),

            // PET TRAVEL SECTION
            _buildSectionTitle('PET TRAVEL'),
            const SizedBox(height: 16),
            _buildSwitchRow(
              'Travelling with pet',
              _travellingWithPet,
              (val) => setState(() => _travellingWithPet = val),
              activeTrackColor: const Color(0xFF10B981), // Green track
            ),
            if (_travellingWithPet) ...[
              const SizedBox(height: 16),
              _buildTextField(
                label: 'PET TYPE',
                hint: 'Dog, Cat, etc.',
                icon: Icons.favorite_border,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'BREED',
                hint: 'Breed name',
                icon: Icons.favorite_border,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'PET AGE',
                hint: 'Age in years',
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 16),
              _buildSwitchRow('Has required vaccinations', _hasRequiredVaccinations, (val) => setState(() => _hasRequiredVaccinations = val)),
              const SizedBox(height: 12),
              _buildSwitchRow('Has microchip', _hasMicrochip, (val) => setState(() => _hasMicrochip = val)),
            ],

            const SizedBox(height: 40),

            // Run Check Button
            GestureDetector(
              onTap: () {
                // Action for Run BorderReady Check
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC229),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC229).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Run BorderReady™ Check',
                      style: TextStyle(
                         color: Colors.black,
                         fontSize: 16,
                         fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
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
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white54,
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
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFC229).withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFFFC229), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.auto_awesome, color: Color(0xFFFFC229), size: 16),
        ],
      ),
    ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0C162A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.white54, size: 20),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged, {Color? activeColor, Color? activeTrackColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor ?? Colors.white,
            activeTrackColor: activeTrackColor ?? Colors.white,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
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
          backgroundColor: const Color(0xFF0C162A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Paste flight confirmation email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white54, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071120),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: TextFormField(
                    maxLines: null,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Copy and paste your airline confirmation\nemail here (subject line + full body)...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14, height: 1.4),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC229),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFC229).withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
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
          backgroundColor: const Color(0xFF0C162A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SCAN TRAVEL DOCUMENT',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white54, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071120),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFC229).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.upload_file, color: Colors.white54, size: 24),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tap or drag passport/visa image',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'JPG, PNG, or PDF — max 10MB',
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC229),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC229).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Scan & Auto-Fill',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Uses AI to extract name, dates, and passport info — data is not stored',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
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
