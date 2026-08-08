import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/sfx_player.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/export_tasks.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/import_tasks.dart';
import '../../domain/usecases/toggle_task.dart';

class TasksViewModel extends ChangeNotifier {
  TasksViewModel({
    required GetTasks getTasks,
    required AddTask addTask,
    required ToggleTask toggleTask,
    required DeleteTask deleteTask,
    required ExportTasks exportTasks,
    required ImportTasks importTasks,
    required SfxPlayer sfx,
  })  : _getTasks = getTasks,
        _addTask = addTask,
        _toggleTask = toggleTask,
        _deleteTask = deleteTask,
        _exportTasks = exportTasks,
        _importTasks = importTasks,
        _sfx = sfx;

  final GetTasks _getTasks;
  final AddTask _addTask;
  final ToggleTask _toggleTask;
  final DeleteTask _deleteTask;
  final ExportTasks _exportTasks;
  final ImportTasks _importTasks;
  final SfxPlayer _sfx;

  List<Task> _tasks = const [];
  bool _loading = true;
  bool _muted = false;
  String _query = '';

  /// Todas las tareas, sin filtrar. El contador y el medidor usan estas.
  List<Task> get tasks => _tasks;

  /// Solo las que pasan el filtro de busqueda. La lista usa estas.
  List<Task> get visibleTasks {
    if (_query.isEmpty) return _tasks;
    final q = _query.toLowerCase();
    return _tasks.where((t) => t.text.toLowerCase().contains(q)).toList();
  }

  bool get loading => _loading;
  bool get muted => _muted;
  String get query => _query;
  bool get searching => _query.isNotEmpty;

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

  void search(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }

  void toggleMute() {
    _muted = !_muted;
    _sfx.muted = _muted;
    notifyListeners();
  }

  /// Texto del respaldo, listo para copiar.
  Future<String> buildBackup() => _exportTasks();

  /// Reemplaza la lista con el contenido del respaldo.
  /// Devuelve cuantas tareas quedaron. Lanza [FormatException] si no sirve.
  Future<int> restoreBackup(String raw) async {
    _tasks = await _importTasks(raw);
    _query = '';
    _sfx.play(Sfx.add);
    HapticFeedback.mediumImpact();
    notifyListeners();
    return _tasks.length;
  }

  @override
  void dispose() {
    _sfx.dispose();
    super.dispose();
  }
}