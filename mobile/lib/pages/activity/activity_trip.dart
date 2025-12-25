/// 活动（路线）数据模型
class ActivityTrip {
  final String id;
  final String title;
  final String location;

  /// 活动时间（原始字段：activity_time）
  final DateTime? activityTime;

  /// 列表页显示用的日期标签（由 activity_time 计算出来）
  final String dateLabel;

  /// 统计指标（来自 activity 表）
  final int avgHeartRate;
  final int maxHeartRate;
  final double avgSpeed;
  final double maxSpeed;
  final int calories;
  final double elevationGain;
  final double elevationLoss;
  final double? maxElevation;
  final double? minElevation;
  final int movingTimeSec;

  /// 展示用的已格式化文本（来自 activity 表派生）
  final String durationText;
  final String distanceText;
  final String photosText;

  final String description;
  final String coverImageUrl;
  final List<String> galleryImageUrls;
  final String? starImageUrl;

  const ActivityTrip({
    required this.id,
    required this.title,
    required this.location,
    required this.dateLabel,
    required this.durationText,
    required this.distanceText,
    required this.photosText,
    required this.description,
    required this.coverImageUrl,
    required this.galleryImageUrls,
    this.activityTime,
    this.avgHeartRate = 0,
    this.maxHeartRate = 0,
    this.avgSpeed = 0,
    this.maxSpeed = 0,
    this.calories = 0,
    this.elevationGain = 0,
    this.elevationLoss = 0,
    this.maxElevation,
    this.minElevation,
    this.movingTimeSec = 0,
    this.starImageUrl,
  });

  @override
  String toString() {
    return 'ActivityTrip(id: ' '$id, title: $title, location: $location)';
  }
}
