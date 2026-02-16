/// ====================================================================
/// Forward AI — Track Vibe Screen
/// ====================================================================
/// A premium static showcase screen for the Frontend Development track.
/// Shows the "vibe" — tools, day-in-the-life, salary, projects, traits.
/// ====================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';
import '../data/mock_data.dart';

class TrackVibeScreen extends StatelessWidget {
  /// The name of the track to display (e.g., "Backend Development").
  /// Defaults to "Frontend Development" if not provided or not found.
  final String trackName;

  const TrackVibeScreen({super.key, this.trackName = 'Frontend Development'});

  @override
  Widget build(BuildContext context) {
    // Look up track data from the allTracks map, fallback to frontend
    final track = allTracks[trackName] ?? frontendTrackInfo;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- App Bar ---
              SliverAppBar(
                expandedHeight: 80,
                floating: true,
                pinned: true,
                backgroundColor: AppTheme.backgroundColor.withAlpha(229),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                        Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text(
                    'Track Vibe',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  titlePadding: EdgeInsets.only(left: 60, bottom: 16),
                ),
              ),

              // --- Content ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // Hero section
                    _buildHeroSection(context, track),
                    const SizedBox(height: 28),

                    // Vibe stats
                    _buildVibeStats(context, track),
                    const SizedBox(height: 28),

                    // Tools & Technologies
                    _buildToolsSection(context, track),
                    const SizedBox(height: 28),

                    // A Day in the Life
                    _buildDayInTheLife(context, track),
                    const SizedBox(height: 28),

                    // Salary Range
                    _buildSalaryCard(context, track),
                    const SizedBox(height: 28),

                    // Personality Traits That Fit
                    _buildTraitsSection(context, track),
                    const SizedBox(height: 28),

                    // Sample Projects
                    _buildProjectsSection(context, track),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Hero Section
  // -----------------------------------------------------------------------

  Widget _buildHeroSection(BuildContext context, track) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withAlpha(50),
            AppTheme.secondaryColor.withAlpha(30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryColor.withAlpha(60),
        ),
      ),
      child: Column(
        children: [
          Text(track.emoji, style: const TextStyle(fontSize: 64))
              .animate()
              .scaleXY(
                  begin: 0.5, end: 1, duration: 500.ms,
                  curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            track.name,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            track.tagline,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            track.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  // -----------------------------------------------------------------------
  // Vibe Stats
  // -----------------------------------------------------------------------

  Widget _buildVibeStats(BuildContext context, track) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: (track.vibeStats as List<String>).asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardColor),
          ),
          child: Text(
            stat,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (200 + index * 80).ms)
            .scaleXY(begin: 0.8, end: 1, duration: 300.ms);
      }).toList(),
    );
  }

  // -----------------------------------------------------------------------
  // Tools & Technologies
  // -----------------------------------------------------------------------

  Widget _buildToolsSection(BuildContext context, track) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.build_rounded,
          title: 'Tools & Technologies',
          subtitle: 'Your daily toolkit',
          color: AppTheme.secondaryColor,
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
          ),
          itemCount: track.tools.length,
          itemBuilder: (context, index) {
            final tool = track.tools[index];
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tool.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tool.category,
                    style: TextStyle(
                      color: AppTheme.secondaryColor.withAlpha(178),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: (index * 60).ms)
                .scaleXY(begin: 0.85, end: 1, duration: 300.ms);
          },
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }

  // -----------------------------------------------------------------------
  // A Day in the Life
  // -----------------------------------------------------------------------

  Widget _buildDayInTheLife(BuildContext context, track) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.schedule_rounded,
          title: 'A Day in the Life',
          subtitle: 'What a typical day looks like',
          color: AppTheme.accentColor,
        ),
        const SizedBox(height: 14),
        ...(track.dayInTheLife as List).asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          final isLast = index == track.dayInTheLife.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline
                SizedBox(
                  width: 36,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentColor.withAlpha(76),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: AppTheme.accentColor.withAlpha(50),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Content
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.cardColor),
                    ),
                    child: Row(
                      children: [
                        Text(activity.emoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.time,
                                style: TextStyle(
                                  color:
                                      AppTheme.accentColor.withAlpha(200),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activity.activity,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(
                          duration: 300.ms, delay: (index * 80).ms)
                      .slideX(begin: 0.1, end: 0, duration: 300.ms),
                ),
              ],
            ),
          );
        }),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 500.ms);
  }

  // -----------------------------------------------------------------------
  // Salary Card
  // -----------------------------------------------------------------------

  Widget _buildSalaryCard(BuildContext context, track) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successColor.withAlpha(30),
            AppTheme.successColor.withAlpha(15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.successColor.withAlpha(60)),
      ),
      child: Column(
        children: [
          const Icon(Icons.attach_money_rounded,
              color: AppTheme.successColor, size: 36),
          const SizedBox(height: 12),
          Text(
            'Average Salary Range',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            track.salaryRange,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.successColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on global market data',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 600.ms)
        .scaleXY(begin: 0.95, end: 1, duration: 500.ms);
  }

  // -----------------------------------------------------------------------
  // Personality Traits That Fit
  // -----------------------------------------------------------------------

  Widget _buildTraitsSection(BuildContext context, track) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.psychology_rounded,
          title: 'You\'ll Thrive If You\'re...',
          subtitle: 'Personality traits that fit',
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 14),
        ...(track.fittingTraits as List<String>)
            .asMap()
            .entries
            .map((entry) {
          final index = entry.key;
          final trait = entry.value;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    trait,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: (index * 80).ms)
              .slideX(begin: 0.1, end: 0, duration: 300.ms);
        }),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 700.ms);
  }

  // -----------------------------------------------------------------------
  // Sample Projects
  // -----------------------------------------------------------------------

  Widget _buildProjectsSection(BuildContext context, track) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.folder_special_rounded,
          title: 'Starter Projects',
          subtitle: 'Build these to kickstart your journey',
          color: AppTheme.secondaryColor,
        ),
        const SizedBox(height: 14),
        ...(track.sampleProjects as List).asMap().entries.map((entry) {
          final index = entry.key;
          final project = entry.value;

          Color difficultyColor;
          switch (project.difficulty) {
            case 'Beginner':
              difficultyColor = AppTheme.successColor;
              break;
            case 'Intermediate':
              difficultyColor = AppTheme.accentColor;
              break;
            case 'Advanced':
              difficultyColor = AppTheme.errorColor;
              break;
            default:
              difficultyColor = AppTheme.textTertiary;
          }

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: difficultyColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: difficultyColor.withAlpha(76)),
                      ),
                      child: Text(
                        project.difficulty,
                        style: TextStyle(
                          color: difficultyColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: (index * 100).ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms);
        }),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 800.ms);
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
