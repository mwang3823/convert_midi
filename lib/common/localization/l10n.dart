import 'package:flutter/material.dart';

class LangKey {
  static const LocalizationsDelegate<LangKey> delegate = _Delegate();

  static const List<Locale> supportedLocales = [
    Locale('vi'),
    Locale('en'),
  ];

  static LangKey of(BuildContext context) =>
      Localizations.of<LangKey>(context, LangKey) ?? LangKey();
}

class _Delegate extends LocalizationsDelegate<LangKey> {
  const _Delegate();

  @override
  bool isSupported(Locale locale) =>
      ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<LangKey> load(Locale locale) async => LangKey();

  @override
  bool shouldReload(_Delegate old) => false;
}
