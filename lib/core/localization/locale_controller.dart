import 'package:flutter/material.dart';

class LocaleController extends ValueNotifier<Locale> {
  LocaleController() : super(const Locale('en'));

  void setLocale(Locale locale) {
    if (locale.languageCode != 'en' && locale.languageCode != 'ms') {
      return;
    }

    value = locale;
  }

  void toggleLocale() {
    value = value.languageCode == 'en'
        ? const Locale('ms')
        : const Locale('en');
  }
}

final localeController = LocaleController();