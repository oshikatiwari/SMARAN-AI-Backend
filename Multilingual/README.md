# SMARAN Multilingual & Localization Contribution

This folder documents the **Multilingual & Localization Contribution** developed for the SMARAN Cognitive Care Platform (SIH 2026).

## Overview

To ensure accessibility for elderly dementia patients across India, comprehensive multilingual support was integrated into the platform covering 5 major languages:

1. **English (`en`)**: Default fallback language.
2. **Hindi (`hi`)**: Northern region support (संज्ञानात्मक देखभाल खेल).
3. **Assamese (`as`)**: North-Eastern region support (সংজ্ঞানাত্মক যত্ন খেলসমূহ).
4. **Khasi (`kha`)**: Meghalaya regional support (Jingkyntu Jingkynmaw Games).
5. **Mizo (`lus`)**: Mizoram regional support (Hriatna Zirna Chhaih).

---

## Canonical Implementation Location

The canonical source-code implementation of the localization system resides inside the Flutter application at:

`Flutter_Game/lib/l10n/`

### File Mapping:
* **ARB Translation Source Files**:
  * `Flutter_Game/lib/l10n/app_en.arb`
  * `Flutter_Game/lib/l10n/app_hi.arb`
  * `Flutter_Game/lib/l10n/app_as.arb`
  * `Flutter_Game/lib/l10n/app_kha.arb`
  * `Flutter_Game/lib/l10n/app_lus.arb`
* **Typed Localization Classes**:
  * `Flutter_Game/lib/l10n/app_localizations.dart`
  * `Flutter_Game/lib/l10n/app_localizations_en.dart`
  * `Flutter_Game/lib/l10n/app_localizations_hi.dart`
  * `Flutter_Game/lib/l10n/app_localizations_as.dart`
  * `Flutter_Game/lib/l10n/app_localizations_kha.dart`
  * `Flutter_Game/lib/l10n/app_localizations_lus.dart`
* **State & UI Selector**:
  * `Flutter_Game/lib/features/games/presentation/providers/locale_provider.dart` (`localeProvider`)
  * `_ElderlyLanguageSelector` in `Flutter_Game/lib/main.dart`

---

## Key Features

* **Elderly-Friendly UI Selector**: Large touch targets ($\ge 48\text{px}$), high contrast labels, and native script names (`English`, `हिन्दी`, `অসমীয়া`, `খাসী`, `Mizo`).
* **Dynamic Locale Switching**: Changing the selected chip updates Riverpod's `localeProvider` and dynamically re-renders all app screens instantly.
* **Placeholder Integrity**: Preserves formatted parameters across languages (`{time}`, `{count}`, `{current}`, `{total}`, `{difficulty}`).
