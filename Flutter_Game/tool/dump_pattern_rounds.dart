// Dev-only utility: dumps every deterministic Pattern Recognition round
// (sequence, options, correct index) for all pattern types and difficulties.
// Used to cross-check the live UI during manual/automated play-testing.
// Delete after testing.
import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/pattern_type.dart';
import 'package:cognitive_care_games/features/games/presentation/pattern_recognition/flame/components/pattern_controller.dart';

void main() {
  for (final type in PatternType.values) {
    for (final difficulty in Difficulty.values) {
      final controller = PatternController(
        difficulty: difficulty,
        patternType: type,
      );
      print('=== ${type.name} / ${difficulty.name} '
          '(${difficulty.totalRounds} rounds) ===');
      var round = controller.nextRound();
      var n = 1;
      while (round != null) {
        final options = round.options;
        print('R$n seq=[${round.sequence.join(',')}] '
            'answer=${round.correctAnswer} '
            'options=[${options.join(',')}] '
            'correctIndex=${options.indexOf(round.correctAnswer)}');
        round = controller.nextRound();
        n++;
      }
    }
  }
}
