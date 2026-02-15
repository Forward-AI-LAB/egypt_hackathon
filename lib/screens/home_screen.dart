/// ====================================================================
/// Forward AI — Home Screen
/// ====================================================================
/// The main input screen where users enter their desired job title
/// and list their current skills. Features:
///   - Animated gradient background
///   - Job title text field with validation
///   - Dynamic skill chips with add/remove functionality
///   - Server health indicator
///   - Premium loading animation during analysis
///
/// Design Patterns:
///   - Consumer/Provider pattern for reactive state management
///   - Form validation with GlobalKey<FormState>
///   - Separation of UI and business logic (via AnalysisProvider)
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/analysis_provider.dart';
import 'result_screen.dart';

/// The home screen of the Forward AI app.
///
/// This is the first screen users see. It collects:
///   1. A job title (what they want to become)
///   2. Their existing skills (what they already know)
///
/// After submission, it triggers the analysis via [AnalysisProvider]
/// and navigates to [ResultScreen] on success.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // --- Form Management ---
  /// Form key for validation (ensures job title is not empty).
  final _formKey = GlobalKey<FormState>();

  /// Controller for the job title text field.
  final _jobTitleController = TextEditingController();

  /// Controller for the skill input text field.
  final _skillController = TextEditingController();

  /// List of skills the user has added.
  final List<String> _userSkills = [];

  /// Focus node for the skill input field (to manage keyboard).
  final _skillFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Check server health on screen load
    // This runs after the first frame to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalysisProvider>().checkServerHealth();
    });
  }

  @override
  void dispose() {
    // Always dispose controllers and focus nodes to prevent memory leaks
    _jobTitleController.dispose();
    _skillController.dispose();
    _skillFocusNode.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Skill Management Methods
  // -----------------------------------------------------------------------

  /// Adds a skill to the user's skill list.
  ///
  /// Validates that:
  ///   - The skill is not empty (after trimming whitespace)
  ///   - The skill is not already in the list (case-insensitive check)
  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isEmpty) return;

    // Check for duplicates (case-insensitive)
    final isDuplicate = _userSkills.any(
      (existing) => existing.toLowerCase() == skill.toLowerCase(),
    );

    if (isDuplicate) {
      // Show a brief message that the skill already exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$skill" is already in your list.'),
          backgroundColor: AppTheme.warningColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _userSkills.add(skill);
      _skillController.clear();
    });

    // Keep focus on the skill input for quick multi-add
    _skillFocusNode.requestFocus();
  }

  /// Removes a skill from the list by index.
  void _removeSkill(int index) {
    setState(() {
      _userSkills.removeAt(index);
    });
  }

  // -----------------------------------------------------------------------
  // Analysis Submission
  // -----------------------------------------------------------------------

  /// Validates input and triggers the career analysis.
  ///
  /// Flow:
  ///   1. Validate the form (job title required)
  ///   2. Call [AnalysisProvider.analyzeCareer()]
  ///   3. On success → navigate to [ResultScreen]
  ///   4. On error → show error message (handled by provider listener)
  Future<void> _submitAnalysis() async {
    // Validate form (checks if job title is provided)
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AnalysisProvider>();

    // Trigger the analysis
    await provider.analyzeCareer(
      jobTitle: _jobTitleController.text.trim(),
      userSkills: List.from(_userSkills), // Pass a copy to avoid mutation
    );

    // Check the result and navigate if successful
    if (!mounted) return; // Safety check — widget might be disposed

    if (provider.isSuccess && provider.result != null) {
      // Navigate to the results screen
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ResultScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Smooth slide-up transition for premium feel
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else if (provider.isError) {
      // Show error as a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'RETRY',
            textColor: Colors.white,
            onPressed: _submitAnalysis,
          ),
        ),
      );
    }
  }

  // -----------------------------------------------------------------------
  // Build Method
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              // --- Background Gradient ---
              Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
                ),
              ),

              // --- Main Content ---
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // --- Header Section ---
                        _buildHeader(provider),
                        const SizedBox(height: 36),

                        // --- Job Title Input ---
                        _buildJobTitleInput(),
                        const SizedBox(height: 24),

                        // --- Skills Input ---
                        _buildSkillsInput(),
                        const SizedBox(height: 16),

                        // --- Added Skills Chips ---
                        if (_userSkills.isNotEmpty) ...[
                          _buildSkillChips(),
                          const SizedBox(height: 32),
                        ] else
                          const SizedBox(height: 16),

                        // --- Submit Button ---
                        _buildSubmitButton(provider),
                        const SizedBox(height: 32),

                        // --- Info Card ---
                        _buildInfoCard(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Full-Screen Loading Overlay ---
              if (provider.isLoading) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Widget Builders
  // -----------------------------------------------------------------------

  /// Builds the app header with logo, title, and health indicator.
  Widget _buildHeader(AnalysisProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App logo and name row
        Row(
          children: [
            // Animated logo icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(76),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 26,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                  duration: 3000.ms,
                  color: Colors.white24,
                ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forward AI',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Career Intelligence Platform',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const Spacer(),
            // Server health indicator dot
            _buildHealthDot(provider.isServerHealthy),
          ],
        ),

        const SizedBox(height: 24),

        // Hero tagline
        Text(
          'Discover your\nskill gaps.',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                height: 1.15,
                letterSpacing: -1,
              ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.2, end: 0, duration: 600.ms),

        const SizedBox(height: 8),

        Text(
          'Get a personalized AI roadmap to bridge them.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms),
      ],
    );
  }

  /// Builds a small dot indicating server health status.
  Widget _buildHealthDot(bool isHealthy) {
    return Tooltip(
      message: isHealthy ? 'Server connected' : 'Server unreachable',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isHealthy ? AppTheme.successColor : AppTheme.errorColor,
          boxShadow: [
            BoxShadow(
              color: (isHealthy ? AppTheme.successColor : AppTheme.errorColor)
                  .withAlpha(127),
              blurRadius: 8,
            ),
          ],
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .fadeIn()
          .then()
          .fadeOut(duration: 1500.ms)
          .then()
          .fadeIn(duration: 1500.ms),
    );
  }

  /// Builds the job title input field with validation.
  Widget _buildJobTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          '🎯  Target Role',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        // Text field
        TextFormField(
          controller: _jobTitleController,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'e.g., Flutter Developer, Data Scientist...',
            prefixIcon: Icon(Icons.work_outline_rounded,
                color: AppTheme.textTertiary),
          ),
          textInputAction: TextInputAction.next,
          // Validation: job title cannot be empty
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a job title';
            }
            return null;
          },
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideX(begin: -0.05, end: 0, duration: 500.ms);
  }

  /// Builds the skill input field with an add button.
  Widget _buildSkillsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          '🛠  Your Skills',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        // Input row with add button
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillController,
                focusNode: _skillFocusNode,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'e.g., Dart, Git, Firebase...',
                  prefixIcon: Icon(Icons.code_rounded,
                      color: AppTheme.textTertiary),
                ),
                textInputAction: TextInputAction.done,
                // Add skill when user presses "Done" on keyboard
                onSubmitted: (_) => _addSkill(),
              ),
            ),
            const SizedBox(width: 12),
            // Add button with gradient background
            GestureDetector(
              onTap: _addSkill,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryColor.withAlpha(76),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 400.ms)
        .slideX(begin: -0.05, end: 0, duration: 500.ms);
  }

  /// Builds the row of skill chips showing added skills.
  ///
  /// Each chip has a delete button to remove the skill.
  /// Uses [Wrap] for automatic line-breaking when chips overflow.
  Widget _buildSkillChips() {
    return Wrap(
      spacing: 8, // Horizontal space between chips
      runSpacing: 8, // Vertical space between chip rows
      children: List.generate(_userSkills.length, (index) {
        return Chip(
          label: Text(
            _userSkills[index],
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          deleteIcon: const Icon(Icons.close_rounded, size: 18),
          deleteIconColor: AppTheme.textSecondary,
          onDeleted: () => _removeSkill(index),
          backgroundColor: AppTheme.primaryColor.withAlpha(25),
          side: BorderSide(color: AppTheme.primaryColor.withAlpha(76)),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .scaleXY(begin: 0.8, end: 1, duration: 300.ms);
      }),
    );
  }

  /// Builds the submit button with gradient and loading awareness.
  Widget _buildSubmitButton(AnalysisProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withAlpha(76),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: provider.isLoading ? null : _submitAnalysis,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 22),
              const SizedBox(width: 10),
              Text(
                'Analyze My Career Path',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 500.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  /// Builds an informational card explaining how the app works.
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withAlpha(127),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.secondaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'How it works',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'We analyze real market demand for your target role'),
          const SizedBox(height: 8),
          _buildStep('2', 'AI identifies the skills you\'re missing'),
          const SizedBox(height: 8),
          _buildStep('3', 'Get a personalized week-by-week learning roadmap'),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 600.ms);
  }

  /// Builds a single step in the info card.
  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(38),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }

  /// Builds a full-screen loading overlay with animated elements.
  ///
  /// Shown when the analysis is in progress. Includes:
  ///   - Semi-transparent background
  ///   - Pulsing icon animation
  ///   - Progress indicator
  ///   - Rotating status messages
  Widget _buildLoadingOverlay() {
    return Container(
      color: AppTheme.backgroundColor.withAlpha(229),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated rocket icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(76),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 40,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.9, end: 1.1, duration: 1000.ms)
                .then()
                .scaleXY(begin: 1.1, end: 0.9, duration: 1000.ms),

            const SizedBox(height: 32),

            // Loading text
            Text(
              'Analyzing Market Data...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: 600.ms)
                .then()
                .fadeOut(duration: 600.ms, delay: 2000.ms)
                .then()
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 12),

            Text(
              'This may take 15-30 seconds...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),

            const SizedBox(height: 32),

            // Progress indicator
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: AppTheme.cardColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
