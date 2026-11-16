import 'package:flutter/material.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/theme/app_theme.dart';
import 'pill_field.dart';
import 'push_button.dart';

/// Campo de captura en pastilla + boton Anadir, ambos de la misma altura.
class AddTaskRow extends StatefulWidget {
  const AddTaskRow({super.key, required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<AddTaskRow> createState() => _AddTaskRowState();
}

class _AddTaskRowState extends State<AddTaskRow> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;

    final textStyle = TextStyle(
      fontFamily: AppFonts.mono,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: c.ink,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PillField(
              child: TextField(
                controller: _controller,
                style: textStyle,
                cursorColor: c.accent,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: t.t('add_placeholder'),
                  hintStyle: textStyle.copyWith(color: c.inkFaint),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(0, 15, 16, 15),
                  prefixIcon: Icon(
                    Icons.edit_rounded,
                    size: 22,
                    color: c.inkFaint,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 48),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          PushButton(
            label: t.t('add_button'),
            icon: Icons.add_rounded,
            spinIcon: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
