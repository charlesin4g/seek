import '../annotations/enum_value.dart';

enum TrainSeatClass {
  @EnumValue('二等座')
  secondClass,

  @EnumValue('一等座')
  firstClass,

  @EnumValue('商务座')
  businessClass,

  @EnumValue('特等座')
  premiumClass,
}
