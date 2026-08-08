import '../entities/task.dart';
import '../repositories/task_repository.dart';

class AddTask {
  const AddTask(this._repository);
  final TaskRepository _repository;

  /// Ignora texto vacio: regla de negocio, no de UI.
  Future<List<Task>> call(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return _repository.getTasks();
    return _repository.addTask(clean);
  }
}