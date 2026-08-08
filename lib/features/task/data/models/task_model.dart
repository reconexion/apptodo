import '../../domain/entities/task.dart';

/// Modelo de datos: entidad + serializacion JSON.
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.text,
    super.done,
  });

  factory TaskModel.fromEntity(Task task) =>
      TaskModel(id: task.id, text: task.text, done: task.done);

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: (json['id'] as num).toInt(),
    text: json['text'] as String? ?? '',
    done: json['done'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'done': done,
  };
}