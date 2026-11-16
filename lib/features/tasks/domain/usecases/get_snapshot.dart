import '../entities/task_snapshot.dart';
import '../repositories/task_repository.dart';

class GetSnapshot {
  const GetSnapshot(this._repository);
  final TaskRepository _repository;

  Future<TaskSnapshot> call() => _repository.load();
}
