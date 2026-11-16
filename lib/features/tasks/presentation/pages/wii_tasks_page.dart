import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/gloss.dart';
import '../../../missions/presentation/widgets/missions_entry.dart';
import '../viewmodels/tasks_view_model.dart';
import '../widgets/wii/add_task_row.dart';
import '../widgets/wii/chassis.dart';
import '../widgets/wii/panel_display.dart';
import '../widgets/wii/panel_plate.dart';
import '../widgets/wii/search_bar_row.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/wii/tab_strip.dart';
import '../widgets/task_tabs_sheet.dart';
import '../widgets/wii/task_tile.dart';

/// Estilo menu de consola: piezas plateadas brillantes y animaciones.
class WiiTasksPage extends StatelessWidget {
  const WiiTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;
    final vm = context.watch<TasksViewModel>();
    final visible = vm.visibleTasks;

    final labelStyle = TextStyle(
      fontFamily: AppFonts.display,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: c.engrave,
    );

    final overlay = c.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    final header = <Widget>[
      PanelPlate(
        muted: vm.muted,
        onToggleSound: vm.toggleMute,
        onOpenSettings: () => showSettingsSheet(context, vm),
      ),
      PanelDisplay(
        pending: vm.pending,
        doneCount: vm.doneCount,
        total: vm.tasks.length,
        progress: vm.progress,
        kaomoji: vm.kaomoji,
      ),
      const MissionsEntry(),
      if (vm.hasTabs)
        TabStrip(
          tabs: vm.tabs,
          activeId: vm.activeTabId,
          pendingOf: vm.pendingIn,
          onSelect: vm.selectTab,
        ),
      if (vm.canAddTask) AddTaskRow(onSubmit: vm.add),
      if (vm.hasTabs)
        SearchBarRow(
          key: ValueKey(vm.activeTabId),
          onChanged: vm.search,
          onClear: vm.clearSearch,
        ),
      if (vm.hasTabs)
        Gloss(
          radius: 16,
          top: c.tileBottom,
          bottom: c.tileDoneBottom,
          elevated: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [...previous, ?current],
                  ),
                  child: Text(
                    '${t.t('log_label')}'
                    '${vm.activeTab != null ? ' · ${vm.activeTab!.name}' : ''}',
                    key: ValueKey(vm.activeTabId),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: labelStyle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOutBack,
                  ),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  vm.searching
                      ? t.t('log_of_label', {
                          'visible': visible.length,
                          'total': vm.tabTasks.length,
                        })
                      : '${vm.tabTasks.length}',
                  key: ValueKey(
                    '${vm.searching}-${visible.length}-${vm.tabTasks.length}',
                  ),
                  style: labelStyle,
                ),
              ),
            ],
          ),
        ),
    ];

    // Todo va en un solo scroll: asi nada se desborda al abrir el teclado
    // ni en pantallas chicas o con letra grande.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: Chassis(
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      sliver: SliverList.separated(
                        itemCount: header.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => Entrance(
                          delay: Entrance.stagger(i, stepMs: 70),
                          child: header[i],
                        ),
                      ),
                    ),
                    if (!vm.hasTabs)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _NoTabsState(
                            onOpenSettings: () =>
                                showSettingsSheet(context, vm),
                          ),
                        ),
                      )
                    else if (vm.loading)
                      const SliverToBoxAdapter(child: SizedBox.shrink())
                    else if (visible.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                        sliver: SliverToBoxAdapter(
                          child: Entrance(
                            key: ValueKey('empty-${vm.activeTabId}'),
                            child: _EmptyState(searching: vm.searching),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          10,
                          24,
                          16 + MediaQuery.paddingOf(context).bottom,
                        ),
                        sliver: SliverList.separated(
                          itemCount: visible.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final task = visible[index];
                            // La clave incluye la pestana: al cambiar de
                            // pestana las tarjetas vuelven a entrar escalonadas.
                            return Entrance(
                              key: ValueKey('${vm.activeTabId}-${task.id}'),
                              delay: Entrance.stagger(index),
                              child: TaskTile(
                                task: task,
                                tabs: vm.tabs,
                                showTabChips:
                                    vm.isAllSelected || task.tabIds.length > 1,
                                onToggle: () => vm.toggle(task.id),
                                onDelete: () => vm.remove(task.id),
                                onLongPress: () =>
                                    showTaskTabsSheet(context, vm, task),
                              ),
                            );
                          },
                        ),
                      ),
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
          _Float(
            child: Gloss(
              radius: 22,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.t('no_tabs_title'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.mono,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: c.inkDim,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.t('no_tabs_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.mono,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: c.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Pressable(
            onTap: onOpenSettings,
            child: Gloss(
              radius: 24,
              top: c.accentLight,
              bottom: c.accent,
              border: c.accentDark,
              glow: c.halo,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              child: Text(
                t.t('no_tabs_open_settings'),
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
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

    return _Float(
      child: Gloss(
        radius: 22,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              searching ? t.t('empty_search_title') : t.t('empty_tab_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.2,
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: c.inkFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Flota suavemente arriba y abajo.
class _Float extends StatefulWidget {
  const _Float({required this.child});

  final Widget child;

  @override
  State<_Float> createState() => _FloatState();
}

class _FloatState extends State<_Float> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    motionOff(context) ? _c.stop() : _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, Curves.easeInOut.transform(_c.value) * -6),
        child: child,
      ),
      child: widget.child,
    );
  }
}
