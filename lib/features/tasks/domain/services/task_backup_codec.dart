import '../entities/task.dart';
import '../entities/task_snapshot.dart';
import '../entities/task_tab.dart';

/// Convierte todo a texto plano y de regreso.
/// Formato: "## NOMBRE" declara una pestana. Cada tarea puede llevar
/// "{Nombre, Nombre2}" antes del texto para ligarse a varias a la vez.
class TaskBackupCodec {
  const TaskBackupCodec();

  static final RegExp _taskLine =
      RegExp(r'^\s*\[\s*([xX ])\s*\]\s*(?:\{([^}]*)\}\s*)?(.+)$');
  static final RegExp _tabLine = RegExp(r'^\s*##\s*(.+)$');

  String encode(List<TaskTab> tabs, List<Task> tasks, {DateTime? at}) {
    final now = at ?? DateTime.now();
    final done = tasks.where((t) => t.done).length;
    final nameById = {for (final tab in tabs) tab.id: tab.name};

    final buffer = StringBuffer()
      ..writeln('# PENDIENTES / MOD. TD-01')
      ..writeln('# exportado ${_stamp(now)}')
      ..writeln('# $done de ${tasks.length} hechas');

    // Se listan todas las pestanas, aunque no tengan ninguna tarea ligada
    // todavia: si no, se perderian al re-importar el respaldo.
    for (final tab in tabs) {
      buffer.writeln('## ${tab.name}');
    }
    buffer.writeln();

    for (final t in tasks) {
      final tagNames =
          t.tabIds.map((id) => nameById[id]).whereType<String>().toList();
      final tags = tagNames.isEmpty ? '' : '{${tagNames.join(', ')}} ';
      buffer.writeln('${t.done ? '[x]' : '[ ]'} $tags${t.text}');
    }
    return buffer.toString().trimRight();
  }

  /// Lanza [FormatException] si no encuentra nada aprovechable.
  /// Si el texto no trae ninguna linea "## nombre" ni "{...}", las tareas
  /// quedan sin pestana: quien llama decide a donde van.
  TaskSnapshot decode(String raw) {
    final tabs = <TaskTab>[];
    final tasks = <Task>[];
    final tabIdByName = <String, int>{};
    var tabId = 0;
    var taskId = 0;
    // Pestana bajo la que va cayendo cada tarea suelta (sin "{...}" propio),
    // igual que el anidado clasico: 0 significa "todavia ninguna".
    var currentTabId = 0;

    int tabIdFor(String name) {
      final key = name.toLowerCase();
      final existing = tabIdByName[key];
      if (existing != null) return existing;
      final id = ++tabId;
      tabIdByName[key] = id;
      tabs.add(TaskTab(id: id, name: name));
      return id;
    }

    for (final rawLine in raw.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final tabMatch = _tabLine.firstMatch(line);
      if (tabMatch != null) {
        final name = tabMatch.group(1)!.trim();
        if (name.isNotEmpty) currentTabId = tabIdFor(name);
        continue;
      }

      if (line.startsWith('#')) continue;

      final taskMatch = _taskLine.firstMatch(line);
      if (taskMatch != null) {
        final marked = taskMatch.group(1)!.toLowerCase() == 'x';
        final tagsRaw = taskMatch.group(2);
        final text = taskMatch.group(3)!.trim();
        if (text.isEmpty) continue;

        final tabIds = <int>{};
        if (tagsRaw != null && tagsRaw.isNotEmpty) {
          // "{...}" explicito: liga exactamente a esas, sin importar
          // bajo que "##" este anidada la linea.
          for (final name in tagsRaw.split(',')) {
            final clean = name.trim();
            if (clean.isNotEmpty) tabIds.add(tabIdFor(clean));
          }
        } else if (currentTabId != 0) {
          // Sin "{...}": hereda la pestana del "##" bajo el que esta anidada.
          tabIds.add(currentTabId);
        }

        tasks.add(Task(id: ++taskId, text: text, done: marked, tabIds: tabIds));
        continue;
      }

      // Linea suelta sin corchetes: se toma como pendiente, hereda igual.
      final tabIds = currentTabId == 0 ? const <int>{} : {currentTabId};
      tasks.add(Task(id: ++taskId, text: line, tabIds: tabIds));
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
