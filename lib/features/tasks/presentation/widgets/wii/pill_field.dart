import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

/// Ranura en pastilla para campos de texto: blanca, ligeramente hundida
/// y con borde plateado. Al enfocarla se ilumina en azul.
class PillField extends StatefulWidget {
  const PillField({super.key, required this.child});

  final Widget child;

  @override
  State<PillField> createState() => _PillFieldState();
}

class _PillFieldState extends State<PillField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _focused ? c.accentLight : c.edge,
            width: _focused ? 2 : 1.4,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.fieldDeep, c.field, c.field],
            stops: const [0.0, 0.35, 1.0],
          ),
          boxShadow: [
            BoxShadow(color: c.sheen, offset: const Offset(0, 1.5)),
            if (_focused) BoxShadow(color: c.halo, blurRadius: 12),
          ],
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
