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
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
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
        title: Text(
          'New Claim',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stepper Indicator Row
            _buildStepperHeader(),

            SizedBox(height: 28),

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
    final color = (isActive || isCompleted) ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.onSurface.withOpacity(0.24);

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
              ? Icon(Icons.check, size: 14, color: Colors.black)
              : Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: (isActive || isCompleted) ? Colors.black : Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: (isActive || isCompleted) ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
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
      margin: EdgeInsets.only(bottom: 14),
      color: isCompleted ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
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
        return SizedBox();
    }
  }

  // --- STEP 1: SELECT FLIGHT ---
  Widget _buildSelectFlightStep() {
    final isButtonEnabled = _selectedFlightIndex != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select the flight you want to claim for',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 20),

        // Flight 1: UA 2847
        _buildFlightSelectionCard(
          index: 0,
          flightNumber: 'UA 2847',
          route: 'SFO → JFK',
          date: 'May 15, 2026',
          statusText: '2h 30m',
          statusColor: const Color(0xFFFFC229),
        ),

        SizedBox(height: 12),

        // Flight 2: BA 112
        _buildFlightSelectionCard(
          index: 1,
          flightNumber: 'BA 112',
          route: 'LHR → SFO',
          date: 'May 10, 2026',
          statusText: 'Cancelled',
          statusColor: const Color(0xFFFFC229),
        ),

        SizedBox(height: 48),

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
            padding: EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: isButtonEnabled ? const Color(0xFFFFC229) : Color(0xFFFFC229).withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              'Continue',
              style: TextStyle(
                color: isButtonEnabled ? Colors.black : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
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
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.outline,
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  route,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  date,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
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
        Text(
          'Upload your boarding pass and ticket',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 20),

        // Big Dotted Upload box matching Screen 1 (with yellow border check)
        GestureDetector(
          onTap: _isUploading ? null : _startUploadSimulation,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _documentsUploaded ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.outline,
                style: BorderStyle.solid,
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                if (_isUploading) ...[
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Uploading documents... ${( _uploadProgress * 100 ).toInt()}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else if (_documentsUploaded) ...[
                  Icon(
                    Icons.check,
                    color: Color(0xFFFFC229),
                    size: 32,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Documents uploaded',
                    style: TextStyle(
                      color: Color(0xFFFFC229),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'boarding_pass.pdf',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                      fontSize: 12,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.upload_file,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    size: 40,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tap to upload documents',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'PDF, JPG, or PNG',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        SizedBox(height: 48),

        // Generating... / Continue Button
        GestureDetector(
          onTap: (_documentsUploaded && !_isGeneratingTransition) ? _triggerGeneratingTransition : null,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: _isGeneratingTransition
                  ? const Color(0xFF6B5817) // Dimmer gold during generation
                  : (_documentsUploaded ? const Color(0xFFFFC229) : Color(0xFFFFC229).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: _isGeneratingTransition
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Generating...',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Continue',
                    style: TextStyle(
                      color: _documentsUploaded ? Colors.black : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
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
        Text(
          'AI has generated your complaint letter',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 20),

        // Complaint Letter Card
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: Color(0xFFFFC229),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complaint Letter',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Generated by AI',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 18),
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Dear United Airlines,\n\nI am writing to claim compensation for flight UA 2847 on May 15, 2026, which was delayed by 2 hours and 30 minutes due to air traffic congestion...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
              SizedBox(height: 14),
              Center(
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

        SizedBox(height: 14),

        // Estimated Compensation Card
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated Compensation',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              Text(
                compensationAmount,
                style: TextStyle(
                  color: Color(0xFFFFC229), // Gold
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Based on EU Regulation 261/2004',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 48),

        // Continue Button
        GestureDetector(
          onTap: () {
            setState(() {
              _currentStep = 4;
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC229),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
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
        Text(
          'Review and submit your claim',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 20),

        // Summary Card Box matching Screen 3 exactly
        Container(
          padding: EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Column(
            children: [
              _buildReviewRow('Flight', flightName),
              Divider(color: Theme.of(context).colorScheme.outline, height: 28),
              _buildReviewRow('Route', routeText),
              Divider(color: Theme.of(context).colorScheme.outline, height: 28),
              _buildReviewRow('Delay', delayText),
              Divider(color: Theme.of(context).colorScheme.outline, height: 28),
              _buildReviewRow('Compensation', claimAmount, isGold: true),
            ],
          ),
        ),

        SizedBox(height: 48),

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
            padding: EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC229),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isGold ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
