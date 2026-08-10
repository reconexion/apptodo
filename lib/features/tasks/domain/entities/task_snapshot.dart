import 'task.dart';
import 'task_tab.dart';

/// Estado completo: pestanas + tareas. Es lo que devuelve el repositorio
/// en cada operacion, para que la vista siempre tenga la foto entera.
class TaskSnapshot {
  const TaskSnapshot({required this.tabs, required this.tasks});

  final List<TaskTab> tabs;
  final List<Task> tasks;

  static const empty = TaskSnapshot(tabs: [], tasks: []);
}