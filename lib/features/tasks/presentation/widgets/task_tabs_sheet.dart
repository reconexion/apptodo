import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_tab.dart';
import '../viewmodels/tasks_view_model.dart';

/// Editor de pestanas ligadas a una tarea. Se abre al mantener presionada.
/// Cada toque liga o desliga esa pestana de una vez, sin boton de guardar.
Future<void> showTaskTabsSheet(
  BuildContext context,
  TasksViewModel vm,
  Task task,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider<TasksViewModel>.value(
      value: vm,
      child: TaskTabsSheet(taskId: task.id, initialText: task.text),
    ),
  );
}

class TaskTabsSheet extends StatelessWidget {
  const TaskTabsSheet({
    super.key,
    required this.taskId,
    required this.initialText,
  });

  final int taskId;
  final String initialText;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;
    final vm = context.watch<TasksViewModel>();

    // La tarea puede haberse borrado mientras la hoja estaba abierta.
    Task? current;
    for (final task in vm.tasks) {
      if (task.id == taskId) {
        current = task;
        break;
      }
    }
    if (current == null) return const SizedBox.shrink();
    final task = current;

    final label = TextStyle(
      fontFamily: AppFonts.display,
      fontSize: AppFonts.ds(9),
      fontWeight: FontWeight.w800,
      letterSpacing: AppFonts.track(3.2),
      color: c.engrave,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(
          top: BorderSide(color: c.edge),
          left: BorderSide(color: c.edge),
          right: BorderSide(color: c.edge),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.panelLight, c.panelDark],
        ),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.edge,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(t.t('task_tabs_title'), style: label),
                const SizedBox(height: 4),
                Text(
                  initialText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontSize: AppFonts.ms(19),
                    fontWeight: AppFonts.monoWeight,
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: vm.tabs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final tab = vm.tabs[index];
                      final linked = task.tabIds.contains(tab.id);
                      return _TabOption(
                        tab: tab,
                        linked: linked,
                        onTap: () {
                          final next = {...task.tabIds};
                          if (!next.remove(tab.id)) next.add(tab.id);
                          vm.setTaskTabs(task.id, next);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabOption extends StatelessWidget {
  const _TabOption({required this.tab, required this.linked, this.onTap});

  final TaskTab tab;
  final bool linked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: linked ? c.chipActive : c.field,
          border: Border.all(color: linked ? c.accentDark : c.edge),
        ),
        child: Row(
          children: [
            Icon(
              linked ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: linked ? c.accent : c.inkFaint,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tab.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontSize: AppFonts.ms(19),
                  fontWeight: AppFonts.monoWeight,
                  color: linked ? c.ink : c.inkDim,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
