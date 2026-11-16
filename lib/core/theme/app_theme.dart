import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_palette.dart';
import 'theme_controller.dart';

/// Las fuentes dependen del estilo del tema activo. ThemeController
/// actualiza [style] al cambiar de tema.
class AppFonts {
  const AppFonts._();

  static UiStyle style = UiStyle.wii;

  static bool get _wii => style == UiStyle.wii;

  /// Retro: pixelada (VT323). Wii: redondeada (Nunito).
  static String get mono => _wii ? 'Nunito' : 'VT323';

  /// Retro: etiquetas grabadas (Archivo). Wii: la misma redondeada.
  static String get display => _wii ? 'Nunito' : 'Archivo';

  /// VT323 se ve mas chica que Nunito al mismo tamano; esto las empareja
  /// en las pantallas que comparten ambos estilos (configuracion, etc.).
  static double ms(double size) => _wii ? size * 0.78 : size;

  static FontWeight get monoWeight => _wii ? FontWeight.w600 : FontWeight.w400;

  /// Etiquetas diminutas: un poco mas grandes y menos espaciadas en Wii.
  static double ds(double size) => _wii && size < 11 ? size + 2 : size;
  static double track(double spacing) => _wii ? spacing * 0.45 : spacing;
}

/// Atajo: `context.palette` en cualquier widget bajo el provider.
extension PaletteContext on BuildContext {
  AppPalette get palette => watch<ThemeController>().palette;
}

class AppTheme {
  const AppTheme._();

  static ThemeData from(AppPalette p) {
    final base = p.brightness == Brightness.dark
        ? const ColorScheme.dark()
        : const ColorScheme.light();

    return ThemeData(
      useMaterial3: true,
      fontFamily: p.style == UiStyle.wii ? 'Nunito' : 'VT323',
      brightness: p.brightness,
      scaffoldBackgroundColor: p.panelDark,
      colorScheme: base.copyWith(
        primary: p.accent,
        onPrimary: p.onAccent,
        surface: p.panel,
        onSurface: p.ink,
        error: p.danger,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionHandleColor: p.accent,
        selectionColor: p.accentDark,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
