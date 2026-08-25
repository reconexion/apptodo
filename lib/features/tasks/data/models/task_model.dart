import '../../domain/entities/task.dart';

/// Modelo de datos: entidad + serializacion JSON.
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.text,
    super.tabIds,
    super.done,
  });

  factory TaskModel.fromEntity(Task task) => TaskModel(
    id: task.id,
    text: task.text,
    tabIds: task.tabIds,
    done: task.done,
  );

  /// [fallbackTabId] cubre respaldos viejos que no traian pestanas.
  factory TaskModel.fromJson(Map<String, dynamic> json, int fallbackTabId) {
    final rawIds = json['tabIds'] as List<dynamic>?;
    if (rawIds != null) {
      return TaskModel(
        id: (json['id'] as num).toInt(),
        text: json['text'] as String? ?? '',
        tabIds: rawIds.map((e) => (e as num).toInt()).toSet(),
        done: json['done'] as bool? ?? false,
      );
    }

    // Formato viejo de una sola pestana ('tabId'), o respaldo sin ninguna.
    final singleTabId = (json['tabId'] as num?)?.toInt();
    return TaskModel(
      id: (json['id'] as num).toInt(),
      text: json['text'] as String? ?? '',
      tabIds: {singleTabId ?? fallbackTabId},
      done: json['done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'tabIds': tabIds.toList(),
    'done': done,
  };
}
