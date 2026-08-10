/// Una pestana con nombre editable.
class TaskTab {
  const TaskTab({required this.id, required this.name});

  final int id;
  final String name;

  TaskTab copyWith({String? name}) => TaskTab(id: id, name: name ?? this.name);

  @override
  bool operator ==(Object other) =>
      other is TaskTab && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}