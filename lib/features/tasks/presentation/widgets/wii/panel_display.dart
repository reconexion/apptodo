import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/gloss.dart';

/// Tarjeta principal: contador global, kaomoji del dia, estrellita
/// animada y barra de avance con brillo.
class PanelDisplay extends StatelessWidget {
  const PanelDisplay({
    super.key,
    required this.pending,
    required this.doneCount,
    required this.total,
    required this.progress,
    required this.kaomoji,
  });

  final int pending;
  final int doneCount;
  final int total;
  final double progress;
  final String kaomoji;

  String _caption(AppStrings t) {
    if (pending == 0) return t.t('display_ready');
    if (pending == 1) return t.t('display_one_pending');
    return t.t('display_many_pending');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;

    final small = TextStyle(
      fontFamily: AppFonts.mono,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: c.displayTick,
    );

    return Gloss(
      radius: 26,
      top: c.glassTop,
      bottom: c.glass,
      border: c.glassEdge,
      sheenFactor: 0.45,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -6,
            top: -6,
            child: _StarBuddy(color: c.mascot, size: 92),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 76),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 12,
                  children: [
                    _BumpNumber(
                      value: pending,
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontSize: 58,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: c.displayInk,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _caption(t),
                          key: ValueKey(_caption(t)),
                          style: TextStyle(
                            fontFamily: AppFonts.mono,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: c.displayInkSoft,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              _Wobble(
                child: Text(
                  kaomoji,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.2,
                    color: c.displayInkSoft,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Meter(progress: progress, palette: c),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.t('done_of_total', {'done': doneCount, 'total': total}),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: small,
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: progress * 100),
                    duration: const Duration(milliseconds: 450),
                    builder: (context, v, _) =>
                        Text('${v.round()}%', style: small),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Numero que cuenta hasta el valor nuevo y da un saltito al cambiar.
class _BumpNumber extends StatefulWidget {
  const _BumpNumber({required this.value, required this.style});

  final int value;
  final TextStyle style;

  @override
  State<_BumpNumber> createState() => _BumpNumberState();
}

class _BumpNumberState extends State<_BumpNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    value: 1,
  );

  @override
  void didUpdateWidget(covariant _BumpNumber old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _bump.forward(from: 0);
  }

  @override
  void dispose() {
    _bump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bump,
      builder: (context, child) {
        // Sube a 1.18 y vuelve con rebote.
        final v = _bump.value;
        final scale = 1 + 0.18 * math.sin(v * math.pi) * (1 - v * 0.6);
        return Transform.scale(
          scale: scale,
          alignment: Alignment.bottomLeft,
          child: child,
        );
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: widget.value.toDouble()),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOut,
        builder: (context, v, _) =>
            Text(v.round().toString(), style: widget.style),
      ),
    );
  }
}

/// Balanceo suave de lado a lado.
class _Wobble extends StatefulWidget {
  const _Wobble({required this.child});

  final Widget child;

  @override
  State<_Wobble> createState() => _WobbleState();
}

class _WobbleState extends State<_Wobble> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    motionOff(context) ? _c.stop() : _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Transform.rotate(
        angle: math.sin(_c.value * 2 * math.pi) * 0.04,
        alignment: Alignment.centerLeft,
        child: child,
      ),
      child: Align(alignment: Alignment.centerLeft, child: widget.child),
    );
  }
}

/// Estrellita translucida con ojos: flota, parpadea y salta al tocarla.
class _StarBuddy extends StatefulWidget {
  const _StarBuddy({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  State<_StarBuddy> createState() => _StarBuddyState();
}

class _StarBuddyState extends State<_StarBuddy> with TickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );
  late final AnimationController _jump = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (motionOff(context)) {
      _float.stop();
      _blink.stop();
    } else {
      _float.repeat();
      _blink.repeat();
    }
  }

  @override
  void dispose() {
    _float.dispose();
    _blink.dispose();
    _jump.dispose();
    super.dispose();
  }

  void _poke() {
    HapticFeedback.lightImpact();
    _jump.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return GestureDetector(
      onTap: _poke,
      child: AnimatedBuilder(
        animation: Listenable.merge([_float, _blink, _jump]),
        builder: (context, _) {
          final f = _float.value * 2 * math.pi;
          final j = _jump.value;
          final jumpY = -math.sin(j * math.pi) * 22;
          final bob = math.sin(f) * 4;
          final spin = Curves.easeInOutBack.transform(j);
          final tilt = math.sin(f * 0.5) * 0.06;

          // Parpadeo: ojos aplastados un instante cerca del final del ciclo.
          final b = _blink.value;
          final eyeScale = (b > 0.94 && b < 0.99) ? 0.15 : 1.0;

          final eye = Transform.scale(
            scaleY: eyeScale,
            child: Container(
              width: size * 0.07,
              height: size * 0.17,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          );

          return Transform.translate(
            offset: Offset(0, bob + jumpY),
            child: Transform.rotate(
              angle: tilt + spin * 2 * math.pi,
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: size,
                      color: widget.color.withValues(alpha: 0.5),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: size * 0.06),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          eye,
                          SizedBox(width: size * 0.09),
                          eye,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Barra de avance azul con un destello que la recorre.
class _Meter extends StatefulWidget {
  const _Meter({required this.progress, required this.palette});

  final double progress;
  final AppPalette palette;

  @override
  State<_Meter> createState() => _MeterState();
}

class _MeterState extends State<_Meter> with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    motionOff(context) ? _shine.stop() : _shine.repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;

    return Container(
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: p.meterTrackEdge),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(p.meterTrack, Colors.black, 0.08)!,
            p.meterTrack,
            Color.lerp(p.meterTrack, Colors.white, 0.35)!,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: widget.progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            builder: (context, value, _) => FractionallySizedBox(
              widthFactor: value <= 0 ? 0 : value.clamp(0.06, 1.0),
              heightFactor: 1,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [p.accentLight, p.accent, p.accentDark],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Reflejo fijo de arriba.
                    Align(
                      alignment: Alignment.topCenter,
                      child: FractionallySizedBox(
                        heightFactor: 0.45,
                        widthFactor: 1,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                    // Destello que corre de izquierda a derecha.
                    AnimatedBuilder(
                      animation: _shine,
                      builder: (context, _) => Align(
                        alignment: Alignment(-1.6 + _shine.value * 3.2, 0),
                        child: FractionallySizedBox(
                          widthFactor: 0.35,
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.55),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
