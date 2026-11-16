import 'package:flutter/material.dart';

/// Retro: carcasa con tornillos y LCD. Wii: menu de consola brillante.
enum UiStyle { retro, wii }

/// Todos los colores del aparato. Cambiar de tema es cambiar de paleta.
class AppPalette {
  const AppPalette({
    this.style = UiStyle.retro,
    this.mascot = const Color(0xFF8CCF4D),
    this.stripes = const Color(0x00000000),
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
    required this.wave,
    required this.waveSoft,
    required this.sheen,
    required this.shadow,
  });

  final UiStyle style;

  /// Estrellita de adorno del contador (solo estilo Wii).
  final Color mascot;

  /// Rayas horizontales finas del fondo (solo estilo Wii).
  final Color stripes;

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

  /// Ondas decorativas del fondo.
  final Color wave;
  final Color waveSoft;

  /// Brillo blanco de la mitad superior de botones y tarjetas.
  final Color sheen;

  /// Sombra suave bajo las piezas.
  final Color shadow;
}

class AppPalettes {
  const AppPalettes._();

  /// Igual que Wii pero con ondas verdes de fondo.
  /// Menu de consola: gris claro con blanco, plata brillante y acento
  /// azul cielo. Tema por defecto.
  static const wii = AppPalette(
    style: UiStyle.wii,
    mascot: Color(0xFF8DD5FF),
    stripes: Color.fromRGBO(255, 255, 255, 0.55),
    id: 'wii',
    label: 'WII',
    brightness: Brightness.light,
    panelLight: Color(0xFFF7F8F9),
    panel: Color(0xFFE6E9EC),
    panelDark: Color(0xFFCDD2D7),
    edge: Color(0xFFC6CCD0),
    engrave: Color(0xFF5C646C),
    ink: Color(0xFF383D43),
    inkDim: Color(0xFF666E76),
    inkFaint: Color(0xFF9CA3AA),
    field: Color(0xFFFFFFFF),
    fieldDeep: Color(0xFFEFF1F2),
    glassTop: Color(0xFFFCFCFD),
    glass: Color(0xFFE3E6E9),
    glassEdge: Color(0xFFC3C9CE),
    displayInk: Color(0xFF383D43),
    displayInkSoft: Color(0xFF5A626A),
    displayTick: Color(0xFF5A626A),
    glow: Color.fromRGBO(52, 168, 239, 0.45),
    halo: Color.fromRGBO(52, 168, 239, 0.35),
    meterTrack: Color(0xFFC4C9CE),
    meterTrackEdge: Color(0xFFADB3B9),
    accent: Color(0xFF2FA3EC),
    accentLight: Color(0xFF8DD5FF),
    accentDark: Color(0xFF1677BF),
    onAccent: Color(0xFFFFFFFF),
    tileTop: Color(0xFFFDFDFE),
    tileBottom: Color(0xFFE1E4E7),
    tileDoneTop: Color(0xFFF1F3F4),
    tileDoneBottom: Color(0xFFDADEE1),
    ledOffTop: Color(0xFFF4F5F6),
    ledOffBottom: Color(0xFFC3C8CD),
    ledOffBorder: Color(0xFFB3B9BF),
    chipActive: Color(0xFFDDF2FF),
    chipIdle: Color(0xFFF2F3F4),
    scanline: Color(0x00000000),
    danger: Color(0xFFE0533D),
    screwLight: Color(0xFFF4F5F6),
    screwDark: Color(0xFFC3C8CD),
    screwSlot: Color(0xFF9CA3AA),
    wave: Color(0xFFFFFFFF),
    waveSoft: Color(0xFFD9DDE1),
    sheen: Color.fromRGBO(255, 255, 255, 0.85),
    shadow: Color.fromRGBO(40, 55, 60, 0.20),
  );

  static const wiiGreen = AppPalette(
    style: UiStyle.wii,
    stripes: Color.fromRGBO(255, 255, 255, 0.35),
    id: 'wii_green',
    label: 'WII VERDE',
    brightness: Brightness.light,
    panelLight: Color(0xFFFBFCFC),
    panel: Color(0xFFF1F4F3),
    panelDark: Color(0xFFE3E8E6),
    edge: Color(0xFFC6CCD0),
    engrave: Color(0xFF5C646C),
    ink: Color(0xFF383D43),
    inkDim: Color(0xFF666E76),
    inkFaint: Color(0xFF9CA3AA),
    field: Color(0xFFFFFFFF),
    fieldDeep: Color(0xFFEFF1F2),
    glassTop: Color(0xFFFCFCFD),
    glass: Color(0xFFE3E6E9),
    glassEdge: Color(0xFFC3C9CE),
    displayInk: Color(0xFF383D43),
    displayInkSoft: Color(0xFF5A626A),
    displayTick: Color(0xFF5A626A),
    glow: Color.fromRGBO(52, 168, 239, 0.45),
    halo: Color.fromRGBO(52, 168, 239, 0.35),
    meterTrack: Color(0xFFC4C9CE),
    meterTrackEdge: Color(0xFFADB3B9),
    accent: Color(0xFF2FA3EC),
    accentLight: Color(0xFF8DD5FF),
    accentDark: Color(0xFF1677BF),
    onAccent: Color(0xFFFFFFFF),
    tileTop: Color(0xFFFDFDFE),
    tileBottom: Color(0xFFE1E4E7),
    tileDoneTop: Color(0xFFF1F3F4),
    tileDoneBottom: Color(0xFFDADEE1),
    ledOffTop: Color(0xFFF4F5F6),
    ledOffBottom: Color(0xFFC3C8CD),
    ledOffBorder: Color(0xFFB3B9BF),
    chipActive: Color(0xFFDDF2FF),
    chipIdle: Color(0xFFF2F3F4),
    scanline: Color(0x00000000),
    danger: Color(0xFFE0533D),
    screwLight: Color(0xFFF4F5F6),
    screwDark: Color(0xFFC3C8CD),
    screwSlot: Color(0xFF9CA3AA),
    wave: Color(0xFF8CCF4D),
    waveSoft: Color(0xFFCBEBA6),
    sheen: Color.fromRGBO(255, 255, 255, 0.85),
    shadow: Color.fromRGBO(40, 55, 60, 0.20),
  );

  /// Verde sobre crema, tipo consola de 8 bits. Tema por defecto.
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
    wave: Color(0xFF7FB335),
    waveSoft: Color(0xFFC9DB9A),
    sheen: Color.fromRGBO(255, 255, 255, 0.7),
    shadow: Color.fromRGBO(60, 70, 30, 0.18),
  );

  /// Azul sobre crema, misma familia que NES pero en frio.
  static const nesBlue = AppPalette(
    id: 'nes_blue',
    label: 'NES AZUL',
    brightness: Brightness.light,
    panelLight: Color(0xFFEEF2F6),
    panel: Color(0xFFDCE4EC),
    panelDark: Color(0xFFC5D0DC),
    edge: Color(0xFF9DAEBE),
    engrave: Color(0xFF52708C),
    ink: Color(0xFF17263A),
    inkDim: Color(0xFF556C82),
    inkFaint: Color(0xFF7C90A3),
    field: Color(0xFFF7FAFC),
    fieldDeep: Color(0xFFECF1F5),
    glassTop: Color(0xFF3E7FB8),
    glass: Color(0xFF2E6699),
    glassEdge: Color(0xFF204C77),
    displayInk: Color(0xFF0D2338),
    displayInkSoft: Color(0xFF1B3B57),
    displayTick: Color(0xFF2A567B),
    glow: Color.fromRGBO(13, 35, 56, 0.22),
    halo: Color.fromRGBO(255, 255, 255, 0.22),
    meterTrack: Color(0xFF285F8C),
    meterTrackEdge: Color(0xFF1D496D),
    accent: Color(0xFF2C6FA3),
    accentLight: Color(0xFF4E92C6),
    accentDark: Color(0xFF1B486B),
    onAccent: Color(0xFFEEF2F6),
    tileTop: Color(0xFFF7FAFC),
    tileBottom: Color(0xFFE7EDF3),
    tileDoneTop: Color(0xFFE1E8EF),
    tileDoneBottom: Color(0xFFD3DCE4),
    ledOffTop: Color(0xFFCBD6E0),
    ledOffBottom: Color(0xFFAEBECD),
    ledOffBorder: Color(0xFF95A7B9),
    chipActive: Color(0xFFCEE0EF),
    chipIdle: Color(0xFFE7EDF3),
    scanline: Color.fromRGBO(70, 90, 110, 0.10),
    danger: Color(0xFFB5432F),
    screwLight: Color(0xFFE3E9EF),
    screwDark: Color(0xFF95A7B9),
    screwSlot: Color(0xFF6C7F92),
    wave: Color(0xFF4E92C6),
    waveSoft: Color(0xFFB5D0E6),
    sheen: Color.fromRGBO(255, 255, 255, 0.7),
    shadow: Color.fromRGBO(20, 40, 60, 0.18),
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
    wave: Color(0xFFB85F0E),
    waveSoft: Color(0xFF3A2A18),
    sheen: Color.fromRGBO(255, 255, 255, 0.06),
    shadow: Color.fromRGBO(0, 0, 0, 0.5),
  );

  /// Carcasa azul noche, saturada y profunda; pantalla y controles en
  /// naranja pleno que resalta contra el fondo oscuro.
  static const blueAmber = AppPalette(
    id: 'blue_amber',
    label: 'AZUL ÁMBAR',
    brightness: Brightness.dark,
    panelLight: Color(0xFF1B3B6B),
    panel: Color(0xFF122A52),
    panelDark: Color(0xFF091A38),
    edge: Color(0xFF2C5C9E),
    engrave: Color(0xFF4E93E0),
    ink: Color(0xFFE8F1FF),
    inkDim: Color(0xFF7FA8DE),
    inkFaint: Color(0xFF4E729E),
    field: Color(0xFF0E2444),
    fieldDeep: Color(0xFF081833),
    glassTop: Color(0xFFFFC169),
    glass: Color(0xFFFF9A1F),
    glassEdge: Color(0xFFE67E00),
    displayInk: Color(0xFF4A2600),
    displayInkSoft: Color(0xFF6B3D00),
    displayTick: Color(0xFF8A5013),
    glow: Color.fromRGBO(74, 38, 0, 0.25),
    halo: Color.fromRGBO(255, 255, 255, 0.35),
    meterTrack: Color(0xFFE0821A),
    meterTrackEdge: Color(0xFFB8650A),
    accent: Color(0xFFFF9A1F),
    accentLight: Color(0xFFFFC266),
    accentDark: Color(0xFFCC7300),
    onAccent: Color(0xFF3D2000),
    tileTop: Color(0xFF17325C),
    tileBottom: Color(0xFF102748),
    tileDoneTop: Color(0xFF122A50),
    tileDoneBottom: Color(0xFF0C1F3C),
    ledOffTop: Color(0xFF2C4E80),
    ledOffBottom: Color(0xFF162E54),
    ledOffBorder: Color(0xFF3563A0),
    chipActive: Color(0xFF3D2A10),
    chipIdle: Color(0xFF122A50),
    scanline: Color.fromRGBO(10, 30, 60, 0.20),
    danger: Color(0xFFE5533D),
    screwLight: Color(0xFF3A6398),
    screwDark: Color(0xFF0F2444),
    screwSlot: Color(0xFF061428),
    wave: Color(0xFF2C5C9E),
    waveSoft: Color(0xFF1B3B6B),
    sheen: Color.fromRGBO(255, 255, 255, 0.08),
    shadow: Color.fromRGBO(0, 8, 24, 0.5),
  );

  /// El primero es el tema por defecto.
  static const all = <AppPalette>[
    wii,
    wiiGreen,
    nesBlue,
    nes,
    amber,
    blueAmber,
  ];

  static AppPalette byId(String? id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return wii;
  }
}
