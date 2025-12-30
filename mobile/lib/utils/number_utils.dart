class NumberUtils {
  
  // 动态类型转换为double
  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

}