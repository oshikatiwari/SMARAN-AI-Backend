// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cognitive Care Games';

  @override
  String get gameSelectionTitle => 'Choose a Game';

  @override
  String get gameSelectionSubtitle => 'Select a game to begin your session.';

  @override
  String get memoryMatchingTitle => 'Memory Matching';

  @override
  String get memoryMatchingDescription =>
      'Flip cards and find matching pairs. Trains recall and focus.';

  @override
  String get patternRecognitionTitle => 'Pattern Recognition';

  @override
  String get patternRecognitionDescription =>
      'Watch the pattern, choose what comes next. Trains logical thinking.';

  @override
  String get howToPlayHeading => 'How to Play';

  @override
  String get memoryMatchingHowToPlay =>
      'Flip cards to find matching pairs. Remember where each card is to make matches quickly.';

  @override
  String get patternRecognitionHowToPlay =>
      'Watch the pattern, then choose what comes next.';

  @override
  String get selectDifficulty => 'Select Difficulty';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyTimeEasy => '3 min';

  @override
  String get difficultyTimeMedium => '2 min';

  @override
  String get difficultyTimeHard => '90 sec';

  @override
  String get labelGrid => 'Grid';

  @override
  String get labelPairs => 'Pairs';

  @override
  String get labelTime => 'Time';

  @override
  String get labelRounds => 'Rounds';

  @override
  String get labelType => 'Type';

  @override
  String get labelRound => 'Round';

  @override
  String get startGame => 'Start Game';

  @override
  String get quitGame => 'Quit';

  @override
  String get keepPlaying => 'Keep Playing';

  @override
  String get quitDialogTitle => 'Quit Game?';

  @override
  String get quitDialogBody => 'Your progress will be saved as incomplete.';

  @override
  String get yourResults => 'Your Results';

  @override
  String get wellDone => 'Well Done!';

  @override
  String get goodTry => 'Good Try!';

  @override
  String get playAgain => 'Play Again';

  @override
  String get backToMenu => 'Back to Menu';

  @override
  String get labelDuration => 'Duration';

  @override
  String get labelAccuracy => 'Accuracy';

  @override
  String get labelAttempts => 'Attempts';

  @override
  String get labelErrors => 'Errors';

  @override
  String get labelHintsUsed => 'Hints Used';

  @override
  String get labelCompletion => 'Completion';

  @override
  String get patternTypeNumbers => 'Numbers';

  @override
  String get patternTypeColors => 'Colors';

  @override
  String get patternTypeShapes => 'Shapes';

  @override
  String get patternInstructionNumeric => 'What number comes next?';

  @override
  String get patternInstructionColor => 'What color comes next?';

  @override
  String get patternInstructionShape => 'What shape comes next?';

  @override
  String get selectPatternType => 'Pattern Type';

  @override
  String get errorGeneric => 'An error occurred.';

  @override
  String get errorSaveFailed => 'Failed to save game result. Please try again.';

  @override
  String get noTimeLimitSymbol => '∞';

  @override
  String timerSemanticLabel(String time) {
    return 'Timer: $time';
  }

  @override
  String attemptsSemanticLabel(int count) {
    return '$count attempts';
  }

  @override
  String errorsSemanticLabel(int count) {
    return '$count errors';
  }

  @override
  String hintsSemanticLabel(int count) {
    return '$count hints used';
  }

  @override
  String roundSemanticLabel(int current, int total) {
    return 'Round $current of $total';
  }

  @override
  String difficultySemanticLabel(String difficulty) {
    return '$difficulty difficulty';
  }
}
