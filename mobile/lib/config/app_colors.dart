import 'package:flutter/material.dart';

/// 应用色彩配置文件 - 安全舒适主题
/// 主色调：浅蓝色用于导航栏和主要功能区域
/// 辅助色：浅绿色用于按钮、提示框等交互元素
/// 背景色：采用柔和的浅蓝白渐变
/// 文字颜色：深灰确保可读性
class AppColors {
  // 主色调 - 浅蓝色系列
  static const Color primaryLightBlue = Color(0xFFE6F7FF); // 主色调：浅蓝色
  static const Color primaryBlue = Color(0xFF91D5FF);      // 主要蓝色
  static const Color primaryDarkBlue = Color(0xFF1890FF); // 深蓝色
  static const Color primaryDeeperBlue = Color(0xFF096DD9); // 更深蓝色
  
  // 辅助色 - 浅绿色系列
  static const Color secondaryLightGreen = Color(0xFFE8F8F5); // 辅助色：浅绿色
  static const Color secondaryGreen = Color(0xFF52C41A);     // 主要绿色
  static const Color secondaryDarkGreen = Color(0xFF389E0D); // 深绿色
  
  // 背景色 - 渐变系列
  static const Color backgroundLight = Color(0xFFF0F9FF);     // 背景渐变起始色
  static const Color backgroundWhite = Color(0xFFFFFFFF);     // 纯白色
  static const Color backgroundGrey = Color(0xFFFAFAFA);      // 浅灰色背景
  
  // 文字颜色
  static const Color textPrimary = Color(0xFF333333);       // 主要文字：深灰
  static const Color textSecondary = Color(0xFF666666);      // 次要文字：中灰
  static const Color textTertiary = Color(0xFF999999);       // 提示文字：浅灰
  static const Color textWhite = Color(0xFFFFFFFF);          // 白色文字
  
  // 状态颜色
  static const Color success = Color(0xFF52C41A);            // 成功：绿色
  static const Color warning = Color(0xFFFAAD14);          // 警告：黄色
  static const Color error = Color(0xFFFF4D4F);             // 错误：红色
  static const Color info = Color(0xFF1890FF);             // 信息：蓝色
  
  // 边框和分割线
  static const Color borderLight = Color(0xFFE8E8E8);       // 浅色边框
  static const Color borderDefault = Color(0xFFD9D9D9);      // 默认边框
  static const Color divider = Color(0xFFF0F0F0);          // 分割线
  
  // 阴影颜色
  static const Color shadowLight = Color(0x0D000000);        // 浅色阴影：rgba(0,0,0,0.05)
  static const Color shadowMedium = Color(0x1A000000);      // 中等阴影：rgba(0,0,0,0.1)
  static const Color shadowDark = Color(0x26000000);        // 深色阴影：rgba(0,0,0,0.15)
  
  // 渐变配置
  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundLight, backgroundWhite],
  );
  
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLightBlue, primaryBlue],
  );
  
  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLightGreen, secondaryGreen],
  );
}

/// 扩展的BoxShadow配置
class AppShadows {
  // 柔和阴影：0 2px 8px rgba(0,0,0,0.05)
  static const BoxShadow light = BoxShadow(
    color: AppColors.shadowLight,
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  
  // 中等阴影：0 4px 12px rgba(0,0,0,0.1)
  static const BoxShadow medium = BoxShadow(
    color: AppColors.shadowMedium,
    blurRadius: 12,
    offset: Offset(0, 4),
  );
  
  // 深色阴影：0 6px 16px rgba(0,0,0,0.15)
  static const BoxShadow dark = BoxShadow(
    color: AppColors.shadowDark,
    blurRadius: 16,
    offset: Offset(0, 6),
  );
}

/// 扩展的BorderRadius配置
class AppBorderRadius {
  // 小圆角：4px
  static const BorderRadius small = BorderRadius.all(Radius.circular(4));
  
  // 中等圆角：6px
  static const BorderRadius medium = BorderRadius.all(Radius.circular(6));
  
  // 大圆角：8px
  static const BorderRadius large = BorderRadius.all(Radius.circular(8));
  
  // 超大圆角：12px
  static const BorderRadius extraLarge = BorderRadius.all(Radius.circular(12));
}

/// 扩展的EdgeInsets配置
class AppSpacing {
  // 小间距：8px
  static const EdgeInsets small = EdgeInsets.all(8);
  
  // 中间距：16px
  static const EdgeInsets medium = EdgeInsets.all(16);
  
  // 大间距：24px
  static const EdgeInsets large = EdgeInsets.all(24);
  
  // 水平间距：16px
  static const EdgeInsets horizontal = EdgeInsets.symmetric(horizontal: 16);
  
  // 垂直间距：16px
  static const EdgeInsets vertical = EdgeInsets.symmetric(vertical: 16);
}

/// 字体大小配置
class AppFontSizes {
  // 正文：14px
  static const double body = 14;
  
  // 正文大：16px
  static const double bodyLarge = 16;
  
  // 小标题：18px
  static const double subtitle = 18;
  
  // 标题：20px
  static const double title = 20;
  
  // 大标题：24px
  static const double titleLarge = 24;
}