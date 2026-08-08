import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'push_button.dart';

/// Campo de captura + boton fisico, ambos de la misma altura.
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
    const textStyle = TextStyle(
      fontFamily: AppFonts.mono,
      fontSize: 20,
      color: AppColors.ink,
    );

    return SizedBox(
      height: 52,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: textStyle,
              cursorColor: AppColors.green,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'nueva tarea...',
                hintStyle: textStyle.copyWith(color: const Color(0xFF6B7554)),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFF171A11),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.edge),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.greenDark),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          PushButton(label: 'AÑADIR', onPressed: _submit),
        ],
      ),
    );
  }
}