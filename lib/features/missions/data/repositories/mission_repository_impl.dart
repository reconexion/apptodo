import '../../domain/entities/mission.dart';
import '../../domain/repositories/mission_repository.dart';
import '../datasources/mission_local_data_source.dart';

class MissionRepositoryImpl implements MissionRepository {
  MissionRepositoryImpl(this._local);

  final MissionLocalDataSource _local;
  List<Mission>? _cache;

  List<Mission> get _missions => _cache ??= _local.read();

  Future<List<Mission>> _commit(List<Mission> next) async {
    _cache = next;
    await _local.write(next);
    return List.unmodifiable(next);
  }

  @override
  Future<List<Mission>> load() async => List.unmodifiable(_missions);

  @override
  Future<List<Mission>> save(Mission mission) {
    if (mission.id == 0) {
      final id = _missions.fold<int>(0, (m, x) => x.id > m ? x.id : m) + 1;
      return _commit([..._missions, mission.withId(id)]);
    }
    return _commit([
      for (final m in _missions) m.id == mission.id ? mission : m,
    ]);
  }

  @override
  Future<List<Mission>> delete(int id) =>
      _commit(_missions.where((m) => m.id != id).toList());

  @override
  Future<List<Mission>> replaceAll(List<Mission> missions) =>
      _commit(List.of(missions));
}

extension on Mission {
  Mission withId(int id) => Mission(
    id: id,
    title: title,
    description: description,
    taskIds: taskIds,
    completed: completed,
  );
}
