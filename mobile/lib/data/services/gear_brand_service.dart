import 'package:mobile/data/daos/gear_brand_dao.dart';
import 'package:mobile/data/entities/gear_brand.dart';

class GearBrandService {
  final GearBrandDao _gearBrandDao;

  GearBrandService(this._gearBrandDao);

  // 获取所有品牌
  Future<List<GearBrand>> getAllBrands() async {
    return await _gearBrandDao.findAll();
  }

  // 根据ID获取品牌
  Future<GearBrand?> getBrandById(int id) async {
    return await _gearBrandDao.findById(id);
  }

  // 根据名称搜索品牌
  Future<List<GearBrand>> searchBrands(String keyword) async {
    return await _gearBrandDao.searchByName('%$keyword%');
  }

  // 根据类别获取品牌
  Future<List<GearBrand>> getBrandsByCategory(String category) async {
    return await _gearBrandDao.findByCategory(category);
  }

  // 根据国家获取品牌
  Future<List<GearBrand>> getBrandsByCountry(String country) async {
    return await _gearBrandDao.findByCountry(country);
  }

  // 根据价格区间获取品牌
  Future<List<GearBrand>> getBrandsByPriceRange(String priceRange) async {
    return await _gearBrandDao.findByPriceRange(priceRange);
  }

  // 根据专业领域获取品牌
  Future<List<GearBrand>> getBrandsBySpecialty(String specialty) async {
    return await _gearBrandDao.findBySpecialty(specialty);
  }

  // 获取收藏的品牌
  Future<List<GearBrand>> getFavoriteBrands() async {
    return await _gearBrandDao.findFavorites();
  }

  // 根据评分获取品牌
  Future<List<GearBrand>> getBrandsByRating(double minRating) async {
    return await _gearBrandDao.findByRating(minRating);
  }

  // 获取所有国家列表
  Future<List<String>> getAllCountries() async {
    return await _gearBrandDao.getAllCountries();
  }

  // 获取所有类别列表
  Future<List<String>> getAllCategories() async {
    return await _gearBrandDao.getAllCategories();
  }

  // 新增品牌
  Future<void> addBrand({
    required String name,
    String? englishName,
    String? description,
    String? category,
    String? country,
    int? foundedYear,
    String? priceRange,
    String? specialty,
    String? officialWebsite,
    String? socialMedia,
    String? logoUrl,
    String? popularProducts,
    bool? environmentFriendly,
    String? warrantyPolicy,
    double? rating,
    String? notes,
  }) async {
    final brand = GearBrand(
      name: name,
      englishName: englishName,
      description: description,
      category: category,
      country: country,
      foundedYear: foundedYear,
      specialty: specialty,
      officialWebsite: officialWebsite,
      socialMedia: socialMedia,
      logoUrl: logoUrl,
      popularProducts: popularProducts,
      environmentFriendly: environmentFriendly,
      warrantyPolicy: warrantyPolicy,
      isFavorite: false,
      rating: rating,
      notes: notes
    );
    return await _gearBrandDao.insert(brand);
  }

  // 更新品牌
  Future<int> updateBrand({
    required int id,
    required String name,
    String? englishName,
    String? description,
    String? category,
    String? country,
    int? foundedYear,
    String? priceRange,
    String? specialty,
    String? officialWebsite,
    String? socialMedia,
    String? logoUrl,
    String? popularProducts,
    bool? environmentFriendly,
    String? warrantyPolicy,
    bool? isFavorite,
    double? rating,
    String? notes,
  }) async {
    // 首先获取现有品牌以保留createdAt
    final existingBrand = await _gearBrandDao.findById(id);
    if (existingBrand == null) {
      return 0;
    }

    final brand = GearBrand(
      id: id,
      name: name,
      englishName: englishName,
      description: description,
      category: category,
      country: country,
      foundedYear: foundedYear,
      specialty: specialty,
      officialWebsite: officialWebsite,
      socialMedia: socialMedia,
      logoUrl: logoUrl,
      popularProducts: popularProducts,
      environmentFriendly: environmentFriendly,
      warrantyPolicy: warrantyPolicy,
      isFavorite: isFavorite ?? existingBrand.isFavorite,
      rating: rating,
      notes: notes
    );
    return await _gearBrandDao.update(brand);
  }

  // 更新收藏状态
  Future<void> updateBrandFavorite(int id, bool isFavorite) async {
    return await _gearBrandDao.updateFavoriteStatus(id, isFavorite);
  }

  // 删除品牌
  Future<void> deleteBrand(int id) async {
    return await _gearBrandDao.deleteById(id);
  }

  // 删除所有品牌
  Future<void> deleteAllBrands() async {
    return await _gearBrandDao.deleteAll();
  }

  // 获取品牌数量
  Future<int?> getBrandCount() async {
    return await _gearBrandDao.getCount();
  }
}