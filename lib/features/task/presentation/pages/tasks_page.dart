import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../viewmodels/tasks_view_model.dart';
import '../widgets/add_task_row.dart';
import '../widgets/chassis.dart';
import '../widgets/panel_display.dart';
import '../widgets/panel_plate.dart';
import '../widgets/task_tile.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TasksViewModel>();

    return Scaffold(
      body: Chassis(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PanelPlate(
                      muted: vm.muted,
                      onToggleSound: vm.toggleMute,
                    ),
                    const SizedBox(height: 12),
                    PanelDisplay(
                      pending: vm.pending,
                      doneCount: vm.doneCount,
                      total: vm.tasks.length,
                      progress: vm.progress,
                    ),
                    const SizedBox(height: 18),
                    AddTaskRow(onSubmit: vm.add),
                    const SizedBox(height: 18),
                    const Text(
                      'REGISTRO',
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.2,
                        color: Color(0xFF6F7C56),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: vm.loading
                          ? const SizedBox.shrink()
                          : vm.tasks.isEmpty
                          ? const _EmptyState()
                          : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: vm.tasks.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final task = vm.tasks[index];
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 34),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.edge),
        ),
        child: const Text(
          'sin registros - sistema en reposo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontSize: 20,
            color: Color(0xFF6B7554),
          ),
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
      padding: EdgeInsets.only(top: 12),
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