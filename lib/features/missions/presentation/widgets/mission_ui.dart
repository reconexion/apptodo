import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/gloss.dart';

/// Piezas visuales de misiones que se adaptan al estilo del tema:
/// brillantes en Wii, planas con borde en retro.

bool isWii(BuildContext context) => context.palette.style == UiStyle.wii;

/// Etiqueta pequena en mayusculas (encabezados de seccion).
TextStyle missionLabel(AppPalette c) => TextStyle(
  fontFamily: AppFonts.display,
  fontSize: AppFonts.ds(9),
  fontWeight: FontWeight.w800,
  letterSpacing: AppFonts.track(3.2),
  color: c.engrave,
);

/// Texto principal (titulos de mision, tareas).
TextStyle missionText(AppPalette c, double size, {Color? color}) => TextStyle(
  fontFamily: AppFonts.mono,
  fontSize: AppFonts.ms(size),
  fontWeight: c.style == UiStyle.wii ? FontWeight.w700 : FontWeight.w400,
  height: 1.15,
  color: color ?? c.ink,
);

/// Tarjeta: Gloss en Wii, caja con borde en retro.
class MissionPanel extends StatelessWidget {
  const MissionPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.highlight = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Resalta con el color de acento (mision completada).
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    if (isWii(context)) {
      return Gloss(
        radius: 22,
        top: highlight ? Color.lerp(c.chipActive, Colors.white, 0.5) : null,
        bottom: highlight ? c.chipActive : null,
        border: highlight ? c.accentLight : null,
        borderWidth: highlight ? 2 : 1.2,
        glow: highlight ? c.halo : null,
        padding: padding,
        child: child,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: highlight ? c.accentDark : c.edge),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: highlight
              ? [c.chipActive, c.chipActive]
              : [c.tileTop, c.tileBottom],
        ),
      ),
      child: child,
    );
  }
}

/// Barra de avance de una mision.
class MissionMeter extends StatelessWidget {
  const MissionMeter({super.key, required this.ratio, this.height = 10});

  final double ratio;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final wii = isWii(context);
    final radius = BorderRadius.circular(wii ? height / 2 : 3);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: wii ? c.meterTrack : c.fieldDeep,
        border: Border.all(color: wii ? c.meterTrackEdge : c.edge),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: ratio.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 600),
            curve: wii ? Curves.easeOutBack : Curves.easeOutCubic,
            builder: (context, v, _) => FractionallySizedBox(
              widthFactor: v.clamp(0.0, 1.0),
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: wii ? Alignment.topCenter : Alignment.centerLeft,
                    end: wii ? Alignment.bottomCenter : Alignment.centerRight,
                    colors: [c.accentLight, c.accent, c.accentDark],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Boton principal (guardar, nueva mision).
class MissionButton extends StatelessWidget {
  const MissionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final wii = isWii(context);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: c.onAccent),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: AppFonts.ds(wii ? 15 : 12),
              fontWeight: FontWeight.w800,
              letterSpacing: AppFonts.track(2),
              color: c.onAccent,
            ),
          ),
        ),
      ],
    );

    if (wii) {
      return Pressable(
        onTap: onTap,
        child: Gloss(
          radius: 24,
          top: c.accentLight,
          bottom: c.accent,
          border: c.accentDark,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          child: Center(child: content),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
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
            BoxShadow(color: c.accentDark, offset: const Offset(0, 3)),
          ],
        ),
        child: Center(child: content),
      ),
    );
  }
}

/// Entrada animada solo en estilo Wii (retro se queda quieto, como antes).
Widget missionEntrance(BuildContext context, int index, Widget child) =>
    isWii(context)
    ? Entrance(delay: Entrance.stagger(index), child: child)
    : child;
