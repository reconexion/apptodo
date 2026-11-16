import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/gloss.dart';
import '../pages/mission_editor_page.dart';
import '../viewmodels/missions_view_model.dart';
import 'mission_ui.dart';

/// Lista de misiones, desde abajo. Tocar una la edita.
Future<void> showMissionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const MissionsSheet(),
  );
}

class MissionsSheet extends StatelessWidget {
  const MissionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;
    final vm = context.watch<MissionsViewModel>();
    // Activas primero, completadas al final.
    final list = vm.missions
      ..sort((a, b) {
        if (a.complete != b.complete) return a.complete ? 1 : -1;
        return b.ratio.compareTo(a.ratio);
      });

    return Container(
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
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 8, 6),
                child: Row(
                  children: [
                    Icon(Icons.flag_rounded, size: 18, color: c.engrave),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.t('missions_title'),
                        style: missionLabel(c),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: c.inkDim),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: MissionButton(
                  label: t.t('missions_new'),
                  icon: Icons.add_rounded,
                  onTap: () => openMissionEditor(context),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: list.isEmpty
                    ? _Empty()
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => missionEntrance(
                          context,
                          i,
                          _MissionCard(
                            progress: list[i],
                            onTap: () => openMissionEditor(
                              context,
                              missionId: list[i].mission.id,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: MissionPanel(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
        child: Column(
          children: [
            Icon(Icons.outlined_flag_rounded, size: 34, color: c.inkFaint),
            const SizedBox(height: 6),
            Text(
              t.t('missions_empty_title'),
              textAlign: TextAlign.center,
              style: missionText(c, 20, color: c.inkDim),
            ),
            const SizedBox(height: 4),
            Text(
              t.t('missions_empty_subtitle'),
              textAlign: TextAlign.center,
              style: missionText(c, 16, color: c.inkFaint),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.progress, required this.onTap});

  final MissionProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final t = context.t;
    final m = progress.mission;
    final done = progress.complete;

    final card = MissionPanel(
      highlight: done,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  done ? Icons.emoji_events_rounded : Icons.flag_rounded,
                  size: 22,
                  color: done ? c.accent : c.inkFaint,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(m.title, style: missionText(c, 21))),
              if (done) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(
                      isWii(context) ? 10 : 4,
                    ),
                  ),
                  child: Text(
                    t.t('mission_done_badge'),
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: AppFonts.ds(9),
                      fontWeight: FontWeight.w800,
                      letterSpacing: AppFonts.track(1.6),
                      color: c.onAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (m.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              m.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: missionText(c, 16, color: c.inkDim),
            ),
          ],
          const SizedBox(height: 10),
          MissionMeter(ratio: progress.ratio),
          const SizedBox(height: 6),
          Text(
            t.t('mission_progress', {
              'done': progress.done,
              'total': progress.total,
            }),
            style: missionText(c, 15, color: c.inkFaint),
          ),
        ],
      ),
    );

    return isWii(context)
        ? Pressable(pressedScale: 0.97, onTap: onTap, child: card)
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: card,
          );
  }
}
