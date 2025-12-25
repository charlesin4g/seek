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

class GearBrand {
  static const List<String> brands = [];
}

class Brand {
  final int id;
  final String name;
  final String displayName;

  const Brand({
    required this.id,
    required this.name,
    required this.displayName,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    final int id = (json['id'] as num?)?.toInt() ?? 0;
    final String name = json['name'] as String;
    final Object? display = json['displayName'];
    return Brand(
      id: id,
      name: name,
      displayName: display == null ? name : display as String,
    );
  }
}

class WeightUnit {
  static const List<String> units = ['g', 'kg', '斤'];
}
