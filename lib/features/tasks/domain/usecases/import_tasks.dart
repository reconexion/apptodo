import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../services/task_backup_codec.dart';

class ImportTasks {
  const ImportTasks(this._repository, this._codec);

  final TaskRepository _repository;
  final TaskBackupCodec _codec;

  /// Reemplaza todo lo que haya. Lanza [FormatException] si el texto no sirve.
  Future<List<Task>> call(String raw) {
    final tasks = _codec.decode(raw);
    return _repository.replaceAll(tasks);
  }
}