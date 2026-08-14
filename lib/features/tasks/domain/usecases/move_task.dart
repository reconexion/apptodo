import '../entities/task_snapshot.dart';
import '../repositories/task_repository.dart';

class MoveTask {
  const MoveTask(this._repository);
  final TaskRepository _repository;

  Future<TaskSnapshot> call(int taskId, int toTabId) =>
      _repository.moveTask(taskId, toTabId);
}