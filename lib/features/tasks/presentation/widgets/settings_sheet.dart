import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../viewmodels/tasks_view_model.dart';
import 'push_button.dart';

/// Abre el panel de configuracion desde abajo.
Future<void> showSettingsSheet(BuildContext context, TasksViewModel vm) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => SettingsSheet(vm: vm),
  );
}

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key, required this.vm});

  final TasksViewModel vm;

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  final TextEditingController _importController = TextEditingController();

  String _backup = '';
  String _message = '';
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadBackup();
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _loadBackup() async {
    final text = await widget.vm.buildBackup();
    if (!mounted) return;
    setState(() => _backup = text);
  }

  void _say(String text, {bool error = false}) {
    setState(() {
      _message = text;
      _error = error;
    });
  }

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
    _say('texto pegado, revisalo y presiona importar');
  }

  Future<void> _import() async {
    final raw = _importController.text.trim();
    if (raw.isEmpty) {
      _say('pega primero un respaldo', error: true);
      return;
    }

    final confirmed = await _confirm();
    if (confirmed != true) return;

    try {
      final count = await widget.vm.restoreBackup(raw);
      if (!mounted) return;
      _importController.clear();
      await _loadBackup();
      _say('$count tareas importadas');
    } on FormatException {
      _say('el texto no tiene tareas validas', error: true);
    }
  }

  Future<bool?> _confirm() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.edge),
        ),
        title: const Text(
          'reemplazar todo',
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontSize: 22,
            color: AppColors.ink,
          ),
        ),
        content: const Text(
          'esto borra las tareas actuales y deja solo las del respaldo. '
              'no se puede deshacer.',
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontSize: 18,
            height: 1.2,
            color: AppColors.inkDim,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'cancelar',
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 18,
                color: AppColors.inkDim,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'importar',
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 18,
                color: AppColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          border: Border(
            top: BorderSide(color: AppColors.edge),
            left: BorderSide(color: AppColors.edge),
            right: BorderSide(color: AppColors.edge),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.panelLight, AppColors.panelDark],
          ),
        ),
        child: SafeArea(
          top: false,
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
                      color: AppColors.edge,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CONFIGURACION', style: _label),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.inkFaint,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ---------- exportar ----------
                const Text('EXPORTAR', style: _label),
                const SizedBox(height: 6),
                const Text(
                  'los [x] son las marcadas y los [ ] las pendientes.',
                  style: _hint,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 160),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F110A),
                    border: Border.all(color: AppColors.edge),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _backup.isEmpty ? '...' : _backup,
                      style: const TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 16,
                        height: 1.25,
                        color: AppColors.green,
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
                const Divider(color: AppColors.edge, height: 1),
                const SizedBox(height: 22),

                // ---------- importar ----------
                const Text('IMPORTAR', style: _label),
                const SizedBox(height: 6),
                const Text(
                  'reemplaza toda la lista con lo que pegues aqui.',
                  style: _hint,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _importController,
                  maxLines: 5,
                  style: const TextStyle(
                    fontFamily: AppFonts.mono,
                    fontSize: 16,
                    height: 1.25,
                    color: AppColors.ink,
                  ),
                  cursorColor: AppColors.green,
                  decoration: InputDecoration(
                    hintText: '[ ] pega aqui tu respaldo',
                    hintStyle: const TextStyle(
                      fontFamily: AppFonts.mono,
                      fontSize: 16,
                      color: Color(0xFF5B6448),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0F110A),
                    contentPadding: const EdgeInsets.all(12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: AppColors.edge),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: AppColors.greenDark),
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
                        child: PushButton(
                          label: 'IMPORTAR',
                          onPressed: _import,
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
                      color: _error ? AppColors.danger : AppColors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _label = TextStyle(
  fontFamily: AppFonts.display,
  fontSize: 9,
  fontWeight: FontWeight.w800,
  letterSpacing: 3.2,
  color: Color(0xFF6F7C56),
);

const _hint = TextStyle(
  fontFamily: AppFonts.mono,
  fontSize: 16,
  height: 1.1,
  color: AppColors.inkDim,
);

/// Boton secundario, sin relleno verde.
class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.edge),
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF15170F),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: AppColors.engrave,
          ),
        ),
      ),
    );
  }
}