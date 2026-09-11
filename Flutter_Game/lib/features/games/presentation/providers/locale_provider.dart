import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages active app [Locale] for internationalization.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void setLocale(Locale locale) {
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
