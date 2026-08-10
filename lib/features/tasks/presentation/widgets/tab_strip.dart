import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task_tab.dart';

/// Fila de pestanas con su contador de pendientes.
/// Solo cambia de pestana: crear y borrar viven en configuracion.
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
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
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
    );
  }
}

class _TabChip extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final c = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
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
            Text(
              name,
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 19,
                height: 1.0,
                color: active ? c.accent : c.inkDim,
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