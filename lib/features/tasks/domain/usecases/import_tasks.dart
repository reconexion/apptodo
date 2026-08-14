import '../entities/task_snapshot.dart';
import '../repositories/task_repository.dart';
import '../services/task_backup_codec.dart';

class ImportTasks {
  const ImportTasks(this._repository, this._codec);

  final TaskRepository _repository;
  final TaskBackupCodec _codec;


  Future<TaskSnapshot> call(String raw, {required int intoTabId}) {
    final backup = _codec.decode(raw);
    return _repository.mergeBackup(
      incomingTabs: backup.tabs,
      incomingTasks: backup.tasks,
      intoTabId: intoTabId,
    );
  }
}