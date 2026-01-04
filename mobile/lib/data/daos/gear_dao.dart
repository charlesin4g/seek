import 'package:floor/floor.dart';
import 'package:mobile/data/entities/gear.dart';

@dao
abstract class GearDao {
  @Query('SELECT * FROM gear ORDER BY usageCount DESC')
  Future<List<Gear>> findAll();

  @Query('SELECT * FROM gear WHERE id = :id')
  Future<Gear?> findById(int id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(Gear ticket);

  @Update()
  Future<void> update(Gear ticket);

  @Query('DELETE FROM gear WHERE id = :id')
  Future<void> deleteById(int id);
}
