import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

class TicketSummaryCard extends StatelessWidget {
  const TicketSummaryCard({
    super.key,
    required this.ticketKindDisplay,
    required this.codeController,
    required this.departController,
    required this.arriveController,
    required this.priceController,
    required this.departTime,
    required this.arriveTime,
  });

  final String ticketKindDisplay;
  final TextEditingController codeController;
  final TextEditingController departController;
  final TextEditingController arriveController;
  final TextEditingController priceController;
  final DateTime departTime;
  final DateTime arriveTime;

  IconData get _summaryIcon =>
      ticketKindDisplay == '飞机票' ? Icons.flight_takeoff : Icons.train;

  String get _durationLabel {
    final diffMinutes = arriveTime.difference(departTime).inMinutes.abs();
    final hours = diffMinutes ~/ 60;
    final minutes = diffMinutes % 60;
    if (hours == 0) {
      return '$minutes分钟';
    }
    if (minutes == 0) {
      return '$hours小时';
    }
    return '$hours小时$minutes分钟';
  }

  String _formatPrice(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(cleaned);
    if (value == null || value == 0) {
      return '预算待定';
    }
    return '¥ ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isFlight = ticketKindDisplay == '飞机票';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isFlight ? AppColors.secondaryGradient : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ticketKindDisplay,
                  style: const TextStyle(
                    fontSize: AppFontSizes.body,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: priceController,
                builder: (_, value, __) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _formatPrice(value.text),
                      style: const TextStyle(
                        fontSize: AppFontSizes.body,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: codeController,
            builder: (_, value, __) {
              final text = value.text.trim();
              return Text(
                text.isEmpty ? '输入车次/航班号' : text.toUpperCase(),
                style: const TextStyle(
                  fontSize: AppFontSizes.titleLarge,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: Listenable.merge([departController, arriveController]),
            builder: (_, __) {
              final depart = departController.text.trim().isEmpty
                  ? '出发地待定'
                  : departController.text.trim();
              final arrive = arriveController.text.trim().isEmpty
                  ? '到达地待定'
                  : arriveController.text.trim();
              return Text(
                '$depart  ·  $arrive',
                style: const TextStyle(
                  fontSize: AppFontSizes.body,
                  color: Colors.black87,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TicketTerminalColumn(
                  label: '出发',
                  controller: departController,
                  date: departTime,
                  alignEnd: false,
                ),
              ),
              SizedBox(
                width: 56,
                child: Column(
                  children: [
                    Icon(_summaryIcon, color: Colors.black.withValues(alpha: 0.8)),
                    const SizedBox(height: 8),
                    Text(
                      _durationLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppFontSizes.body,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _TicketTerminalColumn(
                  label: '到达',
                  controller: arriveController,
                  date: arriveTime,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketTerminalColumn extends StatelessWidget {
  const _TicketTerminalColumn({
    required this.label,
    required this.controller,
    required this.date,
    required this.alignEnd,
  });

  final String label;
  final TextEditingController controller;
  final DateTime date;
  final bool alignEnd;

  String _formatDate(DateTime dt) {
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$month月$day日';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        final place = value.text.trim().isEmpty
            ? (label == '出发' ? '出发地' : '到达地')
            : value.text.trim();
        return Column(
          crossAxisAlignment:
              alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: AppFontSizes.body,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              place,
              textAlign: alignEnd ? TextAlign.end : TextAlign.start,
              style: const TextStyle(
                fontSize: AppFontSizes.subtitle,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatDate(date),
              style: const TextStyle(
                fontSize: AppFontSizes.body,
                color: Colors.black87,
              ),
            ),
            Text(
              _formatTime(date),
              style: const TextStyle(
                fontSize: AppFontSizes.title,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }
}
