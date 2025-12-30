import 'package:floor/floor.dart';
import 'package:mobile/data/entities/ticket.dart';

@dao
abstract class TicketDao {
  @Query('SELECT * FROM ticket ORDER BY departureTime DESC')
  Future<List<Ticket>> findAll();

  @Query('SELECT * FROM ticket WHERE id = :id')
  Future<Ticket?> findById(int id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(Ticket ticket);

  @Update()
  Future<void> update(Ticket ticket);

  @Query('DELETE FROM ticket WHERE id = :id')
  Future<void> deleteById(int id);
}
