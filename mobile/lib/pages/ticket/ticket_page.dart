import 'package:flutter/material.dart';
import '../../widgets/section_card.dart';
import '../../services/ticket_api.dart';
import '../../models/ticket.dart';
import 'add_ticket_page.dart';
import 'edit_ticket_page.dart';
import '../../widgets/refresh_and_empty.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final TicketApi _api = TicketApi();
  bool _hasPendingSync = false; // 是否存在待同步数据（离线变更）

  Future<List<Ticket>> _loadTickets() async {
    try {
      final list = await _api.getMyTickets();
      // 标记待同步状态（来自本地仓储的 synced=0）
      _hasPendingSync = list.any((e) => (e['synced'] == 0));
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
          actions: const [],
        ),
        body: FutureBuilder<List<Ticket>>(
          future: _loadTickets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final tickets = snapshot.data ?? [];
            return RefreshAndEmpty(
              isEmpty: tickets.isEmpty,
              onRefresh: () async {
                // 统一刷新：重新执行加载逻辑并触发重建
                try {
                  await _loadTickets();
                  if (mounted) setState(() {});
                  return true;
                } catch (_) {
                  return false;
                }
              },
              emptyIcon: Icons.confirmation_number,
              emptyTitle: '暂无票据',
              emptySubtitle: '下拉刷新或点击右下角 + 新建',
              emptyActionText: null,
              onEmptyAction: null,
              child: Column(
              children: [
                if (_hasPendingSync)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SectionCard(
                      title: '同步状态',
                      children: const [
                        Text('有待同步数据，网络恢复后将自动同步。'),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemCount: tickets.length,
                    itemBuilder: (_, i) {
                      final t = tickets[i];
                      return SectionCard(
                        title: '${t.type == 'train' ? '火车票' : '飞机票'} · ${t.code}',
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          iconSize: 18, // 做得小一点
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          tooltip: '编辑',
                          onPressed: t.id == null ? null : () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditTicketPage(ticket: t)),
                            );
                            if (updated == true && mounted) setState(() {});
                          },
                        ),
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
                  ),
                ),
              ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () async {
            final added = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTicketPage()),
            );
            if (added == true && mounted) setState(() {});
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}