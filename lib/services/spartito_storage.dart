import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/spartito.dart';

class SpartitoStorage {
  static const _key = 'spartiti';

  static Future<void> save(List<Spartito> spartiti) async {
    final prefs = await SharedPreferences.getInstance();
    final list = spartiti.map((s) => json.encode(s.toJson())).toList();
    await prefs.setStringList(_key, list);
  }

  static Future<List<Spartito>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list == null) return [];
    return list.map((s) => Spartito.fromJson(json.decode(s))).toList();
  }
}
