/// ====================================================================
/// Forward AI — Result Screen
/// ====================================================================
/// Displays the complete career analysis results including:
///   1. Market Insights — skills demanded by the market (chip tags)
///   2. Skill Gap Analysis — matched vs missing skills comparison
///   3. AI-Generated Roadmap — week-by-week learning plan (timeline)
///   4. Performance Metadata — processing time and stats
///
/// Design Patterns:
///   - Consumer pattern for reading provider state
///   - Widget decomposition — each section is a separate builder method
///   - Clean Architecture — no business logic in the UI layer
/// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/theme.dart';
import '../models/analysis_result.dart';
import '../providers/analysis_provider.dart';

/// Screen that displays the analyzed career path results.
///
/// Reads the [AnalysisResult] from [AnalysisProvider] and renders
/// market insights, skill gaps, and the personalized roadmap.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisProvider>(
      builder: (context, provider, child) {
        final result = provider.result;

        // Safety check — if there's no result, go back to home
        if (result == null) {
          return const Scaffold(
            body: Center(child: Text('No data available.')),
          );
        }

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
                  _buildSliverAppBar(context, result),

                  // --- Content ---
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),

                        // Section 1: Summary Stats Cards
                        _buildStatsRow(context, result),
                        const SizedBox(height: 28),

                        // Section 2: Market Skills
                        _buildMarketSkillsSection(context, result),
                        const SizedBox(height: 28),

                        // Section 3: Skill Gap Analysis
                        _buildSkillGapSection(context, result),
                        const SizedBox(height: 28),

                        // Section 4: AI Roadmap Timeline
                        _buildRoadmapSection(context, result),
                        const SizedBox(height: 24),

                        // Section 5: New Analysis Button
                        _buildNewAnalysisButton(context, provider),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------------------
  // App Bar
  // -----------------------------------------------------------------------

  /// Builds a custom sliver app bar with the job title.
  SliverAppBar _buildSliverAppBar(
      BuildContext context, AnalysisResult result) {
    return SliverAppBar(
      expandedHeight: 100,
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
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          result.jobTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
      ),
      actions: [
        // Processing time badge
        if (result.metadata != null)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.successColor.withAlpha(76)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined,
                    size: 14, color: AppTheme.successColor),
                const SizedBox(width: 4),
                Text(
                  '${(result.metadata!.processingTimeMs / 1000).toStringAsFixed(1)}s',
                  style: const TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Summary Stats Row
  // -----------------------------------------------------------------------

  /// Builds a row of 3 stat cards showing key metrics.
  Widget _buildStatsRow(BuildContext context, AnalysisResult result) {
    return Row(
      children: [
        _buildStatCard(
          context,
          icon: Icons.trending_up_rounded,
          label: 'Market Skills',
          value: '${result.marketSkills.length}',
          color: AppTheme.secondaryColor,
          delay: 0,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          context,
          icon: Icons.check_circle_outline_rounded,
          label: 'You Have',
          value: '${result.matchedSkills.length}',
          color: AppTheme.successColor,
          delay: 100,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          context,
          icon: Icons.warning_amber_rounded,
          label: 'Missing',
          value: '${result.missingSkills.length}',
          color: result.missingSkills.isEmpty
              ? AppTheme.successColor
              : AppTheme.warningColor,
          delay: 200,
        ),
      ],
    );
  }

  /// Builds a single stat card widget.
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required int delay,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(38)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: delay.ms)
          .scaleXY(begin: 0.9, end: 1, duration: 400.ms),
    );
  }

  // -----------------------------------------------------------------------
  // Market Skills Section
  // -----------------------------------------------------------------------

  /// Builds the "Market Insights" section showing demanded skills.
  Widget _buildMarketSkillsSection(
      BuildContext context, AnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _buildSectionHeader(
          context,
          icon: Icons.insights_rounded,
          title: 'Market Insights',
          subtitle:
              'Top skills demanded for ${result.jobTitle}',
          color: AppTheme.secondaryColor,
        ),
        const SizedBox(height: 14),

        // Skill chips wrapped
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: result.marketSkills.asMap().entries.map((entry) {
            final index = entry.key;
            final skill = entry.value;

            // Check if user already has this skill
            final hasSkill = result.matchedSkills
                .any((s) => s.toLowerCase() == skill.toLowerCase());

            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: hasSkill
                    ? AppTheme.successColor.withAlpha(20)
                    : AppTheme.secondaryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hasSkill
                      ? AppTheme.successColor.withAlpha(76)
                      : AppTheme.secondaryColor.withAlpha(76),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasSkill)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.check_rounded,
                          size: 16, color: AppTheme.successColor),
                    ),
                  Text(
                    skill,
                    style: TextStyle(
                      color: hasSkill
                          ? AppTheme.successColor
                          : AppTheme.secondaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: (index * 60).ms)
                .scaleXY(begin: 0.8, end: 1, duration: 300.ms);
          }).toList(),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms);
  }

  // -----------------------------------------------------------------------
  // Skill Gap Section
  // -----------------------------------------------------------------------

  /// Builds the "Skill Gap" section showing matched vs missing skills.
  Widget _buildSkillGapSection(
      BuildContext context, AnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.compare_arrows_rounded,
          title: 'Skill Gap Analysis',
          subtitle: 'Your skills vs market requirements',
          color: AppTheme.accentColor,
        ),
        const SizedBox(height: 14),

        // Matched skills
        if (result.matchedSkills.isNotEmpty) ...[
          _buildSkillCategory(
            context,
            label: '✅  Skills You Have',
            skills: result.matchedSkills,
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 12),
        ],

        // Missing skills
        if (result.missingSkills.isNotEmpty)
          _buildSkillCategory(
            context,
            label: '❌  Skills to Learn',
            skills: result.missingSkills,
            color: AppTheme.errorColor,
          ),

        // Perfect match message
        if (result.missingSkills.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.successColor.withAlpha(76)),
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: AppTheme.accentColor, size: 40),
                const SizedBox(height: 8),
                Text(
                  'Perfect Match! 🎉',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You already have all the skills the market requires!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 500.ms);
  }

  /// Builds a category card showing a list of skills.
  Widget _buildSkillCategory(
    BuildContext context, {
    required String label,
    required List<String> skills,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: skills
                .map(
                  (skill) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Roadmap Section (Timeline)
  // -----------------------------------------------------------------------

  /// Builds the "Personalized Roadmap" section as a vertical timeline.
  Widget _buildRoadmapSection(
      BuildContext context, AnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.route_rounded,
          title: 'Your Learning Roadmap',
          subtitle: '${result.roadmap.length}-week personalized plan',
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 14),

        // Timeline
        ...result.roadmap.asMap().entries.map((entry) {
          final index = entry.key;
          final week = entry.value;
          final isLast = index == result.roadmap.length - 1;

          return _buildTimelineCard(
            context,
            week: week,
            isLast: isLast,
            index: index,
          );
        }),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 700.ms);
  }

  /// Builds a single card in the roadmap timeline.
  Widget _buildTimelineCard(
    BuildContext context, {
    required RoadmapWeek week,
    required bool isLast,
    required int index,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Timeline line + dot ---
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Week number circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withAlpha(76),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${week.week}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                // Connecting line (not shown for last item)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withAlpha(38),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // --- Card content ---
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.cardColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Week label
                  Text(
                    'Week ${week.week}',
                    style: TextStyle(
                      color: AppTheme.primaryColor.withAlpha(178),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Topic title
                  Text(
                    week.topic,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    week.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Resources list
                  ...week.resources.map((resource) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Icon(Icons.arrow_right_rounded,
                                  size: 18, color: AppTheme.secondaryColor),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                resource,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      )),

                  // Link button
                  if (week.link.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _launchUrl(week.link),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.secondaryColor.withAlpha(76)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new_rounded,
                                size: 14, color: AppTheme.secondaryColor),
                            SizedBox(width: 6),
                            Text(
                              'Open Resource',
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: (index * 150).ms)
                .slideX(begin: 0.1, end: 0, duration: 400.ms),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // New Analysis Button
  // -----------------------------------------------------------------------

  /// Builds the "Start New Analysis" button at the bottom.
  Widget _buildNewAnalysisButton(
      BuildContext context, AnalysisProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () {
          // Reset provider state and navigate back to home
          provider.reset();
          Navigator.pop(context);
        },
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Start New Analysis'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textPrimary,
          side: const BorderSide(color: AppTheme.cardColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Helper Widgets
  // -----------------------------------------------------------------------

  /// Builds a section header with icon, title, and subtitle.
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

  /// Launches a URL in the device's default browser.
  ///
  /// Handles invalid URLs gracefully by catching exceptions.
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('❌ Could not launch URL: $url — $e');
    }
  }
}
