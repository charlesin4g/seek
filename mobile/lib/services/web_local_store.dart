// 条件导入：Web 使用 localStorage 实现；非 Web 使用内存存储兜底
import 'web_local_store_stub.dart' if (dart.library.html) 'web_local_store_web.dart';

// 统一导出适配类
export 'web_local_store_stub.dart' if (dart.library.html) 'web_local_store_web.dart';