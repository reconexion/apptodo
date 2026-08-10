import '../../domain/entities/task.dart';

/// Modelo de datos: entidad + serializacion JSON.
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.text,
    required super.tabId,
    super.done,
  });

  factory TaskModel.fromEntity(Task task) => TaskModel(
    id: task.id,
    text: task.text,
    tabId: task.tabId,
    done: task.done,
  );

  /// [fallbackTabId] cubre respaldos viejos que no traian pestanas.
  factory TaskModel.fromJson(Map<String, dynamic> json, int fallbackTabId) =>
      TaskModel(
        id: (json['id'] as num).toInt(),
        text: json['text'] as String? ?? '',
        tabId: (json['tabId'] as num?)?.toInt() ?? fallbackTabId,
        done: json['done'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'tabId': tabId,
    'done': done,
  };
}