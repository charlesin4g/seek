import 'package:flutter/material.dart';
import '../../widgets/section_card.dart';
import '../../services/ticket_api.dart';
import '../../models/ticket.dart';
import 'add_ticket_page.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final TicketApi _api = TicketApi();

  Future<List<Ticket>> _loadTickets() async {
    try {
      final list = await _api.getMyTickets();
      return list.map((m) => Ticket.fromJson(m)).toList();
    } catch (_) {
      return [];
    }
  }

  String _fmtRange(Ticket t) {
    String fmt(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${fmt(t.departTime)} → ${fmt(t.arriveTime)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3F2FD), Color(0xFFF8F9FA)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: const [
              Icon(Icons.confirmation_number, color: Colors.blue),
              SizedBox(width: 8),
              Text('票据管理', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTicketPage()),
                );
                if (added == true && mounted) setState(() {});
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: FutureBuilder<List<Ticket>>(
          future: _loadTickets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final tickets = snapshot.data ?? [];
            if (tickets.isEmpty) {
              return Center(
                child: SectionCard(
                  title: '我的票据',
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('暂无票据，点击右上角 + 新建。'),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemCount: tickets.length,
              itemBuilder: (_, i) {
                final t = tickets[i];
                return SectionCard(
                  title: '${t.type == 'train' ? '火车票' : '飞机票'} · ${t.code}',
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.place, size: 18, color: Colors.blue),
                        const SizedBox(width: 6),
                        Expanded(child: Text('${t.departStation} → ${t.arriveStation}')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18, color: Colors.blue),
                        const SizedBox(width: 6),
                        Expanded(child: Text(_fmtRange(t))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.chair, size: 18, color: Colors.blue),
                        const SizedBox(width: 6),
                        Expanded(child: Text('${t.seatType ?? ''} ${t.seatNo ?? ''}'.trim())),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.payments, size: 18, color: Colors.blue),
                        const SizedBox(width: 6),
                        Expanded(child: Text('¥${t.price.toStringAsFixed(2)} · ${t.ticketCategory} · ${t.status}')),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}