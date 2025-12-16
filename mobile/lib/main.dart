import 'package:flutter/material.dart';
import 'pages/gear/gear_page.dart';
import 'pages/login_page.dart';
import 'pages/user/profile_page.dart';
import 'pages/trail/trail_list_page.dart';
import 'pages/trail/trail_map_page.dart';
import 'services/auth_service.dart';
import 'services/user_api.dart';
import 'services/env.dart';
import 'services/storage_service.dart';
import 'config/app_colors.dart';
import 'utils/responsive.dart';

void main() {
  // 初始化绑定，确保可以设置错误处理器
  WidgetsFlutterBinding.ensureInitialized();

  // 捕获 Flutter 框架错误（包括构建/布局/绘制阶段产生的错误）并打印到控制台
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (details.stack != null) {
      debugPrintStack(stackTrace: details.stack);
    }
  };

  // 捕获异步未处理错误（Future、微任务等）并打印到控制台
  WidgetsBinding.instance.platformDispatcher.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught async error: $error');
    debugPrintStack(stackTrace: stack);
    return true; // 标记已处理，避免重复上报
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
                const SizedBox(height: 12),
                const Text('页面加载出错', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(details.exceptionAsString(), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    };
    return MaterialApp(
      title: 'Seek Mobile',
      theme: ThemeData(
        // 使用新的色彩方案
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.secondaryGreen,
          surface: AppColors.backgroundWhite,
        ),
        // 应用栏主题
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryLightBlue,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppFontSizes.title,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        // 按钮主题
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondaryGreen,
            foregroundColor: AppColors.textWhite,
            minimumSize: const Size(double.infinity, 44), // 高度44px
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.medium, // 圆角6px
            ),
            textStyle: const TextStyle(
              fontSize: AppFontSizes.body,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // 文本按钮主题
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryDarkBlue,
            textStyle: const TextStyle(
              fontSize: AppFontSizes.body,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // 卡片主题
        cardTheme: CardThemeData(
          color: AppColors.backgroundWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.large, // 圆角8px
            side: BorderSide(color: AppColors.borderLight),
          ),
          margin: AppSpacing.medium, // 间距16px
        ),
        // 文本主题
        textTheme: const TextTheme(
          bodySmall: TextStyle(fontSize: AppFontSizes.body, color: AppColors.textSecondary),
          bodyMedium: TextStyle(fontSize: AppFontSizes.bodyLarge, color: AppColors.textPrimary),
          bodyLarge: TextStyle(fontSize: AppFontSizes.bodyLarge, color: AppColors.textPrimary),
          titleSmall: TextStyle(fontSize: AppFontSizes.subtitle, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: AppFontSizes.title, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontSize: AppFontSizes.titleLarge, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        // 输入框主题
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.backgroundGrey,
          border: OutlineInputBorder(
            borderRadius: AppBorderRadius.medium,
            borderSide: BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.medium,
            borderSide: BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.medium,
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          contentPadding: AppSpacing.horizontal,
        ),
        // 底部导航栏主题
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.backgroundWhite,
          indicatorColor: AppColors.primaryLightBlue,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: AppFontSizes.body, color: AppColors.textSecondary),
          ),
          iconTheme: WidgetStateProperty.all(
            const IconThemeData(color: AppColors.textSecondary),
          ),
        ),
        // 浮动操作按钮主题
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondaryGreen,
          foregroundColor: AppColors.textWhite,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.large,
          ),
        ),
        // 对话框主题
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.backgroundWhite,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.extraLarge,
          ),
          elevation: 8,
        ),
        // 分割线颜色
        dividerColor: AppColors.divider,
        // 禁用状态颜色
        disabledColor: AppColors.textTertiary,
        // 指示器颜色
        indicatorColor: AppColors.primaryBlue,
        // 选中颜色
        highlightColor: AppColors.primaryLightBlue.withValues(alpha: 0.1),
        // 波纹颜色
        splashColor: AppColors.primaryBlue.withValues(alpha: 0.1),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<void>? _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    // Debug 模式下，自动获取用户信息并缓存，跳过登录页
    if (Env.useTestDefaultLogin) {
      _bootstrapFuture = _bootstrapDebugUser();
    }
  }

  Future<void> _bootstrapDebugUser() async {
    try {
      // 默认使用 admin 作为测试用户
      final user = await UserApi()
          .getUserByUsername('admin')
          .timeout(const Duration(seconds: 3));
      await AuthService().bootstrapWithUser(user);
    } catch (e) {
      // 失败则保持未登录状态，回退到登录页
      debugPrint('Debug bootstrap user failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    if (!Env.useTestDefaultLogin) {
      // 正常模式：根据登录状态选择页面
      return authService.isLoggedIn ? const MainApp() : const LoginPage();
    }

    // Debug 模式：用 FutureBuilder 等待一次性引导，完成后进入主界面
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              return const LoginPage();
            }
            return const MainApp();
        }
      },
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const HomeTabs();
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _currentIndex = 0;

  late final List<Widget> _pages = <Widget>[
    HomePage(onNavigate: (index) => setState(() => _currentIndex = index)),
    const TrailListPage(),
    const TrailMapPage(),
    const GearPage(),
    const UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() => _currentIndex = index);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: '足迹',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: '地图',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: '计划',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        backgroundColor: AppColors.backgroundWhite,
        indicatorColor: AppColors.primaryLightBlue,
        elevation: 0,
        shadowColor: Colors.transparent,
      )
    );
  }
}

class FullScreenBackground extends StatelessWidget {
  final Widget child;
  final ImageProvider? image;
  const FullScreenBackground({super.key, required this.child, this.image});

  @override
  Widget build(BuildContext context) {
    final img = image ?? const AssetImage('lib/assests/background.png');
    return Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder<void>(
            future: precacheImage(img, context),
            builder: (context, snapshot) {
              final loaded = snapshot.connectionState == ConnectionState.done;
              return AnimatedOpacity(
                opacity: loaded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: img,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.low,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onNavigate});
  final void Function(int) onNavigate;

  @override
  Widget build(BuildContext context) {
    final cached = StorageService().getCachedUserSync();
    final displayName = (cached?['displayName'] ?? cached?['username'] ?? AuthService().currentUser ?? '旅行者').toString();

    Widget buildStatCard({
      required IconData icon,
      required String label,
      required String value,
      required Color color,
    }) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: AppBorderRadius.extraLarge,
            boxShadow: const [AppShadows.light],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: AppFontSizes.titleLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: AppFontSizes.body,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildSegmentChip(String label, {bool selected = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDarkBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? AppColors.textWhite : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      );
    }

    Widget buildTrendCard() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: AppBorderRadius.extraLarge,
          boxShadow: const [AppShadows.light],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '心率趋势',
                  style: TextStyle(
                    fontSize: AppFontSizes.subtitle,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    buildSegmentChip('今日', selected: true),
                    const SizedBox(width: 4),
                    buildSegmentChip('本周'),
                    const SizedBox(width: 4),
                    buildSegmentChip('本月'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _TrendBar(heightFactor: 0.4)),
                  Expanded(child: _TrendBar(heightFactor: 0.75)),
                  Expanded(child: _TrendBar(heightFactor: 0.6)),
                  Expanded(child: _TrendBar(heightFactor: 0.9)),
                  Expanded(child: _TrendBar(heightFactor: 0.55)),
                  Expanded(child: _TrendBar(heightFactor: 0.8)),
                  Expanded(child: _TrendBar(heightFactor: 0.5)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('08:00', style: TextStyle(fontSize: AppFontSizes.body, color: AppColors.textTertiary)),
                Text('10:00', style: TextStyle(fontSize: AppFontSizes.body, color: AppColors.textTertiary)),
                Text('12:00', style: TextStyle(fontSize: AppFontSizes.body, color: AppColors.textTertiary)),
                Text('16:00', style: TextStyle(fontSize: AppFontSizes.body, color: AppColors.textTertiary)),
                Text('20:00', style: TextStyle(fontSize: AppFontSizes.body, color: AppColors.textTertiary)),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildTripCard({
      required String from,
      required String to,
      required String detail,
      required String badgeText,
      required Color badgeColor,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: AppBorderRadius.extraLarge,
          boxShadow: const [AppShadows.light],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Icon(Icons.flight_takeoff, size: 20, color: AppColors.textWhite),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$from → $to',
                    style: const TextStyle(
                      fontSize: AppFontSizes.bodyLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontSize: AppFontSizes.body,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
            ),
          ),
          SafeArea(
            child: ResponsiveContainer(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '早安，旅行者',
                                style: TextStyle(
                                  fontSize: AppFontSizes.subtitle,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '愿每次旅程元气满满！',
                                style: TextStyle(
                                  fontSize: Responsive.responsiveFontSize(context, AppFontSizes.body),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.backgroundWhite,
                          child: Text(
                            displayName.isNotEmpty ? displayName[0] : '旅',
                            style: const TextStyle(
                              fontSize: AppFontSizes.subtitle,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDarkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        buildStatCard(
                          icon: Icons.directions_walk,
                          label: '步数',
                          value: '12,847',
                          color: AppColors.secondaryGreen,
                        ),
                        buildStatCard(
                          icon: Icons.favorite,
                          label: '心率',
                          value: '8.6',
                          color: AppColors.primaryDarkBlue,
                        ),
                        buildStatCard(
                          icon: Icons.access_time,
                          label: '时长',
                          value: '2h 35m',
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    buildTrendCard(),
                    const SizedBox(height: 24),
                    const Text(
                      '即将出行',
                      style: TextStyle(
                        fontSize: AppFontSizes.subtitle,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildTripCard(
                      from: '北京',
                      to: '西安',
                      detail: '明天 14:30 · 三等座 12车06F',
                      badgeText: '18小时',
                      badgeColor: AppColors.warning,
                    ),
                    buildTripCard(
                      from: '西安',
                      to: '拉萨',
                      detail: '3月15日 09:45 · 软卧 32A',
                      badgeText: '5天',
                      badgeColor: AppColors.secondaryGreen,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendBar extends StatelessWidget {
  const _TrendBar({required this.heightFactor});

  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
    );
  }
}
