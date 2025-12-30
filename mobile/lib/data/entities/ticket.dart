import 'package:floor/floor.dart';
import 'package:mobile/annotations/field_info.dart';
import 'package:mobile/data/datetime_converter.dart';

@Entity(tableName: 'ticket')
class Ticket {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'type')
  @FieldInfo(
    '交通类型',
    example: 'train',
    isRequired: true,
    enumValues: ['train: 火车', 'airplane: 飞机', 'bus: 客车', 'ship: 轮船'],
  )
  final String type;

  @ColumnInfo(name: 'transport_no')
  @FieldInfo('车次/航班号', example: 'G1234/K1234/CA1234', isRequired: true)
  final String transportNo;

  @ColumnInfo(name: 'from')
  @FieldInfo('出发地', example: '北京南', isRequired: true)
  final String from;

  @ColumnInfo(name: 'to')
  @FieldInfo('到达地', example: '上海虹桥', isRequired: true)
  final String to;

  @ColumnInfo(name: 'departure_time')
  @FieldInfo('出发时间', example: '2024-01-15 08:00:00', isRequired: true)
  @TypeConverters([DateTimeConverter])
  final DateTime departureTime;

  @ColumnInfo(name: 'arrival_time')
  @FieldInfo('到达时间', example: '2024-01-15 08:00:00', isRequired: true)
  @TypeConverters([DateTimeConverter])
  final DateTime arrivalTime;

  @ColumnInfo(name: 'seat_class')
  @FieldInfo(
    '车厢/舱位/座位等级',
    example: 'secondClass',
    enumValues: [
      '火车座位: secondClass(二等座), firstClass(一等座), businessClass(商务座), premiumClass(特等座)',
      '飞机座位: economy(经济舱), premiumEconomy(超级经济舱), business(商务舱), first(头等舱)',
    ],
  )
  final String? seatClass;

  @FieldInfo('座位号', example: '10车13B/21A')
  @ColumnInfo(name: 'seat_no')
  final String? seatNo;

  @FieldInfo('检票口/登机口/值机柜台', example: 'A12/B23/32号柜台')
  @ColumnInfo(name: 'check_in_position')
  final String? checkInPosition;

  @FieldInfo('候车区/航站楼', example: 'T3航站楼/2号候车室')
  @ColumnInfo(name: 'terminal_area')
  final String? terminalArea;

  @FieldInfo('票价', example: '553.5')
  @ColumnInfo(name: 'price')
  final double? price;

  @FieldInfo('承运人', example: '中国铁路/中国国际航空')
  @ColumnInfo(name: 'carrier')
  final String? carrier;

  @FieldInfo('票号/PNR/订单号', example: 'E123456789/999-8888888888')
  @ColumnInfo(name: 'booking_reference')
  final String? bookingReference;

  @FieldInfo(
    '购票平台',
    example: 'official12306',
    enumValues: [
      'official12306: 12306',
      'ctrip: 携程旅行',
      'qunar: 去哪儿网',
      'fliggy: 飞猪旅行',
      'tongcheng: 同程旅行',
      'other: 其他',
    ],
  )
  @ColumnInfo(name: 'purchase_platform')
  final String? purchasePlatform;

  @FieldInfo('备注信息')
  @ColumnInfo(name: 'notes')
  final String? notes;

  Ticket({
    this.id,
    required this.type,
    required this.transportNo,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    this.seatClass,
    this.seatNo,
    this.checkInPosition,
    this.terminalArea,
    this.price,
    this.carrier,
    this.bookingReference,
    required this.purchasePlatform,
    this.notes,
  });
}
