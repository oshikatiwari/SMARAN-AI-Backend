// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Mizo (`lus`).
class AppLocalizationsLus extends AppLocalizations {
  AppLocalizationsLus([String locale = 'lus']) : super(locale);

  @override
  String get appTitle => 'Hriatna Zirna Chhaih';

  @override
  String get gameSelectionTitle => 'Chhaih Thlang Rawh';

  @override
  String get gameSelectionSubtitle =>
      'Tan turin chhaih zinga pakhat thlang rawh.';

  @override
  String get memoryMatchingTitle => 'Hriatrengna Inrem Zuk';

  @override
  String get memoryMatchingDescription =>
      'Kard inang zawng chhuak rawh. Hriatrengna leh rilru tinfim a tanpui.';

  @override
  String get patternRecognitionTitle => 'Thil Zui Hriatna';

  @override
  String get patternRecognitionDescription =>
      'Thil thleng zui entu rawh, a dawt a thil awm tur thlang rawh. Rilru ngaihtuahna a chawm.';

  @override
  String get howToPlayHeading => 'Khelh Dan Tur';

  @override
  String get memoryMatchingHowToPlay =>
      'Kard inrem zawng turin thlu rawh. A inrem awlsam zawk nan kard awmna hre reng rawh.';

  @override
  String get patternRecognitionHowToPlay =>
      'A zui dan en la, a dawt a thil awm tur thlang rawh.';

  @override
  String get selectDifficulty => 'Har Sualna Thlang Rawh';

  @override
  String get difficultyEasy => 'Awlsam';

  @override
  String get difficultyMedium => 'Laihawl';

  @override
  String get difficultyHard => 'Harsa';

  @override
  String get difficultyTimeEasy => '3 minit';

  @override
  String get difficultyTimeMedium => '2 minit';

  @override
  String get difficultyTimeHard => '90 sec';

  @override
  String get labelGrid => 'Grid';

  @override
  String get labelPairs => 'Inrem';

  @override
  String get labelTime => 'Hun';

  @override
  String get labelRounds => 'Phek';

  @override
  String get labelType => 'Chi';

  @override
  String get labelRound => 'Phek';

  @override
  String get startGame => 'Tan Rawh';

  @override
  String get quitGame => 'Bawh Chhuak';

  @override
  String get keepPlaying => 'Chhunzawm Rawh';

  @override
  String get quitDialogTitle => 'Chhaih atangin chhuah i duh em?';

  @override
  String get quitDialogBody =>
      'I hmasawnna tluantling lovin dah ṭha a ni ang.';

  @override
  String get yourResults => 'I Hmasawnna';

  @override
  String get wellDone => 'Thawk Tha Tak!';

  @override
  String get goodTry => 'Thawh Rim Tak!';

  @override
  String get playAgain => 'Chhaih Nawn Rawh';

  @override
  String get backToMenu => 'Menu-ah Kir Rawh';

  @override
  String get labelDuration => 'Hun Hman';

  @override
  String get labelAccuracy => 'A Dik Zong';

  @override
  String get labelAttempts => 'Chhinna';

  @override
  String get labelErrors => 'Tihdikloh';

  @override
  String get labelHintsUsed => 'Hriattirna Hman';

  @override
  String get labelCompletion => 'Puitlinna';

  @override
  String get patternTypeNumbers => 'Humber';

  @override
  String get patternTypeColors => 'Rawng';

  @override
  String get patternTypeShapes => 'Lem';

  @override
  String get patternInstructionNumeric =>
      'A dawt a number awm tur chu eng nge?';

  @override
  String get patternInstructionColor => 'A dawt a rawng awm tur chu eng nge?';

  @override
  String get patternInstructionShape => 'A dawt a lem awm tur chu eng nge?';

  @override
  String get selectPatternType => 'Thil Zui Chi';

  @override
  String get errorGeneric => 'Rukhmang a thleng a ni.';

  @override
  String get errorSaveFailed =>
      'Result dah ṭhat a hlawhtling lo. Khawngaihin tum nawn rawh.';

  @override
  String get noTimeLimitSymbol => '∞';

  @override
  String timerSemanticLabel(String time) {
    return 'Hun: $time';
  }

  @override
  String attemptsSemanticLabel(int count) {
    return 'Chhinna $count';
  }

  @override
  String errorsSemanticLabel(int count) {
    return 'Tihdikloh $count';
  }

  @override
  String hintsSemanticLabel(int count) {
    return 'Hriattirna hman $count';
  }

  @override
  String roundSemanticLabel(int current, int total) {
    return 'Phek $current / $total';
  }

  @override
  String difficultySemanticLabel(String difficulty) {
    return '$difficulty harsa zong';
  }
}
