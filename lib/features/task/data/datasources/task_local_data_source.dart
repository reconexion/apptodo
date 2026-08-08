import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';

/// Fuente local. Todo vive en el telefono, cero internet.
abstract class TaskLocalDataSource {
  Future<List<TaskModel>> read();
  Future<void> write(List<TaskModel> tasks);
}

class SharedPrefsTaskLocalDataSource implements TaskLocalDataSource {
  const SharedPrefsTaskLocalDataSource(this._prefs);

  /// Misma llave que la version web, por si algun dia sincronizas.
  static const storageKey = 'todoapp.tasks';

  final SharedPreferences _prefs;

  @override
  Future<List<TaskModel>> read() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> write(List<TaskModel> tasks) async {
    final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(storageKey, raw);
  }
}