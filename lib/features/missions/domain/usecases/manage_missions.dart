import '../entities/mission.dart';
import '../repositories/mission_repository.dart';

class GetMissions {
  const GetMissions(this._repository);
  final MissionRepository _repository;

  Future<List<Mission>> call() => _repository.load();
}

class SaveMission {
  const SaveMission(this._repository);
  final MissionRepository _repository;

  /// Una mision necesita titulo y al menos una tarea.
  Future<List<Mission>> call(Mission mission) {
    final title = mission.title.trim();
    if (title.isEmpty || mission.taskIds.isEmpty) return _repository.load();
    return _repository.save(
      mission.copyWith(title: title, description: mission.description.trim()),
    );
  }
}

class DeleteMission {
  const DeleteMission(this._repository);
  final MissionRepository _repository;

  Future<List<Mission>> call(int id) => _repository.delete(id);
}

class UpdateMissions {
  const UpdateMissions(this._repository);
  final MissionRepository _repository;

  Future<List<Mission>> call(List<Mission> missions) =>
      _repository.replaceAll(missions);
}
