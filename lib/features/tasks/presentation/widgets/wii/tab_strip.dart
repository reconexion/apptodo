import 'package:flutter/material.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/gloss.dart';
import '../../../domain/entities/task_tab.dart';
import '../../viewmodels/tasks_view_model.dart';

/// Fila de pestanas. "Todas" queda fija a la izquierda y el resto
/// se desplaza horizontalmente, para que muchas pestanas no rompan el layout.
class TabStrip extends StatelessWidget {
  const TabStrip({
    super.key,
    required this.tabs,
    required this.activeId,
    required this.pendingOf,
    required this.onSelect,
  });

  final List<TaskTab> tabs;
  final int activeId;
  final int Function(int tabId) pendingOf;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    // La lista horizontal necesita una altura fija: se calcula con el
    // tamano de letra del telefono para que el texto nunca se desborde.
    // Lleva espacio extra para el halo de la pestana activa.
    final textH = MediaQuery.textScalerOf(context).scale(17) * 1.4;
    final height = textH + 24 + 20;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          _TabChip(
            name: t.t('all_tab'),
            pending: 0,
            active: activeId == kAllTabsId,
            onTap: () => onSelect(kAllTabsId),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.only(right: 4),
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = tabs[index];
                return Entrance(
                  delay: Entrance.stagger(index + 1, stepMs: 60),
                  offset: 10,
                  child: _TabChip(
                    name: tab.name,
                    pending: pendingOf(tab.id),
                    active: tab.id == activeId,
                    onTap: () => onSelect(tab.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatefulWidget {
  const _TabChip({
    required this.name,
    required this.pending,
    required this.active,
    required this.onTap,
  });

  final String name;
  final int pending;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<_TabChip>
    with SingleTickerProviderStateMixin {
  /// Respiracion del halo cuando la pestana esta activa.
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _TabChip old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.active && !motionOff(context)) {
      if (!_breath.isAnimating) _breath.repeat(reverse: true);
    } else {
      _breath.stop();
      _breath.value = 0.5;
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final active = widget.active;

    return Center(
      child: Pressable(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _breath,
          builder: (context, child) => Gloss(
            radius: 18,
            top: active
                ? Color.lerp(c.chipActive, Colors.white, 0.6)
                : c.tileTop,
            bottom: active
                ? Color.lerp(c.chipActive, c.accentLight, 0.5)
                : c.tileBottom,
            border: active ? c.accentLight : c.edge,
            borderWidth: active ? 2 : 1.2,
            glow: active
                ? c.halo.withValues(
                    alpha: c.halo.a * (0.55 + 0.9 * _breath.value),
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: child!,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 40, maxWidth: 170),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: active ? c.accentDark : c.ink,
                    ),
                    child: Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: widget.pending > 0
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) => ScaleTransition(
                              scale: CurvedAnimation(
                                parent: anim,
                                curve: Curves.elasticOut,
                              ),
                              child: child,
                            ),
                            child: Container(
                              key: ValueKey(widget.pending),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: active ? c.accent : c.edge,
                              ),
                              child: Text(
                                '${widget.pending}',
                                style: TextStyle(
                                  fontFamily: AppFonts.display,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: active ? c.onAccent : c.inkDim,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
