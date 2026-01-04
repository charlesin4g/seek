import 'package:mobile/data/daos/activity_dao.dart';
import 'package:mobile/data/entities/activity.dart';

class ActivityService {
  final ActivityDao _activityDao;

  ActivityService(this._activityDao);

  // 获取所有活动
  Future<List<Activity>> getAllActivities() async {
    return await _activityDao.findAll();
  }

  // 根据ID获取活动
  Future<Activity?> getActivityById(String id) async {
    return await _activityDao.findById(id);
  }

  // 根据类型获取活动
  Future<List<Activity>> getActivitiesByType(String type) async {
    return await _activityDao.findByType(type);
  }

  // 根据时间范围获取活动
  Future<List<Activity>> getActivitiesByTimeRange(
    String startTime,
    String endTime,
  ) async {
    return await _activityDao.findByTimeRange(
      DateTime.parse(startTime),
      DateTime.parse(endTime),
    );
  }

  // 搜索活动
  Future<List<Activity>> searchActivities(String keyword) async {
    return await _activityDao.searchByKeyword('%$keyword%');
  }

  // 新增活动
  Future<void> insertActivity({
    required String id,
    required String name,
    required String type,
    String? description,
    required String activityTime,
    int? avgHeartRate,
    int? maxHeartRate,
    double? avgSpeed,
    double? maxSpeed,
    int? calories,
    double? distance,
    int? elevationGain,
    int? elevationLoss,
    int? maxElevation,
    int? minElevation,
    int? movingTime,
    int? totalTime,
    String? location,
    int? imageCount,
    String? images,
    String? starImage,
    double? la,
    double? lo,
  }) async {
    final activity = Activity(
      id: id,
      name: name,
      type: type,
      description: description,
      activityTime: DateTime.parse(activityTime),
      avgHeartRate: avgHeartRate,
      maxHeartRate: maxHeartRate,
      avgSpeed: avgSpeed,
      maxSpeed: maxSpeed,
      calories: calories,
      distance: distance,
      elevationGain: elevationGain,
      elevationLoss: elevationLoss,
      maxElevation: maxElevation,
      minElevation: minElevation,
      movingTime: movingTime,
      totalTime: totalTime,
      location: location,
      imageCount: imageCount,
      images: images,
      starImage: starImage,
      la: la,
      lo: lo,
    );
    return await _activityDao.insert(activity);
  }

  // 更新活动
  Future<void> updateActivity({
    required String id,
    required String name,
    required String type,
    String? description,
    required String activityTime,
    int? avgHeartRate,
    int? maxHeartRate,
    double? avgSpeed,
    double? maxSpeed,
    int? calories,
    double? distance,
    int? elevationGain,
    int? elevationLoss,
    int? maxElevation,
    int? minElevation,
    int? movingTime,
    int? totalTime,
    String? location,
    int? imageCount,
    String? images,
    String? starImage,
    double? la,
    double? lo,
  }) async {
    final activity = Activity(
      id: id,
      name: name,
      type: type,
      description: description,
      activityTime: DateTime.parse(activityTime),
      avgHeartRate: avgHeartRate,
      maxHeartRate: maxHeartRate,
      avgSpeed: avgSpeed,
      maxSpeed: maxSpeed,
      calories: calories,
      distance: distance,
      elevationGain: elevationGain,
      elevationLoss: elevationLoss,
      maxElevation: maxElevation,
      minElevation: minElevation,
      movingTime: movingTime,
      totalTime: totalTime,
      location: location,
      imageCount: imageCount,
      images: images,
      starImage: starImage,
      la: la,
      lo: lo,
    );
    return await _activityDao.update(activity);
  }

  // 根据ID删除活动
  Future<void> deleteActivityById(String id) async {
    return await _activityDao.deleteById(id);
  }

  // 删除所有活动
  Future<void> deleteAllActivities() async {
    return await _activityDao.deleteAll();
  }
}
