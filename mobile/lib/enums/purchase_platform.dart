import '../annotations/enum_value.dart';
/// 购票平台枚举
enum PurchasePlatform {
  @EnumValue('12306')
  official12306,

  @EnumValue('携程旅行')
  ctrip,

  @EnumValue('去哪儿网')
  qunar,

  @EnumValue('飞猪旅行')
  fliggy,

  @EnumValue('同程旅行')
  tongcheng,

  @EnumValue('其他平台')
  other,
}