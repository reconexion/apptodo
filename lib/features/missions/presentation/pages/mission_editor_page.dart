import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/viewmodels/tasks_view_model.dart';
import '../../../tasks/presentation/widgets/hold_button.dart';
import '../viewmodels/missions_view_model.dart';
import '../widgets/mission_ui.dart';

/// Abre el editor. Sin [missionId] crea una mision nueva.
Future<void> openMissionEditor(BuildContext context, {int? missionId}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, _, _) => MissionEditorPage(missionId: missionId),
      transitionsBuilder: (_, anim, _, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

class MissionEditorPage extends StatefulWidget {
  const MissionEditorPage({super.key, this.missionId});

  final int? missionId;

  @override
  State<MissionEditorPage> createState() => _MissionEditorPageState();
}

class _MissionEditorPageState extends State<MissionEditorPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _search = TextEditingController();
  Set<int> _selected = {};
  String _query = '';
  String _message = '';

  bool get _editing => widget.missionId != null;

  @override
  void initState() {
    super.initState();
    final id = widget.missionId;
    if (id != null) {
      final m = context.read<MissionsViewModel>().byId(id)?.mission;
      if (m != null) {
        _title.text = m.title;
        _desc.text = m.description;
        _selected = {...m.taskIds};
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.t;
    if (_title.text.trim().isEmpty) {
      setState(() => _message = t.t('msg_mission_needs_title'));
      return;
    }
    if (_selected.isEmpty) {
      setState(() => _message = t.t('msg_mission_needs_tasks'));
      return;
    }
    await context.read<MissionsViewModel>().save(
      id: widget.missionId ?? 0,
      title: _title.text,
      description: _desc.text,
      taskIds: _selected,
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final id = widget.missionId;
    if (id == null) return;
    await context.read<MissionsViewModel>().remove(id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;
    final tasksVm = context.watch<TasksViewModel>();
    final wii = isWii(context);

    final q = _query.toLowerCase();
    final tasks = tasksVm.tasks
        .where((task) => q.isEmpty || task.text.toLowerCase().contains(q))
        .toList();
    final tabNames = {for (final tab in tasksVm.tabs) tab.id: tab.name};

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.panelLight, c.panel, c.panelDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 18, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: c.inkDim,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              t.t(
                                _editing
                                    ? 'mission_editor_edit'
                                    : 'mission_editor_new',
                              ),
                              style: missionLabel(
                                c,
                              ).copyWith(fontSize: AppFonts.ds(11)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                    sliver: SliverList.list(
                      children: [
                        Text(
                          t.t('mission_title_label'),
                          style: missionLabel(c),
                        ),
                        const SizedBox(height: 6),
                        _Field(
                          controller: _title,
                          hint: t.t('mission_title_placeholder'),
                          size: 21,
                          maxLength: 40,
                          onChanged: (_) => setState(() => _message = ''),
                        ),
                        const SizedBox(height: 16),
                        Text(t.t('mission_desc_label'), style: missionLabel(c)),
                        const SizedBox(height: 6),
                        _Field(
                          controller: _desc,
                          hint: t.t('mission_desc_placeholder'),
                          size: 18,
                          maxLines: 4,
                          maxLength: 240,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.t('mission_tasks_label'),
                                style: missionLabel(c),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (child, a) =>
                                  ScaleTransition(scale: a, child: child),
                              child: Text(
                                t.t('mission_tasks_count', {
                                  'count': _selected.length,
                                }),
                                key: ValueKey(_selected.length),
                                style: missionLabel(
                                  c,
                                ).copyWith(color: c.accent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (tasksVm.tasks.length > 6) ...[
                          _Field(
                            controller: _search,
                            hint: t.t('mission_tasks_search'),
                            size: 17,
                            icon: Icons.search_rounded,
                            onChanged: (v) => setState(() => _query = v),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (tasksVm.tasks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              t.t('mission_no_tasks'),
                              style: missionText(c, 16, color: c.inkFaint),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                    sliver: SliverList.separated(
                      itemCount: tasks.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, i) {
                        final task = tasks[i];
                        return _TaskOption(
                          task: task,
                          tabs: [
                            for (final id in task.tabIds)
                              if (tabNames[id] != null) tabNames[id]!,
                          ],
                          selected: _selected.contains(task.id),
                          onTap: () => setState(() {
                            _message = '';
                            if (!_selected.remove(task.id)) {
                              _selected.add(task.id);
                            }
                          }),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                    sliver: SliverList.list(
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: _message.isEmpty
                              ? const SizedBox(width: double.infinity)
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    _message,
                                    textAlign: TextAlign.center,
                                    style: missionText(c, 16, color: c.danger),
                                  ),
                                ),
                        ),
                        MissionButton(
                          label: t.t('mission_save'),
                          icon: Icons.check_rounded,
                          onTap: _save,
                        ),
                        if (_editing) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: wii ? 50 : 46,
                            child: HoldButton(
                              label: t.t('mission_hold_delete'),
                              confirmLabel: t.t('settings_hold_confirm'),
                              danger: true,
                              duration: const Duration(seconds: 2),
                              onComplete: _delete,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.size,
    this.maxLines = 1,
    this.maxLength,
    this.icon,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final double size;
  final int maxLines;
  final int? maxLength;
  final IconData? icon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final wii = c.style == UiStyle.wii;
    final radius = BorderRadius.circular(wii ? 22 : 10);
    final style = missionText(c, size);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: 1,
      maxLength: maxLength,
      onChanged: onChanged,
      style: style,
      cursorColor: c.accent,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: style.copyWith(color: c.inkFaint),
        counterText: '',
        isDense: true,
        filled: true,
        fillColor: c.field,
        prefixIcon: icon == null ? null : Icon(icon, color: c.inkFaint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: c.edge, width: wii ? 1.4 : 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: wii ? c.accentLight : c.accentDark,
            width: wii ? 2 : 1,
          ),
        ),
      ),
    );
  }
}

class _TaskOption extends StatelessWidget {
  const _TaskOption({
    required this.task,
    required this.tabs,
    required this.selected,
    required this.onTap,
  });

  final Task task;
  final List<String> tabs;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final wii = c.style == UiStyle.wii;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(wii ? 16 : 10),
          color: selected ? c.chipActive : c.field,
          border: Border.all(
            color: selected ? (wii ? c.accentLight : c.accentDark) : c.edge,
            width: selected && wii ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, a) => ScaleTransition(
                scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                child: child,
              ),
              child: Icon(
                selected
                    ? (wii ? Icons.check_box_rounded : Icons.check_box)
                    : (wii
                          ? Icons.check_box_outline_blank_rounded
                          : Icons.check_box_outline_blank),
                key: ValueKey(selected),
                size: 24,
                color: selected ? c.accent : c.inkFaint,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.text,
                    style:
                        missionText(
                          c,
                          18,
                          color: task.done ? c.inkFaint : c.ink,
                        ).copyWith(
                          decoration: task.done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: c.inkFaint,
                        ),
                  ),
                  if (tabs.isNotEmpty)
                    Text(
                      tabs.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: missionText(c, 14, color: c.inkFaint),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
