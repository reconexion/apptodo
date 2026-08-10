import '../repositories/task_repository.dart';
import '../services/task_backup_codec.dart';

class ExportTasks {
  const ExportTasks(this._repository, this._codec);

  final TaskRepository _repository;
  final TaskBackupCodec _codec;

  Future<String> call() async {
    final snapshot = await _repository.load();
    return _codec.encode(snapshot.tabs, snapshot.tasks);
  }
}