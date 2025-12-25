import 'dart:typed_data';

/// 本地图片存储服务（非 IO 平台占位实现）
///
/// 说明：
/// - 为避免在 Web 平台引入 dart:io/path_provider 导致编译失败，使用条件导入；
/// - 非 IO 平台调用时会抛出 UnsupportedError，调用方应提前判断平台类型。
class LocalImageStorage {
  const LocalImageStorage();

  Future<String> saveUserPhoto(Uint8List bytes) async {
    throw UnsupportedError('Local image storage is not supported on this platform');
  }

  Future<String> saveTrailActivityImage({
    required String activityId,
    required Uint8List bytes,
  }) async {
    throw UnsupportedError('Local image storage is not supported on this platform');
  }
}
