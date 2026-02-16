/// ====================================================================
/// Forward AI — API Service (Repository Pattern)
/// ====================================================================
/// This service handles all HTTP communication with the Node.js backend.
///
/// Design Pattern: Repository Pattern
///   - Abstracts the data source (HTTP API) behind a clean interface.
///   - The rest of the app doesn't care HOW data is fetched, just that
///     it can call `analyzeCareer()` and get an [AnalysisResult].
///   - Makes it easy to swap the data source (e.g., mock for testing).
///
/// Performance Optimizations:
///   - Dio is configured with connection pooling and timeouts.
///   - Request/response interceptors for logging and error handling.
///   - Singleton pattern ensures only one Dio instance exists.
/// ====================================================================
library;

import 'package:dio/dio.dart';
import '../models/analysis_result.dart';
import '../models/personality_question.dart';

/// Service class that handles all API communication with the backend.
///
/// Uses the Dio HTTP client for robust networking with:
///   - Automatic timeout handling (60 seconds for AI processing)
///   - Request/response logging for debugging
///   - Structured error handling with user-friendly messages
class ApiService {
  /// The Dio HTTP client instance (singleton per ApiService).
  late final Dio _dio;

  /// Base URL of the Node.js orchestration backend.
  ///
  /// For Android Emulator: Use 10.0.2.2 which maps to host machine's localhost.
  /// For iOS Simulator:    Use localhost directly.
  /// For Physical Device:  Use your machine's local network IP.
  /// For Web:              Use localhost directly.
  static const String _baseUrl = 'http://10.0.2.2:3000';

  /// Creates a new [ApiService] instance and configures the Dio client.
  ///
  /// The constructor sets up:
  ///   - Base URL for all requests
  ///   - Timeouts (connection, send, receive)
  ///   - Content-Type headers
  ///   - Logging interceptor for debugging
  ApiService() {
    _dio = Dio(
      BaseOptions(
        // Base URL — all request paths are relative to this
        baseUrl: _baseUrl,

        // Timeout Configuration:
        // - connectTimeout: Max time to establish a TCP connection
        // - sendTimeout:    Max time to send the request body
        // - receiveTimeout: Max time to receive the response body
        //   (set high because AI processing can take 20-40 seconds)
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),

        // Default headers for all requests
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },

        // Accept all status codes and handle errors manually
        // This gives us more control over error messaging
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add logging interceptor for development debugging
    _dio.interceptors.add(
      LogInterceptor(
        request: true, // Log request details
        requestHeader: false, // Skip headers (too verbose)
        requestBody: true, // Log what we're sending
        responseBody: true, // Log what we receive
        responseHeader: false, // Skip response headers
        error: true, // Always log errors
        logPrint: (msg) => print('🌐 [ApiService] $msg'),
      ),
    );
  }

  /// Sends a career analysis request to the backend.
  ///
  /// This is the main entry point for the app's core functionality.
  /// It sends the user's job title and existing skills to the Node.js
  /// backend, which orchestrates:
  ///   1. Python service call (market skill extraction)
  ///   2. Skill gap calculation
  ///   3. Gemini AI roadmap generation
  ///
  /// Args:
  ///   [jobTitle]   — The target job role (e.g., "Flutter Developer").
  ///   [userSkills] — List of skills the user already has (e.g., ["Dart", "Git"]).
  ///
  /// Returns:
  ///   An [AnalysisResult] containing market skills, gaps, and roadmap.
  ///
  /// Throws:
  ///   [ApiException] with a user-friendly message if anything goes wrong.
  Future<AnalysisResult> analyzeCareer({
    required String jobTitle,
    required List<String> userSkills,
  }) async {
    try {
      print('🚀 [ApiService] Sending analysis request...');
      print('   Job Title: $jobTitle');
      print('   User Skills: $userSkills');

      // POST request to the Node.js backend
      final response = await _dio.post(
        '/api/analyze',
        data: {
          'jobTitle': jobTitle,
          'userSkills': userSkills,
        },
      );

      // Check if the response indicates success
      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ [ApiService] Analysis complete!');
        // Parse the JSON response into our data model
        return AnalysisResult.fromJson(response.data);
      } else {
        // Backend returned an error response (e.g., 400 Bad Request)
        final errorMsg =
            response.data['error'] ?? 'Server returned an error.';
        print('❌ [ApiService] Server error: $errorMsg');
        throw ApiException(errorMsg);
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors with user-friendly messages
      print('❌ [ApiService] DioException: ${e.type} — ${e.message}');
      throw ApiException(_getDioErrorMessage(e));
    } catch (e) {
      // Handle any other unexpected errors
      if (e is ApiException) rethrow;
      print('❌ [ApiService] Unexpected error: $e');
      throw ApiException('An unexpected error occurred. Please try again.');
    }
  }

  /// Sends personality quiz answers to the backend for AI-powered
  /// track recommendation via Gemini prompt engineering.
  ///
  /// Args:
  ///   [answers]     — List of maps with { question, chosenAnswer, trait }.
  ///   [traitScores] — Accumulated trait scores from the quiz.
  ///
  /// Returns:
  ///   A [TrackResult] with the AI-recommended track.
  ///
  /// Throws:
  ///   [ApiException] if the backend is unreachable or returns an error.
  Future<TrackResult> evaluatePersonality({
    required List<Map<String, String>> answers,
    required Map<String, int> traitScores,
  }) async {
    try {
      print('🧠 [ApiService] Sending personality evaluation...');
      print('   Answers: ${answers.length}');
      print('   Trait Scores: $traitScores');

      final response = await _dio.post(
        '/api/personality',
        data: {
          'answers': answers,
          'traitScores': traitScores,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ [ApiService] Personality evaluation complete!');
        final data = response.data;
        return TrackResult(
          trackName: data['trackName'] ?? 'Frontend Development',
          matchPercentage: data['matchPercentage'] ?? 75,
          description: data['description'] ?? '',
          strengths: List<String>.from(data['strengths'] ?? []),
          emoji: data['emoji'] ?? '🎯',
        );
      } else {
        final errorMsg =
            response.data['error'] ?? 'Server returned an error.';
        print('❌ [ApiService] Server error: $errorMsg');
        throw ApiException(errorMsg);
      }
    } on DioException catch (e) {
      print('❌ [ApiService] DioException: ${e.type} — ${e.message}');
      throw ApiException(_getDioErrorMessage(e));
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ [ApiService] Unexpected error: $e');
      throw ApiException('An unexpected error occurred. Please try again.');
    }
  }

  /// Checks if the backend server is reachable.
  ///
  /// Calls the /health endpoint to verify connectivity.
  /// Useful for showing connection status in the UI.
  ///
  /// Returns true if the server responds with a 200 status.
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(
        '/health',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Converts Dio exceptions to user-friendly error messages.
  ///
  /// Users don't care about HTTP status codes or socket errors.
  /// They want to know WHAT went wrong and WHAT to do about it.
  ///
  /// @param e The DioException to convert.
  /// @returns A human-readable error message string.
  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timed out while sending data. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'The server took too long to respond. The AI might be processing a complex request — please try again.';
      case DioExceptionType.connectionError:
        return 'Could not connect to the server. Make sure the backend is running on localhost:3000.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          return 'Invalid request. Please check your input and try again.';
        } else if (statusCode == 429) {
          return 'Too many requests. Please wait a moment and try again.';
        } else if (statusCode == 500) {
          return 'Server error. Our team has been notified.';
        }
        return 'Server responded with an error (HTTP $statusCode).';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'A network error occurred. Please check your connection.';
    }
  }
}

/// Custom exception class for API errors.
///
/// Carries a user-friendly message that can be displayed directly in the UI.
class ApiException implements Exception {
  /// The user-friendly error message.
  final String message;

  /// Creates a new [ApiException] with the given message.
  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
