import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parte.dart';

class ParteStorage {
  static const _key = 'parti';

  static Future<void> save(List<Parte> parti) async {
    final prefs = await SharedPreferences.getInstance();
    final list = parti.map((p) => json.encode(p.toJson())).toList();
    await prefs.setStringList(_key, list);
  }

  static Future<List<Parte>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list == null) return [];
    return list.map((s) => Parte.fromJson(json.decode(s))).toList();
  }
}
