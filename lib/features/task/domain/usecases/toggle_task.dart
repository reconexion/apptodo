import '../entities/task.dart';
import '../repositories/task_repository.dart';

class ToggleTask {
  const ToggleTask(this._repository);
  final TaskRepository _repository;

  Future<List<Task>> call(int id) => _repository.toggleTask(id);
}