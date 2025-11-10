import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../local_db.dart';
import '../web_local_store.dart';

/// 票据离线仓储（本地等效实现）
/// 保持与线上 TicketApi 方法语义一致
class TicketRepository {
  TicketRepository._internal();
  static final TicketRepository instance = TicketRepository._internal();

  /// 添加票据并记录变更日志
  Future<String> addTicket(Map<String, dynamic> data) async {
    // Web 平台：走 localStorage
    if (kIsWeb) {
      return WebLocalStore.instance.addTicket(data);
    }
    final db = await LocalDatabase.instance.init();
    final id = data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    final row = {
      'id': id,
      'owner': (data['owner'] ?? '1').toString(),
      'category': data['category']?.toString(),
      'travelNo': data['travelNo']?.toString(),
      'fromPlace': data['fromPlace']?.toString(),
      'toPlace': data['toPlace']?.toString(),
      'departureTime': data['departureTime']?.toString(),
      'arrivalTime': data['arrivalTime']?.toString(),
      'seatClass': data['seatClass']?.toString(),
      'seatNo': data['seatNo']?.toString(),
      'price': (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      'currency': data['currency']?.toString(),
      'passengerName': data['passengerName']?.toString(),
      'remark': data['remark']?.toString(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'synced': 0,
    };

    await LocalDatabase.instance.runInTransaction((tx) async {
      await tx.insert('ticket', row, conflictAlgorithm: ConflictAlgorithm.replace);
      await tx.insert('change_log', {
        'entity': 'ticket',
        'entityId': id,
        'op': 'insert',
        'payload': jsonEncode(data),
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
    });
    return id;
  }

  /// 查询我的票据
  Future<List<Map<String, dynamic>>> getMyTickets(String owner) async {
    if (kIsWeb) {
      return WebLocalStore.instance.getMyTickets(owner);
    }
    final db = await LocalDatabase.instance.init();
    final rows = await db.query(
      'ticket',
      where: 'owner = ?',
      whereArgs: [owner],
      orderBy: 'updatedAt DESC',
    );
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// 编辑票据并记录变更日志
  Future<void> editTicket(String ticketId, Map<String, dynamic> data) async {
    if (kIsWeb) {
      await WebLocalStore.instance.editTicket(ticketId, data);
      return;
    }
    await LocalDatabase.instance.runInTransaction((tx) async {
      await tx.update(
        'ticket',
        {
          'category': data['category']?.toString(),
          'travelNo': data['travelNo']?.toString(),
          'fromPlace': data['fromPlace']?.toString(),
          'toPlace': data['toPlace']?.toString(),
          'departureTime': data['departureTime']?.toString(),
          'arrivalTime': data['arrivalTime']?.toString(),
          'seatClass': data['seatClass']?.toString(),
          'seatNo': data['seatNo']?.toString(),
          'price': (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
          'currency': data['currency']?.toString(),
          'passengerName': data['passengerName']?.toString(),
          'remark': data['remark']?.toString(),
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'synced': 0,
        },
        where: 'id = ?',
        whereArgs: [ticketId],
      );
      await tx.insert('change_log', {
        'entity': 'ticket',
        'entityId': ticketId,
        'op': 'update',
        'payload': jsonEncode(data),
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }
}