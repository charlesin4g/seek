import '../annotations/enum_value.dart';

/// 交通类型枚举
enum TransportType {

  @EnumValue('火车')
  train,

  @EnumValue('飞机')
  flight,

  @EnumValue('客车')
  bus,

  @EnumValue('轮船')
  ship,
}