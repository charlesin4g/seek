import 'package:flutter/material.dart';
import 'package:mobile/pages/map/map_page.dart';
import 'pages/login_page.dart';
import 'pages/user/user_overview_page.dart';
import 'pages/activity/activity_list_page.dart';
import 'pages/plan/travel_plan_page.dart';
import 'services/auth_service.dart';
import 'services/user_api.dart';
import 'services/env.dart';
import 'services/storage_service.dart';
import 'config/app_colors.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

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
  WidgetsBinding.instance.platformDispatcher.onError =
      (Object error, StackTrace stack) {
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
                const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                const Text(
                  '页面加载出错',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
          bodySmall: TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.textSecondary,
          ),
          bodyMedium: TextStyle(
            fontSize: AppFontSizes.bodyLarge,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: AppFontSizes.bodyLarge,
            color: AppColors.textPrimary,
          ),
          titleSmall: TextStyle(
            fontSize: AppFontSizes.subtitle,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            fontSize: AppFontSizes.title,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            fontSize: AppFontSizes.titleLarge,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
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
            const TextStyle(
              fontSize: AppFontSizes.body,
              color: AppColors.textSecondary,
            ),
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
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.large),
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
    const ActivityListPage(),
    MapPage(),
    const TravelPlanPage(),
    const UserOverviewPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
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
            label: '活动',
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
      ),
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
        Positioned.fill(child: child),
      ],
    );
  }
}

class HealthStatsCard extends StatefulWidget {
  const HealthStatsCard({super.key});

  @override
  State<HealthStatsCard> createState() => _HealthStatsCardState();
}

class _HealthStatsCardState extends State<HealthStatsCard> {
  // 定义状态变量，默认显示 '--'
  String _steps = '--';
  String _heartRate = '--';
  String _distance = '--';

  final Health _health = Health();

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    // 定义需要获取的数据类型
    var types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.DISTANCE_DELTA,
    ];

    try {
      // Android 需要 Activity Recognition 权限
      await Permission.activityRecognition.request();
      // iOS/Android 需要定位权限 (某些健康数据依赖)
      await Permission.location.request();

      // 请求 Health 授权
      bool requested = await _health.requestAuthorization(types);

      if (requested) {
        var now = DateTime.now();
        var midnight = DateTime(now.year, now.month, now.day);

        // --- 1. 获取步数 ---
        int? steps = await _health.getTotalStepsInInterval(midnight, now);

        // --- 2. 获取其他数据 (心率、距离) ---
        List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.HEART_RATE, HealthDataType.DISTANCE_DELTA],
          startTime: midnight,
          endTime: now,
        );

        // 处理心率 (取最近一次)
        String hrValue = '--';
        var heartRatePoints = healthData
            .where((e) => e.type == HealthDataType.HEART_RATE)
            .toList();

        if (heartRatePoints.isNotEmpty) {
          heartRatePoints.sort((a, b) => b.dateTo.compareTo(a.dateTo));
          // 注意：不同版本 Health 包 value 类型不同，这里转 string 再 parse 比较稳妥
          double val =
              double.tryParse(heartRatePoints.first.value.toString()) ?? 0;
          hrValue = val.toInt().toString();
        }

        // 处理距离 (累加当天)
        var distancePoints = healthData
            .where((e) => e.type == HealthDataType.DISTANCE_DELTA)
            .toList();
        double totalDistanceMeters = 0;
        for (var point in distancePoints) {
          totalDistanceMeters += double.tryParse(point.value.toString()) ?? 0;
        }
        String distanceValue =
            "${(totalDistanceMeters / 1000).toStringAsFixed(2)} km";

        if (mounted) {
          setState(() {
            _steps = steps?.toString() ?? "0";
            _heartRate = hrValue;
            _distance = distanceValue;
          });
        }
      } else {
        debugPrint("用户拒绝了健康权限授权");
      }
    } catch (e) {
      debugPrint("获取健康数据异常: $e");
    }
  }

  // 构建单个统计子项的私有方法
  Widget _buildStatItem({
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: AppFontSizes.titleLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
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

  @override
  Widget build(BuildContext context) {
    // 这里将三个卡片组合成一行
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.directions_walk,
          label: '步数',
          value: _steps,
          color: AppColors.secondaryGreen,
        ),
        _buildStatItem(
          icon: Icons.favorite,
          label: '心率',
          value: _heartRate,
          color: const Color.fromARGB(255, 237, 7, 7),
        ),
        _buildStatItem(
          icon: Icons.access_time,
          label: '距离',
          value: _distance,
          color: AppColors.warning,
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
    final displayName =
        (cached?['displayName'] ??
                cached?['username'] ??
                AuthService().currentUser ??
                '旅行者')
            .toString();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 背景装饰
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
            ),
          ),
          // 顶部装饰圆 - 增加自然氛围
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // 头部区域
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryLightGreen,
                        child: Text(
                          displayName.isNotEmpty ? displayName[0] : '旅',
                          style: const TextStyle(
                            fontSize: AppFontSizes.title,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '早安，旅行者',
                              style: TextStyle(
                                fontSize: AppFontSizes.body,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '准备好出发了吗？',
                              style: const TextStyle(
                                fontSize: AppFontSizes.title,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {}, // TODO: Notifications
                        icon: const Icon(Icons.notifications_outlined),
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
                
                // 滚动内容区域
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 健康数据概览
                        const HealthStatsCard(),
                        const SizedBox(height: 24),
                        
                        // 即将开始的行程
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '即将出行',
                              style: TextStyle(
                                fontSize: AppFontSizes.subtitle,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => onNavigate(3), // Jump to Plan
                              child: const Text('查看全部'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTripCard(
                          context,
                          from: '北京',
                          to: '西安',
                          date: '明天 14:30',
                          seat: '三等座 12车06F',
                          badgeText: '18小时',
                          badgeColor: AppColors.warning,
                        ),
                        _buildTripCard(
                          context,
                          from: '西安',
                          to: '拉萨',
                          date: '3月15日 09:45',
                          seat: '软卧 32A',
                          badgeText: '5天',
                          badgeColor: AppColors.primaryGreen,
                        ),
                        const SizedBox(height: 24),
                        
                        // 探索建议
                        const Text(
                          '探索发现',
                          style: TextStyle(
                            fontSize: AppFontSizes.subtitle,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDiscoveryCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context, {
    required String from,
    required String to,
    required String date,
    required String seat,
    required String badgeText,
    required Color badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppBorderRadius.extraLarge,
        boxShadow: [AppShadows.light],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildLocationNode(from, isStart: true),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomPaint(
                          size: const Size(double.infinity, 2),
                          painter: DashedLinePainter(color: AppColors.borderDefault),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          Icons.directions_train, 
                          size: 16, 
                          color: AppColors.textTertiary
                        ),
                      ],
                    ),
                  ),
                ),
                _buildLocationNode(to, isStart: false),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: AppFontSizes.body,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  seat,
                  style: const TextStyle(
                    fontSize: AppFontSizes.body,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationNode(String city, {required bool isStart}) {
    return Column(
      crossAxisAlignment: isStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          city,
          style: const TextStyle(
            fontSize: AppFontSizes.title,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isStart ? '出发地' : '目的地',
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDiscoveryCard() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.extraLarge,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDarkGreen,
            AppColors.primaryGreen,
          ],
        ),
        boxShadow: [AppShadows.medium],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.terrain,
              size: 140,
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '本周推荐',
                    style: TextStyle(color: Colors.black, fontSize: 10),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '秦岭穿越路线',
                  style: TextStyle(
                    fontSize: AppFontSizes.title,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '探索未知的自然风光，记录你的足迹',
                  style: TextStyle(
                    fontSize: AppFontSizes.body,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double dashWidth = 4;
    double dashSpace = 4;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

