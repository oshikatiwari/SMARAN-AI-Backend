import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

import 'package:cognitive_care_games/features/games/domain/entities/game_result.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';

/// Response payload returned by the SMARAN AI backend `POST /predict-difficulty`.
///
/// Fields:
/// - [recommendedDifficulty]: parsed [Difficulty] enum ("Easy" | "Medium" | "Hard")
/// - [patientMessage]: patient encouragement message
/// - [caregiverSummary]: caregiver summary string
class SmaranAiResponse {
  const SmaranAiResponse({
    required this.recommendedDifficulty,
    required this.patientMessage,
    required this.caregiverSummary,
  });

  final Difficulty recommendedDifficulty;
  final String patientMessage;
  final String caregiverSummary;

  factory SmaranAiResponse.fromJson(Map<String, dynamic> json) {
    final levelStr = json['recommended_level'] as String? ?? 'Easy';
    return SmaranAiResponse(
      recommendedDifficulty: Difficulty.fromString(levelStr),
      patientMessage: json['patient_message'] as String? ?? '',
      caregiverSummary: json['caregiver_summary'] as String? ?? '',
    );
  }
}

/// Clean API service for interacting with the SMARAN AI FastAPI Backend.
///
/// Configurable API base URL:
/// Reads `SMARAN_API_BASE_URL` from `--dart-define=SMARAN_API_BASE_URL=...`.
/// Defaults to local development URL: `http://127.0.0.1:8000`.
class SmaranAiService {
  static const String defaultBaseUrl = String.fromEnvironment(
    'SMARAN_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  SmaranAiService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? defaultBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  /// Returns the active API base URL.
  String get baseUrl => _baseUrl;

  /// Predicts recommended difficulty for the subsequent game session.
  ///
  /// Sends session telemetry metrics to `POST /predict-difficulty`.
  ///
  /// Compliance Rules:
  /// - Excludes `patient_id`.
  /// - Excludes `attempts`.
  /// - Uses `gameType.value` ("memory_matching" | "pattern_recognition").
  /// - Uses `currentDifficulty.value` ("easy" | "medium" | "hard").
  /// - Fails gracefully on network issues, backend down, or timeout.
  Future<SmaranAiResponse?> predictDifficulty({
    required GameType gameType,
    required Difficulty currentDifficulty,
    required GameResult result,
  }) async {
    final uri = Uri.parse('$_baseUrl/predict-difficulty');

    // Build the precise payload expected by FastAPI backend
    final payload = <String, dynamic>{
      'game_type': gameType.value,
      'current_difficulty': currentDifficulty.value,
      'accuracy': result.accuracy,
      'completion_rate': result.completionRate,
      'response_time_ms': result.responseTimeMs,
      'errors': result.errors,
      'hints_used': result.hintsUsed,
    };

    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        return SmaranAiResponse.fromJson(decoded);
      } else {
        developer.log(
          'SMARAN AI API returned HTTP status ${response.statusCode}: ${response.body}',
          name: 'SmaranAiService',
        );
        return null;
      }
    } catch (e, stackTrace) {
      // Graceful error fallback - ensures offline-first stability
      developer.log(
        'SMARAN AI backend request failed gracefully: $e',
        name: 'SmaranAiService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
