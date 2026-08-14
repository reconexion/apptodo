import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

/// Seguro contra toques accidentales, en dos pasos:
/// 1. Mantener presionado 5 segundos hasta que la barra se llena.
/// 2. Soltar y tocar una vez mas para confirmar.
/// Si sueltas antes de tiempo, o dejas pasar la confirmacion, se cancela.
class HoldButton extends StatefulWidget {
  const HoldButton({
    super.key,
    required this.label,
    required this.confirmLabel,
    required this.onComplete,
    this.danger = false,
    this.enabled = true,
    this.compact = false,
    this.duration = const Duration(seconds: 5),
    this.confirmWindow = const Duration(seconds: 3),
  });

  final String label;
  final String confirmLabel;
  final VoidCallback onComplete;
  final bool danger;
  final bool enabled;
  final bool compact;
  final Duration duration;
  final Duration confirmWindow;

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

enum _Stage { idle, holding, armed }

class _HoldButtonState extends State<HoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..addStatusListener(_onStatus);

  _Stage _stage = _Stage.idle;

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    HapticFeedback.mediumImpact();
    setState(() => _stage = _Stage.armed);
    _scheduleReset();
  }

  void _scheduleReset() {
    Future.delayed(widget.confirmWindow, () {
      if (!mounted || _stage != _Stage.armed) return;
      _reset();
    });
  }

  void _reset() {
    _controller.animateBack(
      0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
    setState(() => _stage = _Stage.idle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown() {
    if (!widget.enabled) return;

    if (_stage == _Stage.armed) {
      HapticFeedback.heavyImpact();
      _controller.value = 0;
      setState(() => _stage = _Stage.idle);
      widget.onComplete();
      return;
    }

    setState(() => _stage = _Stage.holding);
    HapticFeedback.selectionClick();
    _controller.forward(from: 0);
  }

  void _onTapCancel() {
    if (_stage != _Stage.holding) return;
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final fill = widget.danger ? c.danger : c.accent;
    final idle = widget.enabled ? c.engrave : c.inkFaint;

    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapCancel(),
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final armed = _stage == _Stage.armed;

          return Container(
            height: widget.compact ? 34 : 46,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: c.field,
              border: Border.all(
                color: armed ? fill : (t > 0 ? fill : c.edge),
                width: armed ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: armed ? 1 : t,
                    heightFactor: 1,
                    child: ColoredBox(
                      color: armed ? fill.withValues(alpha: 0.4) : fill,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    armed ? widget.confirmLabel : widget.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: widget.compact ? 10 : 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                      color: armed
                          ? fill
                          : (t > 0.55 ? c.onAccent : idle),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}