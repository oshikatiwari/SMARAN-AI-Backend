import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cognitive_care_games/features/games/data/services/smaran_ai_service.dart';
import 'package:cognitive_care_games/features/games/domain/entities/game_result.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/sync_status.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'smaran_ai_service_test.mocks.dart';

void main() {
  late MockClient mockHttpClient;
  late SmaranAiService defaultSmaranAiService;

  final testGameResult = GameResult(
    id: 'res-123',
    sessionId: 'sess-456',
    accuracy: 0.85,
    responseTimeMs: 45000,
    attempts: 10,
    errors: 2,
    hintsUsed: 1,
    completionRate: 1.0,
    syncStatus: SyncStatus.unsynced,
    createdAt: 1700000000000,
  );

  setUp(() {
    mockHttpClient = MockClient();
    defaultSmaranAiService = SmaranAiService(client: mockHttpClient);
  });

  group('SmaranAiService Configuration & URL Resolution', () {
    test('defaults to local development URL http://127.0.0.1:8000 when no baseUrl is provided', () {
      expect(defaultSmaranAiService.baseUrl, equals('http://127.0.0.1:8000'));
    });

    test('uses custom URL passed through configuration constructor', () {
      const customUrl = 'http://192.168.1.100:8000';
      final customService = SmaranAiService(client: mockHttpClient, baseUrl: customUrl);
      expect(customService.baseUrl, equals(customUrl));
    });
  });

  group('SmaranAiService API Integration', () {
    test('predictDifficulty sends correct JSON payload excluding patient_id and attempts to default local URL', () async {
      when(mockHttpClient.post(
        Uri.parse('http://127.0.0.1:8000/predict-difficulty'),
        headers: {'Content-Type': 'application/json'},
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'recommended_level': 'Hard',
              'patient_message': 'Great job! Moving to Hard level.',
              'caregiver_summary': 'Patient showed high accuracy.',
            }),
            200,
          ));

      final response = await defaultSmaranAiService.predictDifficulty(
        gameType: GameType.memoryMatching,
        currentDifficulty: Difficulty.medium,
        result: testGameResult,
      );

      expect(response, isNotNull);
      expect(response!.recommendedDifficulty, Difficulty.hard);
      expect(response.patientMessage, 'Great job! Moving to Hard level.');
      expect(response.caregiverSummary, 'Patient showed high accuracy.');

      // Verify payload sent to backend
      final verification = verify(mockHttpClient.post(
        Uri.parse('http://127.0.0.1:8000/predict-difficulty'),
        headers: {'Content-Type': 'application/json'},
        body: captureAnyNamed('body'),
      ));
      verification.called(1);

      final capturedBodyStr = verification.captured.first as String;
      final capturedJson = jsonDecode(capturedBodyStr) as Map<String, dynamic>;

      expect(capturedJson['game_type'], 'memory_matching');
      expect(capturedJson['current_difficulty'], 'medium');
      expect(capturedJson['accuracy'], 0.85);
      expect(capturedJson['completion_rate'], 1.0);
      expect(capturedJson['response_time_ms'], 45000);
      expect(capturedJson['errors'], 2);
      expect(capturedJson['hints_used'], 1);

      // Verify omitted fields
      expect(capturedJson.containsKey('patient_id'), false);
      expect(capturedJson.containsKey('attempts'), false);
    });

    test('predictDifficulty respects custom configured URL when sending request', () async {
      const customUrl = 'http://192.168.1.50:8000';
      final customService = SmaranAiService(client: mockHttpClient, baseUrl: customUrl);

      when(mockHttpClient.post(
        Uri.parse('$customUrl/predict-difficulty'),
        headers: {'Content-Type': 'application/json'},
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'recommended_level': 'Medium',
              'patient_message': 'Comfortable level maintained.',
              'caregiver_summary': 'Performance stable.',
            }),
            200,
          ));

      final response = await customService.predictDifficulty(
        gameType: GameType.patternRecognition,
        currentDifficulty: Difficulty.medium,
        result: testGameResult,
      );

      expect(response, isNotNull);
      expect(response!.recommendedDifficulty, Difficulty.medium);

      verify(mockHttpClient.post(
        Uri.parse('$customUrl/predict-difficulty'),
        headers: {'Content-Type': 'application/json'},
        body: anyNamed('body'),
      )).called(1);
    });

    test('predictDifficulty fails gracefully on HTTP error status and returns null', () async {
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Server Error', 500));

      final response = await defaultSmaranAiService.predictDifficulty(
        gameType: GameType.patternRecognition,
        currentDifficulty: Difficulty.easy,
        result: testGameResult,
      );

      expect(response, isNull);
    });

    test('predictDifficulty fails gracefully on network timeout or exception and returns null', () async {
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(Exception('Network timeout'));

      final response = await defaultSmaranAiService.predictDifficulty(
        gameType: GameType.patternRecognition,
        currentDifficulty: Difficulty.easy,
        result: testGameResult,
      );

      expect(response, isNull);
    });
  });
}
