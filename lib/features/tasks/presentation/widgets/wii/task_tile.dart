import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/gloss.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_tab.dart';

/// Tarjeta de tarea en pastilla brillante.
/// - Casilla de la izquierda (o tocar la tarjeta): marcar como hecha.
/// - Flecha azul (o mantener presionada): elegir sus pestanas.
/// - Deslizar hacia la izquierda: eliminar.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.tabs,
    required this.onToggle,
    required this.onDelete,
    required this.onLongPress,
    this.showTabChips = false,
  });

  final Task task;

  /// Todas las pestanas existentes, para resolver los nombres de las ligadas.
  final List<TaskTab> tabs;

  /// Muestra los nombres de las pestanas ligadas debajo del texto.
  /// Util en "Todas" o cuando la tarea esta en mas de una.
  final bool showTabChips;

  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final linked = tabs.where((tab) => task.tabIds.contains(tab.id)).toList();

    final card = Pressable(
      onTap: onToggle,
      onLongPress: onLongPress,
      pressedScale: 0.98,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: task.done ? 0.78 : 1,
        child: Gloss(
          radius: 22,
          top: task.done ? c.tileDoneTop : c.tileTop,
          bottom: task.done ? c.tileDoneBottom : c.tileBottom,
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            children: [
              _CheckBox(done: task.done, onTap: onToggle),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StrikeText(
                      text: task.text,
                      done: task.done,
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: task.done ? c.inkFaint : c.ink,
                      ),
                      lineColor: c.inkFaint,
                    ),
                    if (showTabChips && linked.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final tab in linked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: c.chipActive,
                                border: Border.all(
                                  color: c.accentLight.withValues(alpha: 0.7),
                                ),
                              ),
                              child: Text(
                                tab.name,
                                style: TextStyle(
                                  fontFamily: AppFonts.display,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: c.accentDark,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              _NudgeArrow(onTap: onLongPress),
            ],
          ),
        ),
      ),
    );

    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              c.danger.withValues(alpha: 0.2),
              c.danger.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
      ),
      child: card,
    );
  }
}

/// Texto con una linea que lo tacha de izquierda a derecha al completarse.
class _StrikeText extends StatelessWidget {
  const _StrikeText({
    required this.text,
    required this.done,
    required this.style,
    required this.lineColor,
  });

  final String text;
  final bool done;
  final TextStyle style;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: done ? 1 : 0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => CustomPaint(
        foregroundPainter: _StrikePainter(
          progress: v,
          color: lineColor,
          text: text,
          style: style,
          textScaler: MediaQuery.textScalerOf(context),
        ),
        child: child,
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: style,
        child: Text(text),
      ),
    );
  }
}

class _StrikePainter extends CustomPainter {
  _StrikePainter({
    required this.progress,
    required this.color,
    required this.text,
    required this.style,
    required this.textScaler,
  });

  final double progress;
  final Color color;
  final String text;
  final TextStyle style;
  final TextScaler textScaler;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout(maxWidth: size.width);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Se tacha renglon por renglon, en orden, segun el avance.
    final lines = tp.computeLineMetrics();
    final total = lines.fold<double>(0, (a, l) => a + l.width);
    var budget = total * progress;
    for (final l in lines) {
      if (budget <= 0) break;
      final len = math.min(budget, l.width);
      final y = l.baseline - l.ascent * 0.32;
      canvas.drawLine(Offset(l.left, y), Offset(l.left + len, y), paint);
      budget -= len;
    }
    tp.dispose();
  }

  @override
  bool shouldRepaint(covariant _StrikePainter old) =>
      old.progress != progress || old.text != text || old.color != color;
}

/// Flecha que se asoma a la derecha al tocarla.
class _NudgeArrow extends StatefulWidget {
  const _NudgeArrow({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_NudgeArrow> createState() => _NudgeArrowState();
}

class _NudgeArrowState extends State<_NudgeArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _c.forward(from: 0);
        widget.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) => Transform.translate(
            offset: Offset(math.sin(_c.value * math.pi) * 6, 0),
            child: child,
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            size: 30,
            color: c.accent,
            shadows: [Shadow(color: c.sheen, offset: const Offset(0, 1))],
          ),
        ),
      ),
    );
  }
}

/// Casilla brillante. Al marcarla: rebota, dibuja la palomita y suelta
/// unas chispitas.
class _CheckBox extends StatefulWidget {
  const _CheckBox({required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  State<_CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<_CheckBox> with TickerProviderStateMixin {
  late final AnimationController _check = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    value: widget.done ? 1 : 0,
  );
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    value: 1,
  );
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    value: 1,
  );

  @override
  void didUpdateWidget(covariant _CheckBox old) {
    super.didUpdateWidget(old);
    if (old.done == widget.done) return;
    _pop.forward(from: 0);
    if (widget.done) {
      _check.forward();
      if (!motionOff(context)) _burst.forward(from: 0);
    } else {
      _check.reverse();
    }
  }

  @override
  void dispose() {
    _check.dispose();
    _pop.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    const size = 34.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_check, _pop, _burst]),
        builder: (context, _) {
          final p = _pop.value;
          final scale = 1 + 0.28 * math.sin(p * math.pi) * (1 - p);
          final on = _check.value;

          return SizedBox(
            width: size + 8,
            height: size + 8,
            child: CustomPaint(
              painter: _BurstPainter(_burst.value, c.accent, c.accentLight),
              child: Center(
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color.lerp(c.ledOffBorder, c.accentDark, on)!,
                        width: 1.4,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.lerp(c.fieldDeep, c.accentLight, on)!,
                          Color.lerp(c.field, c.accent, on)!,
                          Color.lerp(c.field, c.accentDark, on)!,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                      boxShadow: [
                        if (on > 0)
                          BoxShadow(
                            color: c.glow.withValues(alpha: c.glow.a * on),
                            blurRadius: 10,
                          ),
                        BoxShadow(
                          color: c.shadow,
                          blurRadius: 3,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: _CheckPainter(on, c.onAccent, c.sheen),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Palomita que se dibuja trazo a trazo segun [t] (0..1).
class _CheckPainter extends CustomPainter {
  _CheckPainter(this.t, this.color, this.sheen);

  final double t;
  final Color color;
  final Color sheen;

  @override
  void paint(Canvas canvas, Size size) {
    // Reflejo en la mitad de arriba.
    final top = Rect.fromLTWH(2, 2, size.width - 4, size.height * 0.45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(top, const Radius.circular(8)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            sheen.withValues(alpha: sheen.a * 0.8),
            sheen.withValues(alpha: 0),
          ],
        ).createShader(top),
    );

    if (t <= 0) return;
    final a = Offset(size.width * 0.24, size.height * 0.52);
    final b = Offset(size.width * 0.43, size.height * 0.71);
    final d = Offset(size.width * 0.77, size.height * 0.31);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(d.dx, d.dy);

    final metric = path.computeMetrics().first;
    final partial = metric.extractPath(0, metric.length * t);
    canvas.drawPath(
      partial,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) => old.t != t;
}

/// Chispitas de cuatro puntas que salen disparadas y se apagan.
class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t, this.a, this.b);

  final double t;
  final Color a;
  final Color b;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final center = size.center(Offset.zero);
    final ease = Curves.easeOutCubic.transform(t);
    const n = 8;
    for (var i = 0; i < n; i++) {
      final ang = i * 2 * math.pi / n + 0.3;
      final dist = 14 + 22 * ease;
      final pos = center + Offset(math.cos(ang), math.sin(ang)) * dist;
      final r = (i.isEven ? 4.5 : 3.0) * (1 - t);
      final paint = Paint()
        ..color = (i.isEven ? a : b).withValues(alpha: 1 - t);
      canvas.drawPath(_sparkle(pos, r), paint);
    }
  }

  Path _sparkle(Offset c, double r) {
    final k = r * 0.3;
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - r)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}
