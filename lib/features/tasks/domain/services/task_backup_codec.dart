import '../entities/task.dart';

/// Convierte la lista a texto plano y de regreso.
/// El formato es una checklist legible: [x] hecha, [ ] pendiente.
class TaskBackupCodec {
  const TaskBackupCodec();

  static final RegExp _line = RegExp(r'^\s*\[\s*([xX ])\s*\]\s*(.+)$');

  String encode(List<Task> tasks, {DateTime? at}) {
    final now = at ?? DateTime.now();
    final done = tasks.where((t) => t.done).length;

    final buffer = StringBuffer()
      ..writeln('# PENDIENTES / MOD. TD-01')
      ..writeln('# exportado ${_stamp(now)}')
      ..writeln('# $done de ${tasks.length} hechas')
      ..writeln();

    for (final t in tasks) {
      buffer.writeln('${t.done ? '[x]' : '[ ]'} ${t.text}');
    }
    return buffer.toString().trimRight();
  }

  /// Lanza [FormatException] si no encuentra ninguna tarea valida.
  List<Task> decode(String raw) {
    final tasks = <Task>[];
    var id = 0;

    for (final rawLine in raw.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final match = _line.firstMatch(line);
      if (match != null) {
        final marked = match.group(1)!.toLowerCase() == 'x';
        final text = match.group(2)!.trim();
        if (text.isEmpty) continue;
        tasks.add(Task(id: ++id, text: text, done: marked));
        continue;
      }

      // Linea suelta sin corchetes: se toma como pendiente.
      tasks.add(Task(id: ++id, text: line, done: false));
    }

    if (tasks.isEmpty) {
      throw const FormatException('No se encontraron tareas en el texto.');
    }
    return tasks;
  }

  String _stamp(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} '
        '${two(d.hour)}:${two(d.minute)}';
  }
}