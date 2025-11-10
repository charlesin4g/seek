import 'dart:convert';
import 'http_client.dart';
import 'offline_mode.dart';
import 'repository/station_repository.dart';

class StationApi {
  /// 默认使用全局共享的 HttpClient
  StationApi({HttpClient? client}) : _client = client ?? HttpClient.shared;

  final HttpClient _client;

  Future<Map<String, dynamic>> addStation(Map<String, dynamic> data) async {
    if (OfflineModeManager.instance.isOffline.value) {
      return StationRepository.instance.addStation(data);
    }
    try {
      final raw = await _client.postJson('/api/ticket/station/add', body: data);
      if (raw.isEmpty) return {};
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      await OfflineModeManager.instance.setOffline(true);
      return StationRepository.instance.addStation(data);
    }
  }

  Future<Map<String, dynamic>?> getByCode(String code) async {
    if (OfflineModeManager.instance.isOffline.value) {
      return StationRepository.instance.getByCode(code);
    }
    try {
      final c = Uri.encodeQueryComponent(code.toUpperCase());
      final raw = await _client.getJson('/api/ticket/station?code=$c');
      if (raw.isEmpty) return null;
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      await OfflineModeManager.instance.setOffline(true);
      return StationRepository.instance.getByCode(code);
    }
  }

  Future<List<Map<String, dynamic>>> search(String keyword) async {
    if (OfflineModeManager.instance.isOffline.value) {
      return StationRepository.instance.search(keyword);
    }
    try {
      final q = Uri.encodeQueryComponent(keyword);
      final raw = await _client.getJson('/api/ticket/station/search?keyword=$q');
      if (raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      await OfflineModeManager.instance.setOffline(true);
      return StationRepository.instance.search(keyword);
    }
  }
}