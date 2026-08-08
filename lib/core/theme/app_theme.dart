import 'package:flutter/material.dart';

/// Paleta del aparato: carcasa verde-carbon, display de fosforo verde.
class AppColors {
  const AppColors._();

  static const panelLight = Color(0xFF2B2F24);
  static const panel = Color(0xFF23261D);
  static const panelDark = Color(0xFF121410);
  static const edge = Color(0xFF3A3F2F);
  static const engrave = Color(0xFF8FA070);

  static const ink = Color(0xFFDDE7CB);
  static const inkDim = Color(0xFF6A7458);
  static const inkFaint = Color(0xFF5F6A4A);

  static const glass = Color(0xFF070A05);
  static const glassEdge = Color(0xFF313726);

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