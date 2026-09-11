import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_as.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kha.dart';
import 'app_localizations_lus.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('as'),
    Locale('kha'),
    Locale('lus'),
  ];

  /// Main application title shown in AppBar
  ///
  /// In en, this message translates to:
  /// **'Cognitive Care Games'**
  String get appTitle;

  /// Home screen heading
  ///
  /// In en, this message translates to:
  /// **'Choose a Game'**
  String get gameSelectionTitle;

  /// No description provided for @gameSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a game to begin your session.'**
  String get gameSelectionSubtitle;

  /// Game name for Memory Matching
  ///
  /// In en, this message translates to:
  /// **'Memory Matching'**
  String get memoryMatchingTitle;

  /// No description provided for @memoryMatchingDescription.
  ///
  /// In en, this message translates to:
  /// **'Flip cards and find matching pairs. Trains recall and focus.'**
  String get memoryMatchingDescription;

  /// Game name for Pattern Recognition
  ///
  /// In en, this message translates to:
  /// **'Pattern Recognition'**
  String get patternRecognitionTitle;

  /// No description provided for @patternRecognitionDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch the pattern, choose what comes next. Trains logical thinking.'**
  String get patternRecognitionDescription;

  /// No description provided for @howToPlayHeading.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlayHeading;

  /// No description provided for @memoryMatchingHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'Flip cards to find matching pairs. Remember where each card is to make matches quickly.'**
  String get memoryMatchingHowToPlay;

  /// No description provided for @patternRecognitionHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'Watch the pattern, then choose what comes next.'**
  String get patternRecognitionHowToPlay;

  /// No description provided for @selectDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get selectDifficulty;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultyTimeEasy.
  ///
  /// In en, this message translates to:
  /// **'3 min'**
  String get difficultyTimeEasy;

  /// No description provided for @difficultyTimeMedium.
  ///
  /// In en, this message translates to:
  /// **'2 min'**
  String get difficultyTimeMedium;

  /// No description provided for @difficultyTimeHard.
  ///
  /// In en, this message translates to:
  /// **'90 sec'**
  String get difficultyTimeHard;

  /// No description provided for @labelGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get labelGrid;

  /// No description provided for @labelPairs.
  ///
  /// In en, this message translates to:
  /// **'Pairs'**
  String get labelPairs;

  /// No description provided for @labelTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get labelTime;

  /// No description provided for @labelRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get labelRounds;

  /// No description provided for @labelType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get labelType;

  /// No description provided for @labelRound.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get labelRound;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @quitGame.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quitGame;

  /// No description provided for @keepPlaying.
  ///
  /// In en, this message translates to:
  /// **'Keep Playing'**
  String get keepPlaying;

  /// No description provided for @quitDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit Game?'**
  String get quitDialogTitle;

  /// No description provided for @quitDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be saved as incomplete.'**
  String get quitDialogBody;

  /// No description provided for @yourResults.
  ///
  /// In en, this message translates to:
  /// **'Your Results'**
  String get yourResults;

  /// No description provided for @wellDone.
  ///
  /// In en, this message translates to:
  /// **'Well Done!'**
  String get wellDone;

  /// No description provided for @goodTry.
  ///
  /// In en, this message translates to:
  /// **'Good Try!'**
  String get goodTry;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get backToMenu;

  /// No description provided for @labelDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get labelDuration;

  /// No description provided for @labelAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get labelAccuracy;

  /// No description provided for @labelAttempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get labelAttempts;

  /// No description provided for @labelErrors.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get labelErrors;

  /// No description provided for @labelHintsUsed.
  ///
  /// In en, this message translates to:
  /// **'Hints Used'**
  String get labelHintsUsed;

  /// No description provided for @labelCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get labelCompletion;

  /// No description provided for @patternTypeNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get patternTypeNumbers;

  /// No description provided for @patternTypeColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get patternTypeColors;

  /// No description provided for @patternTypeShapes.
  ///
  /// In en, this message translates to:
  /// **'Shapes'**
  String get patternTypeShapes;

  /// No description provided for @patternInstructionNumeric.
  ///
  /// In en, this message translates to:
  /// **'What number comes next?'**
  String get patternInstructionNumeric;

  /// No description provided for @patternInstructionColor.
  ///
  /// In en, this message translates to:
  /// **'What color comes next?'**
  String get patternInstructionColor;

  /// No description provided for @patternInstructionShape.
  ///
  /// In en, this message translates to:
  /// **'What shape comes next?'**
  String get patternInstructionShape;

  /// No description provided for @selectPatternType.
  ///
  /// In en, this message translates to:
  /// **'Pattern Type'**
  String get selectPatternType;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorGeneric;

  /// No description provided for @errorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save game result. Please try again.'**
  String get errorSaveFailed;

  /// Displayed when no time limit is set
  ///
  /// In en, this message translates to:
  /// **'∞'**
  String get noTimeLimitSymbol;

  /// No description provided for @timerSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Timer: {time}'**
  String timerSemanticLabel(String time);

  /// No description provided for @attemptsSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} attempts'**
  String attemptsSemanticLabel(int count);

  /// No description provided for @errorsSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} errors'**
  String errorsSemanticLabel(int count);

  /// No description provided for @hintsSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} hints used'**
  String hintsSemanticLabel(int count);

  /// No description provided for @roundSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Round {current} of {total}'**
  String roundSemanticLabel(int current, int total);

  /// No description provided for @difficultySemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'{difficulty} difficulty'**
  String difficultySemanticLabel(String difficulty);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'as', 'kha', 'lus'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'as':
      return AppLocalizationsAs();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kha':
      return AppLocalizationsKha();
    case 'lus':
      return AppLocalizationsLus();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
