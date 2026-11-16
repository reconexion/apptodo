import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../missions/presentation/widgets/mission_celebration.dart';
import 'retro_tasks_page.dart';
import 'wii_tasks_page.dart';

/// Elige la pantalla segun el estilo del tema activo.
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.palette.style;

    return MissionCelebrationHost(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: style == UiStyle.wii
            ? const WiiTasksPage(key: ValueKey('wii'))
            : const RetroTasksPage(key: ValueKey('retro')),
      ),
    );
  }
}
