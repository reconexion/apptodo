import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_palette.dart';
import 'theme_controller.dart';

class AppFonts {
  const AppFonts._();

  /// Fuente del display y de las tareas.
  static const mono = 'VT323';

  /// Fuente de las etiquetas "grabadas" en la carcasa.
  static const display = 'Archivo';
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