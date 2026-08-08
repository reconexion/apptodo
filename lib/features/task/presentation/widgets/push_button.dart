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
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF5F8A1C)),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.greenLight,
              AppColors.green,
              Color(0xFF7FBB27),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF45690F),
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        child: Text(
          widget.label,
          style: const TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: Color(0xFF16210A),
          ),
        ),
      ),
    );
  }
}