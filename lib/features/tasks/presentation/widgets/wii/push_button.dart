import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/gloss.dart';

/// Boton brillante en forma de pastilla, con icono opcional en azul.
/// Con [spinIcon] el icono da un giro con rebote en cada toque.
class PushButton extends StatefulWidget {
  const PushButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.spinIcon = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool spinIcon;

  @override
  State<PushButton> createState() => _PushButtonState();
}

class _PushButtonState extends State<PushButton> {
  double _turns = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Pressable(
      onTap: () {
        if (widget.spinIcon) setState(() => _turns += 0.25);
        widget.onPressed();
      },
      child: Gloss(
        radius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Center(
          widthFactor: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                AnimatedRotation(
                  turns: _turns,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  child: Icon(widget.icon, size: 26, color: c.accent),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: c.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
