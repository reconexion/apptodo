import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/gloss.dart';
import '../viewmodels/missions_view_model.dart';
import 'mission_ui.dart';

/// Escucha las misiones que se completan y muestra la celebracion.
/// Va envolviendo la pantalla principal.
class MissionCelebrationHost extends StatefulWidget {
  const MissionCelebrationHost({super.key, required this.child});

  final Widget child;

  @override
  State<MissionCelebrationHost> createState() => _MissionCelebrationHostState();
}

class _MissionCelebrationHostState extends State<MissionCelebrationHost> {
  StreamSubscription<MissionProgress>? _sub;
  final List<MissionProgress> _queue = [];
  bool _showing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sub ??= context.read<MissionsViewModel>().celebrations.listen((p) {
      _queue.add(p);
      _next();
    });
  }

  /// Si se completan dos misiones a la vez, se muestran una tras otra.
  Future<void> _next() async {
    if (_showing || _queue.isEmpty || !mounted) return;
    _showing = true;
    final p = _queue.removeAt(0);
    await showMissionComplete(context, p);
    _showing = false;
    _next();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> showMissionComplete(BuildContext context, MissionProgress p) {
  return showGeneralDialog<void>(
    context: context,
    // El navegador raiz esta fuera de los providers (tema, misiones):
    // hay que abrirla en el de la pantalla.
    useRootNavigator: false,
    barrierDismissible: true,
    barrierLabel: 'mission',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 520),
    pageBuilder: (_, _, _) => _CelebrationView(progress: p),
    transitionBuilder: (_, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: anim,
          curve: Curves.elasticOut,
        ).drive(Tween(begin: 0.6, end: 1.0)),
        child: child,
      ),
    ),
  );
}

class _CelebrationView extends StatefulWidget {
  const _CelebrationView({required this.progress});

  final MissionProgress progress;

  @override
  State<_CelebrationView> createState() => _CelebrationViewState();
}

class _CelebrationViewState extends State<_CelebrationView>
    with TickerProviderStateMixin {
  /// Rayos que giran y confeti que cae: en bucle mientras se ve.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  /// Entrada escalonada de estrella, titulo y texto.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  Timer? _auto;
  final _confetti = List.generate(36, (i) => _Piece(math.Random(i * 31 + 7)));

  @override
  void initState() {
    super.initState();
    // Dura lo mismo que la melodia y un poco mas; luego se cierra sola.
    _auto = Timer(const Duration(milliseconds: 5200), _close);
  }

  void _close() {
    _auto?.cancel();
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _auto?.cancel();
    _loop.dispose();
    _intro.dispose();
    super.dispose();
  }

  Animation<double> _step(
    double from,
    double to, [
    Curve curve = Curves.easeOutBack,
  ]) => CurvedAnimation(
    parent: _intro,
    curve: Interval(from, to, curve: curve),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;
    final m = widget.progress.mission;
    final wii = c.style == UiStyle.wii;
    final calm = motionOff(context);

    final star = _step(0.0, 0.55, Curves.elasticOut);
    final title = _step(0.2, 0.6);
    final name = _step(0.35, 0.75);
    final rest = _step(0.5, 1.0, Curves.easeOut);

    Widget rise(Animation<double> a, Widget child) => AnimatedBuilder(
      animation: a,
      builder: (context, child) => Opacity(
        opacity: a.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - a.value) * 16),
          child: child,
        ),
      ),
      child: child,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _close,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            if (!calm)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ConfettiPainter(_loop, _confetti, [
                      c.accent,
                      c.accentLight,
                      c.mascot,
                      c.wave,
                      Colors.white,
                    ]),
                  ),
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: MissionPanel(
                    highlight: true,
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (!calm)
                                AnimatedBuilder(
                                  animation: _loop,
                                  builder: (context, _) => Transform.rotate(
                                    angle: _loop.value * 2 * math.pi,
                                    child: CustomPaint(
                                      size: const Size(130, 130),
                                      painter: _RaysPainter(c.accentLight),
                                    ),
                                  ),
                                ),
                              AnimatedBuilder(
                                animation: Listenable.merge([star, _loop]),
                                builder: (context, child) => Transform.scale(
                                  scale: star.value,
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      calm
                                          ? 0
                                          : math.sin(
                                                  _loop.value * 6 * math.pi,
                                                ) *
                                                4,
                                    ),
                                    child: child,
                                  ),
                                ),
                                child: _BigStar(palette: c),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        rise(
                          title,
                          Text(
                            t.t('mission_complete_title'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppFonts.display,
                              fontSize: wii ? 24 : 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: wii ? 0.5 : 2.5,
                              color: c.accentDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        rise(
                          name,
                          Text(
                            m.title,
                            textAlign: TextAlign.center,
                            style: missionText(c, 24),
                          ),
                        ),
                        rise(
                          rest,
                          Column(
                            children: [
                              if (m.description.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  m.description,
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: missionText(c, 17, color: c.inkDim),
                                ),
                              ],
                              const SizedBox(height: 14),
                              const MissionMeter(ratio: 1, height: 12),
                              const SizedBox(height: 8),
                              Text(
                                t.t('mission_complete_tasks', {
                                  'count': widget.progress.total,
                                }),
                                style: missionText(c, 16, color: c.accent),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                t.t('mission_complete_tap'),
                                style: missionText(c, 14, color: c.inkFaint),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigStar extends StatelessWidget {
  const _BigStar({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final c = palette;
    return ShaderMask(
      shaderCallback: (r) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [c.accentLight, c.accent, c.accentDark],
      ).createShader(r),
      child: Icon(
        Icons.star_rounded,
        size: 96,
        color: Colors.white,
        shadows: [Shadow(color: c.glow, blurRadius: 18)],
      ),
    );
  }
}

/// Rayos de luz alrededor de la estrella.
class _RaysPainter extends CustomPainter {
  _RaysPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;
    const n = 12;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: r));

    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(a - 0.11) * r,
          center.dy + math.sin(a - 0.11) * r,
        )
        ..lineTo(
          center.dx + math.cos(a + 0.11) * r,
          center.dy + math.sin(a + 0.11) * r,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter old) => old.color != color;
}

/// Un papelito de confeti con posicion, velocidad y giro propios.
class _Piece {
  _Piece(math.Random r)
    : x = r.nextDouble(),
      offset = r.nextDouble(),
      speed = 0.6 + r.nextDouble() * 0.8,
      sway = 0.02 + r.nextDouble() * 0.04,
      spin = (r.nextDouble() - 0.5) * 12,
      size = 5 + r.nextDouble() * 6,
      color = r.nextInt(5),
      round = r.nextBool();

  final double x, offset, speed, sway, spin, size;
  final int color;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.anim, this.pieces, this.colors) : super(repaint: anim);

  final Animation<double> anim;
  final List<_Piece> pieces;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    for (final p in pieces) {
      final fall = (p.offset + t * p.speed * 2) % 1.0;
      final y = -20 + fall * (size.height + 40);
      final x =
          (p.x + math.sin((t * 6 + p.offset) * 2 * math.pi) * p.sway) *
          size.width;
      final paint = Paint()
        ..color = colors[p.color % colors.length].withValues(alpha: 0.9);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * p.spin * math.pi);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.5,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => false;
}
