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

  factory Ticket.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v is String) return DateTime.parse(v);
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.now();
    }

    double parseDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '0') ?? 0.0;
    }

    return Ticket(
      id: json['id']?.toString(),
      type: (json['type'] ?? 'train').toString(),
      code: (json['code'] ?? '').toString(),
      departStation: (json['departStation'] ?? '').toString(),
      arriveStation: (json['arriveStation'] ?? '').toString(),
      departTime: parseDate(json['departTime']),
      arriveTime: parseDate(json['arriveTime']),
      durationMinutes: int.tryParse(json['durationMinutes']?.toString() ?? '0') ?? 0,
      coachOrCabin: json['coachOrCabin']?.toString(),
      seatNo: json['seatNo']?.toString(),
      seatType: json['seatType']?.toString(),
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
    return {
      if (id != null) 'id': id,
      'type': type,
      'code': code,
      'departStation': departStation,
      'arriveStation': arriveStation,
      'departTime': departTime.toIso8601String(),
      'arriveTime': arriveTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'coachOrCabin': coachOrCabin,
      'seatNo': seatNo,
      'seatType': seatType,
      'gateOrCheckin': gateOrCheckin,
      'waitingArea': waitingArea,
      'price': price,
      'discount': discount,
      'ticketCategory': ticketCategory,
      'status': status,
      'orderNo': orderNo,
      'passengerName': passengerName,
      'remark': remark,
      'owner': 1,
    };
  }
}