/// ====================================================================
/// Forward AI — Personality Quiz Screen
/// ====================================================================
/// An animated quiz experience where users answer 8 personality
/// questions to discover their ideal software development track.
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/personality_provider.dart';
import 'personality_result_screen.dart';

class PersonalityQuizScreen extends StatelessWidget {
  const PersonalityQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<PersonalityProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  // --- App Bar ---
                  _buildTopBar(context, provider),
                  const SizedBox(height: 16),

                  // --- Progress Bar ---
                  _buildProgressBar(provider),
                  const SizedBox(height: 32),

                  // --- Question ---
                  Expanded(
                    child: _buildQuestionCard(context, provider),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, PersonalityProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            onPressed: () {
              provider.reset();
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor.withAlpha(76)),
            ),
            child: Text(
              '${provider.currentIndex + 1} / ${provider.totalQuestions}',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(PersonalityProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0, end: provider.progress),
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: AppTheme.surfaceColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
      BuildContext context, PersonalityProvider provider) {
    final question = provider.currentQuestion;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Padding(
        key: ValueKey(provider.currentIndex),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji
            Text(
              question.emoji,
              style: const TextStyle(fontSize: 48),
            ).animate().scaleXY(
                  begin: 0.5,
                  end: 1,
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 16),

            // Question text
            Text(
              question.question,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
            ),
            const SizedBox(height: 32),

            // Options
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionButton(context, provider, option, index),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context,
      PersonalityProvider provider, option, int index) {
    return GestureDetector(
      onTap: () {
        // Answer and advance
        provider.answerQuestion(option);

        // If quiz is complete, navigate to result
        if (provider.isComplete) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const PersonalityResultScreen(),
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
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardColor),
        ),
        child: Row(
          children: [
            // Letter indicator
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms, delay: (index * 80).ms)
          .slideX(begin: 0.1, end: 0, duration: 300.ms),
    );
  }
}
