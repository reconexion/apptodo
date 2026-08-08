import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Carcasa del aparato: degradado, grano de escaneo y tornillos en las esquinas.
class Chassis extends StatelessWidget {
  const Chassis({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.panelLight, AppColors.panel, AppColors.panelDark],
          stops: [0.0, 0.38, 1.0],
        ),
      ),
      child: CustomPaint(
        foregroundPainter: _ScanlinePainter(),
        child: Stack(
          children: [
            Positioned.fill(child: child),
            const _Screw(top: 14, left: 14),
            const _Screw(top: 14, right: 14),
            const _Screw(bottom: 14, left: 14),
            const _Screw(bottom: 14, right: 14),
          ],
        ),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final Paint _paint = Paint()..color = const Color.fromRGBO(0, 0, 0, 0.13);

  @override
  void paint(Canvas canvas, Size size) {
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Screw extends StatelessWidget {
  const _Screw({this.top, this.left, this.right, this.bottom});

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
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(-0.3, -0.4),
            colors: [Color(0xFF6A7159), Color(0xFF22261C)],
          ),
        ),
        child: Center(
          child: Transform.rotate(
            angle: 0.5,
            child: Container(
              width: 8,
              height: 1.5,
              color: const Color(0xFF0A0C08),
            ),
          ),
        ),
      ),
    );
  }
}