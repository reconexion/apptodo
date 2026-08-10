import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/sfx_player.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_snapshot.dart';
import '../../domain/entities/task_tab.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/export_tasks.dart';
import '../../domain/usecases/get_snapshot.dart';
import '../../domain/usecases/import_tasks.dart';
import '../../domain/usecases/manage_tabs.dart';
import '../../domain/usecases/toggle_task.dart';

class TasksViewModel extends ChangeNotifier {
  TasksViewModel({
    required GetSnapshot getSnapshot,
    required AddTask addTask,
    required ToggleTask toggleTask,
    required DeleteTask deleteTask,
    required AddTab addTab,
    required RenameTab renameTab,
    required DeleteTab deleteTab,
    required ExportTasks exportTasks,
    required ImportTasks importTasks,
    required SfxPlayer sfx,
  })  : _getSnapshot = getSnapshot,
        _addTask = addTask,
        _toggleTask = toggleTask,
        _deleteTask = deleteTask,
        _addTab = addTab,
        _renameTab = renameTab,
        _deleteTab = deleteTab,
        _exportTasks = exportTasks,
        _importTasks = importTasks,
        _sfx = sfx;

  final GetSnapshot _getSnapshot;
  final AddTask _addTask;
  final ToggleTask _toggleTask;
  final DeleteTask _deleteTask;
  final AddTab _addTab;
  final RenameTab _renameTab;
  final DeleteTab _deleteTab;
  final ExportTasks _exportTasks;
  final ImportTasks _importTasks;
  final SfxPlayer _sfx;

  List<TaskTab> _tabs = const [];
  List<Task> _tasks = const [];
  int _activeTabId = 0;
  bool _loading = true;
  bool _muted = false;
  String _query = '';

  List<TaskTab> get tabs => _tabs;
  int get activeTabId => _activeTabId;

  TaskTab? get activeTab {
    for (final tab in _tabs) {
      if (tab.id == _activeTabId) return tab;
    }
    return _tabs.isEmpty ? null : _tabs.first;
  }

  /// Todas las tareas de todas las pestanas.
  List<Task> get tasks => _tasks;

  /// Solo las de la pestana activa.
  List<Task> get tabTasks =>
      _tasks.where((t) => t.tabId == _activeTabId).toList();

  /// Las de la pestana activa que ademas pasan la busqueda.
  List<Task> get visibleTasks {
    final own = tabTasks;
    if (_query.isEmpty) return own;
    final q = _query.toLowerCase();
    return own.where((t) => t.text.toLowerCase().contains(q)).toList();
  }

  bool get loading => _loading;
  bool get muted => _muted;
  String get query => _query;
  bool get searching => _query.isNotEmpty;

  // --- Contadores globales: no cambian al moverte de pestana. ---
  int get pending => _tasks.where((t) => !t.done).length;
  int get doneCount => _tasks.length - pending;
  double get progress => _tasks.isEmpty ? 0 : doneCount / _tasks.length;

  /// Pendientes de una pestana, para el numerito del chip.
  int pendingIn(int tabId) =>
      _tasks.where((t) => t.tabId == tabId && !t.done).length;

  void _apply(TaskSnapshot snapshot) {
    _tabs = snapshot.tabs;
    _tasks = snapshot.tasks;
    final exists = _tabs.any((t) => t.id == _activeTabId);
    if (!exists) _activeTabId = _tabs.isEmpty ? 0 : _tabs.first.id;
    notifyListeners();
  }

  Future<void> load() async {
    _apply(await _getSnapshot());
    _loading = false;
    notifyListeners();
  }

  Future<void> add(String text) async {
    if (text.trim().isEmpty || _activeTabId == 0) return;
    _apply(await _addTask(text, _activeTabId));
    _sfx.play(Sfx.add);
    HapticFeedback.selectionClick();
  }

  Future<void> toggle(int id) async {
    final wasDone = _tasks.firstWhere((t) => t.id == id).done;
    _apply(await _toggleTask(id));
    _sfx.play(wasDone ? Sfx.undone : Sfx.done);
    HapticFeedback.lightImpact();
  }

  Future<void> remove(int id) async {
    _apply(await _deleteTask(id));
    _sfx.play(Sfx.delete);
    HapticFeedback.mediumImpact();
  }

  void selectTab(int id) {
    if (_activeTabId == id) return;
    _activeTabId = id;
    _query = '';
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  Future<void> createTab(String name) async {
    final before = _tabs.map((t) => t.id).toSet();
    _apply(await _addTab(name));
    for (final tab in _tabs) {
      if (!before.contains(tab.id)) {
        _activeTabId = tab.id;
        break;
      }
    }
    _sfx.play(Sfx.add);
    notifyListeners();
  }

  Future<void> rename(int id, String name) async {
    _apply(await _renameTab(id, name));
    _sfx.play(Sfx.done);
  }

  Future<void> removeTab(int id) async {
    _apply(await _deleteTab(id));
    _sfx.play(Sfx.delete);
    HapticFeedback.mediumImpact();
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

  /// Reemplaza todo con el contenido del respaldo.
  /// Devuelve cuantas tareas quedaron. Lanza [FormatException] si no sirve.
  Future<int> restoreBackup(String raw) async {
    _apply(await _importTasks(raw));
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