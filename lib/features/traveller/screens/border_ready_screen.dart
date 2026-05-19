import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';

class BorderReadyScreen extends StatefulWidget {
  const BorderReadyScreen({super.key});

  @override
  State<BorderReadyScreen> createState() => _BorderReadyScreenState();
}

class _BorderReadyScreenState extends State<BorderReadyScreen> {
  bool _isTravellingWithPet = true;
  String? _petType;
  final TextEditingController _breedController = TextEditingController(text: 'French Bulldog');
  final TextEditingController _ageController = TextEditingController(text: '18');
  
  bool _isMicrochipped = true;
  bool _isRabiesVaccinated = true;
  bool _hasHealthCertificate = false;

  @override
  void dispose() {
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'BorderReady™',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Travel to United Kingdom',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Readiness Score Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0C162A),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFFFC229).withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Readiness Score',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '75%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC229).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flight_takeoff,
                          color: Color(0xFFFFC229),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Divider(color: Colors.white.withOpacity(0.04)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildScoreCount('9', 'Ready', const Color(0xFF10B981)),
                      _buildScoreCount('2', 'Review', const Color(0xFFFFC229)),
                      _buildScoreCount('1', 'Action Needed', const Color(0xFFEF4444)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Passport Section
            _buildSectionHeader(Icons.menu_book, 'Passport'),
            const SizedBox(height: 12),
            _buildItemCard(
              title: 'Passport Validity',
              description: 'Valid until Jan 2028 (2+ years remaining)',
              status: _ItemStatus.ready,
            ),
            const SizedBox(height: 10),
            _buildItemCard(
              title: 'Blank Pages',
              description: '4 blank pages available',
              status: _ItemStatus.ready,
            ),
            const SizedBox(height: 10),
            _buildItemCard(
              title: 'Damage Check',
              description: 'No visible damage detected',
              status: _ItemStatus.ready,
            ),

            const SizedBox(height: 24),

            // Visa & Entry Section
            _buildSectionHeader(Icons.language, 'Visa & Entry'),
            const SizedBox(height: 12),
            _buildItemCard(
              title: 'Visa Requirements',
              description: 'Visa-free entry for US citizens (180 days)',
              status: _ItemStatus.ready,
            ),
            const SizedBox(height: 10),
            _buildItemCard(
              title: 'ESTA/eTA',
              description: 'Not required for UK entry',
              status: _ItemStatus.ready,
            ),
            const SizedBox(height: 10),
            _buildItemCard(
              title: 'Return Ticket',
              description: 'Recommended to have proof of onward travel',
              status: _ItemStatus.review,
            ),

            const SizedBox(height: 24),

            // Health & Safety Section
            _buildSectionHeader(Icons.health_and_safety_outlined, 'Health & Safety'),
            const SizedBox(height: 12),
            _buildItemCard(
              title: 'COVID-19 Requirements',
              description: 'Check latest guidelines before departure',
              status: _ItemStatus.review,
            ),
            const SizedBox(height: 10),
            _buildItemCard(
              title: 'Travel Insurance',
              description: 'Strongly recommended for international travel',
              status: _ItemStatus.action,
            ),
            const SizedBox(height: 10),
            _buildItemCard(
              title: 'Emergency Contacts',
              description: 'Embassy contacts saved',
              status: _ItemStatus.ready,
            ),

            const SizedBox(height: 24),

            // Travel Advisory Section
            _buildSectionHeader(Icons.error_outline, 'Travel Advisory'),
            const SizedBox(height: 12),
            _buildItemCard(
              title: 'Safety Level',
              description: 'Level 1: Exercise normal precautions',
              status: _ItemStatus.ready,
            ),
            const SizedBox(height: 10),
            _buildItemCard(
              title: 'Entry Restrictions',
              description: 'No current restrictions',
              status: _ItemStatus.ready,
            ),
            const SizedBox(height: 10),
            _buildItemCard(
              title: 'Local Alerts',
              description: 'No active alerts',
              status: _ItemStatus.ready,
            ),

            const SizedBox(height: 24),

            // Travelling with a Pet Card
            _buildTravellingWithPetCard(),

            const SizedBox(height: 24),

            // Important Reminder Warning Box (Styled to match Figma layout)
            _buildImportantReminder(),

            const SizedBox(height: 28),

            // Download Button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Checklist downloaded successfully.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFF0C162A),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC229),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Download Full Checklist',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Share Button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Checklist shared with travel companion.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFF0C162A),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C162A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Share with Travel Companion',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const TravellerBottomNav(),
    );
  }

  Widget _buildScoreCount(String count, String label, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFFC229),
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard({
    required String title,
    required String description,
    required _ItemStatus status,
  }) {
    IconData statusIcon;
    Color statusColor;

    switch (status) {
      case _ItemStatus.ready:
        statusIcon = Icons.check_circle_outlined;
        statusColor = const Color(0xFF10B981);
        break;
      case _ItemStatus.review:
        statusIcon = Icons.warning_amber_outlined;
        statusColor = const Color(0xFFFFC229);
        break;
      case _ItemStatus.action:
        statusIcon = Icons.cancel_outlined;
        statusColor = const Color(0xFFEF4444);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          Icon(
            statusIcon,
            color: statusColor,
            size: 18,
          ),
          const SizedBox(width: 14),
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
                  description,
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
    );
  }

  Widget _buildTravellingWithPetCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Travelling with a Pet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch(
                value: _isTravellingWithPet,
                onChanged: (val) {
                  setState(() {
                    _isTravellingWithPet = val;
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF3B82F6),
                inactiveThumbColor: Colors.white24,
                inactiveTrackColor: Colors.white10,
              ),
            ],
          ),
          if (_isTravellingWithPet) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 16),

            // Pet Type Dropdown
            const Text(
              'Pet Type',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF071120),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: _petType,
                  dropdownColor: const Color(0xFF071120),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFFC229)),
                  hint: const Text(
                    'Select pet type.',
                    style: TextStyle(color: Colors.white30, fontSize: 13),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  items: ['Dog', 'Cat', 'Bird', 'Other']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _petType = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Breed Text Field
            const Text(
              'Breed (important for restricted breed checks)',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF071120),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: TextFormField(
                controller: _breedController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'e.g. French Bulldog',
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pet Age Text Field
            const Text(
              'Pet Age (months)',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF071120),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'e.g. 18',
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Toggle Switches List
            _buildPetToggleRow(
              'Pet is microchipped (ISO 11784/11785)',
              _isMicrochipped,
              (val) {
                setState(() {
                  _isMicrochipped = val;
                });
              },
            ),
            _buildPetToggleRow(
              'Rabies vaccination up to date',
              _isRabiesVaccinated,
              (val) {
                setState(() {
                  _isRabiesVaccinated = val;
                });
              },
            ),
            _buildPetToggleRow(
              'Has current veterinary health certificate',
              _hasHealthCertificate,
              (val) {
                setState(() {
                  _hasHealthCertificate = val;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPetToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF071120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF3B82F6),
            inactiveThumbColor: Colors.white24,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget _buildImportantReminder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C162A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFC229).withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            color: Color(0xFFFFC229),
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Important Reminder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Requirements can change. Check official sources 48-72 hours before departure.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ItemStatus {
  ready,
  review,
  action,
}
