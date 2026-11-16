import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/gloss.dart';
import '../viewmodels/missions_view_model.dart';
import 'mission_ui.dart';
import 'missions_sheet.dart';

/// Acceso a misiones en la pantalla principal: resume cuantas hay y
/// muestra la mision activa mas avanzada con su barra.
class MissionsEntry extends StatelessWidget {
  const MissionsEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;
    final vm = context.watch<MissionsViewModel>();
    final wii = isWii(context);

    final active = vm.active..sort((a, b) => b.ratio.compareTo(a.ratio));
    final top = active.isEmpty ? null : active.first;

    final subtitle = !vm.hasMissions
        ? t.t('missions_entry_none')
        : t.t('missions_entry_summary', {
            'active': active.length,
            'done': vm.completedCount,
          });

    final icon = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: wii ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: wii ? null : BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.accentLight, c.accent, c.accentDark],
        ),
        border: Border.all(color: c.accentDark),
        boxShadow: wii ? [BoxShadow(color: c.glow, blurRadius: 8)] : null,
      ),
      child: Icon(Icons.flag_rounded, color: c.onAccent, size: 22),
    );

    final body = Row(
      children: [
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                wii ? t.t('missions_entry') : t.t('missions_title'),
                style: wii
                    ? missionText(c, 22)
                    : missionLabel(c).copyWith(fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                top == null
                    ? subtitle
                    : '${top.mission.title} · ${t.t('mission_progress', {'done': top.done, 'total': top.total})}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: missionText(c, 17, color: c.inkDim),
              ),
              if (top != null) ...[
                const SizedBox(height: 6),
                MissionMeter(ratio: top.ratio, height: 8),
              ],
            ],
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          wii ? Icons.play_arrow_rounded : Icons.chevron_right,
          color: wii ? c.accent : c.inkFaint,
          size: 28,
        ),
      ],
    );

    final panel = MissionPanel(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: body,
    );

    if (wii) {
      return Pressable(
        pressedScale: 0.97,
        onTap: () => showMissionsSheet(context),
        child: panel,
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showMissionsSheet(context),
      child: panel,
    );
  }
}
