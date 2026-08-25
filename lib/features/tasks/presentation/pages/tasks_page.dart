import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../viewmodels/tasks_view_model.dart';
import '../widgets/add_task_row.dart';
import '../widgets/chassis.dart';
import '../widgets/panel_display.dart';
import '../widgets/panel_plate.dart';
import '../widgets/search_bar_row.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/tab_strip.dart';
import '../widgets/task_tabs_sheet.dart';
import '../widgets/task_tile.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;
    final vm = context.watch<TasksViewModel>();
    final visible = vm.visibleTasks;

    final labelStyle = TextStyle(
      fontFamily: AppFonts.display,
      fontSize: 9,
      fontWeight: FontWeight.w800,
      letterSpacing: 3.2,
      color: c.engrave,
    );

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
                      PanelDisplay(
                        pending: vm.pending,
                        doneCount: vm.doneCount,
                        total: vm.tasks.length,
                        progress: vm.progress,
                        kaomoji: vm.kaomoji,
                      ),
                      const SizedBox(height: 12),

                      if (vm.hasTabs) ...[
                        TabStrip(
                          tabs: vm.tabs,
                          activeId: vm.activeTabId,
                          pendingOf: vm.pendingIn,
                          onSelect: vm.selectTab,
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (vm.canAddTask) ...[
                        AddTaskRow(onSubmit: vm.add),
                        const SizedBox(height: 10),
                      ],

                      if (vm.hasTabs) ...[
                        SearchBarRow(
                          key: ValueKey(vm.activeTabId),
                          onChanged: vm.search,
                          onClear: vm.clearSearch,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${t.t('log_label')}'
                                    '${vm.activeTab != null ? ' · ${vm.activeTab!.name}' : ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: labelStyle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              vm.searching
                                  ? t.t('log_of_label', {
                                'visible': visible.length,
                                'total': vm.tabTasks.length,
                              })
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
                            padding:
                            const EdgeInsets.only(bottom: 8),
                            itemCount: visible.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final task = visible[index];
                              return TaskTile(
                                task: task,
                                tabs: vm.tabs,
                                showTabChips:
                                vm.isAllSelected || task.tabIds.length > 1,
                                onToggle: () => vm.toggle(task.id),
                                onDelete: () => vm.remove(task.id),
                                onLongPress: () =>
                                    showTaskTabsSheet(
                                      context,
                                      vm,
                                      task,
                                    ),
                              );
                            },
                          ),
                        ),
                      ] else
                        Expanded(
                          child: _NoTabsState(
                            onOpenSettings: () =>
                                showSettingsSheet(context, vm),
                          ),
                        ),
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

class _NoTabsState extends StatelessWidget {
  const _NoTabsState({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.edge),
            ),
            child: Column(
              children: [
                Text(
                  t.t('no_tabs_title'),
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
                  t.t('no_tabs_subtitle'),
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
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onOpenSettings,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: c.accent,
                border: Border.all(color: c.accentDark),
              ),
              child: Text(
                t.t('no_tabs_open_settings'),
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: c.onAccent,
                ),
              ),
            ),
          ),
        ],
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
    final t = context.t;

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
              searching ? t.t('empty_search_title') : t.t('empty_tab_title'),
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
              searching
                  ? t.t('empty_search_subtitle')
                  : t.t('empty_tab_subtitle'),
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