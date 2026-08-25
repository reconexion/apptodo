import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_tab.dart';

/// Tira de tarea con su LED indicador.
/// Mantener presionada abre el editor de pestanas ligadas.
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
  /// Util en "TODAS" o cuando la tarea esta en mas de una.
  final bool showTabChips;

  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final linked =
        tabs.where((tab) => task.tabIds.contains(tab.id)).toList();

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.edge),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: task.done
                ? [c.tileDoneTop, c.tileDoneBottom]
                : [c.tileTop, c.tileBottom],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Led(on: task.done, onTap: onToggle),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.text,
                    style: TextStyle(
                      fontFamily: AppFonts.mono,
                      fontSize: 21,
                      height: 1.1,
                      color: task.done ? c.inkDim : c.ink,
                      decoration: task.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: c.inkDim,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 18, color: c.inkFaint),
                  ),
                ),
              ],
            ),
            if (showTabChips && linked.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tab in linked)
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.edge),
                      ),
                      child: Text(
                        tab.name,
                        style: TextStyle(
                          fontFamily: AppFonts.display,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: c.engrave,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Led extends StatelessWidget {
  const _Led({required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: on ? c.accentDark : c.ledOffBorder),
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: on
                ? [c.accentLight, c.accentDark]
                : [c.ledOffTop, c.ledOffBottom],
          ),
          boxShadow:
          on ? [BoxShadow(color: c.glow, blurRadius: 13)] : const [],
        ),
      ),
    );
  }
}
