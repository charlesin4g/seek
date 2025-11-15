import 'package:flutter/material.dart';

/// 响应式布局工具类
/// 确保应用在移动设备上（≥375px）有良好的显示效果
class Responsive {
  // 标准断点设置
  static const double mobileSmall = 320;   // 小屏手机
  static const double mobileMedium = 375;  // 标准手机（iPhone 6/7/8）
  static const double mobileLarge = 414;   // 大屏手机（iPhone 6/7/8 Plus）
  static const double tabletSmall = 600;  // 小平板
  static const double tabletLarge = 768;  // 标准平板
  static const double desktop = 1024;     // 桌面

  /// 获取当前设备宽度
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 获取当前设备高度
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// 判断是否是小屏手机（< 375px）
  static bool isMobileSmall(BuildContext context) {
    return width(context) < mobileMedium;
  }

  /// 判断是否是标准手机（≥ 375px）
  static bool isMobileMedium(BuildContext context) {
    return width(context) >= mobileMedium && width(context) < mobileLarge;
  }

  /// 判断是否是大屏手机（≥ 414px）
  static bool isMobileLarge(BuildContext context) {
    return width(context) >= mobileLarge && width(context) < tabletSmall;
  }

  /// 判断是否是手机设备（< 600px）
  static bool isMobile(BuildContext context) {
    return width(context) < tabletSmall;
  }

  /// 判断是否是小屏设备（< 375px），需要特殊处理
  static bool isSmallScreen(BuildContext context) {
    return width(context) < mobileMedium;
  }

  /// 根据屏幕宽度返回不同的值
  /// 小屏手机返回 small 值，标准手机返回 medium 值，大屏返回 large 值
  static T value<T>(BuildContext context, {
    required T small,
    required T medium,
    required T large,
  }) {
    final width = Responsive.width(context);
    if (width < mobileMedium) return small;
    if (width < mobileLarge) return medium;
    return large;
  }

  /// 根据屏幕宽度返回响应式的间距
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = Responsive.width(context);
    if (width < mobileMedium) {
      return const EdgeInsets.all(12); // 小屏手机使用12px间距
    } else if (width < mobileLarge) {
      return const EdgeInsets.all(16); // 标准手机使用16px间距
    } else {
      return const EdgeInsets.all(20); // 大屏手机使用20px间距
    }
  }

  /// 获取响应式的最大内容宽度
  static double maxContentWidth(BuildContext context) {
    final width = Responsive.width(context);
    if (width < mobileMedium) {
      return width - 24; // 小屏手机减去24px边距
    } else if (width < mobileLarge) {
      return width - 32; // 标准手机减去32px边距
    } else if (width < tabletSmall) {
      return width - 40; // 大屏手机减去40px边距
    } else {
      return 600; // 平板和桌面使用固定宽度
    }
  }

  /// 获取响应式的字体大小
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final width = Responsive.width(context);
    if (width < mobileMedium) {
      return baseSize * 0.9; // 小屏手机字体缩小10%
    } else if (width > mobileLarge) {
      return baseSize * 1.1; // 大屏手机字体放大10%
    }
    return baseSize; // 标准手机使用基础大小
  }

  /// 获取响应式的按钮高度
  static double responsiveButtonHeight(BuildContext context) {
    final width = Responsive.width(context);
    if (width < mobileMedium) {
      return 40; // 小屏手机使用40px高度
    } else if (width > mobileLarge) {
      return 48; // 大屏手机使用48px高度
    }
    return 44; // 标准手机使用44px高度（设计要求）
  }
}

/// 响应式布局组件
/// 根据屏幕宽度自动调整子组件的布局
class ResponsiveLayout extends StatelessWidget {
  final WidgetBuilder smallLayout;
  final WidgetBuilder mediumLayout;
  final WidgetBuilder? largeLayout;

  const ResponsiveLayout({
    super.key,
    required this.smallLayout,
    required this.mediumLayout,
    this.largeLayout,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobileSmall(context)) {
      return smallLayout(context);
    } else if (Responsive.isMobileLarge(context)) {
      return largeLayout?.call(context) ?? mediumLayout(context);
    } else {
      return mediumLayout(context);
    }
  }
}

/// 响应式约束容器
/// 自动限制内容的最大宽度，确保在小屏设备上的可读性
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: padding ?? Responsive.responsivePadding(context),
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
}