import 'dart:convert';
import 'http_client.dart';
import 'storage_service.dart';
// 统一由 HttpClient.shared 管理 baseUrl 与请求头

class ActivityApi {
  /// 默认使用全局共享的 HttpClient
  ActivityApi({HttpClient? client}) : _client = client ?? HttpClient.shared;

  final HttpClient _client;

  /// 获取当前用户的活动列表（按时间倒序）
  Future<List<Map<String, dynamic>>> getMyActivities() async {
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
    // 后端接口采用 Path 变量：/api/activity/owner/{owner}
    final raw = await _client.getJson('/api/activity/owner/$owner');
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}