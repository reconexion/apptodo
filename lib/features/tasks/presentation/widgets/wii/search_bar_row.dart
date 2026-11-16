import 'package:flutter/material.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/theme/app_theme.dart';
import 'pill_field.dart';

/// Barra de busqueda en pastilla, con lupa y boton de limpiar.
class SearchBarRow extends StatefulWidget {
  const SearchBarRow({
    super.key,
    required this.onChanged,
    required this.onClear,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<SearchBarRow> createState() => _SearchBarRowState();
}

class _SearchBarRowState extends State<SearchBarRow> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onClear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;

    final textStyle = TextStyle(
      fontFamily: AppFonts.mono,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: c.ink,
    );

    return PillField(
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: textStyle,
        cursorColor: c.accent,
        textInputAction: TextInputAction.search,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: t.t('search_placeholder'),
          hintStyle: textStyle.copyWith(color: c.inkFaint),
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          prefixIcon: Icon(Icons.search_rounded, size: 22, color: c.inkFaint),
          prefixIconConstraints: const BoxConstraints(minWidth: 46),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: _clear,
                  behavior: HitTestBehavior.opaque,
                  child: Icon(
                    Icons.cancel_rounded,
                    size: 20,
                    color: c.inkFaint,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 42),
        ),
      ),
    );
  }
}
