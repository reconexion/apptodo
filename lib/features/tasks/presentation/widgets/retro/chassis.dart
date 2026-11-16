import 'package:flutter/material.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_theme.dart';

/// Carcasa del aparato: degradado, grano de escaneo y tornillos.
class Chassis extends StatelessWidget {
  const Chassis({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.panelLight, c.panel, c.panelDark],
          stops: const [0.0, 0.38, 1.0],
        ),
      ),
      child: CustomPaint(
        foregroundPainter: _ScanlinePainter(c.scanline),
        child: Stack(
          children: [
            Positioned.fill(child: child),
            _Screw(palette: c, top: 14, left: 14),
            _Screw(palette: c, top: 14, right: 14),
            _Screw(palette: c, bottom: 14, left: 14),
            _Screw(palette: c, bottom: 14, right: 14),
          ],
        ),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  _ScanlinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _Screw extends StatelessWidget {
  const _Screw({
    required this.palette,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  final AppPalette palette;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [palette.screwLight, palette.screwDark],
          ),
        ),
        child: Center(
          child: Transform.rotate(
            angle: 0.5,
            child: Container(width: 8, height: 1.5, color: palette.screwSlot),
          ),
        ),
      ),
    );
  }
}
