import '../entities/mission.dart';

abstract class MissionRepository {
  Future<List<Mission>> load();

  /// Crea (si [Mission.id] es 0) o reemplaza una mision. Devuelve la lista.
  Future<List<Mission>> save(Mission mission);

  Future<List<Mission>> delete(int id);

  /// Guarda varias de golpe (estado de completada, tareas borradas, etc.).
  Future<List<Mission>> replaceAll(List<Mission> missions);
}
