import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_palette.dart';

/// Guarda y expone el tema elegido.
class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs)
      : _palette = AppPalettes.byId(_prefs.getString(_key));

  static const _key = 'todoapp.theme';

  final SharedPreferences _prefs;
  AppPalette _palette;

  AppPalette get palette => _palette;
  List<AppPalette> get available => AppPalettes.all;

  void select(AppPalette palette) {
    if (palette.id == _palette.id) return;
    _palette = palette;
    _prefs.setString(_key, palette.id);
    notifyListeners();
  }
}