/// Entidad pura del dominio: no sabe nada de Flutter ni de como se guarda.
class Task {
  const Task({
    required this.id,
    required this.text,
    this.done = false,
  });

  final int id;
  final String text;
  final bool done;

  Task copyWith({String? text, bool? done}) => Task(
    id: id,
    text: text ?? this.text,
    done: done ?? this.done,
  );

  @override
  bool operator ==(Object other) =>
      other is Task && other.id == id && other.text == text && other.done == done;

  @override
  int get hashCode => Object.hash(id, text, done);
}