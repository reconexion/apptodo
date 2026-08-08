import '../entities/task.dart';
import '../repositories/task_repository.dart';

class DeleteTask {
  const DeleteTask(this._repository);
  final TaskRepository _repository;

  Future<List<Task>> call(int id) => _repository.deleteTask(id);
}