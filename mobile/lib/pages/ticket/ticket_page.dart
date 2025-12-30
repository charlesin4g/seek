import 'package:flutter/material.dart';
import 'package:mobile/data/database_provider.dart';
import 'package:mobile/data/services/ticket_service.dart';
import '../../widgets/section_card.dart';
import '../../data/entities/ticket.dart';
import 'add_ticket_page.dart';
import 'edit_ticket_page.dart';
import '../../widgets/refresh_and_empty.dart';
import '../../config/app_colors.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  List<Ticket> _tickets = [];
  late TicketService? _ticketService;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final provider = DatabaseProvider.instance;
    _ticketService = await provider.getTicketService();
    _loadTicketsInBackground();
  }

  void _loadTicketsInBackground() {
    _loadTickets().then((tickets) {
      if (mounted) {
        setState(() {
          _tickets = tickets;
          _hasLoaded = true;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _tickets = [];
          _hasLoaded = true;
        });
      }
    });
  }

  Future<List<Ticket>> _loadTickets() async {
    return await _ticketService!.getAllTickets();
  }

  String _fmtRange(Ticket t) {
    String fmt(DateTime dt) =>
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${fmt(t.departureTime)} → ${fmt(t.arrivalTime)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: const [
              Icon(Icons.confirmation_number, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text(
                '票据管理',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          actions: const [],
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryBlue,
          onPressed: _handleAddTicket,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  void _handleAddTicket() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTicketPage()),
    );
    if (added == true && mounted) {
      _reloadTicketsQuietly();
    }
  }

  void _handleEditTicket(Ticket t) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTicketPage(ticket: t),
      ),
    );
    if (updated == true && mounted) {
      _reloadTicketsQuietly();
    }
  }

  // 修复：返回 Future<bool> 而不是 void
  Future<bool> _reloadTicketsQuietly() async {
    try {
      final tickets = await _loadTickets();
      if (mounted) {
        setState(() {
          _tickets = tickets;
        });
      }
      return true;
    } catch (error) {
      if (mounted) {
        setState(() {
          _tickets = [];
        });
      }
      return false;
    }
  }

  Widget _buildBody() {
    if (!_hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final tickets = _tickets;

    return RefreshIndicator(
      // 修复：使用 () async => 语法包装 void 方法
      onRefresh: () async {
        await _reloadTicketsQuietly();
      },
      child: RefreshAndEmpty(
        isEmpty: tickets.isEmpty,
        // 修复：这里也需要返回 Future<bool>
        onRefresh: _reloadTicketsQuietly,
        emptyIcon: Icons.confirmation_number,
        emptyTitle: '暂无票据',
        emptySubtitle: '下拉刷新或点击右下角 + 新建',
        emptyActionText: null,
        onEmptyAction: null,
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemCount: tickets.length,
                itemBuilder: (_, i) {
                  final t = tickets[i];
                  return SectionCard(
                    title: t.type == '火车' ? '火车票' : '飞机票',
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.primaryDarkBlue,
                      ),
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      tooltip: '编辑',
                      onPressed: () => _handleEditTicket(t),
                    ),
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.place,
                            size: 18,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Expanded(child: Text('${t.from} → ${t.to}')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Expanded(child: Text(_fmtRange(t))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.chair,
                            size: 18,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${t.seatClass ?? ''} ${t.seatNo ?? ''}'.trim(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}