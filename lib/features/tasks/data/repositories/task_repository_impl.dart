import '../../domain/entities/task.dart';
import '../../domain/entities/task_snapshot.dart';
import '../../domain/entities/task_tab.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_model.dart';
import '../models/task_tab_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._local);

  final TaskLocalDataSource _local;

  List<TaskTabModel>? _tabsCache;
  List<TaskModel>? _tasksCache;

  Future<void> _ensureLoaded() async {
    if (_tabsCache != null && _tasksCache != null) return;

    final tabs = await _local.readTabs();
    // fallbackTabId solo importa para respaldos viejos sin tabId; si no
    // hay pestanas todavia, 0 es un valor seguro (no matchea nada real).
    final fallback = tabs.isEmpty ? 0 : tabs.first.id;
    final tasks = await _local.readTasks(fallback);

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
    if (_tabsCache!.every((t) => t.id != tabId)) return _snapshot;
    final id = _nextId(_tasksCache!.map((t) => t.id));
    return _commit(_tabsCache!, [
      TaskModel(id: id, text: text, tabIds: {tabId}),
      ..._tasksCache!,
    ]);
  }

  @override
  Future<TaskSnapshot> toggleTask(int id) async {
    await _ensureLoaded();
    return _commit(_tabsCache!, [
      for (final t in _tasksCache!)
        if (t.id == id)
          TaskModel(id: t.id, text: t.text, tabIds: t.tabIds, done: !t.done)
        else
          t,
    ]);
  }

  @override
  Future<TaskSnapshot> deleteTask(int id) async {
    await _ensureLoaded();
    return _commit(_tabsCache!, _tasksCache!.where((t) => t.id != id).toList());
  }

  @override
  Future<TaskSnapshot> setTaskTabs(int taskId, Set<int> tabIds) async {
    await _ensureLoaded();
    final validIds = _tabsCache!.map((t) => t.id).toSet();
    return _commit(_tabsCache!, [
      for (final t in _tasksCache!)
        if (t.id == taskId)
          TaskModel(
            id: t.id,
            text: t.text,
            tabIds: tabIds.intersection(validIds),
            done: t.done,
          )
        else
          t,
    ]);
  }

  @override
  Future<TaskSnapshot> addTab(String name) async {
    await _ensureLoaded();
    final id = _nextId(_tabsCache!.map((t) => t.id));
    return _commit([
      ..._tabsCache!,
      TaskTabModel(id: id, name: name),
    ], _tasksCache!);
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
    // Ya no se borran las tareas: solo se desligan de la pestana borrada.
    // Pueden quedar sin ninguna pestana, es un estado valido.
    return _commit(_tabsCache!.where((tab) => tab.id != id).toList(), [
      for (final t in _tasksCache!)
        TaskModel(
          id: t.id,
          text: t.text,
          tabIds: t.tabIds.difference({id}),
          done: t.done,
        ),
    ]);
  }

  @override
  Future<TaskSnapshot> replaceAll(List<TaskTab> tabs, List<Task> tasks) async {
    final safeTabs = tabs.map(TaskTabModel.fromEntity).toList();
    var id = 0;
    final safeTasks = [
      for (final t in tasks)
        TaskModel(id: ++id, text: t.text, tabIds: t.tabIds, done: t.done),
    ];
    return _commit(safeTabs, safeTasks);
  }

  @override
  Future<TaskSnapshot> mergeBackup({
    required List<TaskTab> incomingTabs,
    required List<Task> incomingTasks,
    required int intoTabId,
  }) async {
    await _ensureLoaded();

    final tabs = [..._tabsCache!];
    final tasks = [..._tasksCache!];
    var nextTabId = _nextId(tabs.map((t) => t.id));
    var nextTaskId = _nextId(tasks.map((t) => t.id));

    if (incomingTabs.isEmpty) {
      // Texto plano sin "## nombre": todo entra a la pestana activa.
      if (tabs.every((t) => t.id != intoTabId)) return _snapshot;
      for (final t in incomingTasks) {
        tasks.add(
          TaskModel(
            id: nextTaskId++,
            text: t.text,
            tabIds: {intoTabId},
            done: t.done,
          ),
        );
      }
      return _commit(tabs, tasks);
    }

    final resolvedTabId = <int, int>{};

    for (final incoming in incomingTabs) {
      final match = tabs.where(
        (t) => t.name.toLowerCase() == incoming.name.toLowerCase(),
      );
      if (match.isNotEmpty) {
        resolvedTabId[incoming.id] = match.first.id;
      } else {
        final newId = nextTabId++;
        tabs.add(TaskTabModel(id: newId, name: incoming.name));
        resolvedTabId[incoming.id] = newId;
      }
    }

    for (final t in incomingTasks) {
      final targetTabIds = t.tabIds
          .map((id) => resolvedTabId[id])
          .whereType<int>()
          .toSet();
      tasks.add(
        TaskModel(
          id: nextTaskId++,
          text: t.text,
          tabIds: targetTabIds,
          done: t.done,
        ),
      );
    }

    return _commit(tabs, tasks);
  }
}
