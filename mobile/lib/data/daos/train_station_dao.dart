import 'package:floor/floor.dart';
import 'package:mobile/data/entities/train_station.dart';

@dao
abstract class TrainStationDao {
  @Query('SELECT * FROM train_station ORDER BY name ASC')
  Future<List<TrainStation>> findAll();

  @Query('SELECT * FROM train_station WHERE id = :id')
  Future<TrainStation?> findById(int id);

  @Query('SELECT * FROM train_station WHERE code = :code')
  Future<TrainStation?> findByCode(String code);

  @Query('''
    SELECT * FROM train_station 
    WHERE name LIKE :keyword 
       OR code LIKE :keyword 
       OR alias LIKE :keyword 
       OR english_name LIKE :keyword
    ORDER BY name ASC
  ''')
  Future<List<TrainStation>> search(String keyword);

  @Query('SELECT * FROM train_station WHERE city = :city ORDER BY name ASC')
  Future<List<TrainStation>> findByCity(String city);

  @Query('SELECT * FROM train_station WHERE province = :province ORDER BY name ASC')
  Future<List<TrainStation>> findByProvince(String province);

  @Query('SELECT * FROM train_station WHERE railway_administration = :administration ORDER BY name ASC')
  Future<List<TrainStation>> findByRailwayAdministration(String administration);

  @Query('SELECT DISTINCT province FROM train_station ORDER BY province ASC')
  Future<List<String>> getAllProvinces();

  @Query('SELECT DISTINCT city FROM train_station WHERE province = :province ORDER BY city ASC')
  Future<List<String>> getCitiesByProvince(String province);

  @Query('SELECT DISTINCT railway_administration FROM train_station WHERE railway_administration IS NOT NULL ORDER BY railway_administration ASC')
  Future<List<String>> getAllRailwayAdministrations();

  @Query('UPDATE train_station SET visit_count = visit_count + 1 WHERE id = :id')
  Future<void> incrementVisitCount(int id);

  @Query('SELECT * FROM train_station ORDER BY visit_count DESC LIMIT :limit')
  Future<List<TrainStation>> getMostVisited(int limit);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insert(TrainStation station);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertAll(List<TrainStation> stations);

  @Update()
  Future<int> update(TrainStation station);

  @Query('DELETE FROM train_station WHERE id = :id')
  Future<void> deleteById(int id);

  @Query('DELETE FROM train_station')
  Future<void> deleteAll();

  @Query('SELECT COUNT(*) FROM train_station')
  Future<int?> getCount();

  @Query('SELECT COUNT(*) FROM train_station WHERE province = :province')
  Future<int?> getCountByProvince(String province);

  @Query('SELECT COUNT(*) FROM train_station WHERE city = :city')
  Future<int?> getCountByCity(String city);
}