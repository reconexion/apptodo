import '../entities/task_snapshot.dart';
import '../repositories/task_repository.dart';

class AddTab {
  const AddTab(this._repository);
  final TaskRepository _repository;

  Future<TaskSnapshot> call(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return _repository.load();
    return _repository.addTab(clean);
  }
}

class RenameTab {
  const RenameTab(this._repository);
  final TaskRepository _repository;

  Future<TaskSnapshot> call(int id, String name) {
    final clean = name.trim();
    if (clean.isEmpty) return _repository.load();
    return _repository.renameTab(id, clean);
  }
}

class DeleteTab {
  const DeleteTab(this._repository);
  final TaskRepository _repository;

  Future<TaskSnapshot> call(int id) => _repository.deleteTab(id);
}