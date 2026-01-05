import 'package:floor/floor.dart';
import 'package:mobile/data/entities/itinerary.dart';

@dao
abstract class ItineraryDao {
  // 获取所有行程
  @Query('SELECT * FROM itinerary ORDER BY plan_id, day_number, order ASC')
  Future<List<Itinerary>> findAll();

  // 根据ID获取行程
  @Query('SELECT * FROM itinerary WHERE id = :id')
  Future<Itinerary?> findById(int id);

  // 根据计划ID获取所有行程
  @Query('SELECT * FROM itinerary WHERE plan_id = :planId ORDER BY day_number, order ASC')
  Future<List<Itinerary>> findByPlanId(int planId);

  // 根据计划ID和第几天获取行程
  @Query('SELECT * FROM itinerary WHERE plan_id = :planId AND day_number = :dayNumber ORDER BY order ASC')
  Future<List<Itinerary>> findByPlanIdAndDay(int planId, int dayNumber);

  // 根据日期获取行程
  @Query('SELECT * FROM itinerary WHERE date = :date ORDER BY plan_id, day_number, order ASC')
  Future<List<Itinerary>> findByDate(DateTime date);

  // 根据时间范围获取行程
  @Query('SELECT * FROM itinerary WHERE date >= :startDate AND date <= :endDate ORDER BY plan_id, day_number, order ASC')
  Future<List<Itinerary>> findByDateRange(DateTime startDate, DateTime endDate);

  // 搜索行程
  @Query('''
    SELECT * FROM itinerary 
    WHERE title LIKE :keyword 
       OR description LIKE :keyword 
       OR notes LIKE :keyword
    ORDER BY plan_id, day_number, order ASC
  ''')
  Future<List<Itinerary>> search(String keyword);

  // 获取某个计划的最大天数
  @Query('SELECT MAX(day_number) FROM itinerary WHERE plan_id = :planId')
  Future<int?> getMaxDayNumberByPlan(int planId);

  // 获取某个计划的总行程数
  @Query('SELECT COUNT(*) FROM itinerary WHERE plan_id = :planId')
  Future<int?> getCountByPlan(int planId);

  // 获取某个计划的某天行程数
  @Query('SELECT COUNT(*) FROM itinerary WHERE plan_id = :planId AND day_number = :dayNumber')
  Future<int?> getCountByPlanAndDay(int planId, int dayNumber);

  // 更新行程排序
  @Query('UPDATE itinerary SET order = :order WHERE id = :id')
  Future<void> updateOrder(int id, int order);

  // 批量更新排序
  @Query('UPDATE itinerary SET order = :newOrder WHERE id = :id')
  Future<void> updateOrderById(int id, int newOrder);

  // 交换两个行程的排序
  @Query('''
    UPDATE itinerary 
    SET order = CASE 
      WHEN id = :firstId THEN (SELECT order FROM itinerary WHERE id = :secondId)
      WHEN id = :secondId THEN (SELECT order FROM itinerary WHERE id = :firstId)
    END
    WHERE id IN (:firstId, :secondId)
  ''')
  Future<void> swapOrder(int firstId, int secondId);

  // 重新排序某天的行程
  @Query('''
    UPDATE itinerary 
    SET order = row_number - 1
    FROM (
      SELECT id, ROW_NUMBER() OVER (ORDER BY order) as row_number
      FROM itinerary 
      WHERE plan_id = :planId AND day_number = :dayNumber
    ) AS numbered
    WHERE itinerary.id = numbered.id
  ''')
  Future<void> reorderByDay(int planId, int dayNumber);

  // 插入行程
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insert(Itinerary itinerary);

  // 批量插入行程
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertAll(List<Itinerary> itineraries);

  // 更新行程
  @Update()
  Future<int> update(Itinerary itinerary);

  // 根据ID删除行程
  @Query('DELETE FROM itinerary WHERE id = :id')
  Future<void> deleteById(int id);

  // 根据计划ID删除所有行程
  @Query('DELETE FROM itinerary WHERE plan_id = :planId')
  Future<void> deleteByPlanId(int planId);

  // 删除某天的所有行程
  @Query('DELETE FROM itinerary WHERE plan_id = :planId AND day_number = :dayNumber')
  Future<void> deleteByPlanIdAndDay(int planId, int dayNumber);

  // 删除所有行程
  @Query('DELETE FROM itinerary')
  Future<void> deleteAll();

  // 获取行程总数
  @Query('SELECT COUNT(*) FROM itinerary')
  Future<int?> getCount();

  // 获取计划的行程天数
  @Query('SELECT COUNT(DISTINCT day_number) FROM itinerary WHERE plan_id = :planId')
  Future<int?> getDayCountByPlan(int planId);

  // 检查某天是否有行程
  @Query('SELECT EXISTS(SELECT 1 FROM itinerary WHERE plan_id = :planId AND day_number = :dayNumber)')
  Future<bool?> hasItineraryOnDay(int planId, int dayNumber);
}