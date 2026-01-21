import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'local_db.dart';

class IcloudSyncService {
  IcloudSyncService._internal();
  static final IcloudSyncService instance = IcloudSyncService._internal();

  static const MethodChannel _channel = MethodChannel('com.seek/icloud_sync');
  static const EventChannel _statusChannel = EventChannel('com.seek/icloud_sync_status');

  final StreamController<Map<String, dynamic>> _statusController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  bool _listening = false;

  Future<void> _ensureListenStatus() async {
    if (_listening) return;
    _listening = true;
    _statusChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is Map) {
        _statusController.add(Map<String, dynamic>.from(event));
      }
    }, onError: (Object e) {
      _statusController.add(<String, dynamic>{'state': 'error', 'message': e.toString()});
    });
  }

  Future<void> startFullSync() async {
    await _ensureListenStatus();
    final Map<String, dynamic> payload = await _collectStructuredData();
    final List<String> mediaPaths = await _collectMediaFiles();
    await _channel.invokeMethod('startFullSync', <String, dynamic>{
      'payload': jsonEncode(payload),
      'mediaPaths': mediaPaths,
    });
  }

  Future<Map<String, dynamic>> _collectStructuredData() async {
    final Database db = await LocalDatabase.instance.init();
    final List<Map<String, Object?>> tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
    final Map<String, dynamic> data = <String, dynamic>{};
    for (final Map<String, Object?> row in tables) {
      final String? name = row['name']?.toString();
      if (name == null || name.isEmpty) continue;
      try {
        final List<Map<String, Object?>> rows = await db.rawQuery('SELECT * FROM ' + name);
        data[name] = rows.map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList();
      } catch (_) {}
    }
    return data;
  }

  Future<List<String>> _collectMediaFiles() async {
    final Directory docs = await getApplicationDocumentsDirectory();
    final List<String> collected = <String>[];
    Future<void> scanDir(String sub) async {
      final Directory dir = Directory(p.join(docs.path, sub));
      if (await dir.exists()) {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final String ext = p.extension(entity.path).toLowerCase();
            if (['.jpg', '.jpeg', '.png', '.gif', '.heic', '.mp4', '.mov', '.avi'].contains(ext)) {
              collected.add(entity.path);
            }
          }
        }
      }
    }
    await scanDir('user/uploads');
    await scanDir('user_photos');
    await scanDir('trail_activities');
    return collected;
  }
}

