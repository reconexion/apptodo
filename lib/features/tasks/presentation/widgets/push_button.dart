import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Boton fisico: se hunde 3 px y pierde su sombra inferior al presionar.
class PushButton extends StatefulWidget {
  const PushButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<PushButton> createState() => _PushButtonState();
}

class _PushButtonState extends State<PushButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.accentDark),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.accentLight, c.accent, c.accentDark],
            stops: const [0.0, 0.45, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: c.accentDark,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: c.onAccent,
          ),
        ),
      ),
    );
  }
}