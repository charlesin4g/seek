import 'package:mobile/data/services/ticket_service.dart';
import './database.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  static DatabaseProvider get instance => _instance;

  DatabaseProvider._internal();

  static AppDatabase? _database;

  Future<AppDatabase> get database async {
    if (_database != null) return _database!;

    _database = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .build();

    return _database!;
  }

  Future<TicketService> getTicketService() async {
    final db = await database;
    return TicketService(db.ticketDao);
  }
}
