import '../entities/task.dart';
import '../entities/task_snapshot.dart';
import '../entities/task_tab.dart';

/// Contrato del dominio. La capa de datos decide como cumplirlo.
abstract class TaskRepository {
  Future<TaskSnapshot> load();

  Future<TaskSnapshot> addTask(String text, int tabId);
  Future<TaskSnapshot> toggleTask(int id);
  Future<TaskSnapshot> deleteTask(int id);

  Future<TaskSnapshot> addTab(String name);
  Future<TaskSnapshot> renameTab(int id, String name);

  /// No borra la ultima pestana que quede.
  Future<TaskSnapshot> deleteTab(int id);

  /// Reemplaza todo. Lo usa la importacion de respaldos.
  Future<TaskSnapshot> replaceAll(List<TaskTab> tabs, List<Task> tasks);
}