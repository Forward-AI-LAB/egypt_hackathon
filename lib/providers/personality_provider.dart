/// ====================================================================
/// Forward AI — Personality Provider (Quiz State Management)
/// ====================================================================
/// Manages the state of the personality evaluation quiz flow.
/// Now calls the backend API for AI-powered track recommendation.
///
/// State: currentIndex → answers[] → loading → result
/// ====================================================================
library;

import 'package:flutter/foundation.dart';
import '../models/personality_question.dart';
import '../data/mock_data.dart';
import '../services/api_service.dart';

/// Provider for the personality quiz feature.
class PersonalityProvider extends ChangeNotifier {
  /// The list of quiz questions.
  final List<PersonalityQuestion> _questions = List.from(mockQuizQuestions);

  /// Index of the currently displayed question.
  int _currentIndex = 0;

  /// Accumulated trait scores from answers.
  final Map<String, int> _traitScores = {};

  /// Recorded answers for sending to the backend.
  final List<Map<String, String>> _answers = [];

  /// The computed result after completing all questions.
  TrackResult? _result;

  /// Whether the quiz is complete.
  bool _isComplete = false;

  /// Whether we're waiting for the AI response.
  bool _isLoading = false;

  /// Error message if the API call fails.
  String? _error;

  /// API service for backend communication.
  final ApiService _apiService = ApiService();

  // --- Getters ---

  List<PersonalityQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  PersonalityQuestion get currentQuestion => _questions[_currentIndex];
  int get totalQuestions => _questions.length;
  double get progress => (_currentIndex + 1) / _questions.length;
  bool get isComplete => _isComplete;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TrackResult? get result => _result;
  bool get isLastQuestion => _currentIndex >= _questions.length - 1;

  /// Records the answer for the current question and advances.
  ///
  /// If it's the last question, triggers AI-powered result calculation.
  void answerQuestion(QuizOption selectedOption) {
    // Accumulate the trait score
    _traitScores[selectedOption.trait] =
        (_traitScores[selectedOption.trait] ?? 0) + selectedOption.weight;

    // Record the answer for sending to backend
    _answers.add({
      'question': currentQuestion.question,
      'chosenAnswer': selectedOption.label,
      'trait': selectedOption.trait,
    });

    if (_currentIndex < _questions.length - 1) {
      // Advance to next question
      _currentIndex++;
      notifyListeners();
    } else {
      // Quiz complete — calculate result via backend
      _calculateResult();
    }
  }

  /// Computes the best-fit track by calling the AI backend.
  /// Falls back to local scoring if the backend is unavailable.
  Future<void> _calculateResult() async {
    _isLoading = true;
    _error = null;
    _isComplete = true;
    notifyListeners();

    debugPrint('🧠 [PersonalityProvider] Quiz complete! Calling backend...');
    debugPrint('   Trait scores: $_traitScores');
    debugPrint('   Answers: ${_answers.length}');

    try {
      // Try AI-powered analysis via backend
      final trackResult = await _apiService.evaluatePersonality(
        answers: _answers,
        traitScores: _traitScores,
      );

      _result = trackResult;
      _isLoading = false;
      notifyListeners();

      debugPrint('✅ [PersonalityProvider] AI result: ${_result!.trackName} '
          '(${_result!.matchPercentage}%)');
    } catch (e) {
      debugPrint('⚠️ [PersonalityProvider] Backend failed: $e');
      debugPrint('   Falling back to local scoring...');

      // Fallback: local trait-based scoring (improved to support all tracks)
      _calculateResultLocally();
    }
  }

  /// Local fallback: scores each track based on trait overlap.
  void _calculateResultLocally() {
    // Find the dominant trait
    String dominantTrait = 'creative';
    int maxScore = 0;
    _traitScores.forEach((trait, score) {
      if (score > maxScore) {
        maxScore = score;
        dominantTrait = trait;
      }
    });

    // Map dominant traits to tracks
    final traitToTrack = {
      'visual': 'Frontend Development',
      'creative': 'UI/UX Design',
      'analytical': 'Backend Development',
      'detail': 'Backend Development',
      'collaborative': 'UI/UX Design',
      'systematic': 'DevOps Engineering',
      'curious': 'Data Science',
    };

    final traitToEmoji = {
      'visual': '🎨',
      'creative': '✏️',
      'analytical': '⚙️',
      'detail': '⚙️',
      'collaborative': '✏️',
      'systematic': '🔧',
      'curious': '📊',
    };

    final trackName = traitToTrack[dominantTrait] ?? 'Frontend Development';
    final emoji = traitToEmoji[dominantTrait] ?? '🎯';

    // Calculate a match percentage
    final totalAnswers = _questions.length;
    final matchPct = ((maxScore / totalAnswers) * 100).clamp(65, 97).toInt();

    // Build strengths from top traits
    final sortedTraits = _traitScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTraits = sortedTraits.take(3).map((e) => e.key).toList();

    final strengthsMap = {
      'visual': 'Strong visual & aesthetic sense',
      'creative': 'Creative problem-solving & innovation',
      'analytical': 'Logical thinking & optimization',
      'collaborative': 'Team collaboration & communication',
      'detail': 'Attention to detail & quality',
      'systematic': 'Systematic & structured approach',
      'curious': 'Intellectual curiosity & exploration',
    };

    final strengths =
        topTraits.map((t) => strengthsMap[t] ?? t).toList();

    _result = TrackResult(
      trackName: trackName,
      matchPercentage: matchPct,
      description:
          'Your personality aligns well with $trackName! '
          'Your strengths in ${topTraits.join(", ")} '
          'are exactly what makes a great ${trackName.toLowerCase()} professional.',
      strengths: strengths,
      emoji: emoji,
    );

    _isLoading = false;
    notifyListeners();

    debugPrint('📦 [PersonalityProvider] Local result: ${_result!.trackName} '
        '(${_result!.matchPercentage}%)');
  }

  /// Resets the quiz to start over.
  void reset() {
    _currentIndex = 0;
    _traitScores.clear();
    _answers.clear();
    _result = null;
    _isComplete = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
    debugPrint('🔄 [PersonalityProvider] Quiz reset.');
  }
}
