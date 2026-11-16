import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_strings.dart';

class LanguageController extends ChangeNotifier {
  LanguageController(this._prefs) : _locale = _fromPrefs(_prefs);

  static const _key = 'todoapp.locale';

  final SharedPreferences _prefs;
  AppLocale _locale;

  AppLocale get locale => _locale;

  static AppLocale _fromPrefs(SharedPreferences prefs) {
    final saved = prefs.getString(_key);
    return saved == 'en' ? AppLocale.en : AppLocale.es;
  }

  void select(AppLocale locale) {
    if (locale == _locale) return;
    _locale = locale;
    _prefs.setString(_key, locale == AppLocale.en ? 'en' : 'es');
    notifyListeners();
  }
}
