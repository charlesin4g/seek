import 'package:flutter/material.dart';

import 'empty_state.dart';

/// 刷新与空态统一组件
///
/// - 提供统一下拉刷新交互（RefreshIndicator）；
/// - 根据 `isEmpty` 展示统一空态；
/// - 通过 `onRefresh` 回调注入页面刷新逻辑，组件本身不做业务处理。
class RefreshAndEmpty extends StatefulWidget {
  final bool isEmpty;
  final Future<bool> Function() onRefresh;
  final Widget child;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptySubtitle;
  final String? emptyActionText;
  final VoidCallback? onEmptyAction;

  const RefreshAndEmpty({
    super.key,
    required this.isEmpty,
    required this.onRefresh,
    required this.child,
    this.emptyIcon = Icons.inbox,
    this.emptyTitle = '暂无数据',
    this.emptySubtitle,
    this.emptyActionText,
    this.onEmptyAction,
  });

  @override
  State<RefreshAndEmpty> createState() => _RefreshAndEmptyState();
}

class _RefreshAndEmptyState extends State<RefreshAndEmpty> {
  bool _refreshing = false;

  /// 统一下拉刷新处理：显示一致动画，并在回调返回失败时保留空态
  Future<void> _handleRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 当内容为空时，展示统一的空态；否则展示内容并支持下拉刷新
    final content = widget.isEmpty
        ? EmptyState(
            icon: widget.emptyIcon,
            title: widget.emptyTitle,
            subtitle: widget.emptySubtitle,
            actionText: widget.emptyActionText,
            onAction: widget.onEmptyAction,
          )
        : widget.child;

    return RefreshIndicator(
      displacement: 60,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Colors.white,
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        child: content,
      ),
    );
  }
}