import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parte.dart';

class ParteStorage {
  static const String _key = 'parti';
  static List<Parte>? _cache;

  static Future<void> save(List<Parte> parti) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final list = parti.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_key, list);
      _cache = List<Parte>.from(parti);
    } catch (e) {
      if (kDebugMode) print('❌ Errore salvataggio Parti: $e');
      rethrow;
    }
  }

  static Future<List<Parte>> load() async {
    if (_cache != null) return List<Parte>.from(_cache!);

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list == null) return [];

    final validParti = <Parte>[];
    for (int i = 0; i < list.length; i++) {
      try {
        final dynamic decoded = jsonDecode(list[i]);
        if (decoded is Map) {
          validParti.add(Parte.fromJson(Map<String, dynamic>.from(decoded)));
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ Parte corrotta #$i: $e');
      }
    }

    _cache = List<Parte>.from(validParti);
    return validParti;
  }

  static void clearCache() => _cache = null;
}