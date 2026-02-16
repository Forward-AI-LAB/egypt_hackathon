/// ====================================================================
/// Forward AI — Personality Quiz Data Models
/// ====================================================================

/// A single option within a personality question.
class QuizOption {
  /// The display text for this option.
  final String label;

  /// The personality trait this option maps to (e.g., 'creative', 'logical').
  final String trait;

  /// How strongly this option indicates the trait (default 1).
  final int weight;

  const QuizOption({
    required this.label,
    required this.trait,
    this.weight = 1,
  });
}

/// A single personality quiz question with multiple answer options.
class PersonalityQuestion {
  /// The question text displayed to the user.
  final String question;

  /// Emoji icon for visual flair.
  final String emoji;

  /// The available answer options.
  final List<QuizOption> options;

  const PersonalityQuestion({
    required this.question,
    required this.emoji,
    required this.options,
  });
}

/// The result of a completed personality quiz.
class TrackResult {
  /// The recommended track name (e.g., "Frontend Development").
  final String trackName;

  /// Match percentage (0–100).
  final int matchPercentage;

  /// A description of why this track fits.
  final String description;

  /// Key strengths identified from the quiz.
  final List<String> strengths;

  /// Icon name for display.
  final String emoji;

  const TrackResult({
    required this.trackName,
    required this.matchPercentage,
    required this.description,
    required this.strengths,
    required this.emoji,
  });
}
