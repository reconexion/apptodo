import '../entities/task_snapshot.dart';
import '../repositories/task_repository.dart';

class AddTask {
  const AddTask(this._repository);
  final TaskRepository _repository;

  /// Ignora texto vacio: regla de negocio, no de UI.
  Future<TaskSnapshot> call(String text, int tabId) {
    final clean = text.trim();
    if (clean.isEmpty) return _repository.load();
    return _repository.addTask(clean, tabId);
  }
}
