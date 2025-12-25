import 'package:flutter/foundation.dart';

import 'repository/ticket_repository.dart';
import 'storage_service.dart';

/// 票据 API 本地实现
///
/// 说明：
/// - 去掉了所有线上 HTTP 调用，仅保留对本地 SQLite 的读写；
/// - 仍然保留原有类名和方法签名，方便 UI 层无感知切换；
/// - 部分纯线上能力（如机场 IATA 查询）在离线模式下返回空结果。
class TicketApi {
  TicketApi();

  /// 新增票据：始终写入本地 SQLite，并记录变更日志。
  Future<String> addTicket(Map<String, dynamic> data) async {
    // 保持与原语义一致：调用本地仓储写入 ticket
    return TicketRepository.instance.addTicket(data);
  }

  /// 查询当前用户的票据列表（仅本地 SQLite）
  Future<List<Map<String, dynamic>>> getMyTickets() async {
    final cached = StorageService().getCachedUserSync();
    String owner = cached?['userId']?.toString() ?? '1';
    if (cached == null) {
      final persisted = await StorageService().getCachedAdminUser();
      final persistedOwner = persisted?['userId']?.toString();
      if (persistedOwner != null && persistedOwner.isNotEmpty) {
        owner = persistedOwner;
      }
    }

    return TicketRepository.instance.getMyTickets(owner);
  }

  /// 编辑票据：始终更新本地 SQLite，并记录变更日志。
  Future<void> editTicket(String ticketId, Map<String, dynamic> data) async {
    await TicketRepository.instance.editTicket(ticketId, data);
  }

  /// 通过 IATA 码查询机场信息
  ///
  /// 离线模式下暂无本地机场库，这里返回空 Map，调用方需自行降级处理。
  Future<Map<String, dynamic>> getAirportByIata(String iata) async {
    if (kDebugMode) {
      debugPrint('getAirportByIata is disabled in offline-only mode: $iata');
    }
    // 兼容原有调用方 try/catch 逻辑，这里返回空 Map 即可。
    return <String, dynamic>{};
  }
}
