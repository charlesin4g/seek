import 'package:flutter/material.dart';

/// 应用色彩配置文件 - 安全舒适主题
/// 主色调：浅蓝色用于导航栏和主要功能区域
/// 辅助色：浅绿色用于按钮、提示框等交互元素
/// 背景色：采用柔和的浅蓝白渐变
/// 文字颜色：深灰确保可读性
class AppColors {
  // 主色调 - 亮绿色 (Bright Green / Neon Theme)
  static const Color primaryLightGreen = Color(0xFF69F0AE); // 亮绿高光
  static const Color primaryGreen = Color(0xFF00E676);      // 主绿：荧光绿
  static const Color primaryDarkGreen = Color(0xFF00C853);  // 深绿
  static const Color primaryDeeperGreen = Color(0xFF009624); // 更深绿

  // 辅助色 - 保持原有逻辑但适配暗色模式
  static const Color secondaryLightBlue = Color(0xFF40C4FF); // 亮天蓝
  static const Color secondaryBlue = Color(0xFF00B0FF);      // 天空蓝
  static const Color secondaryEarth = Color(0xFF8D6E63);     // 大地棕
  static const Color accentOrange = Color(0xFFFFAB40);       // 亮橙色

  // 兼容旧版命名
  static const Color primaryLightBlue = primaryLightGreen;
  static const Color primaryBlue = primaryGreen;
  static const Color primaryDarkBlue = primaryDarkGreen;
  static const Color primaryDeeperBlue = primaryDeeperGreen;

  // 辅助色兼容
  static const Color secondaryLightGreen = secondaryLightBlue;
  static const Color secondaryGreen = secondaryBlue;
  static const Color secondaryDarkGreen = secondaryEarth;
  
  // 背景色 - 黑色/深灰主题
  static const Color backgroundLight = Color(0xFF121212);     // 深色背景
  static const Color backgroundWhite = Color(0xFF1E1E1E);     // 卡片背景（深灰）
  static const Color backgroundGrey = Color(0xFF2C2C2C);      // 输入框/次要背景
  
  // 文字颜色
  static const Color textPrimary = Color(0xFFFFFFFF);       // 主要文字：纯白
  static const Color textSecondary = Color(0xFFB0BEC5);      // 次要文字：浅灰
  static const Color textTertiary = Color(0xFF78909C);       // 提示文字：深灰
  static const Color textWhite = Color(0xFFFFFFFF);          // 白色文字
  static const Color textBlack = Color(0xFF000000);          // 黑色文字（用于亮色背景上）
  
  // 状态颜色
  static const Color success = Color(0xFF00E676);            // 成功：荧光绿
  static const Color warning = Color(0xFFFFAB40);            // 警告：荧光橙
  static const Color error = Color(0xFFFF5252);              // 错误：荧光红
  static const Color info = Color(0xFF40C4FF);               // 信息：荧光蓝
  
  // 边框和分割线
  static const Color borderLight = Color(0xFF424242);       // 深色边框
  static const Color borderDefault = Color(0xFF616161);      // 默认边框
  static const Color divider = Color(0xFF424242);          // 分割线
  
  // 阴影颜色 - 暗色模式下阴影需要更深或改为发光效果（这里保持深色阴影）
  static const Color shadowLight = Color(0x40000000);        // 浅色阴影
  static const Color shadowMedium = Color(0x80000000);      // 中等阴影
  static const Color shadowDark = Color(0xB3000000);        // 深色阴影
  
  // 渐变配置 - 黑色流光
  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF121212), // 纯黑
      Color(0xFF000000), // 纯黑
    ],
  );
  
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF69F0AE), Color(0xFF00E676)], // 亮绿渐变
  );
  
  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF40C4FF), Color(0xFF00B0FF)], // 亮蓝渐变
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