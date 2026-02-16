/// ====================================================================
/// Forward AI — Analysis Provider (State Management)
/// ====================================================================
/// This provider manages the application state for the career analysis
/// feature using the ChangeNotifier pattern with Flutter's Provider package.
///
/// Design Pattern: ChangeNotifier + Provider
///   - Separation of Concerns: UI code doesn't contain business logic.
///   - Reactive UI: Widgets rebuild automatically when state changes.
///   - Testable: Provider can be tested independently of UI.
///   - Scalable: Easy to add new state fields as the app grows.
///
/// State Machine:
///   IDLE → LOADING → SUCCESS or ERROR → IDLE (on reset)
/// ====================================================================

import 'package:flutter/foundation.dart';
import '../models/analysis_result.dart';
import '../services/api_service.dart';
import '../data/mock_data.dart';

/// Enum representing the possible states of the analysis flow.
///
/// Using an enum (instead of booleans) makes state management cleaner
/// and prevents impossible states (e.g., loading AND error at same time).
enum AnalysisState {
  /// Initial state — no analysis has been performed yet.
  idle,

  /// Analysis is in progress — show loading indicator.
  loading,

  /// Analysis completed successfully — show results.
  success,

  /// Analysis failed — show error message.
  error,
}

/// Provider that manages the career analysis state.
///
/// Holds:
///   - The current state ([AnalysisState])
///   - The analysis result ([AnalysisResult]) if successful
///   - The error message if failed
///   - Server health status
///
/// Exposes:
///   - [analyzeCareer()] to trigger a new analysis
///   - [reset()] to clear results and return to idle state
///   - [checkServerHealth()] to verify backend connectivity
class AnalysisProvider extends ChangeNotifier {
  /// The API service instance (injected via constructor for testability).
  final ApiService _apiService;

  /// Current state of the analysis flow.
  AnalysisState _state = AnalysisState.idle;

  /// The analysis result (populated on success).
  AnalysisResult? _result;

  /// Error message (populated on failure).
  String _errorMessage = '';

  /// Whether the backend server is reachable.
  bool _isServerHealthy = false;

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------

  /// Creates a new [AnalysisProvider] with the given API service.
  ///
  /// Dependency Injection: The [ApiService] is passed in, making this
  /// provider testable with a mock service.
  AnalysisProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // -----------------------------------------------------------------------
  // Getters (Read-Only Access to State)
  // -----------------------------------------------------------------------
  // Getters ensure the UI can read state but cannot modify it directly.
  // State changes only happen through the provider's methods.

  /// Current analysis state.
  AnalysisState get state => _state;

  /// The analysis result (null if no analysis has been completed).
  AnalysisResult? get result => _result;

  /// The error message (empty string if no error).
  String get errorMessage => _errorMessage;

  /// Whether the backend server is reachable.
  bool get isServerHealthy => _isServerHealthy;

  /// Convenience getters for common state checks.
  bool get isIdle => _state == AnalysisState.idle;
  bool get isLoading => _state == AnalysisState.loading;
  bool get isSuccess => _state == AnalysisState.success;
  bool get isError => _state == AnalysisState.error;

  // -----------------------------------------------------------------------
  // Actions (Methods that Modify State)
  // -----------------------------------------------------------------------

  /// Triggers a career analysis for the given job title and user skills.
  ///
  /// State transitions:
  ///   1. Sets state to [AnalysisState.loading]
  ///   2. Calls the backend API via [ApiService]
  ///   3. On success: stores result, sets state to [AnalysisState.success]
  ///   4. On failure: stores error message, sets state to [AnalysisState.error]
  ///
  /// The UI automatically rebuilds via [notifyListeners()] at each transition.
  ///
  /// Args:
  ///   [jobTitle]   — Target job role (e.g., "Flutter Developer").
  ///   [userSkills] — List of user's existing skills (e.g., ["Dart", "Git"]).
  Future<void> analyzeCareer({
    required String jobTitle,
    required List<String> userSkills,
  }) async {
    // --- Transition to LOADING state ---
    _state = AnalysisState.loading;
    _errorMessage = '';
    _result = null;
    notifyListeners(); // Trigger UI rebuild to show loading indicator

    try {
      // --- Call the API ---
      debugPrint('🚀 [AnalysisProvider] Starting analysis...');
      final result = await _apiService.analyzeCareer(
        jobTitle: jobTitle,
        userSkills: userSkills,
      );

      // --- Transition to SUCCESS state ---
      _result = result;
      _state = AnalysisState.success;
      debugPrint('✅ [AnalysisProvider] Analysis complete!');
    } on ApiException catch (e) {
      // --- Transition to ERROR state (known API error) ---
      _errorMessage = e.message;
      _state = AnalysisState.error;
      debugPrint('❌ [AnalysisProvider] API error: ${e.message}');
    } catch (e) {
      // --- Transition to ERROR state (unexpected error) ---
      _errorMessage = 'An unexpected error occurred: $e';
      _state = AnalysisState.error;
      debugPrint('❌ [AnalysisProvider] Unexpected error: $e');
    }

    // Notify all listening widgets to rebuild with the new state
    notifyListeners();
  }

  /// Triggers a career analysis using mock data (no backend needed).
  ///
  /// Simulates a network delay, then returns hardcoded results.
  /// This is the MVP mode — swap to [analyzeCareer] when APIs are ready.
  Future<void> analyzeCareerWithMockData({
    required String jobTitle,
    required List<String> userSkills,
  }) async {
    _state = AnalysisState.loading;
    _errorMessage = '';
    _result = null;
    notifyListeners();

    // Simulate network delay for realistic feel
    await Future.delayed(const Duration(milliseconds: 1500));

    _result = getMockAnalysisResult(
      jobTitle: jobTitle,
      userSkills: userSkills,
    );
    _state = AnalysisState.success;
    debugPrint('✅ [AnalysisProvider] Mock analysis complete!');
    notifyListeners();
  }

  /// Resets the provider to its initial idle state.
  ///
  /// Call this when the user wants to start a new analysis
  /// (e.g., pressing a "New Analysis" button).
  void reset() {
    _state = AnalysisState.idle;
    _result = null;
    _errorMessage = '';
    notifyListeners();
    debugPrint('🔄 [AnalysisProvider] State reset to idle.');
  }

  /// Checks if the backend server is reachable.
  ///
  /// Updates [isServerHealthy] and notifies listeners.
  /// Useful for showing a connection indicator in the UI.
  Future<void> checkServerHealth() async {
    _isServerHealthy = await _apiService.checkHealth();
    notifyListeners();
    debugPrint(
      '🏥 [AnalysisProvider] Server health: ${_isServerHealthy ? "✅ Healthy" : "❌ Unreachable"}',
    );
  }
}
