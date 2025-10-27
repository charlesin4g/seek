import 'dart:convert';
import 'http_client.dart';
import 'storage_service.dart';

/// 用户照片相关 API 封装
///
/// 说明：统一使用项目通用的 `HttpClient`，由其内部管理 `baseUrl` 与默认请求头。
class PhotoApi {
  /// 使用项目通用的 HttpClient；如需自定义可通过参数传入
  PhotoApi({HttpClient? client}) : _client = client ?? HttpClient.shared;

  final HttpClient _client;

  /// 获取当前用户的照片墙（按创建时间倒序）
  Future<List<String>> getMyPhotos() async {
    final cached = StorageService().getCachedUserSync();
    String owner = cached?['userId']?.toString() ?? '1';
    if (cached == null) {
      final persisted = await StorageService().getCachedAdminUser();
      final persistedOwner = persisted?['userId']?.toString();
      if (persistedOwner != null && persistedOwner.isNotEmpty) {
        owner = persistedOwner;
      }
    }

    final raw = await _client.getJson('/api/photo/owner/$owner');
    final decoded = jsonDecode(raw) as List;
    // 后端返回 UserPhotoItem 列表，取 url 字段作为图片地址
    return decoded
        .map((e) => (e as Map<String, dynamic>)['url']?.toString())
        .where((u) => u != null && u.isNotEmpty)
        .map((u) => u!)
        .toList();
  }

  /// 生成用于直传的 PUT 临时签名 URL
  ///
  /// 前端可对该 URL 直接进行 HTTP PUT 上传二进制内容。
  Future<String?> signPutUrl(String key) async {
    final raw = await _client.getJson('/api/oss/sign-put?key=$key');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded['url']?.toString();
  }

  /// 新增一条用户照片记录（上传成功后调用）
  Future<void> addPhotoRecord({
    required String owner,
    required String objectKey,
    String? title,
    String? description,
  }) async {
    await _client.postJson(
      '/api/photo/add',
      body: {
        'owner': owner,
        'objectKey': objectKey,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
      },
    );
  }
}