class Gear {
  final String id;
  final String name;
  final String category;
  final String brand;
  final double weight;
  final String weightUnit;
  final double price;
  final int quantity;
  final DateTime purchaseDate;

  const Gear({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.weight,
    required this.weightUnit,
    required this.price,
    required this.quantity,
    required this.purchaseDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'brand': brand,
      'weight': weight,
      'weightUnit': weightUnit,
      'price': price,
      'quantity': quantity,
      'purchaseDate': purchaseDate.toIso8601String(),
    };
  }

  factory Gear.fromJson(Map<String, dynamic> json) {
    return Gear(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String,
      weight: (json['weight'] as num).toDouble(),
      weightUnit: json['weightUnit'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    );
  }

  Gear copyWith({
    String? id,
    String? name,
    String? category,
    String? brand,
    double? weight,
    String? weightUnit,
    double? price,
    int? quantity,
    DateTime? purchaseDate,
  }) {
    return Gear(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }
}

class GearCategory {
  static const List<String> categories = [
    '背负',
    '睡眠',
    '服装',
    '鞋类',
    '其他',
  ];
}

class GearBrand {
  static const List<String> brands = [
    '神秘农场',
    '牧高笛',
    '始祖鸟',
    '北面',
    '其他',
  ];
}

class WeightUnit {
  static const List<String> units = ['g', 'kg', '斤'];
}
