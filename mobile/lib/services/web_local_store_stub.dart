import 'dart:convert';

/// 非 Web 平台的兜底实现：仅内存存储，避免编译依赖
class WebLocalStore {
  WebLocalStore._internal();
  static final WebLocalStore instance = WebLocalStore._internal();

  static const String _ticketsKey = 'web_store_tickets';
  static const String _stationsKey = 'web_store_stations';
  static const String _logsKey = 'web_store_change_logs';
  // 快照与状态键（非 Web 平台内存兜底）
  static const String _formKey = 'web_form_snapshots';
  static const String _sessionKey = 'web_session_state';
  static const String _cacheKey = 'web_temp_cache';

  final Map<String, String> _mem = {};

  String? _getItem(String key) => _mem[key];
  void _setItem(String key, String value) => _mem[key] = value;

  List<Map<String, dynamic>> _readList(String key) {
    final raw = _getItem(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final parsed = jsonDecode(raw);
      if (parsed is List) {
        return parsed.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  void _writeList(String key, List<Map<String, dynamic>> list) {
    _setItem(key, jsonEncode(list));
  }

  void _upsertByKey(String storeKey, Map<String, dynamic> item) {
    final list = _readList(storeKey);
    final k = (item['key'] ?? '').toString();
    final idx = list.indexWhere((e) => (e['key'] ?? '').toString() == k);
    if (idx >= 0) {
      list[idx] = item;
    } else {
      list.add(item);
    }
    _writeList(storeKey, list);
  }

  Future<String> addTicket(Map<String, dynamic> data) async {
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
    final list = _readList(_ticketsKey);
    final idx = list.indexWhere((e) => (e['id']?.toString() ?? '') == id);
    if (idx >= 0) {
      list[idx] = row;
    } else {
      list.insert(0, row);
    }
    _writeList(_ticketsKey, list);
    _appendLog('ticket', id, 'insert', data);
    return id;
  }

  Future<List<Map<String, dynamic>>> getMyTickets(String owner) async {
    final list = _readList(_ticketsKey);
    final filtered = list.where((e) => (e['owner']?.toString() ?? '') == owner).toList();
    filtered.sort((a, b) => (b['updatedAt'] as int).compareTo(a['updatedAt'] as int));
    return filtered;
  }

  Future<void> editTicket(String ticketId, Map<String, dynamic> data) async {
    final list = _readList(_ticketsKey);
    final idx = list.indexWhere((e) => (e['id']?.toString() ?? '') == ticketId);
    if (idx >= 0) {
      list[idx] = {
        ...list[idx],
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
      _writeList(_ticketsKey, list);
      _appendLog('ticket', ticketId, 'update', data);
    }
  }

  Future<Map<String, dynamic>> addStation(Map<String, dynamic> data) async {
    final row = {
      'code': (data['code'] ?? '').toString().toUpperCase(),
      'name': (data['name'] ?? '').toString(),
      'pinyin': (data['pinyin'] ?? '').toString(),
      'city': (data['city'] ?? '').toString(),
    };
    final list = _readList(_stationsKey);
    final idx = list.indexWhere((e) => (e['code']?.toString() ?? '').toUpperCase() == row['code']);
    if (idx >= 0) {
      list[idx] = row;
    } else {
      list.add(row);
    }
    _writeList(_stationsKey, list);
    return row;
  }

  Future<Map<String, dynamic>?> getByCode(String code) async {
    final list = _readList(_stationsKey);
    final found = list.firstWhere(
      (e) => (e['code']?.toString() ?? '').toUpperCase() == code.toUpperCase(),
      orElse: () => {},
    );
    if (found.isEmpty) return null;
    return found;
  }

  Future<List<Map<String, dynamic>>> search(String keyword) async {
    final list = _readList(_stationsKey);
    final key = keyword.toLowerCase();
    if (key.isEmpty) return list.take(50).toList();
    return list
        .where((e) {
          final name = (e['name'] ?? '').toString().toLowerCase();
          final pinyin = (e['pinyin'] ?? '').toString().toLowerCase();
          final city = (e['city'] ?? '').toString().toLowerCase();
          return name.contains(key) || pinyin.contains(key) || city.contains(key);
        })
        .take(50)
        .toList();
  }

  /// 保存一批表单快照（分批写入以避免阻塞）
  Future<int> saveFormSnapshots(Map<String, Map<String, dynamic>> forms) async {
    int saved = 0;
    final entries = forms.entries.toList();
    const batch = 50;
    for (var i = 0; i < entries.length; i += batch) {
      final slice = entries.skip(i).take(batch);
      for (final e in slice) {
        final item = {
          'key': e.key,
          'payload': jsonEncode(e.value),
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'version': 1,
        };
        _upsertByKey(_formKey, item);
        saved++;
      }
      await Future.delayed(const Duration(milliseconds: 1));
    }
    return saved;
  }

  /// 保存会话状态（如当前用户信息、临时状态等）
  Future<void> saveSessionRecord(String key, Map<String, dynamic> payload) async {
    final item = {
      'key': key,
      'payload': jsonEncode(payload),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    _upsertByKey(_sessionKey, item);
  }

  /// 保存临时缓存（页面缓存、临时文件索引等）
  Future<void> saveTempCache(String key, Map<String, dynamic> payload) async {
    final item = {
      'key': key,
      'payload': jsonEncode(payload),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    _upsertByKey(_cacheKey, item);
  }

  void _appendLog(String entity, String entityId, String op, Map<String, dynamic> payload) {
    final logs = _readList(_logsKey);
    final id = logs.isEmpty ? 1 : ((logs.last['id'] as int) + 1);
    logs.add({
      'id': id,
      'entity': entity,
      'entityId': entityId,
      'op': op,
      'payload': jsonEncode(payload),
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    _writeList(_logsKey, logs);
  }

  Future<List<Map<String, dynamic>>> readChangeLogsAfter(int lastId, {int limit = 100}) async {
    final logs = _readList(_logsKey);
    return logs.where((e) => (e['id'] as int) > lastId).take(limit).toList();
  }
}