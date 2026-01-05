import 'package:floor/floor.dart';
import 'package:mobile/data/entities/gear_brand.dart';

@dao
abstract class GearBrandDao {
  @Query('SELECT * FROM gear_brand ORDER BY name ASC')
  Future<List<GearBrand>> findAll();

  @Query('SELECT * FROM gear_brand WHERE id = :id')
  Future<GearBrand?> findById(int id);

  @Query('SELECT * FROM gear_brand WHERE name LIKE :keyword ORDER BY name ASC')
  Future<List<GearBrand>> searchByName(String keyword);

  @Query('SELECT * FROM gear_brand WHERE category = :category ORDER BY name ASC')
  Future<List<GearBrand>> findByCategory(String category);

  @Query('SELECT * FROM gear_brand WHERE country = :country ORDER BY name ASC')
  Future<List<GearBrand>> findByCountry(String country);

  @Query('SELECT * FROM gear_brand WHERE price_range = :priceRange ORDER BY name ASC')
  Future<List<GearBrand>> findByPriceRange(String priceRange);

  @Query('SELECT * FROM gear_brand WHERE specialty = :specialty ORDER BY name ASC')
  Future<List<GearBrand>> findBySpecialty(String specialty);

  @Query('SELECT * FROM gear_brand WHERE is_favorite = 1 ORDER BY name ASC')
  Future<List<GearBrand>> findFavorites();

  @Query('SELECT * FROM gear_brand WHERE rating >= :minRating ORDER BY rating DESC')
  Future<List<GearBrand>> findByRating(double minRating);

  @Query('SELECT DISTINCT country FROM gear_brand ORDER BY country ASC')
  Future<List<String>> getAllCountries();

  @Query('SELECT DISTINCT category FROM gear_brand ORDER BY category ASC')
  Future<List<String>> getAllCategories();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(GearBrand brand);

  @Update()
  Future<int> update(GearBrand brand);

  @Query('UPDATE gear_brand SET is_favorite = :isFavorite WHERE id = :id')
  Future<void> updateFavoriteStatus(int id, bool isFavorite);

  @Query('DELETE FROM gear_brand WHERE id = :id')
  Future<void> deleteById(int id);

  @Query('DELETE FROM gear_brand')
  Future<void> deleteAll();

  @Query('SELECT COUNT(*) FROM gear_brand')
  Future<int?> getCount();
}