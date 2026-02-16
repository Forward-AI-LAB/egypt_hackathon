/// ====================================================================
/// Forward AI — Data Models
/// ====================================================================
/// This file defines the data models used across the application.
///
/// Design Pattern: Immutable Value Objects
///   - All models use final fields (immutable after construction).
///   - Factory constructors handle JSON deserialization.
///   - toJson() methods support serialization for persistence.
///
/// This separation of data models from business logic follows the
/// Clean Architecture principle, making the codebase scalable.
/// ====================================================================
library;

/// Represents a single week in the personalized learning roadmap.
///
/// Each [RoadmapWeek] contains a topic to learn, a description,
/// actionable resources, and a link to the best free learning material.
class RoadmapWeek {
  /// The week number in the roadmap (starting from 1).
  final int week;

  /// The main skill or topic to focus on this week.
  final String topic;

  /// A brief explanation of what to learn and why it matters.
  final String description;

  /// A list of actionable learning resources (tutorials, docs, projects).
  final List<String> resources;

  /// URL to the best free resource for this topic.
  final String link;

  /// Creates a new [RoadmapWeek] instance.
  const RoadmapWeek({
    required this.week,
    required this.topic,
    required this.description,
    required this.resources,
    required this.link,
  });

  /// Factory constructor to create a [RoadmapWeek] from a JSON map.
  ///
  /// Handles type-safety by providing default values for missing fields
  /// and safely casting list items to strings.
  factory RoadmapWeek.fromJson(Map<String, dynamic> json) {
    return RoadmapWeek(
      // Use 0 as fallback for missing week number
      week: json['week'] as int? ?? 0,
      // Use empty string as fallback for missing text fields
      topic: json['topic'] as String? ?? '',
      description: json['description'] as String? ?? '',
      // Safely cast each list item to String
      resources: (json['resources'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      link: json['link'] as String? ?? '',
    );
  }

  /// Serializes this [RoadmapWeek] to a JSON map.
  Map<String, dynamic> toJson() => {
        'week': week,
        'topic': topic,
        'description': description,
        'resources': resources,
        'link': link,
      };
}

/// Represents the complete analysis result returned by the backend.
///
/// Contains the market skills, the user's matched/missing skills,
/// the AI-generated learning roadmap, and performance metadata.
class AnalysisResult {
  /// Whether the analysis completed successfully.
  final bool success;

  /// The job title that was analyzed.
  final String jobTitle;

  /// All skills currently demanded by the market for this role.
  final List<String> marketSkills;

  /// Skills the user already has that match market requirements.
  final List<String> matchedSkills;

  /// Skills the user is missing and needs to learn.
  final List<String> missingSkills;

  /// The AI-generated week-by-week learning roadmap.
  final List<RoadmapWeek> roadmap;

  /// Metadata about the analysis (processing time, counts, etc.).
  final AnalysisMetadata? metadata;

  /// Creates a new [AnalysisResult] instance.
  const AnalysisResult({
    required this.success,
    required this.jobTitle,
    required this.marketSkills,
    required this.matchedSkills,
    required this.missingSkills,
    required this.roadmap,
    this.metadata,
  });

  /// Factory constructor to create an [AnalysisResult] from a JSON map.
  ///
  /// Parses nested objects (roadmap weeks, metadata) recursively.
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      success: json['success'] as bool? ?? false,
      jobTitle: json['job_title'] as String? ?? '',
      // Parse string lists with safe casting
      marketSkills: _parseStringList(json['market_skills']),
      matchedSkills: _parseStringList(json['matched_skills']),
      missingSkills: _parseStringList(json['missing_skills']),
      // Parse roadmap as a list of RoadmapWeek objects
      roadmap: (json['roadmap'] as List<dynamic>?)
              ?.map((e) => RoadmapWeek.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      // Parse optional metadata
      metadata: json['metadata'] != null
          ? AnalysisMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Helper method to safely parse a list of strings from dynamic JSON.
  static List<String> _parseStringList(dynamic json) {
    if (json is List) {
      return json.map((e) => e.toString()).toList();
    }
    return [];
  }
}

/// Metadata about the analysis request (performance metrics).
///
/// Useful for monitoring and optimizing the system.
class AnalysisMetadata {
  /// Total number of market skills identified.
  final int totalMarketSkills;

  /// Number of user skills that matched market requirements.
  final int totalMatched;

  /// Number of skills the user is missing.
  final int totalMissing;

  /// Number of weeks in the generated roadmap.
  final int roadmapWeeks;

  /// Total server-side processing time in milliseconds.
  final int processingTimeMs;

  /// Creates a new [AnalysisMetadata] instance.
  const AnalysisMetadata({
    required this.totalMarketSkills,
    required this.totalMatched,
    required this.totalMissing,
    required this.roadmapWeeks,
    required this.processingTimeMs,
  });

  /// Factory constructor to create [AnalysisMetadata] from JSON.
  factory AnalysisMetadata.fromJson(Map<String, dynamic> json) {
    return AnalysisMetadata(
      totalMarketSkills: json['total_market_skills'] as int? ?? 0,
      totalMatched: json['total_matched'] as int? ?? 0,
      totalMissing: json['total_missing'] as int? ?? 0,
      roadmapWeeks: json['roadmap_weeks'] as int? ?? 0,
      processingTimeMs: json['processing_time_ms'] as int? ?? 0,
    );
  }
}
