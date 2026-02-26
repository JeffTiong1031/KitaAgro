import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kita_agro/core/services/app_localizations.dart';

// Tutorial Step Model
class TutorialStep {
  final List<String> imagePaths;
  final String title;
  final String description;
  final String? link;
  final String? linkLabel;

  TutorialStep({
    List<String>? imagePaths,
    required this.title,
    required this.description,
    this.link,
    this.linkLabel,
  }) : imagePaths = imagePaths ?? const [];
}

class GrantTutorialScreen extends StatefulWidget {
  const GrantTutorialScreen({super.key});

  @override
  State<GrantTutorialScreen> createState() => _GrantTutorialScreenState();
}

class _GrantTutorialScreenState extends State<GrantTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Tutorial Steps Data
  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      imagePaths: ['assets/images/Step1_createAccount.jpg'],
      title: 'Create e-GAN Account',
      description:
          'First, register on the official e-GAN portal. Fill in your Full Name (as per MyKad), IC Number, Email, and create a Password.\n\n💡 Pro Tip: Use an active email address as you need to verify it immediately.',
      link: 'https://app-egam.kpkm.gov.my/user/register/create',
      linkLabel: 'Open e-GAN Registration Portal',
    ),
    TutorialStep(
      imagePaths: ['assets/images/Step2_verifyEmail.jpg'],
      title: 'Verify Your Email',
      description:
          'Check your inbox for a verification link. Click the blue button \'Pengesahan Akaun\' to activate.\n\n⚠️ Important: Link expires in 60 minutes. Check Spam folder if missing.',
    ),
    TutorialStep(
      imagePaths: ['assets/images/Step3_loginEGam.jpg'],
      title: 'Login to Portal',
      description:
          'Once verified, return to the portal. Enter your IC Number and the Password you just created to log in for the first time.',
    ),
    TutorialStep(
      imagePaths: ['assets/images/Step4_chooseProgram&ApplyNow.jpg'],
      title: 'Select The Grant',
      description:
          'On the sidebar menu, click \'Permohonan Geran Agropreneur NextGen\'. Then, click \'Mohon Sekarang\' (Apply Now) to open the form.',
    ),
    TutorialStep(
      imagePaths: ['assets/images/Step5_selectRequirement.jpg'],
      title: 'Confirm Eligibility',
      description:
          'You must tick the boxes to declare your eligibility:\n\n1. Malaysian Citizen (18-45 years old).\n2. Can read, count, and write.\n3. Have attended training OR have a relevant Diploma/Degree OR have experience.\n\nAction: Click \'Lengkapkan Permohonan\' to proceed to the main form.',
    ),
    TutorialStep(
      imagePaths: ['assets/images/Step6a_fillInformation.jpg'],
      title: 'Step 1: Personal Details',
      description:
          'Fill in your personal information (Marital Status, Phone, Address, etc).\n\n📄 Documents Required:\n• Passport-sized Photo of applicant.\n• Copy of MyKad (IC) - Must be Certified.\n• SSM Registration or Business License - Must be Certified.',
    ),
    TutorialStep(
      imagePaths: ['assets/images/Step6b_ProjectDetails.jpg'],
      title: 'Step 2: Project Information',
      description:
          'Select your project type and the Supervising Agency (Agensi Pembimbing), e.g., DOA for Crops.\n\n📄 Documents Required:\n• Proof of Land Ownership (Certified).\n• Stamped Tenancy Agreement (if renting).\n• Consent Letter (if using parents\' land).',
    ),
    TutorialStep(
      imagePaths: ['assets/images/Step6c_updateListNeeded.jpg'],
      title: 'Step 3: Request for Aid',
      description:
          'List the specific items or machinery you need to buy.\n\n💰 Maximum Limit: RM30,000 (for Crops, Livestock, Fisheries).\n\n⚠️ Important: You MUST upload current price quotations from three (3) different suppliers for the items you are requesting.',
    ),
    TutorialStep(
      imagePaths: ['assets/images/Step6d_fillBusinessDetails.jpg'],
      title: 'Step 4: Business Plan',
      description:
          'This is the most critical section. Describe your business vision.\n\nKey Details to Fill:\n• Introduction: Purpose, Mission, and Vision.\n• Management: Employee roles.\n• Marketing: Sales channels (Online/Wholesalers).\n• Operations: Daily farm activities.\n\n📸 Requirement: You MUST upload at least 3 photos of your project site.',
    ),
    TutorialStep(
      imagePaths: ['assets/images/Step6e_updateBudgetPlan.jpg'],
      title: 'Step 5: Financial Plan',
      description:
          'Calculate your project\'s profitability. Provide realistic estimates.\n\nCash Inflow:\n• Capital (Grant vs Own Money)\n• Sales Projection (Year 1, 2, 3)\n\nCash Outflow:\n• Development Costs (Machinery)\n• Operational Costs (Fertilizer, Feed, Labor)\n\n💡 Pro Tip: Ensure Sales Projection is higher than Operational Costs.',
    ),
    TutorialStep(
      imagePaths: ['assets/images/Step6f_fillDeclaration.jpg'],
      title: 'Step 6: Final Declaration',
      description:
          'You must agree to the terms before submitting:\n\n✅ Acknowledge that the application will be rejected if you do not respond to queries within 3 months.\n✅ Declare that all information provided is TRUE.\n\n⚠️ Warning: Providing false information is a serious offense under Clause 463 of the Penal Code.',
    ),
    TutorialStep(
      imagePaths: [
        'assets/images/Step6g_saveDraft.jpg',
        'assets/images/Step6h_checkDraft&allInformation.jpg',
        'assets/images/Step6i_submitApplication.jpg',
      ],
      title: 'Save, Review & Submit',
      description:
          'Do not submit immediately! Follow this safe process:\n\n1. Click \'Simpan Draf\' (Save Draft) to save your progress.\n2. Check your Dashboard. You can click the Green Pencil Icon to edit if needed.\n3. Once you are 100% satisfied, click the green \'Hantar\' (Submit) button.\n\n✅ Success: Your application is now sent to the Ministry for processing. Good luck!',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _tutorialSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildStyledDescription(String text) {
    // Split by newline to handle sections
    final lines = text.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Check if line contains Pro Tip or Important
        if (line.contains('💡 Pro Tip:')) {
          return _buildHighlightCard(
            line.replaceAll('💡 Pro Tip:', '').trim(),
            Colors.blue[50]!,
            Colors.blue[700]!,
            Icons.lightbulb_outline,
          );
        } else if (line.contains('⚠️ Important:')) {
          return _buildHighlightCard(
            line.replaceAll('⚠️ Important:', '').trim(),
            Colors.orange[50]!,
            Colors.orange[700]!,
            Icons.warning_amber_outlined,
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildHighlightCard(
    String text,
    Color bgColor,
    Color iconColor,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: iconColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).grantTutorial,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step Indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border(bottom: BorderSide(color: Colors.green[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  ).stepOf(_currentPage + 1, _tutorialSteps.length),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(width: 16),
                // Progress indicators
                Row(
                  children: List.generate(
                    _tutorialSteps.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentPage
                            ? const Color(0xFF2E7D32)
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PageView with Tutorial Steps
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _tutorialSteps.length,
              itemBuilder: (context, index) {
                final step = _tutorialSteps[index];
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Image Section (supports multiple images)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: step.imagePaths.map((path) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  path,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback placeholder if image is missing
                                    return Container(
                                      color: Colors.grey[200],
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 32,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Image placeholder\n${path.split('/').last}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Text Content Section (55%)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              step.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Description with styled tips
                            _buildStyledDescription(step.description),

                            // Link Button (if available)
                            if (step.link != null) ...[
                              const SizedBox(height: 16),
                              _buildLinkButton(
                                step.link!,
                                step.linkLabel ?? 'Open Link',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Navigation Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Previous Button
                  if (_currentPage > 0)
                    TextButton.icon(
                      onPressed: _goToPreviousPage,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  const Spacer(),

                  // Next Button
                  ElevatedButton.icon(
                    onPressed: _goToNextPage,
                    icon: Text(
                      _currentPage == _tutorialSteps.length - 1
                          ? AppLocalizations.of(context).finishButton
                          : AppLocalizations.of(context).nextButton,
                    ),
                    label: Icon(
                      _currentPage == _tutorialSteps.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Could not open link: $url')),
              ],
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Widget _buildLinkButton(String url, String label) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: ElevatedButton.icon(
        onPressed: () => _launchURL(url),
        icon: const Icon(Icons.open_in_new, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
