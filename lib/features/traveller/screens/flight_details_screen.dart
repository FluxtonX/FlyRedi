import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/traveller_bottom_nav.dart';
import 'complaint_ready_screen.dart';
import 'claim_status_screen.dart';

class FlightDetailsScreen extends StatefulWidget {
  const FlightDetailsScreen({super.key});

  @override
  State<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends State<FlightDetailsScreen> {
  int _currentStep = 1; // 1: Select Flight, 2: Upload Documents, 3: AI Generation, 4: Review & Submit
  int? _selectedFlightIndex; // 0: UA 2847, 1: BA 112

  // Step 2 State
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _documentsUploaded = false;
  bool _isGeneratingTransition = false;

  @override
  void initState() {
    super.initState();
  }

  void _startUploadSimulation() {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _documentsUploaded = false;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      setState(() {
        _uploadProgress += 0.25;
      });
      if (_uploadProgress >= 1.0) {
        setState(() {
          _uploadProgress = 1.0;
          _isUploading = false;
          _documentsUploaded = true;
        });
        return false;
      }
      return true;
    });
  }

  void _triggerGeneratingTransition() {
    setState(() {
      _isGeneratingTransition = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isGeneratingTransition = false;
        _currentStep = 3;
      });
    });
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
          onPressed: () {
            if (_currentStep > 1) {
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'New Claim',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stepper Indicator Row
            _buildStepperHeader(),

            const SizedBox(height: 28),

            // Step Content
            _buildStepContent(),
          ],
        ),
      ),
      bottomNavigationBar: const TravellerBottomNav(
        activeIndex: 2, // Highlight Claims tab
      ),
    );
  }

  Widget _buildStepperHeader() {
    return Row(
      children: [
        Expanded(child: _buildStepTab(1, 'Select Flight')),
        _buildDivider(1),
        Expanded(child: _buildStepTab(2, 'Upload Docs')),
        _buildDivider(2),
        Expanded(child: _buildStepTab(3, 'AI Generation')),
        _buildDivider(3),
        Expanded(child: _buildStepTab(4, 'Review & Submit')),
      ],
    );
  }

  Widget _buildStepTab(int stepNumber, String label) {
    final isActive = _currentStep == stepNumber;
    final isCompleted = _currentStep > stepNumber;
    final color = (isActive || isCompleted) ? const Color(0xFFFFC229) : Colors.white24;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: (isActive || isCompleted) ? const Color(0xFFFFC229) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, size: 14, color: Colors.black)
              : Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: (isActive || isCompleted) ? Colors.black : Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: (isActive || isCompleted) ? Colors.white : Colors.white30,
            fontSize: 9,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(int stepAfter) {
    final isCompleted = _currentStep > stepAfter;
    return Container(
      width: 18,
      height: 1.5,
      margin: const EdgeInsets.only(bottom: 14),
      color: isCompleted ? const Color(0xFFFFC229) : Colors.white12,
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildSelectFlightStep();
      case 2:
        return _buildUploadStep();
      case 3:
        return _buildAIGenerationStep();
      case 4:
        return _buildReviewSubmitStep();
      default:
        return const SizedBox();
    }
  }

  // --- STEP 1: SELECT FLIGHT ---
  Widget _buildSelectFlightStep() {
    final isButtonEnabled = _selectedFlightIndex != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Select the flight you want to claim for',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),

        // Flight 1: UA 2847
        _buildFlightSelectionCard(
          index: 0,
          flightNumber: 'UA 2847',
          route: 'SFO → JFK',
          date: 'May 15, 2026',
          statusText: '2h 30m',
          statusColor: const Color(0xFFFFC229),
        ),

        const SizedBox(height: 12),

        // Flight 2: BA 112
        _buildFlightSelectionCard(
          index: 1,
          flightNumber: 'BA 112',
          route: 'LHR → SFO',
          date: 'May 10, 2026',
          statusText: 'Cancelled',
          statusColor: const Color(0xFFFFC229),
        ),

        const SizedBox(height: 48),

        // Continue Button
        GestureDetector(
          onTap: isButtonEnabled
              ? () {
                  setState(() {
                    _currentStep = 2;
                  });
                }
              : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: isButtonEnabled ? const Color(0xFFFFC229) : const Color(0xFFFFC229).withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              'Continue',
              style: TextStyle(
                color: isButtonEnabled ? Colors.black : Colors.white30,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlightSelectionCard({
    required int index,
    required String flightNumber,
    required String route,
    required String date,
    required String statusText,
    required Color statusColor,
  }) {
    final isSelected = _selectedFlightIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFlightIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0C162A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFC229) : Colors.white.withOpacity(0.04),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flightNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  route,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 2: UPLOAD DOCUMENTS ---
  Widget _buildUploadStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Upload your boarding pass and ticket',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),

        // Big Dotted Upload box matching Screen 1 (with yellow border check)
        GestureDetector(
          onTap: _isUploading ? null : _startUploadSimulation,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF0C162A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _documentsUploaded ? const Color(0xFFFFC229) : Colors.white.withOpacity(0.08),
                style: BorderStyle.solid,
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                if (_isUploading) ...[
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Uploading documents... ${( _uploadProgress * 100 ).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else if (_documentsUploaded) ...[
                  const Icon(
                    Icons.check,
                    color: Color(0xFFFFC229),
                    size: 32,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Documents uploaded',
                    style: TextStyle(
                      color: Color(0xFFFFC229),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'boarding_pass.pdf',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.upload_file,
                    color: Colors.white70,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap to upload documents',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'PDF, JPG, or PNG',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 48),

        // Generating... / Continue Button
        GestureDetector(
          onTap: (_documentsUploaded && !_isGeneratingTransition) ? _triggerGeneratingTransition : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: _isGeneratingTransition
                  ? const Color(0xFF6B5817) // Dimmer gold during generation
                  : (_documentsUploaded ? const Color(0xFFFFC229) : const Color(0xFFFFC229).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: _isGeneratingTransition
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Generating...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Continue',
                    style: TextStyle(
                      color: _documentsUploaded ? Colors.black : Colors.white30,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // --- STEP 3: AI GENERATION ---
  Widget _buildAIGenerationStep() {
    final compensationAmount = _selectedFlightIndex == 0 ? "\$600" : "\$1,200";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'AI has generated your complaint letter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),

        // Complaint Letter Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0C162A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: Color(0xFFFFC229),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complaint Letter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Generated by AI',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Dear United Airlines,\n\nI am writing to claim compensation for flight UA 2847 on May 15, 2026, which was delayed by 2 hours and 30 minutes due to air traffic congestion...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Click to view full letter',
                  style: TextStyle(
                    color: Color(0xFFFFC229),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Estimated Compensation Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0C162A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated Compensation',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                compensationAmount,
                style: const TextStyle(
                  color: Color(0xFFFFC229), // Gold
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Based on EU Regulation 261/2004',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Continue Button
        GestureDetector(
          onTap: () {
            setState(() {
              _currentStep = 4;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC229),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- STEP 4: REVIEW & SUBMIT ---
  Widget _buildReviewSubmitStep() {
    final flightName = _selectedFlightIndex == 0 ? "UA 2847" : "BA 112";
    final routeText = _selectedFlightIndex == 0 ? "SFO → JFK" : "LHR → SFO";
    final delayText = _selectedFlightIndex == 0 ? "2h 30m" : "Cancelled";
    final claimAmount = _selectedFlightIndex == 0 ? "\$600" : "\$1,200";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Review and submit your claim',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),

        // Summary Card Box matching Screen 3 exactly
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0C162A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          child: Column(
            children: [
              _buildReviewRow('Flight', flightName),
              Divider(color: Colors.white.withOpacity(0.04), height: 28),
              _buildReviewRow('Route', routeText),
              Divider(color: Colors.white.withOpacity(0.04), height: 28),
              _buildReviewRow('Delay', delayText),
              Divider(color: Colors.white.withOpacity(0.04), height: 28),
              _buildReviewRow('Compensation', claimAmount, isGold: true),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Submit Claim Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClaimStatusScreen(
                  flightCode: flightName,
                  route: routeText,
                  date: _selectedFlightIndex == 0 ? "May 15, 2026" : "May 10, 2026",
                  submittedDate: "May 19, 2026",
                  amount: claimAmount,
                  status: "In Review",
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC229),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Submit Claim',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isGold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isGold ? const Color(0xFFFFC229) : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
