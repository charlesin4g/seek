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
    return MaterialApp(
      title: 'Seek Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
      final user = await UserApi().getUserByUsername('admin');
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
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const MainApp();
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
      )
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
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight, maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 上下分散对齐
                children: [
                  // 上方欢迎文本
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        '欢迎回来，$displayName',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  
                  // 下方按钮区域
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60), // 底部间距
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QuickButton(
                          icon: Icons.confirmation_number,
                          label: '票据管理',
                          onPressed: () => onNavigate(1),
                        ),
                        const SizedBox(height: 20),
                        _QuickButton(
                          icon: Icons.sports,
                          label: '装备管理',
                          onPressed: () => onNavigate(2),
                        ),
                        const SizedBox(height: 20), 
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
      height: 64,
      child: FilledButton(
        style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}

