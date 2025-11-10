import 'dart:convert';
import 'http_client.dart';
import 'offline_mode.dart';
import 'repository/ticket_repository.dart';
import 'storage_service.dart';

class TicketApi {
  /// 默认使用全局共享的 HttpClient
  TicketApi({HttpClient? client}) : _client = client ?? HttpClient.shared;

  final HttpClient _client;

  Future<String> addTicket(Map<String, dynamic> data) async {
    // 在线/离线路由：保持接口兼容
    if (OfflineModeManager.instance.isOffline.value) {
      // 离线：写入本地加密数据库，并记录变更日志
      return TicketRepository.instance.addTicket(data);
    }
    // 在线：与后端交互
    try {
      return _client.postJson('/api/ticket/add', body: data);
    } catch (_) {
      // 网络失败：自动切换离线并回退到本地存储
      await OfflineModeManager.instance.setOffline(true);
      return TicketRepository.instance.addTicket(data);
    }
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

    if (OfflineModeManager.instance.isOffline.value) {
      return TicketRepository.instance.getMyTickets(owner);
    }
    try {
      final raw = await _client.getJson('/api/ticket/owner?owner=$owner');
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      await OfflineModeManager.instance.setOffline(true);
      return TicketRepository.instance.getMyTickets(owner);
    }
  }

  Future<void> editTicket(String ticketId, Map<String, dynamic> data) async {
    if (OfflineModeManager.instance.isOffline.value) {
      await TicketRepository.instance.editTicket(ticketId, data);
      return;
    }
    try {
      await _client.putJson('/api/ticket/edit?ticketId=$ticketId', body: data);
    } catch (_) {
      await OfflineModeManager.instance.setOffline(true);
      await TicketRepository.instance.editTicket(ticketId, data);
    }
  }

  Future<Map<String, dynamic>> getAirportByIata(String iata) async {
    final code = Uri.encodeQueryComponent(iata.toUpperCase());
    final raw = await _client.getJson('/api/ticket/airport?iata=$code');
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}