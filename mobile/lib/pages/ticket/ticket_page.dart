import 'package:flutter/material.dart';
import 'package:mobile/data/database_provider.dart';
import 'package:mobile/data/services/ticket_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            '票据记录',
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          actions: const [],
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryGreen,
          onPressed: _handleAddTicket,
          child: const Icon(Icons.add, color: Colors.white),
        ),
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
      color: AppColors.primaryGreen,
      onRefresh: () async {
        await _reloadTicketsQuietly();
      },
      child: RefreshAndEmpty(
        isEmpty: tickets.isEmpty,
        onRefresh: _reloadTicketsQuietly,
        emptyIcon: Icons.confirmation_number_outlined,
        emptyTitle: '暂无票据',
        emptySubtitle: '记录你的每一次出发',
        emptyActionText: null,
        onEmptyAction: null,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemCount: tickets.length,
          itemBuilder: (_, i) {
            final t = tickets[i];
            return _TicketItemCard(
              ticket: t,
              onTap: () => _handleEditTicket(t),
            );
          },
        ),
      ),
    );
  }
}

class _TicketItemCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const _TicketItemCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isTrain = ticket.type == '火车' || ticket.type == 'train';
    final Color typeColor = isTrain ? AppColors.primaryGreen : AppColors.secondaryBlue;
    final IconData typeIcon = isTrain ? Icons.train : Icons.flight;
    final String typeName = isTrain ? '火车票' : '飞机票';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [AppShadows.light],
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(typeIcon, size: 18, color: typeColor),
                  const SizedBox(width: 8),
                  Text(
                    ticket.transportNo.isNotEmpty ? ticket.transportNo : typeName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                  const Spacer(),
                  // Status is not persisted in Ticket entity yet, so we omit it or use a placeholder if needed.
                  // For now, let's just show seat class if available as a tag
                  if (ticket.seatClass != null && ticket.seatClass!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: typeColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        ticket.seatClass!,
                        style: TextStyle(
                          fontSize: 10,
                          color: typeColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStation(ticket.from, isStart: true),
                      const Icon(Icons.arrow_forward, color: AppColors.borderDefault),
                      _buildStation(ticket.to, isStart: false),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem('出发时间', _formatTime(ticket.departureTime)),
                      _buildInfoItem('座位', ticket.seatNo ?? '-'),
                      _buildInfoItem('价格', ticket.price != null ? '¥${ticket.price!.toStringAsFixed(0)}' : '-'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStation(String name, {required bool isStart}) {
    return Column(
      crossAxisAlignment: isStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isStart ? AppColors.primaryLightGreen : AppColors.secondaryLightBlue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isStart ? '出发' : '到达',
            style: TextStyle(
              fontSize: 10,
              color: isStart ? AppColors.primaryDarkGreen : AppColors.secondaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}