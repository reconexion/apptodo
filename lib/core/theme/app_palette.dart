import 'package:flutter/material.dart';

/// Todos los colores del aparato. Cambiar de tema es cambiar de paleta.
class AppPalette {
  const AppPalette({
    required this.id,
    required this.label,
    required this.brightness,
    required this.panelLight,
    required this.panel,
    required this.panelDark,
    required this.edge,
    required this.engrave,
    required this.ink,
    required this.inkDim,
    required this.inkFaint,
    required this.field,
    required this.fieldDeep,
    required this.glassTop,
    required this.glass,
    required this.glassEdge,
    required this.displayInk,
    required this.displayInkSoft,
    required this.displayTick,
    required this.glow,
    required this.halo,
    required this.meterTrack,
    required this.meterTrackEdge,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.onAccent,
    required this.tileTop,
    required this.tileBottom,
    required this.tileDoneTop,
    required this.tileDoneBottom,
    required this.ledOffTop,
    required this.ledOffBottom,
    required this.ledOffBorder,
    required this.chipActive,
    required this.chipIdle,
    required this.scanline,
    required this.danger,
    required this.screwLight,
    required this.screwDark,
    required this.screwSlot,
  });

  final String id;
  final String label;
  final Brightness brightness;

  /// Carcasa.
  final Color panelLight;
  final Color panel;
  final Color panelDark;
  final Color edge;
  final Color engrave;

  /// Texto.
  final Color ink;
  final Color inkDim;
  final Color inkFaint;

  /// Campos de captura.
  final Color field;
  final Color fieldDeep;

  /// Display.
  final Color glassTop;
  final Color glass;
  final Color glassEdge;
  final Color displayInk;
  final Color displayInkSoft;
  final Color displayTick;
  final Color glow;
  final Color halo;
  final Color meterTrack;
  final Color meterTrackEdge;

  /// Acento (botones, LEDs, medidor).
  final Color accent;
  final Color accentLight;
  final Color accentDark;
  final Color onAccent;

  /// Tarjetas de tarea.
  final Color tileTop;
  final Color tileBottom;
  final Color tileDoneTop;
  final Color tileDoneBottom;
  final Color ledOffTop;
  final Color ledOffBottom;
  final Color ledOffBorder;

  /// Pestanas.
  final Color chipActive;
  final Color chipIdle;

  final Color scanline;
  final Color danger;

  final Color screwLight;
  final Color screwDark;
  final Color screwSlot;
}

class AppPalettes {
  const AppPalettes._();

  /// Verde sobre crema, tipo consola de 8 bits.
  static const nes = AppPalette(
    id: 'nes',
    label: 'NES',
    brightness: Brightness.light,
    panelLight: Color(0xFFF4F1E1),
    panel: Color(0xFFE7E3CE),
    panelDark: Color(0xFFD2CDB2),
    edge: Color(0xFFB3AD8C),
    engrave: Color(0xFF6F7A50),
    ink: Color(0xFF26301A),
    inkDim: Color(0xFF6C7657),
    inkFaint: Color(0xFF8D9576),
    field: Color(0xFFFBF8EA),
    fieldDeep: Color(0xFFF1EDDA),
    glassTop: Color(0xFFA8C34A),
    glass: Color(0xFF93B23A),
    glassEdge: Color(0xFF6E8A2A),
    displayInk: Color(0xFF1B3110),
    displayInkSoft: Color(0xFF2E4A1C),
    displayTick: Color(0xFF43602A),
    glow: Color.fromRGBO(27, 49, 16, 0.22),
    halo: Color.fromRGBO(255, 255, 255, 0.20),
    meterTrack: Color(0xFF7C9C2E),
    meterTrackEdge: Color(0xFF5E7A22),
    accent: Color(0xFF5C8C24),
    accentLight: Color(0xFF7FB335),
    accentDark: Color(0xFF3F6417),
    onAccent: Color(0xFFF4F1E1),
    tileTop: Color(0xFFFBF8EA),
    tileBottom: Color(0xFFEDE9D5),
    tileDoneTop: Color(0xFFE6E2CD),
    tileDoneBottom: Color(0xFFDBD6BF),
    ledOffTop: Color(0xFFD8D3B8),
    ledOffBottom: Color(0xFFBEB89B),
    ledOffBorder: Color(0xFFA9A385),
    chipActive: Color(0xFFDDE8C0),
    chipIdle: Color(0xFFEDE9D5),
    scanline: Color.fromRGBO(120, 116, 90, 0.10),
    danger: Color(0xFFB5432F),
    screwLight: Color(0xFFE9E5D2),
    screwDark: Color(0xFFA9A385),
    screwSlot: Color(0xFF7C7660),
  );

  /// Ambar sobre negro, tipo consola futurista.
  static const amber = AppPalette(
    id: 'amber',
    label: 'ÁMBAR',
    brightness: Brightness.dark,
    panelLight: Color(0xFF2B2B2E),
    panel: Color(0xFF1F1F22),
    panelDark: Color(0xFF101012),
    edge: Color(0xFF38383D),
    engrave: Color(0xFF8E8E98),
    ink: Color(0xFFEDE8E0),
    inkDim: Color(0xFF7C7C85),
    inkFaint: Color(0xFF5F5F68),
    field: Color(0xFF16161A),
    fieldDeep: Color(0xFF0E0E11),
    glassTop: Color(0xFF17100A),
    glass: Color(0xFF0B0806),
    glassEdge: Color(0xFF3A2A18),
    displayInk: Color(0xFFFF9224),
    displayInkSoft: Color(0xFFFFC062),
    displayTick: Color(0xFFA9631C),
    glow: Color.fromRGBO(255, 146, 36, 0.75),
    halo: Color.fromRGBO(255, 146, 36, 0.18),
    meterTrack: Color(0xFF0A0705),
    meterTrackEdge: Color(0xFF33240F),
    accent: Color(0xFFFF9224),
    accentLight: Color(0xFFFFC062),
    accentDark: Color(0xFFB85F0E),
    onAccent: Color(0xFF1A0E03),
    tileTop: Color(0xFF232329),
    tileBottom: Color(0xFF191920),
    tileDoneTop: Color(0xFF1C1C21),
    tileDoneBottom: Color(0xFF141418),
    ledOffTop: Color(0xFF3A3A42),
    ledOffBottom: Color(0xFF1D1D22),
    ledOffBorder: Color(0xFF414149),
    chipActive: Color(0xFF2A2119),
    chipIdle: Color(0xFF17171B),
    scanline: Color.fromRGBO(0, 0, 0, 0.16),
    danger: Color(0xFFE5533D),
    screwLight: Color(0xFF6A6A73),
    screwDark: Color(0xFF232329),
    screwSlot: Color(0xFF0C0C0E),
  );

  static const all = <AppPalette>[amber, nes];

  static AppPalette byId(String? id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return amber;
  }
}