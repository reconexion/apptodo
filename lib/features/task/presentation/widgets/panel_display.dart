import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Display de fosforo verde: contador, medidor de avance y marcas.
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
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassEdge),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF10150C), AppColors.glass],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            // Resplandor del tubo, mas fuerte abajo.
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, 1.4),
                    radius: 1.2,
                    colors: [
                      Color.fromRGBO(163, 230, 53, 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      pending.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 62,
                        height: 0.9,
                        color: AppColors.green,
                        shadows: [
                          Shadow(color: AppColors.glow, blurRadius: 14),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _caption,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.mono,
                          fontSize: 21,
                          color: AppColors.greenLight,
                          shadows: [
                            Shadow(color: AppColors.glow, blurRadius: 10),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    const _BlinkingCursor(),
                  ],
                ),
                const SizedBox(height: 14),
                _Meter(progress: progress),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('0', style: _tickStyle),
                    Text('$doneCount / $total hechas', style: _tickStyle),
                    const Text('100', style: _tickStyle),
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

const _tickStyle = TextStyle(
  fontFamily: AppFonts.mono,
  fontSize: 14,
  color: Color(0xFF6F8F3E),
);

class _Meter extends StatelessWidget {
  const _Meter({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFF060803),
        border: Border.all(color: const Color(0xFF2C3323)),
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
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.greenDark,
                      AppColors.green,
                      AppColors.greenLight,
                    ],
                  ),
                  boxShadow: [BoxShadow(color: AppColors.glow, blurRadius: 10)],
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _controller.value < 0.5 ? 1 : 0,
        child: child,
      ),
      child: Container(
        width: 11,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.green,
          boxShadow: [BoxShadow(color: AppColors.glow, blurRadius: 10)],
        ),
      ),
    );
  }
}