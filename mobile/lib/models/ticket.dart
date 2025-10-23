import '../services/storage_service.dart';

class Ticket {
  final String? id;
  final String type; // 'train' | 'flight'

  // Trip info
  final String code; // 车次/航班号
  final String departStation;
  final String arriveStation;
  final DateTime departTime;
  final DateTime arriveTime;
  final int durationMinutes;

  // Seat/boarding
  final String? coachOrCabin; // 车厢/舱位
  final String? seatNo;
  final String? seatType; // 二等座/经济舱等
  final String? gateOrCheckin; // 检票口/登机口/值机柜台
  final String? waitingArea; // 候车区 or 航站楼

  // Ticketing
  final double price;
  final String? discount; // 文本如 "98折"
  final String ticketCategory; // 成人票/儿童票等
  final String status; // 已支付/未支付/退票/改签

  // Order & passenger
  final String? orderNo;
  final String? passengerName;
  final String? remark;

  Ticket({
    this.id,
    required this.type,
    required this.code,
    required this.departStation,
    required this.arriveStation,
    required this.departTime,
    required this.arriveTime,
    required this.durationMinutes,
    this.coachOrCabin,
    this.seatNo,
    this.seatType,
    this.gateOrCheckin,
    this.waitingArea,
    required this.price,
    this.discount,
    required this.ticketCategory,
    required this.status,
    this.orderNo,
    this.passengerName,
    this.remark,
  });

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

  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id']?.toString(),
      type: _mapCategoryToType(json['category']?.toString() ?? ''),
      code: (json['code'] ?? json['travelNo'] ?? '').toString(),
      departStation: (json['departStation'] ?? json['fromPlace'] ?? '').toString(),
      arriveStation: (json['arriveStation'] ?? json['toPlace'] ?? '').toString(),
      departTime: parseDate(json['departTime'] ?? json['departureTime']),
      arriveTime: parseDate(json['arriveTime'] ?? json['arrivalTime']),
      durationMinutes: int.tryParse(json['durationMinutes']?.toString() ?? '0') ?? 0,
      coachOrCabin: json['coachOrCabin']?.toString(),
      seatNo: json['seatNo']?.toString(),
      seatType: (json['seatType'] ?? json['seatClass'])?.toString(),
      gateOrCheckin: json['gateOrCheckin']?.toString(),
      waitingArea: json['waitingArea']?.toString(),
      price: parseDouble(json['price']),
      discount: json['discount']?.toString(),
      ticketCategory: (json['ticketCategory'] ?? '成人票').toString(),
      status: (json['status'] ?? '已支付').toString(),
      orderNo: json['orderNo']?.toString(),
      passengerName: json['passengerName']?.toString(),
      remark: json['remark']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    // 仅发送后端 AddTicketRequest 需要/接受的字段，避免未知字段导致校验问题
    final cachedUser = StorageService().getCachedUserSync();
    final ownerId = cachedUser?['userId']?.toString();
    return {
      'category': type == 'flight' ? 'Flight' : 'Train',
      'travelNo': code,
      'fromPlace': departStation,
      'toPlace': arriveStation,
      'departureTime': departTime.toIso8601String(),
      'arrivalTime': arriveTime.toIso8601String(),
      'seatClass': seatType,
      'seatNo': seatNo,
      'price': price,
      'currency': 'CNY',
      'passengerName': passengerName,
      'owner': ownerId ?? '1',
    };
  }

  static String _mapCategoryToType(String category) {
    switch (category.toLowerCase()) {
      case 'flight':
        return 'flight';
      case 'train':
        return 'train';
      default:
        return category.isEmpty ? 'train' : category.toLowerCase();
    }
  }
}