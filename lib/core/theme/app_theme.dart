import 'package:flutter/material.dart';

/// Paleta del aparato: carcasa verde-carbon, display de fosforo verde.
class AppColors {
  const AppColors._();

  static const panelLight = Color(0xFF22251C);
  static const panel = Color(0xFF1A1C15);
  static const panelDark = Color(0xFF0C0E0A);
  static const edge = Color(0xFF2F3427);
  static const engrave = Color(0xFF7D8C61);

  static const ink = Color(0xFFD5E0C2);
  static const inkDim = Color(0xFF5E6850);
  static const inkFaint = Color(0xFF525C40);

  static const glass = Color(0xFF050703);
  static const glassEdge = Color(0xFF272C1E);

  static const green = Color(0xFFA3E635);
  static const greenLight = Color(0xFFD6F88A);
  static const greenDark = Color(0xFF5F9226);

  static const danger = Color(0xFFD0604F);

  /// Glow verde reutilizable.
  static const glow = Color.fromRGBO(163, 230, 53, 0.75);
}

class AppFonts {
  const AppFonts._();

  /// Fuente del display y de las tareas.
  static const mono = 'VT323';

  /// Fuente de las etiquetas "grabadas" en la carcasa.
  static const display = 'Archivo';
}

class AppTheme {
  const AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.panelDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.green,
      onPrimary: Color(0xFF16210A),
      surface: AppColors.panel,
      onSurface: AppColors.ink,
      error: AppColors.danger,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}