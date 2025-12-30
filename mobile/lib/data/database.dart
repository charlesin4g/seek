import 'package:floor/floor.dart';
import 'package:mobile/data/daos/ticket_dao.dart';
import 'package:mobile/data/entities/ticket.dart';

part 'database.g.dart';

@Database(version: 1, entities: [Ticket])
abstract class AppDatabase extends FloorDatabase  {

  TicketDao get ticketDao;

}