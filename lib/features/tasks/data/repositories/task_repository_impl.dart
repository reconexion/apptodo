import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._local);

  final TaskLocalDataSource _local;

  List<TaskModel>? _cache;

  Future<List<TaskModel>> get _tasks async {
    final cached = _cache;
    if (cached != null) return cached;
    final loaded = await _local.read();
    _cache = loaded;
    return loaded;
  }

  Future<List<Task>> _commit(List<TaskModel> tasks) async {
    _cache = tasks;
    await _local.write(tasks);
    return List<Task>.unmodifiable(tasks);
  }

  @override
  Future<List<Task>> getTasks() async =>
      List<Task>.unmodifiable(await _tasks);

  @override
  Future<List<Task>> addTask(String text) async {
    final current = await _tasks;
    final nextId = current.fold<int>(0, (max, t) => t.id > max ? t.id : max) + 1;
    // Las nuevas van hasta arriba, igual que en la version web.
    return _commit([TaskModel(id: nextId, text: text), ...current]);
  }

  @override
  Future<List<Task>> toggleTask(int id) async {
    final current = await _tasks;
    return _commit([
      for (final t in current)
        if (t.id == id) TaskModel(id: t.id, text: t.text, done: !t.done) else t,
    ]);
  }

  @override
  Future<List<Task>> deleteTask(int id) async {
    final current = await _tasks;
    return _commit(current.where((t) => t.id != id).toList());
  }

  @override
  Future<List<Task>> replaceAll(List<Task> tasks) async {
    // Se reasignan los ids para que no queden huecos ni repetidos.
    var id = 0;
    return _commit([
      for (final t in tasks)
        TaskModel(id: ++id, text: t.text, done: t.done),
    ]);
  }
}