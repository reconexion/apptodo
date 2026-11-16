import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/mission.dart';
import '../models/mission_model.dart';

/// Las misiones viven en el telefono, junto a las tareas.
class MissionLocalDataSource {
  const MissionLocalDataSource(this._prefs);

  static const key = 'todoapp.missions';

  final SharedPreferences _prefs;

  List<Mission> read() {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MissionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> write(List<Mission> missions) => _prefs.setString(
    key,
    jsonEncode(missions.map(MissionModel.toJson).toList()),
  );
}
