/// Una mision agrupa tareas existentes (de cualquier pestana). Se completa
/// cuando todas sus tareas estan marcadas.
class Mission {
  const Mission({
    required this.id,
    required this.title,
    this.description = '',
    this.taskIds = const {},
    this.completed = false,
  });

  final int id;
  final String title;

  /// Lo que se hara: la explicacion de la mision.
  final String description;

  final Set<int> taskIds;

  /// Recordado para no celebrar dos veces la misma mision y para saber
  /// cuales ya estaban completas al abrir la app.
  final bool completed;

  Mission copyWith({
    String? title,
    String? description,
    Set<int>? taskIds,
    bool? completed,
  }) => Mission(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    taskIds: taskIds ?? this.taskIds,
    completed: completed ?? this.completed,
  );
}
