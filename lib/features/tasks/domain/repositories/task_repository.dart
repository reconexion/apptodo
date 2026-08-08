import '../entities/task.dart';

/// Contrato del dominio. La capa de datos decide como cumplirlo.
abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<List<Task>> addTask(String text);
  Future<List<Task>> toggleTask(int id);
  Future<List<Task>> deleteTask(int id);

  /// Reemplaza toda la lista. Lo usa la importacion de respaldos.
  Future<List<Task>> replaceAll(List<Task> tasks);
}