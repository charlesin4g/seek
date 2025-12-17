import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../local_db.dart';
import '../../pages/trail/trail_trip.dart';

/// 足迹（trail）本地仓储
///
/// - 首次访问时，如果本地无数据，会自动写入一批示例数据（原先页面里的 mock 列表）
/// - 后续可扩展为从服务端同步后再落地到本地库
class TrailRepository {
  TrailRepository._internal();
  static final TrailRepository instance = TrailRepository._internal();

  Future<Database> _db() => LocalDatabase.instance.init();

  Future<List<TrailTrip>> getAllTrips() async {
    final db = await _db();
    final countResult = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM trail_trip'),
    );
    if ((countResult ?? 0) == 0) {
      await _seedMockTrips(db);
    }

    final rows = await db.query(
      'trail_trip',
      orderBy: 'dateLabel DESC',
    );

    return rows.map((row) {
      final galleryJson = row['galleryImagesJson']?.toString() ?? '[]';
      final decoded = jsonDecode(galleryJson) as List<dynamic>;
      final gallery = decoded.map((e) => e.toString()).toList();
      return TrailTrip(
        id: row['id']!.toString(),
        title: row['title']!.toString(),
        location: row['location']!.toString(),
        dateLabel: row['dateLabel']!.toString(),
        durationText: row['durationText']!.toString(),
        distanceText: row['distanceText']!.toString(),
        photosText: row['photosText']!.toString(),
        description: row['description']!.toString(),
        coverImageUrl: row['coverImageUrl']!.toString(),
        galleryImageUrls: gallery,
      );
    }).toList();
  }

  Future<void> _seedMockTrips(Database db) async {
    if (kDebugMode) {
      debugPrint('Seeding mock trail_trip data into SQLite');
    }

    const List<Map<String, dynamic>> mockTrips = [
      {
        'id': 'alpine-summit',
        'title': 'Alpine Summit Hike',
        'location': 'Swiss Alps',
        'dateLabel': 'Oct 12, 2024',
        'durationText': '4h 30m',
        'distanceText': '12.5 km',
        'photosText': '12 Photos',
        'description':
            'An unforgettable journey through the heart of the Alps. We started at dawn to catch the sunrise over the peaks. The trail was challenging but the views were absolutely worth every step.',
        'coverImageUrl':
            'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg?auto=compress&cs=tinysrgb&w=800',
        'gallery': [
          'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg?auto=compress&cs=tinysrgb&w=800',
          'https://images.pexels.com/photos/2252039/pexels-photo-2252039.jpeg?auto=compress&cs=tinysrgb&w=800',
        ],
      },
      {
        'id': 'misty-forest',
        'title': 'Misty Forest Trail',
        'location': 'Black Forest',
        'dateLabel': 'Nov 05, 2024',
        'durationText': '2h 15m',
        'distanceText': '8.2 km',
        'photosText': '12 Photos',
        'description':
            'A tranquil walk among towering pines and soft moss paths. Light fog rolled through the forest, making every beam of sunlight feel magical.',
        'coverImageUrl':
            'https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=800',
        'gallery': [
          'https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=800',
          'https://images.pexels.com/photos/167684/pexels-photo-167684.jpeg?auto=compress&cs=tinysrgb&w=800',
        ],
      },
      {
        'id': 'coastal-cliff',
        'title': 'Coastal Cliff Walk',
        'location': 'Dover Coast',
        'dateLabel': 'Sep 20, 2024',
        'durationText': '3h 00m',
        'distanceText': '10.0 km',
        'photosText': '12 Photos',
        'description':
            'A breezy coastal walk along dramatic white cliffs and turquoise waters. Perfect mix of ocean views, sea breeze and gentle ascents.',
        'coverImageUrl':
            'https://images.pexels.com/photos/210205/pexels-photo-210205.jpeg?auto=compress&cs=tinysrgb&w=800',
        'gallery': [
          'https://images.pexels.com/photos/210205/pexels-photo-210205.jpeg?auto=compress&cs=tinysrgb&w=800',
          'https://images.pexels.com/photos/462162/pexels-photo-462162.jpeg?auto=compress&cs=tinysrgb&w=800',
        ],
      },
    ];

    await db.transaction((tx) async {
      for (final m in mockTrips) {
        await tx.insert(
          'trail_trip',
          {
            'id': m['id'],
            'title': m['title'],
            'location': m['location'],
            'dateLabel': m['dateLabel'],
            'durationText': m['durationText'],
            'distanceText': m['distanceText'],
            'photosText': m['photosText'],
            'description': m['description'],
            'coverImageUrl': m['coverImageUrl'],
            'galleryImagesJson': jsonEncode(m['gallery']),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
