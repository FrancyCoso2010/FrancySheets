import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/spartito.dart';

class SpartitoStorage {
  static const String _key = 'spartiti';
  static List<Spartito>? _cache;

  static Future<void> save(List<Spartito> spartiti) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final list = spartiti.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(_key, list);
      _cache = List<Spartito>.from(spartiti);
    } catch (e) {
      if (kDebugMode) print('❌ Errore salvataggio Spartiti: $e');
      rethrow;
    }
  }

  static Future<List<Spartito>> load() async {
    if (_cache != null) return List<Spartito>.from(_cache!);

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list == null) return [];

    final validSpartiti = <Spartito>[];
    for (int i = 0; i < list.length; i++) {
      try {
        final dynamic decoded = jsonDecode(list[i]);
        if (decoded is Map) {
          validSpartiti.add(Spartito.fromJson(Map<String, dynamic>.from(decoded)));
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ Spartito corrotto #$i: $e');
      }
    }

    _cache = List<Spartito>.from(validSpartiti);
    return validSpartiti;
  }

  static void clearCache() => _cache = null;
}