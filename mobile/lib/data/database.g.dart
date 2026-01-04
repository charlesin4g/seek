// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  TicketDao? _ticketDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ticket` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `type` TEXT NOT NULL, `transport_no` TEXT NOT NULL, `from` TEXT NOT NULL, `to` TEXT NOT NULL, `departure_time` TEXT NOT NULL, `arrival_time` TEXT NOT NULL, `seat_class` TEXT, `seat_no` TEXT, `check_in_position` TEXT, `terminal_area` TEXT, `price` REAL, `carrier` TEXT, `booking_reference` TEXT, `purchase_platform` TEXT, `notes` TEXT)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  TicketDao get ticketDao {
    return _ticketDaoInstance ??= _$TicketDao(database, changeListener);
  }
}

class _$TicketDao extends TicketDao {
  _$TicketDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _ticketInsertionAdapter = InsertionAdapter(
            database,
            'ticket',
            (Ticket item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'transport_no': item.transportNo,
                  'from': item.from,
                  'to': item.to,
                  'departure_time':
                      _dateTimeConverter.encode(item.departureTime),
                  'arrival_time': _dateTimeConverter.encode(item.arrivalTime),
                  'seat_class': item.seatClass,
                  'seat_no': item.seatNo,
                  'check_in_position': item.checkInPosition,
                  'terminal_area': item.terminalArea,
                  'price': item.price,
                  'carrier': item.carrier,
                  'booking_reference': item.bookingReference,
                  'purchase_platform': item.purchasePlatform,
                  'notes': item.notes
                }),
        _ticketUpdateAdapter = UpdateAdapter(
            database,
            'ticket',
            ['id'],
            (Ticket item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'transport_no': item.transportNo,
                  'from': item.from,
                  'to': item.to,
                  'departure_time':
                      _dateTimeConverter.encode(item.departureTime),
                  'arrival_time': _dateTimeConverter.encode(item.arrivalTime),
                  'seat_class': item.seatClass,
                  'seat_no': item.seatNo,
                  'check_in_position': item.checkInPosition,
                  'terminal_area': item.terminalArea,
                  'price': item.price,
                  'carrier': item.carrier,
                  'booking_reference': item.bookingReference,
                  'purchase_platform': item.purchasePlatform,
                  'notes': item.notes
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Ticket> _ticketInsertionAdapter;

  final UpdateAdapter<Ticket> _ticketUpdateAdapter;

  @override
  Future<List<Ticket>> findAll() async {
    return _queryAdapter.queryList(
        'SELECT * FROM ticket ORDER BY departureTime DESC',
        mapper: (Map<String, Object?> row) => Ticket(
            id: row['id'] as int?,
            type: row['type'] as String,
            transportNo: row['transport_no'] as String,
            from: row['from'] as String,
            to: row['to'] as String,
            departureTime:
                _dateTimeConverter.decode(row['departure_time'] as String),
            arrivalTime:
                _dateTimeConverter.decode(row['arrival_time'] as String),
            seatClass: row['seat_class'] as String?,
            seatNo: row['seat_no'] as String?,
            checkInPosition: row['check_in_position'] as String?,
            terminalArea: row['terminal_area'] as String?,
            price: row['price'] as double?,
            carrier: row['carrier'] as String?,
            bookingReference: row['booking_reference'] as String?,
            purchasePlatform: row['purchase_platform'] as String?,
            notes: row['notes'] as String?));
  }

  @override
  Future<Ticket?> findById(int id) async {
    return _queryAdapter.query('SELECT * FROM ticket WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Ticket(
            id: row['id'] as int?,
            type: row['type'] as String,
            transportNo: row['transport_no'] as String,
            from: row['from'] as String,
            to: row['to'] as String,
            departureTime:
                _dateTimeConverter.decode(row['departure_time'] as String),
            arrivalTime:
                _dateTimeConverter.decode(row['arrival_time'] as String),
            seatClass: row['seat_class'] as String?,
            seatNo: row['seat_no'] as String?,
            checkInPosition: row['check_in_position'] as String?,
            terminalArea: row['terminal_area'] as String?,
            price: row['price'] as double?,
            carrier: row['carrier'] as String?,
            bookingReference: row['booking_reference'] as String?,
            purchasePlatform: row['purchase_platform'] as String?,
            notes: row['notes'] as String?),
        arguments: [id]);
  }

  @override
  Future<void> deleteById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM ticket WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> insert(Ticket ticket) async {
    await _ticketInsertionAdapter.insert(ticket, OnConflictStrategy.replace);
  }

  @override
  Future<void> update(Ticket ticket) async {
    await _ticketUpdateAdapter.update(ticket, OnConflictStrategy.abort);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
