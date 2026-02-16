/// ====================================================================
/// Forward AI — Track Info Data Model
/// ====================================================================

/// Represents a software development track with all its details.
class TrackInfo {
  /// Track name (e.g., "Frontend Development").
  final String name;

  /// Short tagline for the track.
  final String tagline;

  /// Full description.
  final String description;

  /// Emoji used as visual icon.
  final String emoji;

  /// Tools and technologies used in this track.
  final List<TrackTool> tools;

  /// Average salary range.
  final String salaryRange;

  /// "A Day in the Life" schedule items.
  final List<DayActivity> dayInTheLife;

  /// Personality traits that fit this track.
  final List<String> fittingTraits;

  /// Sample projects a beginner would build.
  final List<SampleProject> sampleProjects;

  /// Key stats (e.g., "95% visual", "Remote-friendly").
  final List<String> vibeStats;

  const TrackInfo({
    required this.name,
    required this.tagline,
    required this.description,
    required this.emoji,
    required this.tools,
    required this.salaryRange,
    required this.dayInTheLife,
    required this.fittingTraits,
    required this.sampleProjects,
    required this.vibeStats,
  });
}

/// A tool/technology used in a track.
class TrackTool {
  final String name;
  final String category; // e.g., "Framework", "Language", "Design"

  const TrackTool({required this.name, required this.category});
}

/// A single activity in the "Day in the Life" timeline.
class DayActivity {
  final String time;
  final String activity;
  final String emoji;

  const DayActivity({
    required this.time,
    required this.activity,
    required this.emoji,
  });
}

/// A sample project a beginner would build.
class SampleProject {
  final String name;
  final String description;
  final String difficulty; // "Beginner", "Intermediate", "Advanced"

  const SampleProject({
    required this.name,
    required this.description,
    required this.difficulty,
  });
}
