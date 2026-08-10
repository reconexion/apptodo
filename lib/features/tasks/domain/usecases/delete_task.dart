import '../entities/task_snapshot.dart';
import '../repositories/task_repository.dart';

class DeleteTask {
  const DeleteTask(this._repository);
  final TaskRepository _repository;

  Future<TaskSnapshot> call(int id) => _repository.deleteTask(id);
}