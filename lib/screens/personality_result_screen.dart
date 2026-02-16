/// ====================================================================
/// Forward AI — Personality Result Screen
/// ====================================================================
/// Shows the quiz result: recommended track, match %, strengths,
/// and CTA buttons to explore the track vibe or start career analysis.
///
/// Now handles loading state while AI processes the quiz answers.
/// ====================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/personality_provider.dart';
import 'track_vibe_screen.dart';

class PersonalityResultScreen extends StatelessWidget {
  const PersonalityResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalityProvider>(
      builder: (context, provider, child) {
        // --- Loading State (while AI processes) ---
        if (provider.isLoading) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🧠', style: TextStyle(fontSize: 64))
                        .animate(onPlay: (c) => c.repeat())
                        .scaleXY(
                          begin: 0.8,
                          end: 1.1,
                          duration: 800.ms,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(height: 24),
                    Text(
                      'AI is analyzing your\npersonality...',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 16),
                    Text(
                      'Finding your perfect track',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                    const SizedBox(height: 32),
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final result = provider.result;

        if (result == null) {
          return const Scaffold(
            body: Center(child: Text('No result available.')),
          );
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // --- Celebration Header ---
                    _buildCelebrationHeader(context),
                    const SizedBox(height: 32),

                    // --- Match Card ---
                    _buildMatchCard(context, result),
                    const SizedBox(height: 24),

                    // --- Strengths Section ---
                    _buildStrengthsSection(context, result),
                    const SizedBox(height: 32),

                    // --- CTA Buttons ---
                    _buildExploreTrackButton(context, provider),
                    const SizedBox(height: 14),
                    _buildRetakeButton(context, provider),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCelebrationHeader(BuildContext context) {
    return Column(
      children: [
        // Big emoji
        const Text('🎉', style: TextStyle(fontSize: 64))
            .animate()
            .scaleXY(
              begin: 0.3,
              end: 1,
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 12),
        Text(
          'Your Perfect Match!',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          'Based on your personality answers',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
      ],
    );
  }

  Widget _buildMatchCard(BuildContext context, result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withAlpha(40),
            AppTheme.secondaryColor.withAlpha(20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryColor.withAlpha(76),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Track emoji
          Text(result.emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),

          // Track name
          Text(
            result.trackName,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Match percentage
          TweenAnimationBuilder<int>(
            duration: const Duration(milliseconds: 1200),
            tween: IntTween(begin: 0, end: result.matchPercentage),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                        ).createShader(const Rect.fromLTWH(0, 0, 120, 60)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      '%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12, left: 6),
                    child: Text(
                      'match',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            result.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .scaleXY(begin: 0.9, end: 1, duration: 600.ms);
  }

  Widget _buildStrengthsSection(BuildContext context, result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.star_rounded,
                  color: AppTheme.accentColor, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Your Strengths',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...result.strengths.asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          final strength = entry.value;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.cardColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    strength,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: (600 + index * 100).ms)
              .slideX(begin: 0.1, end: 0, duration: 300.ms);
        }),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 600.ms);
  }

  Widget _buildExploreTrackButton(
      BuildContext context, PersonalityProvider provider) {
    final trackName = provider.result?.trackName ?? 'Development';

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
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    TrackVibeScreen(trackName: trackName),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
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
          },
          icon: const Icon(Icons.explore_rounded, size: 22),
          label: Text(
            'Explore $trackName Vibe',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 900.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildRetakeButton(
      BuildContext context, PersonalityProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () {
          provider.reset();
          Navigator.pop(context);
        },
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Retake Quiz'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textPrimary,
          side: const BorderSide(color: AppTheme.cardColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1000.ms);
  }
}
