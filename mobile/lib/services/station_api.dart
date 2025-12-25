import 'repository/station_repository.dart';

/// 车站 API 本地实现
///
/// 说明：
/// - 去掉了所有线上 HTTP 调用，仅通过 StationRepository 访问本地 SQLite；
/// - 保留原有类名和方法签名，避免影响调用方；
/// - 在线/离线切换逻辑由上层 OfflineModeManager 控制，这里只关心本地数据。
class StationApi {
  StationApi();

  /// 新增车站：直接写入本地 SQLite。
  Future<Map<String, dynamic>> addStation(Map<String, dynamic> data) {
    return StationRepository.instance.addStation(data);
  }

  /// 按站码查询车站（仅本地 SQLite）
  Future<Map<String, dynamic>?> getByCode(String code) {
    return StationRepository.instance.getByCode(code);
  }

  /// 关键字搜索车站（仅本地 SQLite）
  Future<List<Map<String, dynamic>>> search(String keyword) {
    return StationRepository.instance.search(keyword);
  }
}
