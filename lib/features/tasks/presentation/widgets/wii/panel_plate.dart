import 'package:flutter/material.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/gloss.dart';

/// Encabezado: pestana de titulo con estrella, interruptor de sonido
/// y boton de configuracion. Sin alturas fijas: crece con el texto.
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
      children: [
        Expanded(
          child: CustomPaint(
            painter: _TitleTabPainter(c),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 30, 8),
                child: Row(
                  children: [
                    const _SpinningStar(),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          t.t('brand'),
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: AppFonts.display,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: c.ink,
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
        const SizedBox(width: 8),
        // En pantallas angostas (o con letra grande) el boton de sonido
        // muestra solo la bocina, para dejarle espacio al titulo.
        _SoundPill(
          muted: muted,
          onTap: onToggleSound,
          compact:
              MediaQuery.sizeOf(context).width /
                  MediaQuery.textScalerOf(context).scale(1) <
              380,
        ),
        const SizedBox(width: 8),
        _GearButton(onTap: onOpenSettings),
      ],
    );
  }
}

/// Estrella del titulo: da una vuelta completa al tocarla.
class _SpinningStar extends StatefulWidget {
  const _SpinningStar();

  @override
  State<_SpinningStar> createState() => _SpinningStarState();
}

class _SpinningStarState extends State<_SpinningStar> {
  double _turns = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return GestureDetector(
      onTap: () => setState(() => _turns += 1),
      child: AnimatedRotation(
        turns: _turns,
        duration: const Duration(milliseconds: 900),
        curve: Curves.elasticOut,
        child: Icon(Icons.stars_rounded, size: 28, color: c.engrave),
      ),
    );
  }
}

class _GearButton extends StatefulWidget {
  const _GearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_GearButton> createState() => _GearButtonState();
}

class _GearButtonState extends State<_GearButton> {
  double _turns = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Pressable(
      onTap: () {
        setState(() => _turns += 0.5);
        widget.onTap();
      },
      child: Gloss(
        radius: 22,
        padding: const EdgeInsets.all(10),
        child: AnimatedRotation(
          turns: _turns,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          child: Icon(Icons.settings_rounded, size: 22, color: c.inkDim),
        ),
      ),
    );
  }
}

class _SoundPill extends StatelessWidget {
  const _SoundPill({
    required this.muted,
    required this.onTap,
    required this.compact,
  });

  final bool muted;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;

    return Pressable(
      onTap: onTap,
      child: Gloss(
        radius: 22,
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!compact) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 10,
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: muted ? c.inkFaint : c.ink,
                    ),
                    child: Text(muted ? t.t('sound_off') : t.t('sound_on')),
                  ),
                ),
                Container(width: 1, color: c.edge),
              ],
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 8,
                  vertical: 10,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: CurvedAnimation(
                      parent: anim,
                      curve: Curves.elasticOut,
                    ),
                    child: child,
                  ),
                  child: Icon(
                    muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    key: ValueKey(muted),
                    size: 22,
                    color: muted ? c.inkFaint : c.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pestana con el lado derecho en diagonal larga, como una carpeta.
class _TitleTabPainter extends CustomPainter {
  _TitleTabPainter(this.c);

  final AppPalette c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const r = 18.0;
    final taper = (w * 0.22).clamp(24.0, 80.0);

    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(w - taper - 10, 0)
      ..quadraticBezierTo(w - taper + 4, 0, w - taper + 14, h * 0.18)
      ..lineTo(w - 8, h * 0.88)
      ..quadraticBezierTo(w, h, w - 14, h)
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: const Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..close();

    canvas.drawShadow(path, c.shadow, 3, false);

    final rect = Offset.zero & size;
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.tileTop, c.tileBottom],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipPath(path);
    final top = Rect.fromLTWH(0, 0, w, h * 0.5);
    canvas.drawRect(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.sheen, c.sheen.withValues(alpha: 0)],
        ).createShader(top),
    );
    canvas.restore();
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = c.edge,
    );
  }

  @override
  bool shouldRepaint(covariant _TitleTabPainter old) => old.c != c;
}
