import 'gear.dart';

class GearStatistics {
  final double totalValue;
  final int totalCount;
  final double totalWeight;
  final Map<String, double> categoryValues;
  final Map<String, double> brandValues;
  final Map<String, int> brandCounts;

  const GearStatistics({
    required this.totalValue,
    required this.totalCount,
    required this.totalWeight,
    required this.categoryValues,
    required this.brandValues,
    required this.brandCounts,
  });

  factory GearStatistics.fromGearList(List<Gear> gearList) {
    double totalValue = 0;
    int totalCount = 0;
    double totalWeight = 0;
    Map<String, double> categoryValues = {};
    Map<String, double> brandValues = {};
    Map<String, int> brandCounts = {};

    for (final gear in gearList) {
      final gearValue = gear.price * gear.quantity;
      final gearWeight = _convertWeight(gear.weight, gear.weightUnit);

      totalValue += gearValue;
      totalCount += gear.quantity;
      totalWeight += gearWeight * gear.quantity;

      // Category values
      categoryValues[gear.category] = (categoryValues[gear.category] ?? 0) + gearValue;

      // Brand values
      brandValues[gear.brand] = (brandValues[gear.brand] ?? 0) + gearValue;
      brandCounts[gear.brand] = (brandCounts[gear.brand] ?? 0) + gear.quantity;
    }

    return GearStatistics(
      totalValue: totalValue,
      totalCount: totalCount,
      totalWeight: totalWeight,
      categoryValues: categoryValues,
      brandValues: brandValues,
      brandCounts: brandCounts,
    );
  }

  static double _convertWeight(double weight, String unit) {
    switch (unit) {
      case 'g':
        return weight / 1000; // Convert to kg
      case 'kg':
        return weight;
      case '斤':
        return weight * 0.5; // Convert to kg
      default:
        return weight;
    }
  }
}
