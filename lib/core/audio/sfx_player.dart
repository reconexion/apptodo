import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Efectos disponibles.
enum Sfx { add, done, undone, delete }

const int _kSampleRate = 44100;

/// Sintetiza los sonidos en tiempo de ejecucion (no hay archivos de audio).
/// Cada efecto se genera una sola vez y se guarda en cache como WAV en memoria.
class SfxPlayer {
  SfxPlayer();

  final AudioPlayer _player = AudioPlayer();
  final Map<Sfx, Uint8List> _cache = {};

  bool muted = false;

  Future<void> play(Sfx sfx) async {
    if (muted) return;
    try {
      final bytes = _cache.putIfAbsent(sfx, () => _build(sfx));
      await _player.stop();
      await _player.play(BytesSource(bytes));
    } catch (_) {
      // Si el audio no esta disponible, no pasa nada.
    }
  }

  Future<void> dispose() => _player.dispose();

  Uint8List _build(Sfx sfx) {
    switch (sfx) {
    // Agregar: click de tecla + bip que sube.
      case Sfx.add:
        final b = _Buffer(0.25);
        b.click(level: 0.45);
        b.tone(dur: 0.10, from: 660, to: 1320, level: 0.30, wave: _Wave.square);
        return b.toWav();

    // Completar: arpegio corto ascendente.
      case Sfx.done:
        final b = _Buffer(0.42);
        b.tone(dur: 0.08, from: 784, level: 0.28, wave: _Wave.triangle);
        b.tone(at: 0.07, dur: 0.10, from: 1047, level: 0.28, wave: _Wave.triangle);
        b.tone(at: 0.15, dur: 0.16, from: 1568, level: 0.22, wave: _Wave.triangle);
        return b.toWav();

    // Desmarcar: bip que baja.
      case Sfx.undone:
        final b = _Buffer(0.20);
        b.tone(dur: 0.13, from: 660, to: 330, level: 0.26, wave: _Wave.triangle);
        return b.toWav();

    // Borrar: golpe grave tipo apagon.
      case Sfx.delete:
        final b = _Buffer(0.32);
        b.click(level: 0.35, freq: 600);
        b.tone(dur: 0.24, from: 200, to: 55, level: 0.42, wave: _Wave.saw);
        return b.toWav();
    }
  }
}

enum _Wave { sine, square, triangle, saw }

/// Buffer de muestras en punto flotante + codificador WAV 16 bits mono.
class _Buffer {
  _Buffer(double seconds)
      : _data = List<double>.filled((seconds * _kSampleRate).round(), 0.0);

  final List<double> _data;

  /// Tono con ataque rapido y caida exponencial. Si [to] existe, barre la
  /// frecuencia de [from] a [to] durante [dur].
  void tone({
    double at = 0,
    required double dur,
    required double from,
    double? to,
    double level = 0.3,
    _Wave wave = _Wave.sine,
  }) {
    final start = (at * _kSampleRate).round();
    final total = (dur * _kSampleRate).round();
    final decay = log(1000) / dur;
    const attack = 0.008;
    var phase = 0.0;

    for (var i = 0; i < total; i++) {
      final index = start + i;
      if (index >= _data.length) break;

      final t = i / _kSampleRate;
      final freq = to == null ? from : from * pow(to / from, t / dur).toDouble();
      phase += 2 * pi * freq / _kSampleRate;

      final env = (t < attack ? t / attack : 1.0) * exp(-decay * t);
      _data[index] += _shape(wave, phase) * level * env;
    }
  }

  /// Click seco de relevador: ruido con caida muy rapida.
  void click({double at = 0, double level = 0.4, double freq = 1800}) {
    final start = (at * _kSampleRate).round();
    final total = (0.05 * _kSampleRate).round();
    final rnd = Random(7);

    for (var i = 0; i < total; i++) {
      final index = start + i;
      if (index >= _data.length) break;

      final env = pow(1 - i / total, 6).toDouble();
      final noise = rnd.nextDouble() * 2 - 1;
      final ring = sin(2 * pi * freq * (i / _kSampleRate));
      _data[index] += noise * ring * level * env;
    }
  }

  double _shape(_Wave wave, double phase) {
    switch (wave) {
      case _Wave.sine:
        return sin(phase);
      case _Wave.square:
        return sin(phase) >= 0 ? 1.0 : -1.0;
      case _Wave.triangle:
        return 2 / pi * asin(sin(phase));
      case _Wave.saw:
        return 2 * ((phase / (2 * pi)) % 1) - 1;
    }
  }

  Uint8List toWav() {
    final n = _data.length;
    final out = Uint8List(44 + n * 2);
    final view = ByteData.view(out.buffer);

    void ascii(int offset, String text) {
      for (var i = 0; i < text.length; i++) {
        view.setUint8(offset + i, text.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    view.setUint32(4, 36 + n * 2, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    view.setUint32(16, 16, Endian.little);
    view.setUint16(20, 1, Endian.little); // PCM
    view.setUint16(22, 1, Endian.little); // mono
    view.setUint32(24, _kSampleRate, Endian.little);
    view.setUint32(28, _kSampleRate * 2, Endian.little);
    view.setUint16(32, 2, Endian.little);
    view.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    view.setUint32(40, n * 2, Endian.little);

    for (var i = 0; i < n; i++) {
      final v = (_data[i].clamp(-1.0, 1.0) * 32767).round();
      view.setInt16(44 + i * 2, v, Endian.little);
    }
    return out;
  }
}