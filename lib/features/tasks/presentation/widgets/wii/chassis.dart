import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/gloss.dart';

/// Fondo estilo menu de consola: degradado claro, rayas horizontales
/// finas y ondas que se mecen lentamente.
class Chassis extends StatefulWidget {
  const Chassis({super.key, required this.child});

  final Widget child;

  @override
  State<Chassis> createState() => _ChassisState();
}

class _ChassisState extends State<Chassis> with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (motionOff(context)) {
      _wave.stop();
    } else if (!_wave.isAnimating) {
      _wave.repeat();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.panelLight, c.panel, c.panelDark],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: CustomPaint(painter: _WavesPainter(c, _wave), child: widget.child),
    );
  }
}

class _WavesPainter extends CustomPainter {
  _WavesPainter(this.c, this.anim) : super(repaint: anim);

  final AppPalette c;
  final Animation<double> anim;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = anim.value * 2 * math.pi;
    double s(double phase, double amp) => math.sin(t + phase) * amp;

    // Rayas finas horizontales, como el menu de la consola.
    if (c.stripes.a > 0) {
      final stripe = Paint()..color = c.stripes;
      for (var y = 0.0; y < h; y += 4) {
        canvas.drawRect(Rect.fromLTWH(0, y, w, 1.5), stripe);
      }
    }

    // Onda grande arriba a la derecha.
    _band(
      canvas,
      Path()
        ..moveTo(w * 0.25, 0)
        ..cubicTo(
          w * 0.55,
          h * (0.06 + s(0, 0.015)),
          w * 0.8,
          h * (0.02 + s(1, 0.015)),
          w,
          h * (0.10 + s(2, 0.012)),
        )
        ..lineTo(w, 0)
        ..close(),
      c.waveSoft,
      1.0,
    );
    _band(
      canvas,
      Path()
        ..moveTo(w * 0.45, 0)
        ..cubicTo(
          w * 0.7,
          h * (0.05 + s(1.5, 0.012)),
          w * 0.85,
          h * 0.0,
          w,
          h * (0.04 + s(2.5, 0.01)),
        )
        ..lineTo(w, 0)
        ..close(),
      c.wave,
      0.8,
    );

    // Cintas que cruzan a media altura.
    _ribbon(
      canvas,
      size,
      h * (0.40 + s(0.7, 0.012)),
      h * 0.09,
      t,
      c.waveSoft,
      0.95,
    );
    _ribbon(
      canvas,
      size,
      h * (0.47 + s(2.1, 0.01)),
      h * 0.03,
      t + 1,
      c.wave,
      0.7,
    );

    // Ondas de abajo.
    _band(
      canvas,
      Path()
        ..moveTo(0, h * (0.86 + s(0.3, 0.012)))
        ..cubicTo(
          w * 0.35,
          h * (0.80 + s(1.3, 0.02)),
          w * 0.65,
          h * (0.93 + s(2.3, 0.02)),
          w,
          h * (0.78 + s(3.3, 0.015)),
        )
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      c.waveSoft,
      1.0,
    );
    _band(
      canvas,
      Path()
        ..moveTo(w * 0.5, h)
        ..cubicTo(
          w * 0.7,
          h * (0.93 + s(0.9, 0.015)),
          w * 0.85,
          h * (0.90 + s(1.9, 0.015)),
          w,
          h * (0.84 + s(2.9, 0.012)),
        )
        ..lineTo(w, h)
        ..close(),
      c.wave,
      0.75,
    );
  }

  void _ribbon(
    Canvas canvas,
    Size size,
    double y,
    double thick,
    double t,
    Color color,
    double opacity,
  ) {
    final w = size.width;
    final wob = math.sin(t) * thick * 0.6;
    final path = Path()
      ..moveTo(0, y + thick)
      ..cubicTo(
        w * 0.3,
        y - thick + wob,
        w * 0.6,
        y + thick * 1.6 - wob,
        w,
        y - thick * 0.5,
      )
      ..lineTo(w, y + thick * 0.4)
      ..cubicTo(
        w * 0.6,
        y + thick * 2.4 - wob,
        w * 0.3,
        y + wob,
        0,
        y + thick * 1.9,
      )
      ..close();
    _band(canvas, path, color, opacity);
  }

  void _band(Canvas canvas, Path path, Color color, double opacity) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.6),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(path.getBounds());
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavesPainter old) => old.c != c;
}
