import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';

/// Display: contador global, medidor de avance y marcas.
class PanelDisplay extends StatelessWidget {
  const PanelDisplay({
    super.key,
    required this.pending,
    required this.doneCount,
    required this.total,
    required this.progress,
  });

  final int pending;
  final int doneCount;
  final int total;
  final double progress;

  String get _caption {
    if (pending == 0) return 'todo listo';
    if (pending == 1) return 'cosa por hacer';
    return 'cosas por hacer';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    final tickStyle = TextStyle(
      fontFamily: AppFonts.mono,
      fontSize: 14,
      height: 1.0,
      color: c.displayTick,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.glassEdge),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.glassTop, c.glass],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            // Resplandor del tubo, mas fuerte abajo.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 1.4),
                    radius: 1.2,
                    colors: [c.halo, Colors.transparent],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      pending.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 56,
                        height: 1.0,
                        color: c.displayInk,
                        shadows: [Shadow(color: c.glow, blurRadius: 14)],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.mono,
                          fontSize: 20,
                          height: 1.0,
                          color: c.displayInkSoft,
                          shadows: [Shadow(color: c.glow, blurRadius: 10)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const _BlinkingCursor(),
                  ],
                ),
                const SizedBox(height: 12),
                _Meter(progress: progress, palette: c),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0', style: tickStyle),
                    Text('$doneCount / $total hechas', style: tickStyle),
                    Text('100', style: tickStyle),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({required this.progress, required this.palette});

  final double progress;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: palette.meterTrack,
        border: Border.all(color: palette.meterTrackEdge),
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => FractionallySizedBox(
              widthFactor: value,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      palette.accentDark,
                      palette.accent,
                      palette.accentLight,
                    ],
                  ),
                  boxShadow: [BoxShadow(color: palette.glow, blurRadius: 10)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _controller.value < 0.5 ? 1 : 0,
        child: child,
      ),
      child: Container(
        width: 10,
        height: 20,
        decoration: BoxDecoration(
          color: c.displayInk,
          boxShadow: [BoxShadow(color: c.glow, blurRadius: 10)],
        ),
      ),
    );
  }
}