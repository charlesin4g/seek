import 'dart:typed_data';

/// 上传助手（非 Web 平台占位实现）
///
/// 说明：
/// - 为了避免在移动端引入 dart:html 导致编译失败，使用条件导入；
/// - 非 Web 平台该方法返回 null，后续可接入 image_picker 或 file_picker。
class UploadHelper {
  /// 选择图片文件并返回二进制内容（非 Web 默认无实现）
  Future<Uint8List?> pickImageBytes() async {
    return null;
  }
}