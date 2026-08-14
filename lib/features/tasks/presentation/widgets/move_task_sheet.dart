import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_tab.dart';
import '../viewmodels/tasks_view_model.dart';

/// Menu para mover una tarea a otra pestana. Se abre al mantener presionada.
Future<void> showMoveTaskSheet(
    BuildContext context,
    TasksViewModel vm,
    Task task,
    ) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider<TasksViewModel>.value(
      value: vm,
      child: MoveTaskSheet(task: task),
    ),
  );
}

class MoveTaskSheet extends StatelessWidget {
  const MoveTaskSheet({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;
    final vm = context.watch<TasksViewModel>();

    final label = TextStyle(
      fontFamily: AppFonts.display,
      fontSize: 9,
      fontWeight: FontWeight.w800,
      letterSpacing: 3.2,
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
                Text(t.t('move_task_title'), style: label),
                const SizedBox(height: 4),
                Text(
                  task.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontSize: 19,
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
                      final here = tab.id == task.tabId;
                      return _TabOption(
                        tab: tab,
                        disabled: here,
                        onTap: here
                            ? null
                            : () async {
                          Navigator.pop(context);
                          await vm.moveTask(task.id, tab.id);
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
  const _TabOption({required this.tab, required this.disabled, this.onTap});

  final TaskTab tab;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: c.field,
          border: Border.all(color: c.edge),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                tab.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontSize: 19,
                  color: disabled ? c.inkFaint : c.ink,
                ),
              ),
            ),
            if (disabled)
              Text(
                t.t('move_task_here'),
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontSize: 15,
                  color: c.inkFaint,
                ),
              )
            else
              Icon(Icons.chevron_right, size: 18, color: c.inkDim),
          ],
        ),
      ),
    );
  }
}