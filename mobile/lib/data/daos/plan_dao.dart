import 'package:floor/floor.dart';
import 'package:mobile/data/entities/plan.dart';

@dao
abstract class PlanDao {
  @Query('SELECT * FROM plan ORDER BY start_date DESC')
  Future<List<Plan>> findAll();

  @Query('SELECT * FROM plan WHERE id = :id')
  Future<Plan?> findById(int id);

  @Query('SELECT * FROM plan WHERE name LIKE :keyword OR description LIKE :keyword ORDER BY start_date DESC')
  Future<List<Plan>> search(String keyword);

  @Query('SELECT * FROM plan WHERE status = :status ORDER BY start_date DESC')
  Future<List<Plan>> findByStatus(String status);

  @Query('SELECT * FROM plan WHERE destination LIKE :destination ORDER BY start_date DESC')
  Future<List<Plan>> findByDestination(String destination);

  @Query('SELECT * FROM plan WHERE start_date >= :startDate AND end_date <= :endDate ORDER BY start_date ASC')
  Future<List<Plan>> findByDateRange(DateTime startDate, DateTime endDate);

  @Query('SELECT * FROM plan WHERE start_date >= :date ORDER BY start_date ASC')
  Future<List<Plan>> findUpcoming(DateTime date);

  @Query('SELECT * FROM plan WHERE end_date < :date ORDER BY end_date DESC')
  Future<List<Plan>> findPast(DateTime date);

  @Query('SELECT * FROM plan WHERE start_date <= :date AND end_date >= :date ORDER BY start_date ASC')
  Future<List<Plan>> findCurrent(DateTime date);

  @Query('UPDATE plan SET status = :status WHERE id = :id')
  Future<void> updateStatus(int id, String status);

  @Query('UPDATE plan SET actual_cost = :actualCost WHERE id = :id')
  Future<void> updateActualCost(int id, double actualCost);

  @Query('UPDATE plan SET star_image = :starImage WHERE id = :id')
  Future<void> updateStarImage(int id, String starImage);

  @Query('UPDATE plan SET images = :images WHERE id = :id')
  Future<void> updateImages(int id, String images);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insert(Plan plan);

  @Update()
  Future<int> update(Plan plan);

  @Query('DELETE FROM plan WHERE id = :id')
  Future<void> deleteById(int id);

  @Query('DELETE FROM plan')
  Future<void> deleteAll();

  @Query('SELECT COUNT(*) FROM plan')
  Future<int?> getCount();

  @Query('SELECT COUNT(*) FROM plan WHERE status = :status')
  Future<int?> getCountByStatus(String status);

  @Query('SELECT * FROM plan WHERE start_date <= :date AND (status = "confirmed" OR status = "inProgress") ORDER BY start_date ASC LIMIT 1')
  Future<Plan?> getNextUpcomingPlan(DateTime date);

  @Query('SELECT * FROM plan WHERE status = "inProgress" AND start_date <= :date AND end_date >= :date ORDER BY start_date ASC LIMIT 1')
  Future<Plan?> getCurrentPlan(DateTime date);
}