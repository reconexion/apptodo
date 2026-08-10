/// Entidad pura del dominio: no sabe nada de Flutter ni de como se guarda.
class Task {
  const Task({
    required this.id,
    required this.text,
    required this.tabId,
    this.done = false,
  });

  final int id;
  final String text;

  /// Pestana a la que pertenece.
  final int tabId;
  final bool done;

  Task copyWith({String? text, bool? done, int? tabId}) => Task(
    id: id,
    text: text ?? this.text,
    tabId: tabId ?? this.tabId,
    done: done ?? this.done,
  );

  @override
  bool operator ==(Object other) =>
      other is Task &&
          other.id == id &&
          other.text == text &&
          other.tabId == tabId &&
          other.done == done;

  @override
  int get hashCode => Object.hash(id, text, tabId, done);
}