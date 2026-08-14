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
  /// Si el texto no trae ninguna linea "## nombre", [TaskSnapshot.tabs]
  /// queda vacio y todas las tareas usan tabId 0 (sin resolver): quien
  /// llama decide a que pestana van.
  TaskSnapshot decode(String raw) {
    final tabs = <TaskTab>[];
    final tasks = <Task>[];
    var tabId = 0;
    var taskId = 0;
    var currentTabId = 0;

    for (final rawLine in raw.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final tabMatch = _tabLine.firstMatch(line);
      if (tabMatch != null) {
        final name = tabMatch.group(1)!.trim();
        if (name.isNotEmpty) {
          final tab = TaskTab(id: ++tabId, name: name);
          tabs.add(tab);
          currentTabId = tab.id;
        }
        continue;
      }

      if (line.startsWith('#')) continue;

      final taskMatch = _taskLine.firstMatch(line);
      if (taskMatch != null) {
        final text = taskMatch.group(2)!.trim();
        if (text.isEmpty) continue;
        tasks.add(Task(
          id: ++taskId,
          text: text,
          tabId: currentTabId,
          done: taskMatch.group(1)!.toLowerCase() == 'x',
        ));
        continue;
      }

      // Linea suelta sin corchetes: se toma como pendiente.
      tasks.add(Task(id: ++taskId, text: line, tabId: currentTabId));
    }

    if (tasks.isEmpty) {
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