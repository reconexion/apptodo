import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/sfx_player.dart';
import '../../../../core/kaomoji/kaomoji_set.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_snapshot.dart';
import '../../domain/entities/task_tab.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/export_tasks.dart';
import '../../domain/usecases/get_snapshot.dart';
import '../../domain/usecases/import_tasks.dart';
import '../../domain/usecases/manage_tabs.dart';
import '../../domain/usecases/set_task_tabs.dart';
import '../../domain/usecases/toggle_task.dart';

/// Filtro especial: junta las tareas de todas las pestanas en una vista.
const int kAllTabsId = -1;

class TasksViewModel extends ChangeNotifier {
  TasksViewModel({
    required GetSnapshot getSnapshot,
    required AddTask addTask,
    required ToggleTask toggleTask,
    required DeleteTask deleteTask,
    required SetTaskTabs setTaskTabs,
    required AddTab addTab,
    required RenameTab renameTab,
    required DeleteTab deleteTab,
    required ExportTasks exportTasks,
    required ImportTasks importTasks,
    required SfxPlayer sfx,
  }) : _getSnapshot = getSnapshot,
       _addTask = addTask,
       _toggleTask = toggleTask,
       _deleteTask = deleteTask,
       _setTaskTabs = setTaskTabs,
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
  final SetTaskTabs _setTaskTabs;
  final AddTab _addTab;
  final RenameTab _renameTab;
  final DeleteTab _deleteTab;
  final ExportTasks _exportTasks;
  final ImportTasks _importTasks;
  final SfxPlayer _sfx;

  List<TaskTab> _tabs = const [];
  List<Task> _tasks = const [];

  /// kAllTabsId, un id real, o 0 si no hay ninguna pestana.
  int _activeTabId = 0;
  bool _loading = true;
  bool _muted = false;
  String _query = '';

  /// Se elige una vez al abrir la app y no cambia hasta que se reabra.
  final String kaomoji = KaomojiSet.random();

  List<TaskTab> get tabs => _tabs;
  int get activeTabId => _activeTabId;
  bool get hasTabs => _tabs.isNotEmpty;
  bool get isAllSelected => _activeTabId == kAllTabsId;

  TaskTab? get activeTab {
    if (isAllSelected) return null;
    for (final tab in _tabs) {
      if (tab.id == _activeTabId) return tab;
    }
    return null;
  }

  /// Todas las tareas de todas las pestanas.
  List<Task> get tasks => _tasks;

  /// Las de la pestana activa, o todas si esta seleccionado "TODAS".
  List<Task> get tabTasks {
    if (isAllSelected) return _tasks;
    return _tasks.where((t) => t.tabIds.contains(_activeTabId)).toList();
  }

  /// Las de arriba, filtradas ademas por busqueda.
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

  /// Puedes escribir tareas si hay una pestana real seleccionada
  /// (no aplica en "TODAS", porque no sabria a donde mandarlas).
  bool get canAddTask => !isAllSelected && activeTab != null;

  // --- Contadores globales: no cambian al moverte de pestana. ---
  int get pending => _tasks.where((t) => !t.done).length;
  int get doneCount => _tasks.length - pending;
  double get progress => _tasks.isEmpty ? 0 : doneCount / _tasks.length;

  int pendingIn(int tabId) =>
      _tasks.where((t) => t.tabIds.contains(tabId) && !t.done).length;

  void _apply(TaskSnapshot snapshot) {
    _tabs = snapshot.tabs;
    _tasks = snapshot.tasks;

    if (_tabs.isEmpty) {
      _activeTabId = 0;
    } else if (_activeTabId != kAllTabsId &&
        _tabs.every((t) => t.id != _activeTabId)) {
      _activeTabId = _tabs.first.id;
    }
    notifyListeners();
  }

  Future<void> load() async {
    _apply(await _getSnapshot());
    _loading = false;
    notifyListeners();
  }

  Future<void> add(String text) async {
    if (text.trim().isEmpty || !canAddTask) return;
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
    // Se quita de inmediato: al deslizar para borrar, la tarjeta debe
    // salir del arbol en este mismo frame (lo exige Dismissible).
    _tasks = _tasks.where((t) => t.id != id).toList();
    notifyListeners();
    _apply(await _deleteTask(id));
    _sfx.play(Sfx.delete);
    HapticFeedback.mediumImpact();
  }

  /// Reemplaza el conjunto de pestanas ligadas a una tarea ya creada.
  Future<void> setTaskTabs(int taskId, Set<int> tabIds) async {
    _apply(await _setTaskTabs(taskId, tabIds));
    _sfx.play(Sfx.done);
    HapticFeedback.selectionClick();
  }

  void selectTab(int id) {
    if (_activeTabId == id) return;
    _activeTabId = id;
    _query = '';
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void selectAll() => selectTab(kAllTabsId);

  Future<void> createTab(String name) async {
    final before = _tabs.map((t) => t.id).toSet();
    final wasEmpty = _tabs.isEmpty;
    _apply(await _addTab(name));

    if (wasEmpty) {
      for (final tab in _tabs) {
        if (!before.contains(tab.id)) {
          _activeTabId = tab.id;
          break;
        }
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

  Future<String> buildBackup() => _exportTasks();

  Future<int> restoreBackup(String raw) async {
    final target = activeTab;
    if (target == null) return 0;
    final before = _tasks.length;
    _apply(await _importTasks(raw, intoTabId: target.id));
    _query = '';
    _sfx.play(Sfx.add);
    HapticFeedback.mediumImpact();
    notifyListeners();
    return _tasks.length - before;
  }

  @override
  void dispose() {
    _sfx.dispose();
    super.dispose();
  }
}
