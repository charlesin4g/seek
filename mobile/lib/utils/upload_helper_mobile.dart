import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// 上传助手（移动端实现：iOS/Android）
class UploadHelper {
  UploadHelper() : _picker = ImagePicker();

  final ImagePicker _picker;

  /// 从相册选择图片并返回字节内容
  Future<Uint8List?> pickImageBytes() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return null;
    }
    return file.readAsBytes();
  }
}
