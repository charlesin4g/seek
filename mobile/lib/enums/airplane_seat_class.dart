import '../annotations/enum_value.dart';

enum AirplaneSeatClass {
  @EnumValue('经济舱')
  economy,

  @EnumValue('超级经济舱')
  premiumEconomy,

  @EnumValue('商务舱')
  business,

  @EnumValue('头等舱')
  first,
}