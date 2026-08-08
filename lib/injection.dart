import 'package:shared_preferences/shared_preferences.dart';

import 'core/audio/sfx_player.dart';
import 'features/tasks/data/datasources/task_local_data_source.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/repositories/task_repository.dart';
import 'features/tasks/domain/usecases/add_task.dart';
import 'features/tasks/domain/usecases/delete_task.dart';
import 'features/tasks/domain/usecases/get_tasks.dart';
import 'features/tasks/domain/usecases/toggle_task.dart';
import 'features/tasks/presentation/viewmodels/tasks_view_model.dart';

/// Composition root: aqui se arma el arbol de dependencias una sola vez.
/// Si algun dia cambias SharedPreferences por SQLite, solo tocas este archivo.
class Injection {
  Injection._();

  static late final TaskRepository _repository;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final local = SharedPrefsTaskLocalDataSource(prefs);
    _repository = TaskRepositoryImpl(local);
  }

  static TasksViewModel createTasksViewModel() => TasksViewModel(
    getTasks: GetTasks(_repository),
    addTask: AddTask(_repository),
    toggleTask: ToggleTask(_repository),
    deleteTask: DeleteTask(_repository),
    sfx: SfxPlayer(),
  );
}