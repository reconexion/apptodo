import '../../domain/entities/task_tab.dart';

class TaskTabModel extends TaskTab {
  const TaskTabModel({required super.id, required super.name});

  factory TaskTabModel.fromEntity(TaskTab tab) =>
      TaskTabModel(id: tab.id, name: tab.name);

  factory TaskTabModel.fromJson(Map<String, dynamic> json) => TaskTabModel(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? 'SIN NOMBRE',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}