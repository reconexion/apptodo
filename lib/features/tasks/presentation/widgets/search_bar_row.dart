import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Barra de busqueda: ranura hundida con lupa y boton de limpiar.
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

    final textStyle = TextStyle(
      fontFamily: AppFonts.mono,
      fontSize: 18,
      color: c.ink,
    );

    return SizedBox(
      height: 42,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: textStyle,
        cursorColor: c.accent,
        textInputAction: TextInputAction.search,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'buscar...',
          hintStyle: textStyle.copyWith(color: c.inkFaint),
          isDense: true,
          filled: true,
          fillColor: c.fieldDeep,
          contentPadding: EdgeInsets.zero,
          prefixIcon: Icon(Icons.search, size: 18, color: c.inkFaint),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 38,
            minHeight: 38,
          ),
          suffixIcon: _hasText
              ? GestureDetector(
            onTap: _clear,
            behavior: HitTestBehavior.opaque,
            child: Icon(Icons.close, size: 16, color: c.inkFaint),
          )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 34,
            minHeight: 34,
          ),
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
    );
  }
}