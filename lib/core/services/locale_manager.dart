import 'package:flutter/material.dart';

class LocaleManager {
  final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(const Locale('en'));

  Locale get locale => localeNotifier.value;

  void setLocale(Locale locale) {
    localeNotifier.value = locale;
  }

  void dispose() {
    localeNotifier.dispose();
  }

  static Locale localeFromString(String languageCode) {
    return Locale(languageCode);
  }
}
