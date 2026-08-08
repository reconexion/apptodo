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
    const textStyle = TextStyle(
      fontFamily: AppFonts.mono,
      fontSize: 18,
      color: AppColors.ink,
    );

    return SizedBox(
      height: 42,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: textStyle,
        cursorColor: AppColors.green,
        textInputAction: TextInputAction.search,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'buscar...',
          hintStyle: textStyle.copyWith(color: const Color(0xFF5B6448)),
          isDense: true,
          filled: true,
          fillColor: const Color(0xFF0F110A),
          contentPadding: EdgeInsets.zero,
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: Color(0xFF6C7A52),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 38,
            minHeight: 38,
          ),
          suffixIcon: _hasText
              ? GestureDetector(
            onTap: _clear,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.inkFaint,
            ),
          )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 34,
            minHeight: 34,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0xFF262B1D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: AppColors.greenDark),
          ),
        ),
      ),
    );
  }
}