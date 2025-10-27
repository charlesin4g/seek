import 'dart:convert';
import 'http_client.dart';
import 'storage_service.dart';

class TicketApi {
  /// 默认使用全局共享的 HttpClient
  TicketApi({HttpClient? client}) : _client = client ?? HttpClient.shared;

  final HttpClient _client;

  Future<String> addTicket(Map<String, dynamic> data) async {
    // 与装备保持一致，采用 POST 方式
    return _client.postJson('/api/ticket/add', body: data);
  }

  Future<List<Map<String, dynamic>>> getMyTickets() async {
    // 优先使用内存缓存的用户ID，若为空则从持久化存储读取
    final cached = StorageService().getCachedUserSync();
    String owner = cached?['userId']?.toString() ?? '1';
    if (cached == null) {
      final persisted = await StorageService().getCachedAdminUser();
      final persistedOwner = persisted?['userId']?.toString();
      if (persistedOwner != null && persistedOwner.isNotEmpty) {
        owner = persistedOwner;
      }
    }

    final raw = await _client.getJson('/api/ticket/owner?owner=$owner');
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> editTicket(String ticketId, Map<String, dynamic> data) async {
    await _client.putJson('/api/ticket/edit?ticketId=$ticketId', body: data);
  }

  Future<Map<String, dynamic>> getAirportByIata(String iata) async {
    final code = Uri.encodeQueryComponent(iata.toUpperCase());
    final raw = await _client.getJson('/api/ticket/airport?iata=$code');
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}