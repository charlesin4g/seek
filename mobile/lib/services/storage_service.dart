import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String UserKey = 'user_key';

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setJson(String key, Map<String, dynamic> json) async {
    await setString(key, jsonEncode(json));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Convenience helpers for admin user
  Future<void> cacheUser(Map<String, dynamic> user) async {
    await setJson(UserKey, user);
  }

  Future<Map<String, dynamic>?> getCachedAdminUser() async {
    return getJson(UserKey);
  }
}
