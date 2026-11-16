import '../entities/task_snapshot.dart';
import '../repositories/task_repository.dart';

class ToggleTask {
  const ToggleTask(this._repository);
  final TaskRepository _repository;

  Future<TaskSnapshot> call(int id) => _repository.toggleTask(id);
}
