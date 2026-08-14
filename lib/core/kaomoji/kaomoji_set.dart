import 'dart:math';

/// Kaomojis para el display. Se elige uno al azar cada vez que la app
/// arranca y se queda fijo durante toda la sesion (no cambia con cada
/// build, solo al reabrir).
class KaomojiSet {
  const KaomojiSet._();

  static const List<String> _all = [
    '( ͡° ͜ʖ ͡°)',
    'ʕ•ᴥ•ʔ',
    '¯\\_(ツ)_/¯',
    '(•_•)',
    '(ノ◕ヮ◕)ノ',
    '(=^･ω･^=)',
    '(⌐■_■)',
    '(っ˘ω˘ς)',
    '(ᵔᴥᵔ)',
    '(≧◡≦)',
    'ヽ(・∀・)ﾉ',
    '(๑•̀ㅂ•́)و',
    '(」°ロ°)」',
    '( ˘ ³˘)♥',
    '(◕‿◕)',
    '☆*:.｡.o(≧▽≦)o.｡.:*☆',
    '(¬‿¬)',
    '(づ｡◕‿‿◕｡)づ',
    '(ㆆ_ㆆ)',
    'ᕙ(⇀‸↼‶)ᕗ',
  ];

  static String random({int? seed}) {
    final rnd = seed != null ? Random(seed) : Random();
    return _all[rnd.nextInt(_all.length)];
  }
}