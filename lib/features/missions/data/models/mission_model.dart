import '../../domain/entities/mission.dart';

/// Mision + serializacion JSON.
class MissionModel {
  const MissionModel._();

  static Mission fromJson(Map<String, dynamic> json) => Mission(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    taskIds: ((json['taskIds'] as List<dynamic>?) ?? const [])
        .map((e) => (e as num).toInt())
        .toSet(),
    completed: json['completed'] as bool? ?? false,
  );

  static Map<String, dynamic> toJson(Mission m) => {
    'id': m.id,
    'title': m.title,
    'description': m.description,
    'taskIds': m.taskIds.toList(),
    'completed': m.completed,
  };
}
