import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task.dart';

/// Tira de tarea con su LED indicador.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.edge),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: task.done
              ? const [Color(0xFF17190F), Color(0xFF121409)]
              : const [Color(0xFF1E2117), Color(0xFF15170F)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _Led(on: task.done, onTap: onToggle),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.text,
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 21,
                height: 1.1,
                color: task.done ? AppColors.inkDim : AppColors.ink,
                decoration:
                task.done ? TextDecoration.lineThrough : TextDecoration.none,
                decorationColor: AppColors.inkDim,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 18, color: AppColors.inkFaint),
            ),
          ),
        ],
      ),
    );
  }
}

class _Led extends StatelessWidget {
  const _Led({required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: on ? AppColors.greenDark : const Color(0xFF3B402F),
          ),
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: on
                ? const [AppColors.greenLight, AppColors.greenDark]
                : const [Color(0xFF343A2B), Color(0xFF1B1E15)],
          ),
          boxShadow: on
              ? const [BoxShadow(color: AppColors.glow, blurRadius: 13)]
              : const [],
        ),
      ),
    );
  }
}