import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';
import '../models/task_tab_model.dart';

/// Fuente local. Todo vive en el telefono, cero internet.
abstract class TaskLocalDataSource {
  Future<List<TaskTabModel>> readTabs();
  Future<List<TaskModel>> readTasks(int fallbackTabId);
  Future<void> write(List<TaskTabModel> tabs, List<TaskModel> tasks);
}

class SharedPrefsTaskLocalDataSource implements TaskLocalDataSource {
  const SharedPrefsTaskLocalDataSource(this._prefs);

  static const tasksKey = 'todoapp.tasks';
  static const tabsKey = 'todoapp.tabs';

  final SharedPreferences _prefs;

  @override
  Future<List<TaskTabModel>> readTabs() async {
    final raw = _prefs.getString(tabsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TaskTabModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<TaskModel>> readTasks(int fallbackTabId) async {
    final raw = _prefs.getString(tasksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) =>
          TaskModel.fromJson(e as Map<String, dynamic>, fallbackTabId))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> write(List<TaskTabModel> tabs, List<TaskModel> tasks) async {
    await _prefs.setString(
      tabsKey,
      jsonEncode(tabs.map((t) => t.toJson()).toList()),
    );
    await _prefs.setString(
      tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }
}