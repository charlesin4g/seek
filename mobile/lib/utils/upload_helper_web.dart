import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

/// 上传助手（Web 平台实现）
///
/// 使用原生 <input type="file"> 选择图片并读取为字节。
class UploadHelper {
  Future<Uint8List?> pickImageBytes() async {
    final completer = Completer<Uint8List?>();
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final file = files.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final data = reader.result;
        if (data is ByteBuffer) {
          completer.complete(Uint8List.view(data));
        } else {
          completer.complete(null);
        }
      });
      reader.onError.listen((_) => completer.complete(null));
    });
    return completer.future;
  }
}