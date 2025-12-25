import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:sqflite/sqflite.dart';

import '../local_db.dart';
import '../../pages/activity/activity_trip.dart';

/// 活动（activity）本地仓储
///
/// - 从 activity 表中按时间倒序分页查询活动记录
class ActivityRepository {
  ActivityRepository._internal();
  static final ActivityRepository instance = ActivityRepository._internal();

  final StreamController<ActivityTrip> _tripUpdatesController =
      StreamController<ActivityTrip>.broadcast();

  Stream<ActivityTrip> get tripUpdates => _tripUpdatesController.stream;

  Future<Database> _db() => LocalDatabase.instance.init();

  Future<void> _ensureActivityImageColumns(Database db) async {
    final List<Map<String, Object?>> columns =
        await db.rawQuery('PRAGMA table_info(activity)');
    final Set<String> columnNames = columns
        .map((Map<String, Object?> row) => row['name']?.toString() ?? '')
        .toSet();

    if (!columnNames.contains('images')) {
      await db.execute('ALTER TABLE activity ADD COLUMN images TEXT');
    }
    if (!columnNames.contains('star_image')) {
      await db.execute('ALTER TABLE activity ADD COLUMN star_image TEXT');
    }
  }

  /// 从本地 activity 表分页读取活动记录
  ///
  /// SQL 必须包含字段：
  ///   id, name, type, description, activity_time,
  ///   avg_heart_rate, max_heart_rate, avg_speed, max_speed,
  ///   calories, distance,
  ///   elevation_gain, elevation_loss, max_elevation, min_elevation,
  ///   moving_time_sec, total_duration_sec,
  ///   image_count, location, images, star_image
  Future<List<ActivityTrip>> getActivityTripsPage({
    required int limit,
    required int offset,
  }) async {
    final db = await _db();
    await _ensureActivityImageColumns(db);

    const String sql = '''
      SELECT id, name, type, description, activity_time,
             avg_heart_rate, max_heart_rate, avg_speed, max_speed,
             calories, distance,
             elevation_gain, elevation_loss, max_elevation, min_elevation,
             moving_time_sec, total_duration_sec,
             image_count, location, images, star_image
      FROM activity
      ORDER BY activity_time DESC
      LIMIT ? OFFSET ?
    ''';

    final List<Map<String, Object?>> rows =
        await db.rawQuery(sql, <Object>[limit, offset]);

    return rows.map(_mapActivityRowToTrip).toList();
  }

  Future<void> appendActivityImage({
    required String activityId,
    required String imageUrl,
    bool setAsStar = false,
  }) async {
    try {
      final db = await _db();
      await _ensureActivityImageColumns(db);

      final List<Map<String, Object?>> rows = await db.query(
        'activity',
        columns: <String>['images', 'star_image', 'image_count'],
        where: 'id = ?',
        whereArgs: <Object>[activityId],
        limit: 1,
      );

      String imagesRaw = '[]';
      String starImage = '';
      int imageCount = 0;
      if (rows.isNotEmpty) {
        imagesRaw = rows.first['images']?.toString() ?? '[]';
        starImage = rows.first['star_image']?.toString() ?? '';
        imageCount = int.tryParse(rows.first['image_count']?.toString() ?? '0') ??
            0;
      }

      List<String> images;
      try {
        final dynamic decoded = jsonDecode(imagesRaw);
        if (decoded is List) {
          images = decoded.map((dynamic e) => e.toString()).toList();
        } else {
          images = <String>[];
        }
      } catch (_) {
        images = <String>[];
      }

      if (!images.contains(imageUrl)) {
        images.add(imageUrl);
      }

      if (setAsStar || starImage.isEmpty) {
        starImage = imageUrl;
      }

      final String updatedImagesJson = jsonEncode(images);
      imageCount = images.length;

      await db.update(
        'activity',
        <String, Object?>{
          'images': updatedImagesJson,
          'star_image': starImage,
          'image_count': imageCount,
        },
        where: 'id = ?',
        whereArgs: <Object>[activityId],
      );

      // 广播更新，便于列表页实时刷新对应活动项
      final ActivityTrip? updated = await getActivityById(activityId);
      if (updated != null) {
        _tripUpdatesController.add(updated);
      }
    } catch (error, stackTrace) {
      if (!kReleaseMode) {
        debugPrint('ActivityRepository.appendActivityImage failed: $error');
        debugPrint(stackTrace.toString());
      }
      rethrow;
    }
  }

  Future<ActivityTrip?> getActivityById(String id) async {
    final db = await _db();
    await _ensureActivityImageColumns(db);

    const String sql = '''
      SELECT id, name, type, description, activity_time,
             avg_heart_rate, max_heart_rate, avg_speed, max_speed,
             calories, distance,
             elevation_gain, elevation_loss, max_elevation, min_elevation,
             moving_time_sec, total_duration_sec,
             image_count, location, images, star_image
      FROM activity
      WHERE id = ?
      LIMIT 1
    ''';

    final List<Map<String, Object?>> rows =
        await db.rawQuery(sql, <Object>[id]);

    if (rows.isEmpty) {
      return null;
    }

    return _mapActivityRowToTrip(rows.first);
  }

  ActivityTrip _mapActivityRowToTrip(Map<String, Object?> row) {
    String id = row['id']?.toString() ?? '';
    if (id.isEmpty) {
      id = DateTime.now().microsecondsSinceEpoch.toString();
    }

    final String name = row['name']?.toString() ?? '未命名活动';
    final String location = row['location']?.toString() ?? '未知地点';
    final String type = row['type']?.toString() ?? '';
    final String description = row['description']?.toString() ?? '';

    final String activityTimeRaw = row['activity_time']?.toString() ?? '';

    DateTime? activityTime;
    String dateLabel = activityTimeRaw;
    if (activityTimeRaw.isNotEmpty) {
      try {
        final DateTime dt = DateTime.parse(activityTimeRaw);
        activityTime = dt;
        dateLabel =
            '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {
        // 格式异常时保持原始字符串
      }
    }

    final int avgHeartRate = _parseInt(row['avg_heart_rate']);
    final int maxHeartRate = _parseInt(row['max_heart_rate']);
    final double avgSpeed = _parseDouble(row['avg_speed']);
    final double maxSpeed = _parseDouble(row['max_speed']);
    final double elevationGain = _parseDouble(row['elevation_gain']);
    final double elevationLoss = _parseDouble(row['elevation_loss']);
    final double? maxElevation = _parseNullableDouble(row['max_elevation']);
    final double? minElevation = _parseNullableDouble(row['min_elevation']);
    final int movingTimeSec = _parseInt(row['moving_time_sec']);

    final double distanceMeters = _parseDouble(row['distance']);
    final double distanceKm = distanceMeters / 1000.0;
    final int calories = _parseInt(row['calories']);
    final int imageCount = _parseInt(row['image_count']);
    final int durationSec = _parseInt(row['total_duration_sec']);

    String durationText;
    if (durationSec <= 0) {
      durationText = '0 h';
    } else {
      final double hours = durationSec / 3600.0;
      durationText = '${hours.toStringAsFixed(1)} h';
    }

    final String distanceText =
        distanceKm > 0 ? '${distanceKm.toStringAsFixed(2)} km' : '0 km';
    final String photosText = imageCount > 0 ? '$imageCount 张照片' : '无照片';

    // 解析图片列表与星标图片
    final String imagesRaw = row['images']?.toString() ?? '[]';
    List<String> images;
    try {
      final dynamic decoded = jsonDecode(imagesRaw);
      if (decoded is List) {
        images = decoded.map((dynamic e) => e.toString()).toList();
      } else {
        images = <String>[];
      }
    } catch (_) {
      images = <String>[];
    }

    final String starImage = row['star_image']?.toString() ?? '';

    final String effectiveDescription = description.isNotEmpty
        ? description
        : '类型：${type.isEmpty ? '未分类' : type} · 距离：$distanceText · 消耗：${calories > 0 ? '$calories kcal' : '未知'}';

    // 默认封面图使用本地 asset，避免依赖网络
    const String fallbackImageAsset = 'lib/assests/background.png';

    // 封面统一使用星标图片；如果尚未设置星标，则使用默认封面图
    final String cover = starImage.isNotEmpty ? starImage : fallbackImageAsset;

    return ActivityTrip(
      id: id,
      title: name,
      location: location,
      activityTime: activityTime,
      dateLabel: dateLabel,
      avgHeartRate: avgHeartRate,
      maxHeartRate: maxHeartRate,
      avgSpeed: avgSpeed,
      maxSpeed: maxSpeed,
      calories: calories,
      elevationGain: elevationGain,
      elevationLoss: elevationLoss,
      maxElevation: maxElevation,
      minElevation: minElevation,
      movingTimeSec: movingTimeSec,
      durationText: durationText,
      distanceText: distanceText,
      photosText: photosText,
      description: effectiveDescription,
      coverImageUrl: cover,
      galleryImageUrls: images.isNotEmpty ? images : const <String>[],
      starImageUrl: starImage.isNotEmpty ? starImage : null,
    );
  }

  double _parseDouble(Object? value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double? _parseNullableDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final String s = value.toString();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  int _parseInt(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

}
