import 'dart:convert';
import 'http_client.dart';

class StationApi {
  /// 默认使用全局共享的 HttpClient
  StationApi({HttpClient? client}) : _client = client ?? HttpClient.shared;

  final HttpClient _client;

  Future<Map<String, dynamic>> addStation(Map<String, dynamic> data) async {
    final raw = await _client.postJson('/api/ticket/station/add', body: data);
    if (raw.isEmpty) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<Map<String, dynamic>?> getByCode(String code) async {
    final c = Uri.encodeQueryComponent(code.toUpperCase());
    final raw = await _client.getJson('/api/ticket/station?code=$c');
    if (raw.isEmpty) return null;
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<List<Map<String, dynamic>>> search(String keyword) async {
    final q = Uri.encodeQueryComponent(keyword);
    final raw = await _client.getJson('/api/ticket/station/search?keyword=$q');
    if (raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}