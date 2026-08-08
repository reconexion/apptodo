import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../viewmodels/tasks_view_model.dart';
import '../widgets/add_task_row.dart';
import '../widgets/chassis.dart';
import '../widgets/panel_display.dart';
import '../widgets/panel_plate.dart';
import '../widgets/search_bar_row.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/task_tile.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TasksViewModel>();
    final visible = vm.visibleTasks;

    return Scaffold(
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
                    PanelDisplay(
                      pending: vm.pending,
                      doneCount: vm.doneCount,
                      total: vm.tasks.length,
                      progress: vm.progress,
                    ),
                    const SizedBox(height: 14),
                    AddTaskRow(onSubmit: vm.add),
                    const SizedBox(height: 10),
                    SearchBarRow(
                      onChanged: vm.search,
                      onClear: vm.clearSearch,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('REGISTRO', style: _labelStyle),
                        if (vm.searching)
                          Text(
                            '${visible.length} DE ${vm.tasks.length}',
                            style: _labelStyle,
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
                    const _Footer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _labelStyle = TextStyle(
  fontFamily: AppFonts.display,
  fontSize: 9,
  fontWeight: FontWeight.w800,
  letterSpacing: 3.2,
  color: Color(0xFF6F7C56),
);

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.searching});

  final bool searching;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.edge),
        ),
        child: Column(
          children: [
            Text(
              searching ? 'sin coincidencias' : 'sin registros',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 20,
                height: 1.0,
                color: Color(0xFF8FA070),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              searching ? 'prueba con otra palabra' : 'sistema en reposo',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 16,
                height: 1.0,
                color: Color(0xFF5F6A4A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: AppFonts.display,
      fontSize: 9,
      fontWeight: FontWeight.w600,
      letterSpacing: 2.2,
      color: Color(0xFF6A7654),
    );

    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        ],
      ),
    );
  }
}