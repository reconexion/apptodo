import '../entities/task.dart';
import '../entities/task_snapshot.dart';
import '../entities/task_tab.dart';

/// Contrato del dominio. La capa de datos decide como cumplirlo.
abstract class TaskRepository {
  Future<TaskSnapshot> load();

  Future<TaskSnapshot> addTask(String text, int tabId);
  Future<TaskSnapshot> toggleTask(int id);
  Future<TaskSnapshot> deleteTask(int id);

  /// Reemplaza el conjunto de pestanas ligadas a una tarea.
  Future<TaskSnapshot> setTaskTabs(int taskId, Set<int> tabIds);

  Future<TaskSnapshot> addTab(String name);
  Future<TaskSnapshot> renameTab(int id, String name);

  /// Puede dejar 0 pestanas: es un estado valido.
  Future<TaskSnapshot> deleteTab(int id);

  Future<TaskSnapshot> replaceAll(List<TaskTab> tabs, List<Task> tasks);

  /// Agrega tareas sin borrar nada existente.
  /// Si [incomingTabs] no esta vacio, cada nombre se resuelve contra una
  /// pestana existente o se crea. Si esta vacio, todo entra en [intoTabId].
  Future<TaskSnapshot> mergeBackup({
    required List<TaskTab> incomingTabs,
    required List<Task> incomingTasks,
    required int intoTabId,
  });
}