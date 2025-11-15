import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final Widget? trailing; // 可选右侧操作按钮/区域

  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    this.padding,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? AppSpacing.medium, // 使用统一的间距配置
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withOpacity(0.9),
        borderRadius: AppBorderRadius.extraLarge, // 使用统一圆角
        boxShadow: [AppShadows.light], // 使用统一阴影
        border: Border.all(color: AppColors.borderLight, width: 1), // 添加边框
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行，支持右侧操作区
          if (trailing == null) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: AppFontSizes.title, // 20px
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFontSizes.title, // 20px
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // 右侧操作区
                trailing!,
              ],
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
