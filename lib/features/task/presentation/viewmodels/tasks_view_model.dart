import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/sfx_player.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_task.dart';

class TasksViewModel extends ChangeNotifier {
  TasksViewModel({
    required GetTasks getTasks,
    required AddTask addTask,
    required ToggleTask toggleTask,
    required DeleteTask deleteTask,
    required SfxPlayer sfx,
  })  : _getTasks = getTasks,
        _addTask = addTask,
        _toggleTask = toggleTask,
        _deleteTask = deleteTask,
        _sfx = sfx;

  final GetTasks _getTasks;
  final AddTask _addTask;
  final ToggleTask _toggleTask;
  final DeleteTask _deleteTask;
  final SfxPlayer _sfx;

  List<Task> _tasks = const [];
  bool _loading = true;
  bool _muted = false;

  List<Task> get tasks => _tasks;
  bool get loading => _loading;
  bool get muted => _muted;

  int get pending => _tasks.where((t) => !t.done).length;
  int get doneCount => _tasks.length - pending;
  double get progress => _tasks.isEmpty ? 0 : doneCount / _tasks.length;

  Future<void> load() async {
    _tasks = await _getTasks();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(String text) async {
    if (text.trim().isEmpty) return;
    _tasks = await _addTask(text);
    _sfx.play(Sfx.add);
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  Future<void> toggle(int id) async {
    final wasDone = _tasks.firstWhere((t) => t.id == id).done;
    _tasks = await _toggleTask(id);
    _sfx.play(wasDone ? Sfx.undone : Sfx.done);
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  Future<void> remove(int id) async {
    _tasks = await _deleteTask(id);
    _sfx.play(Sfx.delete);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void toggleMute() {
    _muted = !_muted;
    _sfx.muted = _muted;
    notifyListeners();
  }

  @override
  void dispose() {
    _sfx.dispose();
    super.dispose();
  }
}