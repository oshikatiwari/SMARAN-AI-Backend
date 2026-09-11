// end_game_session.dart
//
// EndGameSession use-case is defined in start_game_session.dart alongside
// StartGameSession and DomainException because:
//   1. Both use-cases share the single DomainException type.
//   2. Both operate on the IGameSessionRepository.
//   3. Keeping session lifecycle use-cases co-located prevents circular imports.
//
// Import the use-case from start_game_session.dart:
//   import 'package:cognitive_care_games/features/games/domain/usecases/start_game_session.dart';
//
// This file is intentionally a redirect/documentation stub so the file tree
// promised in the Phase 0 blueprint exists and is self-explanatory.
//
// If the team decides to split these into separate files later, move the
// EndGameSession class here and update the import in usecase_providers.dart.

export 'start_game_session.dart' show EndGameSession, DomainException;
