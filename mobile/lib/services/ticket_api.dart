import 'dart:convert';
import 'http_client.dart';

class TicketApi {
  TicketApi({HttpClient? client}) : _client = client ?? HttpClient();

  final HttpClient _client;

  Future<String> addTicket(Map<String, dynamic> data) async {
    // 与装备保持一致，采用 POST 方式
    return _client.postJson('/api/ticket/add', body: data);
  }

  Future<List<Map<String, dynamic>>> getMyTickets() async {
    final raw = await _client.getJson('/api/ticket/my?owner=1');
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> editTicket(String ticketId, Map<String, dynamic> data) async {
    await _client.postJson('/api/ticket/edit?ticketId=$ticketId', body: data);
  }

  Future<Map<String, dynamic>> getAirportByIata(String iata) async {
    final code = Uri.encodeQueryComponent(iata.toUpperCase());
    final raw = await _client.getJson('/api/ticket/airport?iata=$code');
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}