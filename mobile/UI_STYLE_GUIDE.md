# Seek Mobile App - UI Style Guide

## 概述
本风格指南定义了Seek移动应用的完整视觉设计系统，以浅蓝色(#E6F7FF)和浅绿色(#E8F8F5)为主色调，打造安全、舒适的视觉体验。

## 色彩方案

### 主色调 - 浅蓝色系列
- **Primary Light Blue** `#E6F7FF` - 主色调：用于导航栏和主要功能区域
- **Primary Blue** `#91D5FF` - 主要蓝色：用于高亮和选中状态
- **Primary Dark Blue** `#1890FF` - 深蓝色：用于重要按钮和链接
- **Primary Deeper Blue** `#096DD9` - 更深蓝色：用于悬停和激活状态

### 辅助色 - 浅绿色系列
- **Secondary Light Green** `#E8F8F5` - 辅助色：用于按钮、提示框等交互元素
- **Secondary Green** `#52C41A` - 主要绿色：用于成功状态和主要按钮
- **Secondary Dark Green** `#389E0D` - 深绿色：用于悬停状态

### 背景色 - 渐变系列
- **Background Light** `#F0F9FF` - 背景渐变起始色
- **Background White** `#FFFFFF` - 纯白色：用于卡片和主要内容区域
- **Background Grey** `#FAFAFA` - 浅灰色背景：用于输入框背景

### 文字颜色
- **Text Primary** `#333333` - 主要文字：深灰色确保可读性
- **Text Secondary** `#666666` - 次要文字：中灰色用于辅助信息
- **Text Tertiary** `#999999` - 提示文字：浅灰色用于占位符和说明
- **Text White** `#FFFFFF` - 白色文字：用于深色背景上的文字

### 状态颜色
- **Success** `#52C41A` - 成功：绿色
- **Warning** `#FAAD14` - 警告：黄色
- **Error** `#FF4D4F` - 错误：红色
- **Info** `#1890FF` - 信息：蓝色

### 边框和分割线
- **Border Light** `#E8E8E8` - 浅色边框
- **Border Default** `#D9D9D9` - 默认边框
- **Divider** `#F0F0F0` - 分割线

### 阴影颜色
- **Shadow Light** `rgba(0,0,0,0.05)` - 浅色阴影
- **Shadow Medium** `rgba(0,0,0,0.1)` - 中等阴影
- **Shadow Dark** `rgba(0,0,0,0.15)` - 深色阴影

## 渐变配置

### 背景渐变
```dart
static const Gradient backgroundGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.backgroundLight, AppColors.backgroundWhite],
);
```

### 主色调渐变
```dart
static const Gradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.primaryLightBlue, AppColors.primaryBlue],
);
```

### 辅助色渐变
```dart
static const Gradient secondaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.secondaryLightGreen, AppColors.secondaryGreen],
);
```

## 阴影效果

### 柔和阴影
```dart
static const BoxShadow light = BoxShadow(
  color: AppColors.shadowLight,  // rgba(0,0,0,0.05)
  blurRadius: 8,
  offset: Offset(0, 2),
);
```

### 中等阴影
```dart
static const BoxShadow medium = BoxShadow(
  color: AppColors.shadowMedium,  // rgba(0,0,0,0.1)
  blurRadius: 12,
  offset: Offset(0, 4),
);
```

### 深色阴影
```dart
static const BoxShadow dark = BoxShadow(
  color: AppColors.shadowDark,  // rgba(0,0,0,0.15)
  blurRadius: 16,
  offset: Offset(0, 6),
);
```

## 圆角配置

### 小圆角
```dart
static const BorderRadius small = BorderRadius.all(Radius.circular(4));
```

### 中等圆角
```dart
static const BorderRadius medium = BorderRadius.all(Radius.circular(6));
```

### 大圆角
```dart
static const BorderRadius large = BorderRadius.all(Radius.circular(8));
```

### 超大圆角
```dart
static const BorderRadius extraLarge = BorderRadius.all(Radius.circular(12));
```

## 间距系统

### 小间距
```dart
static const EdgeInsets small = EdgeInsets.all(8);
```

### 中间距
```dart
static const EdgeInsets medium = EdgeInsets.all(16);
```

### 大间距
```dart
static const EdgeInsets large = EdgeInsets.all(24);
```

### 水平间距
```dart
static const EdgeInsets horizontal = EdgeInsets.symmetric(horizontal: 16);
```

### 垂直间距
```dart
static const EdgeInsets vertical = EdgeInsets.symmetric(vertical: 16);
```

## 字体大小层级

### 正文
```dart
static const double body = 14;        // 正文：14px
static const double bodyLarge = 16;   // 正文大：16px
```

### 标题
```dart
static const double subtitle = 18;      // 小标题：18px
static const double title = 20;       // 标题：20px
static const double titleLarge = 24;  // 大标题：24px
```

## 按钮规范

### 主要按钮
- **高度**: 44px（标准手机）
- **背景色**: 浅绿色(#E8F8F5)
- **文字颜色**: 白色(#FFFFFF)
- **圆角**: 6px
- **字体大小**: 16px
- **阴影**: 柔和阴影

### 响应式按钮高度
- **小屏手机**(< 375px): 40px
- **标准手机**(≥ 375px): 44px
- **大屏手机**(> 414px): 48px

## 响应式布局

### 断点设置
- **Mobile Small**: < 375px (小屏手机)
- **Mobile Medium**: ≥ 375px (标准手机)
- **Mobile Large**: ≥ 414px (大屏手机)
- **Tablet Small**: ≥ 600px (小平板)
- **Tablet Large**: ≥ 768px (标准平板)
- **Desktop**: ≥ 1024px (桌面)

### 响应式间距
- **小屏手机**: 12px
- **标准手机**: 16px
- **大屏手机**: 20px

### 响应式字体大小
- **小屏手机**: 基础大小 × 0.9
- **标准手机**: 基础大小
- **大屏手机**: 基础大小 × 1.1

## 组件样式

### 导航栏
- **背景色**: 浅蓝色(#E6F7FF)
- **文字颜色**: 深灰色(#333333)
- **标题居中**: 是
- **阴影**: 无

### 卡片组件
- **背景色**: 白色(#FFFFFF)
- **边框**: 浅灰色(#E8E8E8)
- **圆角**: 8px
- **间距**: 16px
- **阴影**: 柔和阴影

### 输入框
- **背景色**: 浅灰色(#FAFAFA)
- **边框**: 浅灰色(#E8E8E8)
- **激活边框**: 主蓝色(#1890FF)
- **圆角**: 6px
- **内边距**: 16px(水平)

### 离线模式提示
- **背景色**: 警告色透明10%
- **边框**: 警告色透明30%
- **圆角**: 8px
- **阴影**: 柔和阴影

## 安全提示图标

### SecurityIcon
用于重要操作区域的安全提示，显示盾牌图标和工具提示。

### SecurityBadge  
用于状态显示的安全徽章，包含图标和文字。

### SecurityBanner
用于页面顶部的安全提醒横幅。

## 使用示例

### 颜色使用
```dart
// 主色调
AppColors.primaryLightBlue  // 导航栏背景
AppColors.primaryBlue       // 选中状态
AppColors.primaryDarkBlue   // 重要链接

// 辅助色
AppColors.secondaryLightGreen  // 按钮背景
AppColors.secondaryGreen       // 成功状态

// 文字颜色
AppColors.textPrimary    // 主要文字
AppColors.textSecondary  // 次要文字
AppColors.textTertiary   // 提示文字
```

### 阴影使用
```dart
// 添加柔和阴影
boxShadow: [AppShadows.light]

// 添加中等阴影  
boxShadow: [AppShadows.medium]

// 添加深色阴影
boxShadow: [AppShadows.dark]
```

### 圆角使用
```dart
// 小圆角(4px)
borderRadius: AppBorderRadius.small

// 中等圆角(6px)
borderRadius: AppBorderRadius.medium

// 大圆角(8px)
borderRadius: AppBorderRadius.large
```

### 间距使用
```dart
// 统一间距(16px)
padding: AppSpacing.medium

// 响应式间距
padding: Responsive.responsivePadding(context)
```

### 响应式布局
```dart
// 获取响应式值
Responsive.value(context,
  small: 12,    // 小屏手机
  medium: 16,   // 标准手机
  large: 20,    // 大屏手机
)

// 响应式按钮高度
height: Responsive.responsiveButtonHeight(context)

// 响应式字体大小
fontSize: Responsive.value(context,
  small: AppFontSizes.body,
  medium: AppFontSizes.bodyLarge,
  large: AppFontSizes.bodyLarge + 2,
)
```

## 设计原则

1. **安全性**: 使用安全提示图标和柔和的配色方案营造安全感
2. **舒适性**: 采用浅色调和柔和的阴影效果
3. **一致性**: 统一的间距、圆角和色彩系统
4. **可访问性**: 确保足够的对比度和可读性
5. **响应式**: 适配不同尺寸的移动设备

## 文件结构

```
lib/
├── config/
│   └── app_colors.dart      # 色彩配置
├── utils/
│   └── responsive.dart      # 响应式工具
├── widgets/
│   ├── section_card.dart    # 卡片组件
│   └── security_icons.dart  # 安全图标
└── pages/
    ├── login_page.dart      # 登录页面
    └── user/
        └── profile_page.dart # 个人主页
```

## 更新日志

### v1.0.0 (2024-11-14)
- ✨ 创建完整的色彩系统
- ✨ 实现响应式布局工具
- ✨ 添加安全提示图标组件
- ✨ 统一按钮和卡片样式
- ✨ 优化字体大小层级
- ✨ 添加柔和的阴影效果