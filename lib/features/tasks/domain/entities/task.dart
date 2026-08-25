/// Entidad pura del dominio: no sabe nada de Flutter ni de como se guarda.
class Task {
  const Task({
    required this.id,
    required this.text,
    this.tabIds = const {},
    this.done = false,
  });

  final int id;
  final String text;

  /// Pestanas a las que pertenece. Puede ser mas de una, o ninguna.
  final Set<int> tabIds;
  final bool done;

  Task copyWith({String? text, bool? done, Set<int>? tabIds}) => Task(
    id: id,
    text: text ?? this.text,
    tabIds: tabIds ?? this.tabIds,
    done: done ?? this.done,
  );

  @override
  bool operator ==(Object other) =>
      other is Task &&
      other.id == id &&
      other.text == text &&
      other.done == done &&
      _sameIds(other.tabIds, tabIds);

  @override
  int get hashCode =>
      Object.hash(id, text, done, Object.hashAllUnordered(tabIds));
}

bool _sameIds(Set<int> a, Set<int> b) =>
    a.length == b.length && a.containsAll(b);
