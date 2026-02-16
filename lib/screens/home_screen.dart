/// ====================================================================
/// Forward AI — Home Screen
/// ====================================================================
/// The main hub screen with entry points to:
///   1. Personality Quiz — discover your ideal track
///   2. Track Vibe — explore the frontend dev lifestyle
///   3. Career Analysis — skill gap analysis with mock data
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/analysis_provider.dart';
import '../providers/personality_provider.dart';
import 'personality_quiz_screen.dart';
import 'result_screen.dart';
import 'track_vibe_screen.dart';

/// The home screen of the Forward AI app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // --- Form Management ---
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _skillController = TextEditingController();
  final List<String> _userSkills = [];
  final _skillFocusNode = FocusNode();

  @override
  void dispose() {
    _jobTitleController.dispose();
    _skillController.dispose();
    _skillFocusNode.dispose();
    super.dispose();
  }

  // --- Skill Management ---

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isEmpty) return;

    final isDuplicate = _userSkills.any(
      (existing) => existing.toLowerCase() == skill.toLowerCase(),
    );

    if (isDuplicate) {
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
    _skillFocusNode.requestFocus();
  }

  void _removeSkill(int index) {
    setState(() {
      _userSkills.removeAt(index);
    });
  }

  // --- Analysis Submission (Mock Data) ---

  Future<void> _submitAnalysis() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AnalysisProvider>();

    // Use mock data instead of real API
    await provider.analyzeCareerWithMockData(
      jobTitle: _jobTitleController.text.trim(),
      userSkills: List.from(_userSkills),
    );

    if (!mounted) return;

    if (provider.isSuccess && provider.result != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ResultScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              // --- Background ---
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

                        // --- Header ---
                        _buildHeader(),
                        const SizedBox(height: 28),

                        // --- Feature Cards ---
                        _buildFeatureCards(),
                        const SizedBox(height: 32),

                        // --- Divider ---
                        _buildDivider(),
                        const SizedBox(height: 24),

                        // --- Career Analysis Form ---
                        _buildJobTitleInput(),
                        const SizedBox(height: 24),
                        _buildSkillsInput(),
                        const SizedBox(height: 16),

                        if (_userSkills.isNotEmpty) ...[
                          _buildSkillChips(),
                          const SizedBox(height: 32),
                        ] else
                          const SizedBox(height: 16),

                        _buildSubmitButton(provider),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Loading Overlay ---
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
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
                .shimmer(duration: 3000.ms, color: Colors.white24),
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
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Your path to\ntech mastery.',
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
          'Discover your track, explore the vibe, and build your roadmap.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
      ],
    );
  }

  /// Builds the two feature cards: Personality Quiz and Track Vibe.
  Widget _buildFeatureCards() {
    return Column(
      children: [
        // --- Discover Your Track ---
        GestureDetector(
          onTap: () {
            // Reset quiz state before starting
            context.read<PersonalityProvider>().reset();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const PersonalityQuizScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withAlpha(40),
                  const Color(0xFF7C3AED).withAlpha(25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withAlpha(60),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.psychology_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover Your Track',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Take a quick personality quiz to find your ideal software track',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 18, color: AppTheme.primaryColor),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 300.ms)
            .slideX(begin: -0.05, end: 0, duration: 500.ms),

        const SizedBox(height: 14),

        // --- Explore Frontend Dev ---
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const TrackVibeScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.secondaryColor.withAlpha(35),
                  const Color(0xFF0EA5E9).withAlpha(20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.secondaryColor.withAlpha(60),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.palette_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Frontend Dev',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'See the vibe — tools, salary, daily life & sample projects',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 18, color: AppTheme.secondaryColor),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 400.ms)
            .slideX(begin: -0.05, end: 0, duration: 500.ms),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTheme.cardColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or analyze your skills',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppTheme.cardColor)),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 500.ms);
  }

  Widget _buildJobTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎯  Target Role',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _jobTitleController,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'e.g., Frontend Developer',
            prefixIcon:
                Icon(Icons.work_outline_rounded, color: AppTheme.textTertiary),
          ),
          textInputAction: TextInputAction.next,
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
        .fadeIn(duration: 500.ms, delay: 550.ms)
        .slideX(begin: -0.05, end: 0, duration: 500.ms);
  }

  Widget _buildSkillsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🛠  Your Skills',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillController,
                focusNode: _skillFocusNode,
                style:
                    const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'e.g., HTML, CSS, JavaScript...',
                  prefixIcon:
                      Icon(Icons.code_rounded, color: AppTheme.textTertiary),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addSkill(),
              ),
            ),
            const SizedBox(width: 12),
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
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 600.ms)
        .slideX(begin: -0.05, end: 0, duration: 500.ms);
  }

  Widget _buildSkillChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
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
        .fadeIn(duration: 500.ms, delay: 650.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppTheme.backgroundColor.withAlpha(229),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              child: const Icon(Icons.psychology_rounded,
                  color: Colors.white, size: 40),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.9, end: 1.1, duration: 1000.ms)
                .then()
                .scaleXY(begin: 1.1, end: 0.9, duration: 1000.ms),
            const SizedBox(height: 32),
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
              'This may take a moment...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: AppTheme.cardColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
