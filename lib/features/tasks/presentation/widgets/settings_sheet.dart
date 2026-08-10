import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../domain/entities/task_tab.dart';
import '../viewmodels/tasks_view_model.dart';
import 'hold_button.dart';
import 'push_button.dart';

/// Abre el panel de configuracion desde abajo.
Future<void> showSettingsSheet(BuildContext context, TasksViewModel vm) {
  final theme = context.read<ThemeController>();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>.value(value: theme),
        ChangeNotifierProvider<TasksViewModel>.value(value: vm),
      ],
      child: const SettingsSheet(),
    ),
  );
}

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  final TextEditingController _importController = TextEditingController();
  final TextEditingController _newTabController = TextEditingController();

  String _backup = '';
  String _message = '';
  bool _error = false;

  TasksViewModel get _vm => context.read<TasksViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBackup());
  }

  @override
  void dispose() {
    _importController.dispose();
    _newTabController.dispose();
    super.dispose();
  }

  Future<void> _loadBackup() async {
    final text = await _vm.buildBackup();
    if (!mounted) return;
    setState(() => _backup = text);
  }

  void _say(String text, {bool error = false}) {
    setState(() {
      _message = text;
      _error = error;
    });
  }

  // ---------- pestanas ----------

  Future<void> _createTab() async {
    final name = _newTabController.text.trim();
    if (name.isEmpty) {
      _say('escribe un nombre para la pestaña', error: true);
      return;
    }
    await _vm.createTab(name);
    if (!mounted) return;
    _newTabController.clear();
    await _loadBackup();
    _say('pestaña "$name" creada');
  }

  Future<void> _renameTab(TaskTab tab, String name) async {
    final clean = name.trim();
    if (clean.isEmpty || clean == tab.name) return;
    await _vm.rename(tab.id, clean);
    if (!mounted) return;
    await _loadBackup();
    _say('renombrada a "$clean"');
  }

  Future<void> _deleteTab(TaskTab tab) async {
    await _vm.removeTab(tab.id);
    if (!mounted) return;
    await _loadBackup();
    _say('pestaña "${tab.name}" eliminada');
  }

  // ---------- respaldo ----------

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _backup));
    _say('respaldo copiado al portapapeles');
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (text.isEmpty) {
      _say('el portapapeles esta vacio', error: true);
      return;
    }
    _importController.text = text;
    _say('texto pegado, manten presionado para importar');
  }

  Future<void> _import() async {
    final raw = _importController.text.trim();
    if (raw.isEmpty) {
      _say('pega primero un respaldo', error: true);
      return;
    }
    try {
      final count = await _vm.restoreBackup(raw);
      if (!mounted) return;
      _importController.clear();
      await _loadBackup();
      _say('$count tareas importadas');
    } on FormatException {
      _say('el texto no tiene tareas validas', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final vm = context.watch<TasksViewModel>();
    final themeCtrl = context.watch<ThemeController>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final label = TextStyle(
      fontFamily: AppFonts.display,
      fontSize: 9,
      fontWeight: FontWeight.w800,
      letterSpacing: 3.2,
      color: c.engrave,
    );
    final hint = TextStyle(
      fontFamily: AppFonts.mono,
      fontSize: 16,
      height: 1.1,
      color: c.inkDim,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
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
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CONFIGURACION', style: label),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child:
                          Icon(Icons.close, size: 18, color: c.inkFaint),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ---------- tema ----------
                  Text('TEMA', style: label),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final p in themeCtrl.available) ...[
                        Expanded(
                          child: _ThemeChip(
                            palette: p,
                            selected: p.id == themeCtrl.palette.id,
                            onTap: () => themeCtrl.select(p),
                          ),
                        ),
                        if (p != themeCtrl.available.last)
                          const SizedBox(width: 10),
                      ],
                    ],
                  ),

                  const SizedBox(height: 22),
                  Divider(color: c.edge, height: 1),
                  const SizedBox(height: 22),

                  // ---------- pestanas ----------
                  Text('PESTAÑAS', style: label),
                  const SizedBox(height: 6),
                  Text(
                    'toca el nombre para editarlo. crear y eliminar '
                        'necesitan mantener presionado.',
                    style: hint,
                  ),
                  const SizedBox(height: 10),

                  for (final tab in vm.tabs) ...[
                    _TabRow(
                      key: ValueKey('${tab.id}:${tab.name}'),
                      tab: tab,
                      taskCount:
                      vm.tasks.where((t) => t.tabId == tab.id).length,
                      canDelete: vm.tabs.length > 1,
                      onRename: (name) => _renameTab(tab, name),
                      onDelete: () => _deleteTab(tab),
                    ),
                    const SizedBox(height: 8),
                  ],

                  const SizedBox(height: 4),
                  SizedBox(
                    height: 46,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newTabController,
                            maxLength: 18,
                            textCapitalization: TextCapitalization.characters,
                            style: TextStyle(
                              fontFamily: AppFonts.mono,
                              fontSize: 19,
                              color: c.ink,
                            ),
                            cursorColor: c.accent,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: 'nueva pestaña',
                              counterText: '',
                              isDense: true,
                              hintStyle: TextStyle(
                                fontFamily: AppFonts.mono,
                                fontSize: 19,
                                color: c.inkFaint,
                              ),
                              filled: true,
                              fillColor: c.fieldDeep,
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: c.edge),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: c.accentDark),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 150,
                          child: HoldButton(
                            label: 'MANTÉN P/ CREAR',
                            onComplete: _createTab,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  Divider(color: c.edge, height: 1),
                  const SizedBox(height: 22),

                  // ---------- exportar ----------
                  Text('EXPORTAR', style: label),
                  const SizedBox(height: 6),
                  Text(
                    'los [x] son las marcadas y los [ ] las pendientes. '
                        'cada ## abre una pestaña.',
                    style: hint,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 150),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.glass,
                      border: Border.all(color: c.glassEdge),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _backup.isEmpty ? '...' : _backup,
                        style: TextStyle(
                          fontFamily: AppFonts.mono,
                          fontSize: 16,
                          height: 1.25,
                          color: c.displayInk,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 46,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: PushButton(label: 'COPIAR', onPressed: _copy),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  Divider(color: c.edge, height: 1),
                  const SizedBox(height: 22),

                  // ---------- importar ----------
                  Text('IMPORTAR', style: label),
                  const SizedBox(height: 6),
                  Text(
                    'reemplaza pestañas y tareas con lo que pegues aqui.',
                    style: hint,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _importController,
                    maxLines: 5,
                    style: TextStyle(
                      fontFamily: AppFonts.mono,
                      fontSize: 16,
                      height: 1.25,
                      color: c.ink,
                    ),
                    cursorColor: c.accent,
                    decoration: InputDecoration(
                      hintText: '[ ] pega aqui tu respaldo',
                      hintStyle: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 16,
                        color: c.inkFaint,
                      ),
                      filled: true,
                      fillColor: c.fieldDeep,
                      contentPadding: const EdgeInsets.all(12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide(color: c.edge),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide(color: c.accentDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 46,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _GhostButton(label: 'PEGAR', onTap: _paste),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: HoldButton(
                            label: 'MANTÉN P/ IMPORTAR',
                            danger: true,
                            onComplete: _import,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_message.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      _message,
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 17,
                        color: _error ? c.danger : c.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Muestra del tema con sus tres colores principales.
class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? c.chipActive : c.chipIdle,
          border: Border.all(color: selected ? c.accent : c.edge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Swatch(color: palette.panel),
                const SizedBox(width: 4),
                _Swatch(color: palette.glass),
                const SizedBox(width: 4),
                _Swatch(color: palette.accent),
                const Spacer(),
                if (selected)
                  Icon(Icons.check, size: 14, color: c.accent),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              palette.label,
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 19,
                height: 1.0,
                color: selected ? c.accent : c.inkDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.palette.edge),
      ),
    );
  }
}

/// Renglon de una pestana: nombre editable + seguro para eliminar.
class _TabRow extends StatefulWidget {
  const _TabRow({
    super.key,
    required this.tab,
    required this.taskCount,
    required this.canDelete,
    required this.onRename,
    required this.onDelete,
  });

  final TaskTab tab;
  final int taskCount;
  final bool canDelete;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;

  @override
  State<_TabRow> createState() => _TabRowState();
}

class _TabRowState extends State<_TabRow> {
  late final TextEditingController _controller =
  TextEditingController(text: widget.tab.name);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return SizedBox(
      height: 44,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLength: 18,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onSubmitted: widget.onRename,
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
                widget.onRename(_controller.text);
              },
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 19,
                color: c.ink,
              ),
              cursorColor: c.accent,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                counterText: '',
                isDense: true,
                filled: true,
                fillColor: c.field,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                suffixText: '${widget.taskCount}',
                suffixStyle: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontSize: 16,
                  color: c.inkFaint,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: c.edge),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: c.accentDark),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: HoldButton(
              label: widget.canDelete ? 'MANTÉN P/ BORRAR' : 'ÚNICA PESTAÑA',
              danger: true,
              compact: true,
              enabled: widget.canDelete,
              onComplete: widget.onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

/// Boton secundario, sin relleno de acento.
class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: c.edge),
          borderRadius: BorderRadius.circular(10),
          color: c.field,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: c.engrave,
          ),
        ),
      ),
    );
  }
}