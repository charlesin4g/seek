class DateUtils {
  // 动态类型转换为datetime
  static DateTime parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    final s = value.toString();
    try {
      return DateTime.parse(s);
    } catch (_) {
      return DateTime.now();
    }
  }
}
