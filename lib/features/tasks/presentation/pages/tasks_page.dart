import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../viewmodels/tasks_view_model.dart';
import '../widgets/add_task_row.dart';
import '../widgets/chassis.dart';
import '../widgets/panel_display.dart';
import '../widgets/panel_plate.dart';
import '../widgets/search_bar_row.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/tab_strip.dart';
import '../widgets/task_tile.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final vm = context.watch<TasksViewModel>();
    final visible = vm.visibleTasks;

    final labelStyle = TextStyle(
      fontFamily: AppFonts.display,
      fontSize: 9,
      fontWeight: FontWeight.w800,
      letterSpacing: 3.2,
      color: c.engrave,
    );

    // Los iconos de la barra de estado siguen al tema.
    final overlay = c.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: Chassis(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PanelPlate(
                        muted: vm.muted,
                        onToggleSound: vm.toggleMute,
                        onOpenSettings: () => showSettingsSheet(context, vm),
                      ),
                      const SizedBox(height: 10),
                      // El contador suma TODAS las pestanas.
                      PanelDisplay(
                        pending: vm.pending,
                        doneCount: vm.doneCount,
                        total: vm.tasks.length,
                        progress: vm.progress,
                      ),
                      const SizedBox(height: 12),
                      TabStrip(
                        tabs: vm.tabs,
                        activeId: vm.activeTabId,
                        pendingOf: vm.pendingIn,
                        onSelect: vm.selectTab,
                      ),
                      const SizedBox(height: 12),
                      AddTaskRow(onSubmit: vm.add),
                      const SizedBox(height: 10),
                      SearchBarRow(
                        key: ValueKey(vm.activeTabId),
                        onChanged: vm.search,
                        onClear: vm.clearSearch,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'REGISTRO · ${vm.activeTab?.name ?? ''}',
                            style: labelStyle,
                          ),
                          Text(
                            vm.searching
                                ? '${visible.length} DE ${vm.tabTasks.length}'
                                : '${vm.tabTasks.length}',
                            style: labelStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: vm.loading
                            ? const SizedBox.shrink()
                            : visible.isEmpty
                            ? _EmptyState(searching: vm.searching)
                            : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: visible.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final task = visible[index];
                            return TaskTile(
                              task: task,
                              onToggle: () => vm.toggle(task.id),
                              onDelete: () => vm.remove(task.id),
                            );
                          },
                        ),
                      ),
                      _Footer(style: labelStyle),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.searching});

  final bool searching;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.edge),
        ),
        child: Column(
          children: [
            Text(
              searching ? 'sin coincidencias' : 'pestaña vacía',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 20,
                height: 1.0,
                color: c.inkDim,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              searching ? 'prueba con otra palabra' : 'sistema en reposo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 16,
                height: 1.0,
                color: c.inkFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.style});

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('MOD. TD-01', style: style),
          Text('OFFLINE', style: style),
        ],
      ),
    );
  }
}