import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/sfx_player.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/viewmodels/tasks_view_model.dart';
import '../../domain/entities/mission.dart';
import '../../domain/usecases/manage_missions.dart';

/// Avance de una mision calculado con las tareas actuales.
class MissionProgress {
  const MissionProgress(this.mission, this.tasks);

  final Mission mission;

  /// Solo las tareas que todavia existen.
  final List<Task> tasks;

  int get total => tasks.length;
  int get done => tasks.where((t) => t.done).length;
  double get ratio => total == 0 ? 0 : done / total;
  bool get complete => total > 0 && done == total;
}

/// Escucha las tareas: cuando todas las de una mision quedan marcadas,
/// la da por completada, toca la melodia y avisa para celebrar.
class MissionsViewModel extends ChangeNotifier {
  MissionsViewModel({
    required TasksViewModel tasks,
    required GetMissions getMissions,
    required SaveMission saveMission,
    required DeleteMission deleteMission,
    required UpdateMissions updateMissions,
    required SfxPlayer sfx,
  }) : _tasksVm = tasks,
       _getMissions = getMissions,
       _saveMission = saveMission,
       _deleteMission = deleteMission,
       _updateMissions = updateMissions,
       _sfx = sfx {
    _tasksVm.addListener(_onTasksChanged);
  }

  final TasksViewModel _tasksVm;
  final GetMissions _getMissions;
  final SaveMission _saveMission;
  final DeleteMission _deleteMission;
  final UpdateMissions _updateMissions;
  final SfxPlayer _sfx;

  List<Mission> _missions = const [];
  bool _loaded = false;

  /// Tareas hechas por mision en la ultima revision; sirve para saber si
  /// la mision se completo porque se marco una tarea (y no por borrar una).
  final Map<int, Set<int>> _lastDone = {};

  final StreamController<MissionProgress> _celebrations =
      StreamController.broadcast();

  /// Emite cada mision en el momento en que se completa.
  Stream<MissionProgress> get celebrations => _celebrations.stream;

  List<MissionProgress> get missions => [
    for (final m in _missions) _progressOf(m),
  ];

  List<MissionProgress> get active =>
      missions.where((p) => !p.complete).toList();

  int get completedCount => missions.where((p) => p.complete).length;
  bool get hasMissions => _missions.isNotEmpty;

  MissionProgress? byId(int id) {
    for (final m in _missions) {
      if (m.id == id) return _progressOf(m);
    }
    return null;
  }

  MissionProgress _progressOf(Mission m) {
    final byId = {for (final t in _tasksVm.tasks) t.id: t};
    return MissionProgress(m, [
      for (final id in m.taskIds)
        if (byId[id] != null) byId[id]!,
    ]);
  }

  Future<void> load() async {
    _missions = await _getMissions();
    _loaded = true;
    // Al abrir no se celebra nada: solo se pone al dia.
    await _sync(celebrate: false);
    // La melodia tarda un poco en generarse; se prepara en segundo plano.
    Future.delayed(const Duration(seconds: 1), () => _sfx.preload(Sfx.mission));
  }

  /// Las revisiones van en fila para que dos cambios seguidos no se pisen.
  Future<void> _queue = Future.value();

  void _onTasksChanged() {
    if (!_loaded || _tasksVm.loading) return;
    _queue = _queue.then((_) => _sync(celebrate: true));
  }

  /// Revisa todas las misiones contra las tareas actuales.
  Future<void> _sync({required bool celebrate}) async {
    final existing = _tasksVm.tasks.map((t) => t.id).toSet();
    var changed = false;
    final next = <Mission>[];
    final finished = <MissionProgress>[];

    for (final m in _missions) {
      // Quita tareas que ya no existen.
      var mission = m;
      if (!existing.containsAll(m.taskIds)) {
        mission = m.copyWith(taskIds: m.taskIds.intersection(existing));
        changed = true;
      }

      final p = _progressOf(mission);
      final doneNow = p.tasks.where((t) => t.done).map((t) => t.id).toSet();
      final before = _lastDone[mission.id] ?? doneNow;
      final gainedDone = doneNow.difference(before).isNotEmpty;
      _lastDone[mission.id] = doneNow;

      if (p.complete && !mission.completed) {
        mission = mission.copyWith(completed: true);
        changed = true;
        if (celebrate && gainedDone) finished.add(_progressOf(mission));
      } else if (!p.complete && mission.completed) {
        // Se desmarco una tarea: la mision se reabre.
        mission = mission.copyWith(completed: false);
        changed = true;
      }
      next.add(mission);
    }

    if (changed) _missions = await _updateMissions(next);
    notifyListeners();

    for (final p in finished) {
      _sfx.play(Sfx.mission);
      HapticFeedback.heavyImpact();
      _celebrations.add(p);
    }
  }

  /// Crea o edita. Devuelve false si falta titulo o tareas.
  Future<bool> save({
    int id = 0,
    required String title,
    required String description,
    required Set<int> taskIds,
  }) async {
    if (title.trim().isEmpty || taskIds.isEmpty) return false;
    final previous = id == 0 ? null : byId(id)?.mission;
    _missions = await _saveMission(
      Mission(
        id: id,
        title: title,
        description: description,
        taskIds: taskIds,
        completed: previous?.completed ?? false,
      ),
    );
    // Guardar no celebra: si eliges puras tareas ya hechas, la mision
    // simplemente aparece como completada.
    _lastDone.clear();
    await _sync(celebrate: false);
    _sfx.play(Sfx.add);
    return true;
  }

  Future<void> remove(int id) async {
    _missions = await _deleteMission(id);
    _lastDone.remove(id);
    _sfx.play(Sfx.delete);
    notifyListeners();
  }

  @override
  void dispose() {
    _tasksVm.removeListener(_onTasksChanged);
    _celebrations.close();
    super.dispose();
  }
}
