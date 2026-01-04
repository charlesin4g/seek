import 'package:mobile/data/daos/gear_dao.dart';
import 'package:mobile/data/entities/gear.dart';

class GearService {
  final GearDao _gearDao;

  GearService(this._gearDao);

  // 获取所有票据
  Future<List<Gear>> getAllGears() async {
    return await _gearDao.findAll();
  }

  // 新增票据
  Future<void> insert(
    String name,
    String category,
    String brand,
    double weight,
    String weightUnit,
    double price,
    int quantity,
    String purchaseDate,
    int usageCount,
    String image,
    String status,
  ) async {
    Gear gear = Gear(
      name: name,
      category: category,
      brand: brand,
      weight: weight,
      weightUnit: weightUnit,
      price: price,
      quantity: quantity,
      purchaseDate: DateTime.parse(purchaseDate),
      usageCount: usageCount,
      image: image,
      status: status,
    );
    return await _gearDao.insert(gear);
  }

  // 更新票据
  Future<void> update(
    int id,
    String name,
    String category,
    String brand,
    double weight,
    String weightUnit,
    double price,
    int quantity,
    String purchaseDate,
    int usageCount,
    String image,
    String status,
  ) async {
    Gear gear = Gear(
      id: id,
      name: name,
      category: category,
      brand: brand,
      weight: weight,
      weightUnit: weightUnit,
      price: price,
      quantity: quantity,
      purchaseDate: DateTime.parse(purchaseDate),
      usageCount: usageCount,
      image: image,
      status: status,
    );
    return await _gearDao.update(gear);
  }
}
