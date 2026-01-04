import 'package:floor/floor.dart';
import 'package:mobile/data/entities/activity.dart';

@dao
abstract class ActivityDao {
  @Query('SELECT * FROM activity ORDER BY activity_time DESC')
  Future<List<Activity>> findAll();

  @Query('SELECT * FROM activity WHERE id = :id')
  Future<Activity?> findById(String id);

  @Query(
    'SELECT * FROM activity WHERE type = :type ORDER BY activity_time DESC',
  )
  Future<List<Activity>> findByType(String type);

  @Query(
    'SELECT * FROM activity WHERE activity_time >= :startTime AND activity_time <= :endTime ORDER BY activity_time DESC',
  )
  Future<List<Activity>> findByTimeRange(DateTime startTime, DateTime endTime);

  @Query(
    'SELECT * FROM activity WHERE location LIKE :keyword OR name LIKE :keyword ORDER BY activity_time DESC',
  )
  Future<List<Activity>> searchByKeyword(String keyword);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(Activity activity);

  @Update()
  Future<void> update(Activity activity);

  @Query('DELETE FROM activity WHERE id = :id')
  Future<void> deleteById(String id);

  @Query('DELETE FROM activity')
  Future<void> deleteAll();
}
