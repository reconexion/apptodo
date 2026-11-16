import 'package:shared_preferences/shared_preferences.dart';

import 'core/audio/sfx_player.dart';
import 'core/l10n/language_controller.dart';
import 'core/theme/theme_controller.dart';
import 'features/missions/data/datasources/mission_local_data_source.dart';
import 'features/missions/data/repositories/mission_repository_impl.dart';
import 'features/missions/domain/repositories/mission_repository.dart';
import 'features/missions/domain/usecases/manage_missions.dart';
import 'features/missions/presentation/viewmodels/missions_view_model.dart';
import 'features/tasks/data/datasources/task_local_data_source.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/repositories/task_repository.dart';
import 'features/tasks/domain/services/task_backup_codec.dart';
import 'features/tasks/domain/usecases/add_task.dart';
import 'features/tasks/domain/usecases/delete_task.dart';
import 'features/tasks/domain/usecases/export_tasks.dart';
import 'features/tasks/domain/usecases/get_snapshot.dart';
import 'features/tasks/domain/usecases/import_tasks.dart';
import 'features/tasks/domain/usecases/manage_tabs.dart';
import 'features/tasks/domain/usecases/set_task_tabs.dart';
import 'features/tasks/domain/usecases/toggle_task.dart';
import 'features/tasks/presentation/viewmodels/tasks_view_model.dart';

/// Composition root: aqui se arma el arbol de dependencias una sola vez.
class Injection {
  Injection._();

  static late final SharedPreferences _prefs;
  static late final TaskRepository _repository;
  static late final MissionRepository _missions;
  static const TaskBackupCodec _codec = TaskBackupCodec();

  /// Un solo reproductor para todo: asi el boton de silencio aplica
  /// tambien a la melodia de mision.
  static final SfxPlayer _sfx = SfxPlayer();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _repository = TaskRepositoryImpl(SharedPrefsTaskLocalDataSource(_prefs));
    _missions = MissionRepositoryImpl(MissionLocalDataSource(_prefs));
  }

  static ThemeController createThemeController() => ThemeController(_prefs);

  static LanguageController createLanguageController() =>
      LanguageController(_prefs);

  static TasksViewModel createTasksViewModel() => TasksViewModel(
    getSnapshot: GetSnapshot(_repository),
    addTask: AddTask(_repository),
    toggleTask: ToggleTask(_repository),
    deleteTask: DeleteTask(_repository),
    setTaskTabs: SetTaskTabs(_repository),
    addTab: AddTab(_repository),
    renameTab: RenameTab(_repository),
    deleteTab: DeleteTab(_repository),
    exportTasks: ExportTasks(_repository, _codec),
    importTasks: ImportTasks(_repository, _codec),
    sfx: _sfx,
  );

  static MissionsViewModel createMissionsViewModel(TasksViewModel tasks) =>
      MissionsViewModel(
        tasks: tasks,
        getMissions: GetMissions(_missions),
        saveMission: SaveMission(_missions),
        deleteMission: DeleteMission(_missions),
        updateMissions: UpdateMissions(_missions),
        sfx: _sfx,
      );
}
