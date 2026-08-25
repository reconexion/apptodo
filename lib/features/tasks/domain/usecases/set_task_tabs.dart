import '../entities/task_snapshot.dart';
import '../repositories/task_repository.dart';

class SetTaskTabs {
  const SetTaskTabs(this._repository);
  final TaskRepository _repository;

  Future<TaskSnapshot> call(int taskId, Set<int> tabIds) =>
      _repository.setTaskTabs(taskId, tabIds);
}
