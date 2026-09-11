// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khasi (`kha`).
class AppLocalizationsKha extends AppLocalizations {
  AppLocalizationsKha([String locale = 'kha']) : super(locale);

  @override
  String get appTitle => 'Jingkyntu Jingkynmaw Games';

  @override
  String get gameSelectionTitle => 'Jied ia ka Phawria';

  @override
  String get gameSelectionSubtitle =>
      'Jied ia ka jingialang ban sdang ia ka jingkyntu.';

  @override
  String get memoryMatchingTitle => 'Jingpyniasnoh ha ka Jingkynmaw';

  @override
  String get memoryMatchingDescription =>
      'Pynkylla ia ki dur ban wad ia kiba iasnoh. Yarap ban pynjanai ia ka jingkynmaw.';

  @override
  String get patternRecognitionTitle => 'Jingithuh ia ka Jingiaid';

  @override
  String get patternRecognitionDescription =>
      'Peit ia ka jingiaid, jied ia kaba buddien. Yarap ha ka jingshai bad jingpyrkhat.';

  @override
  String get howToPlayHeading => 'Kumlai ban Ialeh';

  @override
  String get memoryMatchingHowToPlay =>
      'Pynkylla ia ki dur ban wad ia kiba iasnoh. Kynmaw nangno kiei kiei kiei kiba iasnoh buh.';

  @override
  String get patternRecognitionHowToPlay =>
      'Peit ia ka jingiaid, nangta jied ia kaba buddhien.';

  @override
  String get selectDifficulty => 'Jied ia ka Jingeh';

  @override
  String get difficultyEasy => 'Suk';

  @override
  String get difficultyMedium => 'Pdeng';

  @override
  String get difficultyHard => 'Eh';

  @override
  String get difficultyTimeEasy => '3 minit';

  @override
  String get difficultyTimeMedium => '2 minit';

  @override
  String get difficultyTimeHard => '90 sec';

  @override
  String get labelGrid => 'Grid';

  @override
  String get labelPairs => 'Jingiasnoh';

  @override
  String get labelTime => 'Por';

  @override
  String get labelRounds => 'Kyntien';

  @override
  String get labelType => 'Jait';

  @override
  String get labelRound => 'Kyntien';

  @override
  String get startGame => 'Sdang Phawria';

  @override
  String get quitGame => 'Mih Noh';

  @override
  String get keepPlaying => 'Iaishai Ialeh';

  @override
  String get quitDialogTitle => 'Mih noh na ka phawria?';

  @override
  String get quitDialogBody =>
      'Ka jingkiew jong phi bakhraw kan sah khlem dep.';

  @override
  String get yourResults => 'Ka Jingseimot Jong Phi';

  @override
  String get wellDone => 'Kaba Bha Shibun!';

  @override
  String get goodTry => 'Jingpyrshang Kaba Bha!';

  @override
  String get playAgain => 'Ialeh Biang';

  @override
  String get backToMenu => 'Phai sha ka Menu';

  @override
  String get labelDuration => 'Por Baroh';

  @override
  String get labelAccuracy => 'Jingdei';

  @override
  String get labelAttempts => 'Jingpyrshang';

  @override
  String get labelErrors => 'Jingbakla';

  @override
  String get labelHintsUsed => 'Jingyarap';

  @override
  String get labelCompletion => 'Jingdep';

  @override
  String get patternTypeNumbers => 'Ki Dawk-nium';

  @override
  String get patternTypeColors => 'Ki Rong';

  @override
  String get patternTypeShapes => 'Ki Dur';

  @override
  String get patternInstructionNumeric =>
      'Kiei kiba bud kiba dei dawk-nium?';

  @override
  String get patternInstructionColor => 'Kaei ka rong kaba bud?';

  @override
  String get patternInstructionShape => 'Kaei ka dur kaba bud?';

  @override
  String get selectPatternType => 'Jait Jingiaid';

  @override
  String get errorGeneric => 'Don ka jingbakla.';

  @override
  String get errorSaveFailed =>
      'Khlem lah ban kynmaw ia ka jingseimot. To pyrshang biang.';

  @override
  String get noTimeLimitSymbol => '∞';

  @override
  String timerSemanticLabel(String time) {
    return 'Por: $time';
  }

  @override
  String attemptsSemanticLabel(int count) {
    return '$count jingpyrshang';
  }

  @override
  String errorsSemanticLabel(int count) {
    return '$count jingbakla';
  }

  @override
  String hintsSemanticLabel(int count) {
    return '$count jingyarap';
  }

  @override
  String roundSemanticLabel(int current, int total) {
    return 'Kyntien $current ha $total';
  }

  @override
  String difficultySemanticLabel(String difficulty) {
    return '$difficulty jingeh';
  }
}
