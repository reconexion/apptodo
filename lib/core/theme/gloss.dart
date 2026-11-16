import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Pieza brillante estilo menu de consola: degradado vertical, borde
/// fino, reflejo blanco en la mitad superior y sombra suave abajo.
class Gloss extends StatelessWidget {
  const Gloss({
    super.key,
    required this.child,
    this.radius = 22,
    this.top,
    this.bottom,
    this.border,
    this.borderWidth = 1.2,
    this.padding = EdgeInsets.zero,
    this.glow,
    this.elevated = true,
    this.sheenFactor = 0.5,
  });

  final Widget child;
  final double radius;
  final Color? top;
  final Color? bottom;
  final Color? border;
  final double borderWidth;
  final EdgeInsetsGeometry padding;

  /// Halo de color alrededor (ej. pestana activa).
  final Color? glow;
  final bool elevated;

  /// Que tanto de la altura cubre el reflejo.
  final double sheenFactor;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final r = BorderRadius.circular(radius);
    final topColor = top ?? c.tileTop;
    final bottomColor = bottom ?? c.tileBottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: r,
        border: Border.all(color: border ?? c.edge, width: borderWidth),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            topColor,
            Color.lerp(topColor, bottomColor, 0.35)!,
            bottomColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          if (glow != null)
            BoxShadow(color: glow!, blurRadius: 14, spreadRadius: 1),
          if (elevated)
            BoxShadow(
              color: c.shadow,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: FractionallySizedBox(
                    heightFactor: sheenFactor,
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [c.sheen, c.sheen.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// Si el sistema pide reducir movimiento, las animaciones en bucle se apagan.
bool motionOff(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Envuelve algo para que se hunda al presionarlo y rebote al soltarlo.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.pressedScale = 0.94,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: Duration(milliseconds: _down ? 90 : 520),
        curve: _down ? Curves.easeOut : Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}

/// Aparece una vez al montarse: sube, se desvanece hacia dentro y crece
/// un poquito. [delay] permite escalonar varias piezas.
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 18,
  });

  final Widget child;
  final Duration delay;
  final double offset;

  /// Retraso escalonado para elementos de lista (tope para listas largas).
  static Duration stagger(int index, {int stepMs = 45, int max = 10}) =>
      Duration(milliseconds: (index < max ? index : max) * stepMs);

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  static const _run = Duration(milliseconds: 560);

  // El retraso va dentro de la misma animacion (no con un temporizador
  // aparte), asi nunca puede quedarse invisible.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _run + widget.delay,
  )..forward();

  late final double _start =
      widget.delay.inMicroseconds / (_run + widget.delay).inMicroseconds;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (motionOff(context)) return widget.child;
    final fade = CurvedAnimation(
      parent: _c,
      curve: Interval(_start, 1, curve: Curves.easeOut),
    );
    final move = CurvedAnimation(
      parent: _c,
      curve: Interval(_start, 1, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Opacity(
        opacity: fade.value,
        child: Transform.translate(
          offset: Offset(0, (1 - move.value) * widget.offset),
          child: Transform.scale(scale: 0.96 + 0.04 * move.value, child: child),
        ),
      ),
      child: widget.child,
    );
  }
}
