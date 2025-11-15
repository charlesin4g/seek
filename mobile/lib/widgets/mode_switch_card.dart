import 'package:flutter/material.dart';
import '../services/offline_mode.dart';

class ModeSwitchCard extends StatefulWidget {
  final String title;
  final Widget coreInfo;
  final Widget expandedContent;
  final bool initialExpanded;
  final EdgeInsetsGeometry? padding;
  const ModeSwitchCard({super.key, required this.title, required this.coreInfo, required this.expandedContent, this.initialExpanded = true, this.padding});

  @override
  State<ModeSwitchCard> createState() => _ModeSwitchCardState();
}

class _ModeSwitchCardState extends State<ModeSwitchCard> with SingleTickerProviderStateMixin {
  late bool _expanded = widget.initialExpanded;

  @override
  Widget build(BuildContext context) {
    final isOfflineListenable = OfflineModeManager.instance.isOffline;
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: isOfflineListenable,
              builder: (context, offline, _) {
                final color = offline ? Colors.grey : Colors.blue;
                final icon = offline ? Icons.cloud_off : Icons.cloud_queue;
                final text = offline ? '离线' : '在线';
                return Row(
                  children: [
                    Icon(icon, color: color, size: 18),
                    const SizedBox(width: 6),
                    Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                  ],
                );
              },
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: isOfflineListenable,
              builder: (context, offline, _) {
                return Semantics(
                  button: true,
                  label: offline ? '切换到在线' : '切换到离线',
                  child: Tooltip(
                    message: offline ? '切到在线' : '切到离线',
                    child: InkResponse(
                      onTap: () async {
                        await OfflineModeManager.instance.setOffline(!offline);
                        if (mounted) setState(() {});
                      },
                      radius: 24,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          offline ? Icons.wifi : Icons.wifi_off,
                          key: ValueKey(offline),
                          color: offline ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    tooltip: _expanded ? '收起' : '展开',
                    icon: AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _expanded ? 0.0 : 0.25,
                      child: const Icon(Icons.expand_more),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              widget.coreInfo,
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _expanded ? Column(children: [const SizedBox(height: 12), widget.expandedContent]) : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
