/// 足迹（路线）摘要数据模型
class TrailTrip {
  final String id;
  final String title;
  final String location;
  final String dateLabel;
  final String durationText;
  final String distanceText;
  final String photosText;
  final String description;
  final String coverImageUrl;
  final List<String> galleryImageUrls;

  const TrailTrip({
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
  });

  @override
  String toString() {
    return 'TrailTrip(id: ' '$id, title: $title, location: $location)';
  }
}
