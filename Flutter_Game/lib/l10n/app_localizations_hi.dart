// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'संज्ञानात्मक देखभाल खेल';

  @override
  String get gameSelectionTitle => 'एक खेल चुनें';

  @override
  String get gameSelectionSubtitle =>
      'अपना सत्र शुरू करने के लिए एक खेल चुनें।';

  @override
  String get memoryMatchingTitle => 'मेमोरी मैचिंग';

  @override
  String get memoryMatchingDescription =>
      'कार्ड पलटें और जोड़े खोजें। याददाश्त और ध्यान को प्रशिक्षित करता है।';

  @override
  String get patternRecognitionTitle => 'पैटर्न पहचान';

  @override
  String get patternRecognitionDescription =>
      'पैटर्न देखें, अगला क्या आता है चुनें। तार्किक सोच प्रशिक्षित करता है।';

  @override
  String get howToPlayHeading => 'कैसे खेलें';

  @override
  String get memoryMatchingHowToPlay =>
      'कार्ड पलटें और मिलान जोड़े खोजें। याद रखें कि प्रत्येक कार्ड कहाँ है।';

  @override
  String get patternRecognitionHowToPlay =>
      'पैटर्न देखें, फिर अगला क्या आता है चुनें।';

  @override
  String get selectDifficulty => 'कठिनाई चुनें';

  @override
  String get difficultyEasy => 'आसान';

  @override
  String get difficultyMedium => 'मध्यम';

  @override
  String get difficultyHard => 'कठिन';

  @override
  String get difficultyTimeEasy => '3 मिनट';

  @override
  String get difficultyTimeMedium => '2 मिनट';

  @override
  String get difficultyTimeHard => '90 सेकंड';

  @override
  String get labelGrid => 'ग्रिड';

  @override
  String get labelPairs => 'जोड़े';

  @override
  String get labelTime => 'समय';

  @override
  String get labelRounds => 'राउंड';

  @override
  String get labelType => 'प्रकार';

  @override
  String get labelRound => 'राउंड';

  @override
  String get startGame => 'खेल शुरू करें';

  @override
  String get quitGame => 'छोड़ें';

  @override
  String get keepPlaying => 'खेलते रहें';

  @override
  String get quitDialogTitle => 'खेल छोड़ें?';

  @override
  String get quitDialogBody => 'आपकी प्रगति अधूरी के रूप में सहेजी जाएगी।';

  @override
  String get yourResults => 'आपके परिणाम';

  @override
  String get wellDone => 'शाबाश!';

  @override
  String get goodTry => 'अच्छा प्रयास!';

  @override
  String get playAgain => 'फिर खेलें';

  @override
  String get backToMenu => 'मेनू पर वापस';

  @override
  String get labelDuration => 'अवधि';

  @override
  String get labelAccuracy => 'सटीकता';

  @override
  String get labelAttempts => 'प्रयास';

  @override
  String get labelErrors => 'गलतियाँ';

  @override
  String get labelHintsUsed => 'संकेत उपयोग';

  @override
  String get labelCompletion => 'पूर्णता';

  @override
  String get patternTypeNumbers => 'संख्याएँ';

  @override
  String get patternTypeColors => 'रंग';

  @override
  String get patternTypeShapes => 'आकार';

  @override
  String get patternInstructionNumeric => 'अगला नंबर क्या है?';

  @override
  String get patternInstructionColor => 'अगला रंग क्या है?';

  @override
  String get patternInstructionShape => 'अगला आकार क्या है?';

  @override
  String get selectPatternType => 'पैटर्न प्रकार';

  @override
  String get errorGeneric => 'एक त्रुटि हुई।';

  @override
  String get errorSaveFailed =>
      'गेम परिणाम सहेजना विफल रहा। कृपया पुनः प्रयास करें।';

  @override
  String get noTimeLimitSymbol => '∞';

  @override
  String timerSemanticLabel(String time) {
    return 'टाइमर: $time';
  }

  @override
  String attemptsSemanticLabel(int count) {
    return '$count प्रयास';
  }

  @override
  String errorsSemanticLabel(int count) {
    return '$count गलतियाँ';
  }

  @override
  String hintsSemanticLabel(int count) {
    return '$count संकेत उपयोग किए';
  }

  @override
  String roundSemanticLabel(int current, int total) {
    return 'राउंड $current में से $total';
  }

  @override
  String difficultySemanticLabel(String difficulty) {
    return '$difficulty कठिनाई';
  }
}
