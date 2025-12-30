import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../local_db.dart';
import '../web_local_store.dart';

/// 票据离线仓储（本地等效实现)
class TicketRepository {
  TicketRepository._internal();
  static final TicketRepository instance = TicketRepository._internal();

  Future<Database> _db() => LocalDatabase.instance.init();

  /// 添加票据并记录变更日志（仅本地 SQLite）
  Future<String> addTicket(Map<String, dynamic> data) async {
    final db = await _db();

    final String category = data['category'];

    final Map<String, Object?> row = <String, Object?>{
      'category': category,
      // 同时兼容 travel_no 与 travelNo
      'travel_no': (data['travel_no'] ?? data['travelNo'])?.toString(),
      'from': (data['from'] ?? data['fromPlace'])?.toString(),
      'to': (data['to'] ?? data['toPlace'])?.toString(),
      'departure_time': (data['departure_time'] ?? data['departureTime'])
          ?.toString(),
      'arrival_time': (data['arrival_time'] ?? data['arrivalTime'])?.toString(),
      'seat_class': (data['seat_class'] ?? data['seatClass'])?.toString(),
      'seat_no': (data['seat_no'] ?? data['seatNo'])?.toString(),
      'price': parsePrice(data['price']),
      'carrier': data['carrier']?.toString() ?? '',
      // 优先显式 ticket_no，其次订单号
      'ticket_no': data['ticket_no'] ?? data['ticketNo']?.toString(),
    };

    final int newId = await db.insert('tickets', row);
    return newId.toString();
  }

  /// 查询我的票据（本地数据不需要按按 owner 过滤，返回本地所有票据）
  Future<List<Map<String, dynamic>>> getMyTickets() async {

    final db = await _db();

    // 使用列别名，适配 Ticket.fromJson 现有字段命名
    final List<Map<String, Object?>> rows = await db.rawQuery('''
      SELECT
        id,
        category,
        travel_no      AS travelNo,
        "from"         AS fromPlace,
        "to"           AS toPlace,
        departure_time AS departureTime,
        arrival_time   AS arrivalTime,
        seat_class     AS seatClass,
        seat_no        AS seatNo,
        price,
        carrier,
        ticket_no
      FROM tickets
      ORDER BY COALESCE(departure_time, 0) DESC
    ''');

    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// 编辑票据（仅本地 SQLite）
  Future<void> editTicket(String ticketId, Map<String, dynamic> data) async {
    if (kIsWeb) {
      await WebLocalStore.instance.editTicket(ticketId, data);
      return;
    }

    final db = await _db();

    double parsePrice(dynamic v) {
      if (v is num) return v.toDouble();
      if (v == null) return 0.0;
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final Map<String, Object?> row = <String, Object?>{
      'category': (data['category'] ?? '').toString(),
      'travel_no': (data['travel_no'] ?? data['travelNo'])?.toString(),
      'from': (data['from'] ?? data['fromPlace'])?.toString(),
      'to': (data['to'] ?? data['toPlace'])?.toString(),
      'departure_time': (data['departure_time'] ?? data['departureTime'])
          ?.toString(),
      'arrival_time': (data['arrival_time'] ?? data['arrivalTime'])?.toString(),
      'seat_class': (data['seat_class'] ?? data['seatClass'])?.toString(),
      'seat_no': (data['seat_no'] ?? data['seatNo'])?.toString(),
      'price': parsePrice(data['price']),
      'carrier': data['carrier']?.toString() ?? '',
      'ticket_no': data['ticket_no'] ?? data['ticketNo']?.toString(),
    };

    await db.update(
      'tickets',
      row,
      where: 'id = ?',
      whereArgs: <Object>[ticketId],
    );
  }

  double parsePrice(dynamic v) {
    if (v is num) return v.toDouble();
    if (v == null) return 0.0;
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
