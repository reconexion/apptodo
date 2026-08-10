import '../../domain/entities/task.dart';
import '../../domain/entities/task_snapshot.dart';
import '../../domain/entities/task_tab.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_model.dart';
import '../models/task_tab_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._local);

  static const _defaultTabId = 1;
  static const _defaultTabName = 'GENERAL';

  final TaskLocalDataSource _local;

  List<TaskTabModel>? _tabsCache;
  List<TaskModel>? _tasksCache;

  Future<void> _ensureLoaded() async {
    if (_tabsCache != null && _tasksCache != null) return;

    var tabs = await _local.readTabs();
    // Primera vez, o datos de la version sin pestanas.
    if (tabs.isEmpty) {
      tabs = const [TaskTabModel(id: _defaultTabId, name: _defaultTabName)];
    }
    final tasks = await _local.readTasks(tabs.first.id);

    _tabsCache = tabs;
    _tasksCache = tasks;
  }

  Future<TaskSnapshot> _commit(
      List<TaskTabModel> tabs,
      List<TaskModel> tasks,
      ) async {
    _tabsCache = tabs;
    _tasksCache = tasks;
    await _local.write(tabs, tasks);
    return TaskSnapshot(
      tabs: List<TaskTab>.unmodifiable(tabs),
      tasks: List<Task>.unmodifiable(tasks),
    );
  }

  TaskSnapshot get _snapshot => TaskSnapshot(
    tabs: List<TaskTab>.unmodifiable(_tabsCache!),
    tasks: List<Task>.unmodifiable(_tasksCache!),
  );

  int _nextId(Iterable<int> ids) =>
      ids.fold<int>(0, (max, id) => id > max ? id : max) + 1;

  @override
  Future<TaskSnapshot> load() async {
    await _ensureLoaded();
    return _snapshot;
  }

  @override
  Future<TaskSnapshot> addTask(String text, int tabId) async {
    await _ensureLoaded();
    final id = _nextId(_tasksCache!.map((t) => t.id));
    // Las nuevas van hasta arriba.
    return _commit(
      _tabsCache!,
      [TaskModel(id: id, text: text, tabId: tabId), ..._tasksCache!],
    );
  }

  @override
  Future<TaskSnapshot> toggleTask(int id) async {
    await _ensureLoaded();
    return _commit(_tabsCache!, [
      for (final t in _tasksCache!)
        if (t.id == id)
          TaskModel(id: t.id, text: t.text, tabId: t.tabId, done: !t.done)
        else
          t,
    ]);
  }

  @override
  Future<TaskSnapshot> deleteTask(int id) async {
    await _ensureLoaded();
    return _commit(
      _tabsCache!,
      _tasksCache!.where((t) => t.id != id).toList(),
    );
  }

  @override
  Future<TaskSnapshot> addTab(String name) async {
    await _ensureLoaded();
    final id = _nextId(_tabsCache!.map((t) => t.id));
    return _commit(
      [..._tabsCache!, TaskTabModel(id: id, name: name)],
      _tasksCache!,
    );
  }

  @override
  Future<TaskSnapshot> renameTab(int id, String name) async {
    await _ensureLoaded();
    return _commit([
      for (final tab in _tabsCache!)
        if (tab.id == id) TaskTabModel(id: tab.id, name: name) else tab,
    ], _tasksCache!);
  }

  @override
  Future<TaskSnapshot> deleteTab(int id) async {
    await _ensureLoaded();
    // Siempre debe quedar al menos una pestana.
    if (_tabsCache!.length <= 1) return _snapshot;
    return _commit(
      _tabsCache!.where((tab) => tab.id != id).toList(),
      _tasksCache!.where((t) => t.tabId != id).toList(),
    );
  }

  @override
  Future<TaskSnapshot> replaceAll(
      List<TaskTab> tabs,
      List<Task> tasks,
      ) async {
    final safeTabs = tabs.isEmpty
        ? const [TaskTabModel(id: _defaultTabId, name: _defaultTabName)]
        : tabs.map(TaskTabModel.fromEntity).toList();

    // Se reasignan los ids de tarea para que no queden repetidos.
    var id = 0;
    final safeTasks = [
      for (final t in tasks)
        TaskModel(id: ++id, text: t.text, tabId: t.tabId, done: t.done),
    ];
    return _commit(safeTabs, safeTasks);
  }
}