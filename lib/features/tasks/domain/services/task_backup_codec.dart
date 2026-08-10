import '../entities/task.dart';
import '../entities/task_snapshot.dart';
import '../entities/task_tab.dart';

/// Convierte todo a texto plano y de regreso.
/// Formato: "## NOMBRE" abre una pestana, [x] hecha, [ ] pendiente.
class TaskBackupCodec {
  const TaskBackupCodec();

  static final RegExp _taskLine = RegExp(r'^\s*\[\s*([xX ])\s*\]\s*(.+)$');
  static final RegExp _tabLine = RegExp(r'^\s*##\s*(.+)$');

  String encode(List<TaskTab> tabs, List<Task> tasks, {DateTime? at}) {
    final now = at ?? DateTime.now();
    final done = tasks.where((t) => t.done).length;

    final buffer = StringBuffer()
      ..writeln('# PENDIENTES / MOD. TD-01')
      ..writeln('# exportado ${_stamp(now)}')
      ..writeln('# $done de ${tasks.length} hechas')
      ..writeln();

    for (final tab in tabs) {
      buffer.writeln('## ${tab.name}');
      for (final t in tasks.where((t) => t.tabId == tab.id)) {
        buffer.writeln('${t.done ? '[x]' : '[ ]'} ${t.text}');
      }
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  /// Lanza [FormatException] si no encuentra nada aprovechable.
  TaskSnapshot decode(String raw) {
    final tabs = <TaskTab>[];
    final tasks = <Task>[];
    var tabId = 0;
    var taskId = 0;

    void ensureTab() {
      if (tabs.isEmpty) tabs.add(TaskTab(id: ++tabId, name: 'GENERAL'));
    }

    for (final rawLine in raw.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final tabMatch = _tabLine.firstMatch(line);
      if (tabMatch != null) {
        final name = tabMatch.group(1)!.trim();
        if (name.isNotEmpty) tabs.add(TaskTab(id: ++tabId, name: name));
        continue;
      }

      // Comentarios de cabecera.
      if (line.startsWith('#')) continue;

      final taskMatch = _taskLine.firstMatch(line);
      if (taskMatch != null) {
        final text = taskMatch.group(2)!.trim();
        if (text.isEmpty) continue;
        ensureTab();
        tasks.add(Task(
          id: ++taskId,
          text: text,
          tabId: tabs.last.id,
          done: taskMatch.group(1)!.toLowerCase() == 'x',
        ));
        continue;
      }

      // Linea suelta sin corchetes: se toma como pendiente.
      ensureTab();
      tasks.add(Task(id: ++taskId, text: line, tabId: tabs.last.id));
    }

    if (tabs.isEmpty) {
      throw const FormatException('No se encontraron tareas en el texto.');
    }
    return TaskSnapshot(tabs: tabs, tasks: tasks);
  }

  String _stamp(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} '
        '${two(d.hour)}:${two(d.minute)}';
  }
}