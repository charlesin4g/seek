import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// 安全提示图标组件
/// 用于重要操作区域的安全提示
class SecurityIcon extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final double? size;

  const SecurityIcon({
    super.key,
    this.icon = Icons.security,
    this.tooltip,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.primaryDarkBlue;
    final iconSize = size ?? 16.0;

    return Tooltip(
      message: tooltip ?? '安全提示',
      child: Icon(
        icon,
        color: iconColor,
        size: iconSize,
      ),
    );
  }
}

/// 安全提示徽章组件
/// 用于显示安全状态或重要提醒
class SecurityBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;

  const SecurityBadge({
    super.key,
    required this.text,
    this.icon = Icons.security,
    this.backgroundColor = AppColors.primaryLightBlue,
    this.textColor = AppColors.textPrimary,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: AppFontSizes.body,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 安全提示横幅组件
/// 用于页面顶部的安全提醒
class SecurityBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const SecurityBanner({
    super.key,
    required this.message,
    this.icon = Icons.security,
    this.backgroundColor = AppColors.primaryLightBlue,
    this.textColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppBorderRadius.large,
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
        boxShadow: [AppShadows.light],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: AppFontSizes.body,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}