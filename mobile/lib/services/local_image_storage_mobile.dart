import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 本地图片存储服务（移动端/桌面端 IO 平台实现）
class LocalImageStorage {
  const LocalImageStorage();

  Future<String> _ensureSubDir(String subDir) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final Directory dir = Directory(p.join(baseDir.path, subDir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// 保存用户头像/照片到本地目录，并返回文件路径
  Future<String> saveUserPhoto(Uint8List bytes) async {
    final String dirPath = await _ensureSubDir('user_photos');
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = p.join(dirPath, fileName);
    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }

  /// 保存某次活动的图片到本地目录，并返回文件路径
  Future<String> saveTrailActivityImage({
    required String activityId,
    required Uint8List bytes,
  }) async {
    final String dirPath = await _ensureSubDir('trail_activities/$activityId');
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = p.join(dirPath, fileName);
    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }
}
