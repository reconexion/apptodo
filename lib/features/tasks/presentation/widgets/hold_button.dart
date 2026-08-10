import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

/// Seguro contra toques accidentales: hay que mantener presionado
/// hasta que la barra se llena para que dispare la accion.
class HoldButton extends StatefulWidget {
  const HoldButton({
    super.key,
    required this.label,
    required this.onComplete,
    this.danger = false,
    this.enabled = true,
    this.compact = false,
    this.duration = const Duration(milliseconds: 900),
  });

  final String label;
  final VoidCallback onComplete;
  final bool danger;
  final bool enabled;
  final bool compact;
  final Duration duration;

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..addStatusListener(_onStatus);

  bool _holding = false;

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    HapticFeedback.heavyImpact();
    _controller.value = 0;
    setState(() => _holding = false);
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    if (!widget.enabled) return;
    setState(() => _holding = true);
    HapticFeedback.selectionClick();
    _controller.forward();
  }

  void _cancel() {
    if (!_holding) return;
    setState(() => _holding = false);
    _controller.animateBack(
      0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final fill = widget.danger ? c.danger : c.accent;
    final idle = widget.enabled ? c.engrave : c.inkFaint;

    return GestureDetector(
      onTapDown: (_) => _start(),
      onTapUp: (_) => _cancel(),
      onTapCancel: _cancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Container(
            height: widget.compact ? 34 : 46,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: c.field,
              border: Border.all(color: t > 0 ? fill : c.edge),
            ),
            child: Stack(
              children: [
                // Barra que se llena mientras mantienes.
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: t,
                    heightFactor: 1,
                    child: ColoredBox(color: fill),
                  ),
                ),
                Center(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: widget.compact ? 10 : 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                      color: t > 0.55 ? c.onAccent : idle,
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