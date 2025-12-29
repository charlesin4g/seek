class Ticket {
  final String? id;
  final String type; // '火车' | '飞机'

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
    this.discount
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
      code: (json['code'] ?? json['travelNo'] ?? json['travel_no'] ?? '')
          .toString(),
      departStation:
          (json['departStation'] ?? json['fromPlace'] ?? json['from'] ?? '')
              .toString(),
      arriveStation:
          (json['arriveStation'] ?? json['toPlace'] ?? json['to'] ?? '')
              .toString(),
      departTime:
          parseDate(json['departTime'] ?? json['departureTime'] ?? json['departure_time']),
      arriveTime:
          parseDate(json['arriveTime'] ?? json['arrivalTime'] ?? json['arrival_time']),
      durationMinutes:
          int.tryParse(json['durationMinutes']?.toString() ?? '0') ?? 0,
      coachOrCabin: json['coachOrCabin']?.toString(),
      seatNo: (json['seatNo'] ?? json['seat_no'])?.toString(),
      seatType: (json['seatType'] ?? json['seatClass'])?.toString(),
      gateOrCheckin: json['gateOrCheckin']?.toString(),
      waitingArea: json['waitingArea']?.toString(),
      price: parseDouble(json['price']),
      discount: json['discount']?.toString()
    );
  }

  Map<String, dynamic> toJson() {
    // 离线模式：构造本地 SQLite 写入所需字段，同时兼容旧的线上字段名
    return {
      'category': type == '飞机' ? '飞机' : '火车',
      'travelNo': code,
      'fromPlace': departStation,
      'toPlace': arriveStation,
      'departureTime': departTime.toIso8601String(),
      'arrivalTime': arriveTime.toIso8601String(),
      'seatClass': seatType,
      'seatNo': seatNo,
      'price': price
    };
  }

  static String _mapCategoryToType(String category) {
    switch (category.toLowerCase()) {
      case '飞机':
        return '飞机';
      case '火车':
        return '火车';
      default:
        return category.isEmpty ? '火车' : category.toLowerCase();
    }
  }
}