import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_palette.dart';
import 'app_theme.dart';

/// Guarda y expone el tema elegido. El tema Wii es el default.
class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs)
    : _palette = AppPalettes.byId(_prefs.getString(_key));

  // v2: al estrenar el estilo Wii, todos arrancan en el tema nuevo.
  static const _key = 'todoapp.theme.v2';

  final SharedPreferences _prefs;
  AppPalette _palette;

  AppPalette get palette => _palette;
  List<AppPalette> get available => AppPalettes.all;

  void select(AppPalette palette) {
    if (palette.id == _palette.id) return;
    _palette = palette;
    AppFonts.style = palette.style;
    _prefs.setString(_key, palette.id);
    notifyListeners();
  }
}
