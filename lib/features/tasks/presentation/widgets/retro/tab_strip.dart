import 'package:flutter/material.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/task_tab.dart';
import '../../viewmodels/tasks_view_model.dart';

/// Fila de pestanas. "TODAS" queda fija a la izquierda y el resto
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

    return SizedBox(
      height: 36,
      child: Row(
        children: [
          _TabChip(
            name: t.t('all_tab').toUpperCase(),
            pending: 0,
            active: activeId == kAllTabsId,
            wide: true,
            onTap: () => onSelect(kAllTabsId),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final tab = tabs[index];
                return _TabChip(
                  name: tab.name,
                  pending: pendingOf(tab.id),
                  active: tab.id == activeId,
                  onTap: () => onSelect(tab.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.name,
    required this.pending,
    required this.active,
    required this.onTap,
    this.wide = false,
  });

  final String name;
  final int pending;
  final bool active;
  final bool wide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        constraints: BoxConstraints(maxWidth: wide ? 90 : 140),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: active ? c.chipActive : c.chipIdle,
          border: Border.all(color: active ? c.accentDark : c.edge),
          boxShadow: active
              ? [BoxShadow(color: c.halo, blurRadius: 10)]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontSize: 19,
                  height: 1.0,
                  color: active ? c.accent : c.inkDim,
                ),
              ),
            ),
            if (pending > 0) ...[
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: active ? c.accent : c.edge,
                ),
                child: Text(
                  '$pending',
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontSize: 14,
                    height: 1.0,
                    color: active ? c.onAccent : c.inkDim,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
