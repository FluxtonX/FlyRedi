import 'package:flutter/material.dart';
import 'package:sky_rightz_360/core/constants/app_colors.dart';
import '../widgets/workflow_timeline_tracker.dart';
import '../widgets/disruption_details_card.dart';
import '../widgets/confirmation_card.dart';
import '../widgets/passenger_rights_view.dart';
import '../widgets/upload_documents_view.dart';
import '../widgets/choose_resolution_view.dart';
import '../widgets/review_submit_view.dart';
import '../widgets/traveller_bottom_nav.dart';
import 'complaint_ready_screen.dart';

class ResolutionWorkflowScreen extends StatefulWidget {
  const ResolutionWorkflowScreen({super.key});

  @override
  State<ResolutionWorkflowScreen> createState() =>
      _ResolutionWorkflowScreenState();
}

class _ResolutionWorkflowScreenState extends State<ResolutionWorkflowScreen> {
  int _currentStep = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_currentStep > 1) {
                          setState(() {
                            _currentStep--;
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resolution Workflow',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "We'll guide you step-by-step to resolve this disruption",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32),
                WorkflowTimelineTracker(currentStep: _currentStep),
                SizedBox(height: 40),

                // Dynamic step content
                _buildStepContent(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: TravellerBottomNav(
        // Map step 1 to Home index, but others can highlight Assistant
        activeIndex: _currentStep == 1 ? 0 : 3,
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Step 1: Confirm Disruption',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Let's verify the details of your travel disruption",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            const DisruptionDetailsCard(),
            SizedBox(height: 24),
            ConfirmationCard(
              onYesPressed: () {
                setState(() {
                  _currentStep = 2;
                });
              },
            ),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: 'Note: ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Accurate information is essential for a successful claim. Double-check all details before proceeding.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 2:
        return PassengerRightsView(
          onContinue: () {
            setState(() {
              _currentStep = 3;
            });
          },
        );
      case 3:
        return UploadDocumentsView(
          onContinue: () {
            setState(() {
              _currentStep = 4;
            });
          },
        );
      case 4:
        return ChooseResolutionView(
          onContinue: () {
            setState(() {
              _currentStep = 5;
            });
          },
        );
      case 5:
        return ReviewSubmitView(
          onSubmit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ComplaintReadyScreen(),
              ),
            );
          },
        );
      default:
        return SizedBox();
    }
  }


}
