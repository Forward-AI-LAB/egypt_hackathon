/// ====================================================================
/// Forward AI — Personality Provider (Quiz State Management)
/// ====================================================================
/// Manages the state of the personality evaluation quiz flow.
///
/// State: currentIndex → answers[] → result
/// ====================================================================

import 'package:flutter/foundation.dart';
import '../models/personality_question.dart';
import '../data/mock_data.dart';

/// Provider for the personality quiz feature.
class PersonalityProvider extends ChangeNotifier {
  /// The list of quiz questions.
  final List<PersonalityQuestion> _questions = List.from(mockQuizQuestions);

  /// Index of the currently displayed question.
  int _currentIndex = 0;

  /// Accumulated trait scores from answers.
  final Map<String, int> _traitScores = {};

  /// The computed result after completing all questions.
  TrackResult? _result;

  /// Whether the quiz is complete.
  bool _isComplete = false;

  // --- Getters ---

  List<PersonalityQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  PersonalityQuestion get currentQuestion => _questions[_currentIndex];
  int get totalQuestions => _questions.length;
  double get progress => (_currentIndex + 1) / _questions.length;
  bool get isComplete => _isComplete;
  TrackResult? get result => _result;
  bool get isLastQuestion => _currentIndex >= _questions.length - 1;

  /// Records the answer for the current question and advances.
  ///
  /// If it's the last question, computes the result.
  void answerQuestion(QuizOption selectedOption) {
    // Accumulate the trait score
    _traitScores[selectedOption.trait] =
        (_traitScores[selectedOption.trait] ?? 0) + selectedOption.weight;

    if (_currentIndex < _questions.length - 1) {
      // Advance to next question
      _currentIndex++;
      notifyListeners();
    } else {
      // Quiz complete — calculate result
      _calculateResult();
    }
  }

  /// Computes the best-fit track based on accumulated trait scores.
  void _calculateResult() {
    // Find the dominant trait
    String dominantTrait = 'creative';
    int maxScore = 0;
    _traitScores.forEach((trait, score) {
      if (score > maxScore) {
        maxScore = score;
        dominantTrait = trait;
      }
    });

    // Calculate a match percentage (scores range from ~2-8 per trait)
    final totalAnswers = _questions.length;
    final matchPct = ((maxScore / totalAnswers) * 100).clamp(65, 97).toInt();

    // Build the strengths list based on top traits
    final sortedTraits = _traitScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTraits = sortedTraits.take(3).map((e) => e.key).toList();

    final strengthsMap = {
      'visual': 'Strong visual & aesthetic sense',
      'creative': 'Creative problem-solving & innovation',
      'analytical': 'Logical thinking & optimization',
      'collaborative': 'Team collaboration & communication',
      'detail': 'Attention to detail & quality',
    };

    final strengths =
        topTraits.map((t) => strengthsMap[t] ?? t).toList();

    _result = TrackResult(
      trackName: 'Frontend Development',
      matchPercentage: matchPct,
      description:
          'Your personality aligns perfectly with Frontend Development! '
          'You have a natural eye for design, creativity, and user experience — '
          'exactly what makes a great frontend developer.',
      strengths: strengths,
      emoji: '🎨',
    );

    _isComplete = true;
    notifyListeners();

    debugPrint('🧠 [PersonalityProvider] Quiz complete!');
    debugPrint('   Trait scores: $_traitScores');
    debugPrint('   Dominant trait: $dominantTrait ($maxScore)');
    debugPrint('   Match: $matchPct%');
  }

  /// Resets the quiz to start over.
  void reset() {
    _currentIndex = 0;
    _traitScores.clear();
    _result = null;
    _isComplete = false;
    notifyListeners();
    debugPrint('🔄 [PersonalityProvider] Quiz reset.');
  }
}
