import 'package:flutter/material.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/theme/app_theme.dart';

/// Franja superior: marca grabada, controles y lampara de encendido.
class PanelPlate extends StatelessWidget {
  const PanelPlate({
    super.key,
    required this.muted,
    required this.onToggleSound,
    required this.onOpenSettings,
  });

  final bool muted;
  final VoidCallback onToggleSound;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          t.t('brand').toUpperCase(),
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 4.4,
            color: c.engrave,
          ),
        ),
        Row(
          children: [
            _PlateButton(
              onTap: onToggleSound,
              child: Text(
                muted ? t.t('sound_off') : t.t('sound_on'),
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                  color: muted ? c.inkFaint : c.engrave,
                ),
              ),
            ),
            const SizedBox(width: 6),
            _PlateButton(
              onTap: onOpenSettings,
              child: Icon(Icons.settings, size: 14, color: c.engrave),
            ),
            const SizedBox(width: 10),
            const _PowerLamp(),
          ],
        ),
      ],
    );
  }
}

class _PlateButton extends StatelessWidget {
  const _PlateButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 26,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          border: Border.all(color: c.edge),
          borderRadius: BorderRadius.circular(6),
        ),
        child: child,
      ),
    );
  }
}

class _PowerLamp extends StatefulWidget {
  const _PowerLamp();

  @override
  State<_PowerLamp> createState() => _PowerLampState();
}

class _PowerLampState extends State<_PowerLamp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.accent,
          boxShadow: [BoxShadow(color: c.glow, blurRadius: 9)],
        ),
      ),
    );
  }
}
