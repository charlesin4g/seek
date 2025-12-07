import 'package:flutter/material.dart';
import 'pages/gear/gear_page.dart';
import 'pages/login_page.dart';
import 'pages/ticket/ticket_page.dart';
import 'pages/user/profile_page.dart';
import 'widgets/tab_scaffold.dart';
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
    const TicketPage(),
    const GearPage(),
    const TabScaffold(title: 'Messages', icon: Icons.message),
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
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), selectedIcon: Icon(Icons.confirmation_number), label: 'Tickets'),
          NavigationDestination(icon: Icon(Icons.sports_outlined), selectedIcon: Icon(Icons.sports), label: 'Gear'),
          NavigationDestination(icon: Icon(Icons.message_outlined), selectedIcon: Icon(Icons.message), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
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
    final displayName = (cached?['displayName'] ?? cached?['username'] ?? AuthService().currentUser ?? '见山用户').toString();
    final mq = MediaQuery.of(context);
    final minHeight = mq.size.height - mq.padding.top - mq.padding.bottom - 48;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.backgroundGradient, // 使用渐变背景
                boxShadow: [AppShadows.light], // 添加柔和阴影
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ResponsiveContainer( // 使用响应式容器
                padding: Responsive.responsivePadding(context), // 使用响应式间距
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight, maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 32), // 调整间距
                          Text(
                            '欢迎回来，$displayName',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Responsive.value(context,
                                small: AppFontSizes.title, // 小屏使用20px
                                medium: AppFontSizes.titleLarge, // 标准屏使用24px
                                large: AppFontSizes.titleLarge + 2, // 大屏使用26px
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QuickButton(
                              icon: Icons.confirmation_number,
                              label: '票据管理',
                              onPressed: () => onNavigate(1),
                            ),
                            SizedBox(height: Responsive.value(context,
                              small: 12, // 小屏手机使用12px间距
                              medium: 16, // 标准手机使用16px间距
                              large: 20, // 大屏手机使用20px间距
                            )),
                            _QuickButton(
                              icon: Icons.sports,
                              label: '装备管理',
                              onPressed: () => onNavigate(2),
                            ),
                            SizedBox(height: Responsive.value(context,
                              small: 12,
                              medium: 16,
                              large: 20,
                            )),
                            _QuickButton(
                              icon: Icons.person,
                              label: '个人信息',
                              onPressed: () => onNavigate(4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Responsive.responsiveButtonHeight(context), // 使用响应式按钮高度
      child: FilledButton(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.medium, // 圆角6px
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: Responsive.value(context,
              small: 16, // 小屏手机图标16px
              medium: 18, // 标准手机图标18px
              large: 20, // 大屏手机图标20px
            )),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
              fontSize: Responsive.value(context,
                small: AppFontSizes.body, // 小屏手机使用14px
                medium: AppFontSizes.bodyLarge, // 标准手机使用16px
                large: AppFontSizes.bodyLarge + 2, // 大屏手机使用18px
              ),
            )),
          ],
        ),
      ),
    );
  }
}
