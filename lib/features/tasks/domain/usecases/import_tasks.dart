import '../entities/task_snapshot.dart';
import '../repositories/task_repository.dart';
import '../services/task_backup_codec.dart';

class ImportTasks {
  const ImportTasks(this._repository, this._codec);

  final TaskRepository _repository;
  final TaskBackupCodec _codec;

  /// Reemplaza todo. Lanza [FormatException] si el texto no sirve.
  Future<TaskSnapshot> call(String raw) {
    final backup = _codec.decode(raw);
    return _repository.replaceAll(backup.tabs, backup.tasks);
  }
}