import 'package:mobile/data/daos/ticket_dao.dart';
import 'package:mobile/data/entities/ticket.dart';

class TicketService {
  final TicketDao _ticketDao;

  TicketService(this._ticketDao);

  // 获取所有票据
  Future<List<Ticket>> getAllTickets() async {
    return await _ticketDao.findAll();
  }

  // 新增票据
  Future<void> insert(
    String type,
    String transportNo,
    String from,
    String to,
    String departureTime,
    String arrivalTime,
    String seatClass,
    String seatNo,
    double price,
    String carrier,
    String bookingReference,
    String purchasePlatform,
    String notes,
  ) async {
    Ticket ticket = Ticket(
      type: type,
      transportNo: transportNo,
      from: from,
      to: to,
      departureTime: DateTime.parse(departureTime),
      arrivalTime: DateTime.parse(arrivalTime),
      seatClass: seatClass,
      seatNo: seatNo,
      price: price,
      carrier: carrier,
      bookingReference: bookingReference,
      purchasePlatform: purchasePlatform,
      notes: notes,
    );
    return await _ticketDao.insert(ticket);
  }

    // 更新票据
  Future<void> update(int id,
    String type,
    String transportNo,
    String from,
    String to,
    String departureTime,
    String arrivalTime,
    String seatClass,
    String seatNo,
    double price,
    String carrier,
    String bookingReference,
    String purchasePlatform,
    String notes,
  ) async {
    Ticket ticket = Ticket(
      id: id,
      type: type,
      transportNo: transportNo,
      from: from,
      to: to,
      departureTime: DateTime.parse(departureTime),
      arrivalTime: DateTime.parse(arrivalTime),
      seatClass: seatClass,
      seatNo: seatNo,
      price: price,
      carrier: carrier,
      bookingReference: bookingReference,
      purchasePlatform: purchasePlatform,
      notes: notes,
    );
    return await _ticketDao.update(ticket);
  }
}
