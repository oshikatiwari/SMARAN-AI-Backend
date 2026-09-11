// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Assamese (`as`).
class AppLocalizationsAs extends AppLocalizations {
  AppLocalizationsAs([String locale = 'as']) : super(locale);

  @override
  String get appTitle => 'সংজ্ঞানাত্মক যত্ন খেলসমূহ';

  @override
  String get gameSelectionTitle => 'এটা খেল বাছনি কৰক';

  @override
  String get gameSelectionSubtitle =>
      'আপোনাৰ সেশ্বন আৰম্ভ কৰিবলৈ এটা খেল বাছনি কৰক।';

  @override
  String get memoryMatchingTitle => 'স্মৃতি মিলোৱা খেল';

  @override
  String get memoryMatchingDescription =>
      'কাৰ্ডবোৰ উলটাই জোৰা বিচারক। ই স্মৃতি আৰু মনোযোগ বৃদ্ধি কৰে।';

  @override
  String get patternRecognitionTitle => 'প্ৰতিৰূপ চিনাক্তকৰণ';

  @override
  String get patternRecognitionDescription =>
      'প্ৰতিৰূপ চাওক আৰু পিছত কি আহিব বাছনি কৰক। ই যুক্তি চিন্তা বৃদ্ধি কৰে।';

  @override
  String get howToPlayHeading => 'কেনেকৈ খেলিব';

  @override
  String get memoryMatchingHowToPlay =>
      'মিল থকা জোৰাবোৰ বিচাৰি পাবলৈ কাৰ্ডবোৰ উলটাওক। সোনকালে মিল কৰিবলৈ প্ৰত্যেকটো কাৰ্ড ক\'ত আছে মনত ৰাখক।';

  @override
  String get patternRecognitionHowToPlay =>
      'প্ৰতিৰূপ চাওক, তাৰ পিছত পিছত কি আহিব বাছনি কৰক।';

  @override
  String get selectDifficulty => 'কাঠিন্য বাছনি কৰক';

  @override
  String get difficultyEasy => 'সহজ';

  @override
  String get difficultyMedium => 'মধ্যম';

  @override
  String get difficultyHard => 'কঠিন';

  @override
  String get difficultyTimeEasy => '৩ মিনিট';

  @override
  String get difficultyTimeMedium => '২ মিনিট';

  @override
  String get difficultyTimeHard => '৯০ ছেকেণ্ড';

  @override
  String get labelGrid => 'গ্ৰীড';

  @override
  String get labelPairs => 'জোৰা';

  @override
  String get labelTime => 'সময়';

  @override
  String get labelRounds => 'ৰাউণ্ড';

  @override
  String get labelType => 'প্ৰকাৰ';

  @override
  String get labelRound => 'ৰাউণ্ড';

  @override
  String get startGame => 'খেল আৰম্ভ কৰক';

  @override
  String get quitGame => 'প্ৰস্থান';

  @override
  String get keepPlaying => 'খেলি থাকক';

  @override
  String get quitDialogTitle => 'খেলৰ পৰা ওলাই যাবনে?';

  @override
  String get quitDialogBody => 'আপোনাৰ অগ্ৰগতি অসম্পূৰ্ণ বুলি সংৰক্ষণ কৰা হ\'ব।';

  @override
  String get yourResults => 'আপোনাৰ ফলাফল';

  @override
  String get wellDone => 'অতি সুন্দৰ!';

  @override
  String get goodTry => 'ভাল চেষ্টা!';

  @override
  String get playAgain => 'পুনৰ খেলক';

  @override
  String get backToMenu => 'মেনুলৈ ঘূৰি যাওক';

  @override
  String get labelDuration => 'সময়সীমা';

  @override
  String get labelAccuracy => 'সঠিকতা';

  @override
  String get labelAttempts => 'চেষ্টা';

  @override
  String get labelErrors => 'ভুল';

  @override
  String get labelHintsUsed => 'ব্যৱহৃত সংকেত';

  @override
  String get labelCompletion => 'সম্পূৰ্ণতা';

  @override
  String get patternTypeNumbers => 'সংখ্যা';

  @override
  String get patternTypeColors => 'ৰং';

  @override
  String get patternTypeShapes => 'আকাৰ';

  @override
  String get patternInstructionNumeric => 'পিছত কি সংখ্যা আহিব?';

  @override
  String get patternInstructionColor => 'পিছত কি ৰং আহিব?';

  @override
  String get patternInstructionShape => 'পিছত কি আকাৰ আহিব?';

  @override
  String get selectPatternType => 'প্ৰতিৰূপ প্ৰকাৰ';

  @override
  String get errorGeneric => 'এটা ভুল হৈছে।';

  @override
  String get errorSaveFailed =>
      'খেলৰ ফলাফল সংৰক্ষণ কৰিব পৰা নগ\'ল। অনুগ্রহ কৰি পুনৰ চেষ্টা কৰক।';

  @override
  String get noTimeLimitSymbol => '∞';

  @override
  String timerSemanticLabel(String time) {
    return 'সময়: $time';
  }

  @override
  String attemptsSemanticLabel(int count) {
    return '$count টা চেষ্টা';
  }

  @override
  String errorsSemanticLabel(int count) {
    return '$count টা ভুল';
  }

  @override
  String hintsSemanticLabel(int count) {
    return '$count টা সংকেত ব্যৱহৃত';
  }

  @override
  String roundSemanticLabel(int current, int total) {
    return 'ৰাউণ্ড $current / $total';
  }

  @override
  String difficultySemanticLabel(String difficulty) {
    return '$difficulty কাঠিন্য';
  }
}
