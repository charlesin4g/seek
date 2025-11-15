import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/storage_service.dart';
import '../../services/user_api.dart';
import '../../services/activity_api.dart';
import '../../widgets/section_card.dart';
import '../../services/oss_service.dart';
import '../../services/photo_api.dart';
// 条件导入上传助手：Web 使用 dart:html 实现，其他平台为占位
import '../../utils/upload_helper_stub.dart'
    if (dart.library.html) '../../utils/upload_helper_web.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../services/offline_mode.dart';
import '../../services/network_probe_service.dart';
import '../../services/health_check_service.dart';
import '../../widgets/refresh_and_empty.dart';
import '../../config/app_colors.dart';
import '../../widgets/security_icons.dart';
import '../../utils/responsive.dart';


class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _displayName = '加载中...';
  String _signature = '加载中...';
  String? _avatarUrl;
  String? _backgroundUrl; // 个人主页背景图 URL（私有签名访问）
  // 刷新与页面状态
  bool _refreshing = false; // 是否处于刷新过程（用于避免重复触发与平滑过渡）
  bool _loadFailed = false; // 最近一次主动刷新是否失败（控制空态显示）

  Future<void> _loadUserInfo() async {
    try {
      final userData = await StorageService().getCachedAdminUser();
      if (userData != null && mounted) {
        final username = userData['username'];
        if (username != null) {
          // 从后端获取完整的用户信息，包括个人签名
          final userProfile = await UserApi().getUserByUsername(username);
          // 缓存完整用户信息到本地（包含displayName），用于后续快速读取
          await StorageService().cacheUser(userProfile);
          if (mounted) {
            setState(() {
              _displayName = userProfile['displayName'] ?? userProfile['username'] ?? '见山资深用户';
              _signature = userProfile['signature'] ?? '这个人很懒，什么都没有留下';
              // 使用 OssService 解析私有头像 URL（可生成临时签名访问）
              final avatar = userProfile['avatarUrl'] ?? userProfile['avatar'];
              _avatarUrl = OssService().resolvePrivateUrl(avatar?.toString());
              // 使用 OssService 解析私有背景图 URL（可生成临时签名访问）
              final bg = userProfile['backgroundUrl'] ?? userProfile['background'];
              _backgroundUrl = OssService().resolvePrivateUrl(bg?.toString());
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _displayName = '见山资深用户';
              _signature = '这个人很懒，什么都没有留下';
              _avatarUrl = null;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _displayName = '加载失败';
          _signature = '加载失败';
          _avatarUrl = null;
        });
      }
    }
  }

  void _showFeatureHint() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => const CupertinoAlertDialog(
        title: Text('温馨提示'),
        content: Text('此功能正在加紧开发中...'),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  // 统计相关状态
  String _chartScope = 'day'; // day, week, month, year
  List<_DataPoint> _statsData = [];
  double _totalDistance = 0;
  double _totalAscent = 0;
  double _totalDescent = 0;
  List<_SessionRecord> _sessions = [];
  List<_SessionRecord> _allSessions = [];
  bool _loadingMore = false;
  // 照片墙
  List<String> _photoUrls = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadActivities();
    // 加载用户照片墙数据（后端接口），失败时可回退为占位图
    _loadPhotos();
    _scrollController.addListener(_onScroll);
    // 启动网络探测服务：离线时自动探测并在恢复后触发同步
  NetworkProbeService.instance.start();
  }

   @override
   void dispose() {
     _scrollController.removeListener(_onScroll);
     _scrollController.dispose();
     super.dispose();
   }

  void _onScroll() {
    if (_loadingMore) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      if (_sessions.length < _allSessions.length) {
        _loadMoreSessions();
      }
    }
  }

  Future<bool> _verifyPhotosReachable(List<String> urls, {int sample = 3}) async {
    final client = http.Client();
    try {
      final candidates = urls.take(sample).toList();
      for (final u in candidates) {
        final resolved = OssService().resolvePrivateUrl(u);
        if (resolved == null || resolved.isEmpty) continue;
        try {
          final res = await client.head(Uri.parse(resolved)).timeout(const Duration(seconds: 3));
          if (res.statusCode >= 200 && res.statusCode < 400) {
            return true;
          }
        } catch (e) {
          if (!kReleaseMode) debugPrint('Photo HEAD failed: $e');
        }
      }
      return false;
    } finally {
      client.close();
    }
  }

  void _generateDataForScope(String scope) {
    _buildStatsForScope(scope);
  }

  Future<bool> _canLoadImageUrl(String? url, {Duration timeout = const Duration(seconds: 3)}) async {
    if (url == null || url.isEmpty) return false;
    try {
      final client = http.Client();
      try {
        final res = await client.head(Uri.parse(url)).timeout(timeout);
        return res.statusCode >= 200 && res.statusCode < 400;
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Image load failed: $e');
      return false;
    }
  }

  void _recomputeTotals() {
    _totalDistance = _statsData.fold(0.0, (p, e) => p + e.distance);
    _totalAscent = _statsData.fold(0.0, (p, e) => p + e.ascent);
    _totalDescent = _statsData.fold(0.0, (p, e) => p + e.descent);
  }

  Future<void> _loadMoreSessions() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(milliseconds: 200));
    final start = _sessions.length;
    final more = _allSessions.skip(start).take(10).toList();
    setState(() {
      _sessions.addAll(more);
      _loadingMore = false;
    });
  }

  /// 主动刷新处理：触发完整数据请求流程（带重试），失败时清空并显示空态
  Future<void> _refreshAll() async {
    if (_refreshing) return;
    setState(() {
      _refreshing = true;
      _loadFailed = false;
    });
    bool ok = true;
    Future<void> safeCall(Future<void> Function() fn) async {
      try {
        await _runWithRetry(fn, maxAttempts: 2);
      } catch (_) {
        ok = false;
      }
    }
    await safeCall(_loadUserInfo);
    await safeCall(_loadActivities);
    await safeCall(_loadPhotos);
    if (!mounted) return;
    if (!ok) {
      // 清空当前页面数据并显示空态
      setState(() {
        _displayName = '暂无数据';
        _signature = '暂无数据';
        _avatarUrl = null;
        _backgroundUrl = null;
        _sessions = [];
        _allSessions = [];
        _photoUrls = [];
        _statsData = [];
        _totalDistance = 0;
        _totalAscent = 0;
        _totalDescent = 0;
        _loadFailed = true;
        _refreshing = false;
      });
    } else {
      setState(() {
        _refreshing = false;
      });
    }
  }

  /// 带重试的包装（用于刷新流程）
  Future<void> _runWithRetry(Future<void> Function() fn, {int maxAttempts = 2}) async {
    int attempt = 0;
    while (true) {
      try {
        attempt += 1;
        await fn();
        return;
      } catch (e) {
        if (attempt >= maxAttempts) rethrow;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人主页'),
        backgroundColor: AppColors.primaryLightBlue, // 浅蓝色背景
        foregroundColor: AppColors.textPrimary, // 文字颜色
        elevation: 0, // 移除阴影
        centerTitle: true, // 居中标题
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppFontSizes.title, // 20px
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline), 
            onPressed: _showFeatureHint,
            color: AppColors.textPrimary,
          ),
          // 主动刷新：触发完整数据请求流程（失败显示空态）
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
            tooltip: '刷新',
            color: AppColors.textPrimary,
          ),
          // 前端上传入口（Web 平台）
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: _uploadPhoto,
            tooltip: '上传照片',
            color: AppColors.textPrimary,
          ),
          // 安全提示图标
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: SecurityIcon(
              icon: Icons.security,
              tooltip: '个人信息安全保护',
              color: AppColors.primaryDarkBlue,
            ),
          ),
          // 在线/离线状态指示器（AppBar 右上角）
          ValueListenableBuilder<bool>(
            valueListenable: OfflineModeManager.instance.isOffline,
            builder: (context, offline, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: offline ? '当前：离线模式' : '当前：在线模式',
                  child: Icon(
                    offline ? Icons.cloud_off : Icons.cloud_queue,
                    color: offline ? AppColors.textSecondary : AppColors.primaryDarkBlue,
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
          RefreshAndEmpty(
          isEmpty: _loadFailed,
          onRefresh: () async {
            try {
              await _refreshAll();
              return true;
            } catch (_) {
              return false;
            }
          },
          emptyIcon: Icons.person,
          emptyTitle: '暂无数据',
          emptySubtitle: '下拉刷新重试加载个人信息与动态',
          emptyActionText: null,
          onEmptyAction: null,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: Responsive.responsivePadding(context), // 使用响应式间距
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // 顶部离线提示条：明确区分本地缓存与在线模式显示
            ValueListenableBuilder<bool>(
              valueListenable: OfflineModeManager.instance.isOffline,
              builder: (context, offline, _) {
                if (!offline) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  padding: Responsive.responsivePadding(context), // 使用响应式间距
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1), // 使用统一的警告色
                    borderRadius: AppBorderRadius.large, // 使用统一圆角
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    boxShadow: [AppShadows.light], // 添加柔和阴影
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '离线模式：后端不可用或未连接，所有操作仅缓存在本地',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                            fontSize: Responsive.value(context,
                              small: AppFontSizes.body - 1, // 小屏手机使用13px
                              medium: AppFontSizes.body, // 标准手机使用14px
                              large: AppFontSizes.bodyLarge, // 大屏手机使用16px
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: Responsive.value(context,
              small: 12, // 小屏手机使用12px间距
              medium: 16, // 标准手机使用16px间距
              large: 20, // 大屏手机使用20px间距
            )),
            // 头像/昵称/签名
            Padding(
              padding: AppSpacing.horizontal, // 使用统一的水平间距
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 56,
                    width: 56,
                    child: ClipOval(
                      child: FutureBuilder<bool>(
                        future: _canLoadImageUrl(_avatarUrl),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState != ConnectionState.done) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient, // 使用渐变背景
                                borderRadius: BorderRadius.circular(28), // 圆形
                              ),
                              child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textWhite))),
                            );
                          }
                          final useNetwork = snapshot.data == true;
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: useNetwork
                                ? Image.network(_avatarUrl!, fit: BoxFit.cover, key: const ValueKey('av_net'))
                                : Image.asset('lib/assests/avatar.png', fit: BoxFit.cover, key: const ValueKey('av_asset')),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 24), // 调整间距
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_displayName, style: TextStyle(
                          fontSize: AppFontSizes.titleLarge, // 24px
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        )),
                        const SizedBox(height: 8), // 调整间距
                        Text(_signature, style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppFontSizes.body,
                        )),
                        const SizedBox(height: 16), // 统一间距 // 调整间距
                        // 状态指示器 Chip：显示当前在线/离线
                        ValueListenableBuilder<bool>(
                          valueListenable: OfflineModeManager.instance.isOffline,
                          builder: (context, offline, _) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Chip(
                                avatar: Icon(
                                  offline ? Icons.cloud_off : Icons.cloud_queue,
                                  color: AppColors.textWhite,
                                  size: 18,
                                ),
                                label: Text(offline ? '离线模式' : '在线模式'),
                                backgroundColor: offline ? AppColors.warning : AppColors.success,
                                labelStyle: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: AppFontSizes.body,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppBorderRadius.medium,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // 统一间距
            
            if (_photoUrls.isNotEmpty) _PhotoWall(photos: _photoUrls),
            if (_photoUrls.isNotEmpty) const SizedBox(height: 16), // 统一间距
            if (_photoUrls.isNotEmpty) const Divider(height: 1),

            // 统计卡片
            _OverviewCard(
              totalDistanceKm: _totalDistance,
              totalAscentM: _totalAscent,
              totalDescentM: _totalDescent,
            ),
            _DistanceChartCard(
              scope: _chartScope,
              onScopeChange: (s) => _generateDataForScope(s),
              data: _statsData,
            ),
            _SessionListCard(
              sessions: _sessions,
              onLoadMore: _loadMoreSessions,
              loadingMore: _loadingMore,
            ),
            ],
          ),
        ),
        ),
        ],
      ),
    );
  }

  /// 选择图片并上传到 OSS（Web 平台直传）
  ///
  /// 流程：
  /// 1) 选择图片文件并读取字节；
  /// 2) 拼接对象 key（含前缀，可包含用户ID与时间戳）；
  /// 3) 请求后端生成 PUT 临时签名 URL；
  /// 4) 直接对该 URL 执行 HTTP PUT 上传；
  /// 5) 上传成功后，调用 /api/photo/add 写入记录并刷新照片墙。
  Future<void> _uploadPhoto() async {
    if (!kIsWeb) {
      _showFeatureHint();
      return;
    }

    try {
      // 1) 选择图片并读取字节
      final helper = UploadHelper();
      final Uint8List? bytes = await helper.pickImageBytes();
      if (bytes == null || bytes.isEmpty) return;

      // 2) 计算对象 key：photos/{owner}/{timestamp}.jpg
      final cached = await StorageService().getCachedAdminUser();
      final owner = cached?['userId']?.toString() ?? '1';
      final ts = DateTime.now().millisecondsSinceEpoch;
      final objectKey = 'photos/$owner/$ts.jpg';

      // 3) 获取 PUT 签名 URL
      final signedUrl = await PhotoApi().signPutUrl(objectKey);
      if (signedUrl == null || signedUrl.isEmpty) {
        throw Exception('获取上传签名失败');
      }

      // 4) 上传图片（设置通用 content-type）
      final putRes = await http.put(
        Uri.parse(signedUrl),
        headers: {
          'Content-Type': 'image/jpeg',
        },
        body: bytes,
      );
      if (putRes.statusCode < 200 || putRes.statusCode >= 300) {
        throw Exception('上传失败，状态码 ${putRes.statusCode}');
      }

      // 5) 记录入库并刷新照片墙
      await PhotoApi().addPhotoRecord(owner: owner, objectKey: objectKey);
      await _loadPhotos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('上传成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('上传失败: $e')),
        );
      }
    }
  }

  // 从后端加载活动并构建初始统计与列表
  Future<void> _loadActivities() async {
    try {
      final raw = await ActivityApi().getMyActivities();
      final sessions = raw.map((m) {
        DateTime date;
        final ts = m['activityTime']?.toString();
        try {
          date = ts == null ? DateTime.now() : DateTime.parse(ts);
        } catch (_) {
          date = DateTime.now();
        }
        double parseDouble(dynamic v) => v == null
            ? 0.0
            : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
        final distanceKm = parseDouble(m['distance']) / 1000.0;
        final ascentM = parseDouble(m['elevationGain']);
        final descentM = parseDouble(m['elevationLoss']);
        final durationSec = int.tryParse(m['totalDurationSec']?.toString() ?? '0') ?? 0;
        final calories = int.tryParse(m['calories']?.toString() ?? '0') ?? 0;
        String? title;
        for (final key in ['name','title','activityName','activityTitle']) {
          final v = m[key];
          if (v != null) {
            final t = v.toString().trim();
            if (t.isNotEmpty) { title = t; break; }
          }
        }
        return _SessionRecord(
          title: title,
           date: date,
           distanceKm: distanceKm,
           ascentM: ascentM,
           descentM: descentM,
           durationMin: durationSec ~/ 60,
           calories: calories,
         );
      }).toList();
      sessions.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _allSessions = sessions;
        _sessions = _allSessions.take(20).toList();
      });
      _buildStatsForScope(_chartScope);
    } catch (e) {
      // 忽略错误以避免页面崩溃，可按需提示
    }
  }

  // 从后端加载用户照片墙数据
  Future<void> _loadPhotos() async {
    try {
      final healthy = await HealthCheckService.instance.checkAvailable(timeout: const Duration(seconds: 3));
      if (!healthy) {
        if (mounted) setState(() => _photoUrls = []);
        return;
      }
      final urls = await PhotoApi().getMyPhotos();
      final ok = urls.isNotEmpty && await _verifyPhotosReachable(urls);
      if (mounted) setState(() => _photoUrls = ok ? urls : []);
    } catch (e) {
      if (!kReleaseMode) debugPrint('Load photos error: $e');
      if (mounted) setState(() => _photoUrls = []);
    }
  }

  void _buildStatsForScope(String scope) {
    _chartScope = scope;
    final now = DateTime.now();
    List<_DataPoint> points = [];

    List<double> sumInRange(DateTime start, DateTime end) {
      double distance = 0.0, ascent = 0.0, descent = 0.0;
      for (final s in _allSessions) {
        if (!s.date.isBefore(start) && s.date.isBefore(end)) {
          distance += s.distanceKm;
          ascent += s.ascentM;
          descent += s.descentM;
        }
      }
      return [distance, ascent, descent];
    }

    DateTime startOfWeek(DateTime dt) {
      final d0 = DateTime(dt.year, dt.month, dt.day);
      return d0.subtract(Duration(days: dt.weekday - 1)); // 周一为一周起始
    }

    if (scope == 'day') {
      final today = DateTime(now.year, now.month, now.day);
      points = List.generate(30, (i) {
        final start = today.subtract(Duration(days: 29 - i));
        final end = start.add(const Duration(days: 1));
        final agg = sumInRange(start, end);
        return _DataPoint(date: start, distance: agg[0], ascent: agg[1], descent: agg[2]);
      });
    } else if (scope == 'week') {
      final sow = startOfWeek(now);
      points = List.generate(10, (i) {
        final start = sow.subtract(Duration(days: (9 - i) * 7));
        final end = start.add(const Duration(days: 7));
        final agg = sumInRange(start, end);
        return _DataPoint(date: start, distance: agg[0], ascent: agg[1], descent: agg[2]);
      });
    } else if (scope == 'month') {
      points = List.generate(12, (i) {
        final start = DateTime(now.year, now.month - (11 - i), 1);
        final end = DateTime(start.year, start.month + 1, 1);
        final agg = sumInRange(start, end);
        return _DataPoint(date: start, distance: agg[0], ascent: agg[1], descent: agg[2]);
      });
    } else {
      points = List.generate(5, (i) {
        final start = DateTime(now.year - (4 - i), 1, 1);
        final end = DateTime(start.year + 1, 1, 1);
        final agg = sumInRange(start, end);
        return _DataPoint(date: start, distance: agg[0], ascent: agg[1], descent: agg[2]);
      });
    }

    setState(() {
      _statsData = points;
      _recomputeTotals();
    });
  }
}

class _DataPoint {
    final DateTime date;
    final double distance;
    final double ascent;
    final double descent;
    _DataPoint({required this.date, required this.distance, required this.ascent, required this.descent});
  }

  class _OverviewCard extends StatelessWidget {
    final double totalDistanceKm;
    final double totalAscentM;
    final double totalDescentM;
    const _OverviewCard({required this.totalDistanceKm, required this.totalAscentM, required this.totalDescentM});
  
    @override
    Widget build(BuildContext context) {
      return Container(
        margin: AppSpacing.medium, // 使用统一的间距配置
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // 调整内边距
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite.withOpacity(0.9),
          borderRadius: AppBorderRadius.extraLarge, // 使用统一圆角
          boxShadow: [AppShadows.light], // 使用统一阴影
          border: Border.all(color: AppColors.borderLight, width: 1), // 添加边框
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatItem(title: '总距离', value: '${totalDistanceKm.toStringAsFixed(1)} km'),
            _StatItem(title: '总爬升', value: '${totalAscentM.toStringAsFixed(0)} m'),
            _StatItem(title: '总下降', value: '${totalDescentM.toStringAsFixed(0)} m'),
          ],
        ),
      );
    }
  }

  class _StatItem extends StatelessWidget {
    final String title;
    final String value;
    const _StatItem({required this.title, required this.value});
    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppFontSizes.body,
          )),
          const SizedBox(height: 8), // 调整间距
          Text(value, style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppFontSizes.title, // 20px
            fontWeight: FontWeight.bold,
          )),
        ],
      );
    }
  }

  class _DistanceChartCard extends StatelessWidget {
    final String scope;
    final ValueChanged<String> onScopeChange;
    final List<_DataPoint> data;
    const _DistanceChartCard({required this.scope, required this.onScopeChange, required this.data});
  
    @override
    Widget build(BuildContext context) {
      return Container(
        margin: AppSpacing.medium, // 使用统一的间距配置
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), // 调整内边距
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite.withOpacity(0.9),
          borderRadius: AppBorderRadius.extraLarge, // 使用统一圆角
          boxShadow: [AppShadows.light], // 使用统一阴影
          border: Border.all(color: AppColors.borderLight, width: 1), // 添加边框
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('徒步距离(km)', style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppFontSizes.title, // 20px
                  fontWeight: FontWeight.w600,
                )),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: CupertinoSegmentedControl<String>(
                    groupValue: scope,
                    onValueChanged: onScopeChange,
                    children: const {
                      'day': Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('日')),
                      'week': Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('周')),
                      'month': Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('月')),
                      'year': Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('年')),
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 12), // 调整间距
            SizedBox(
              height: 130,
              width: double.infinity,
              child: CustomPaint(
                painter: _ChartPainter(data: data),
              ),
            ),
            const SizedBox(height: 12), // 调整间距
            Row(
              children: const [
                _LegendDot(color: AppColors.primaryBlue, label: '距离'),
                SizedBox(width: 16), // 调整间距
                _LegendDot(color: AppColors.secondaryGreen, label: '爬升'),
                SizedBox(width: 16), // 调整间距
                _LegendDot(color: AppColors.warning, label: '下降'),
              ],
            )
          ],
        ),
      );
    }
  }

  class _LegendDot extends StatelessWidget {
    final Color color;
    final String label;
    const _LegendDot({required this.color, required this.label});
    @override
    Widget build(BuildContext context) {
      return Row(
        children: [
          Container(
            width: 10, 
            height: 10, 
            decoration: BoxDecoration(
              color: color, 
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8), // 调整间距
          Text(label, style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppFontSizes.body,
          )),
        ],
      );
    }
  }

  // 照片墙组件：横向滑动的图片缩略图列表
  class _PhotoWall extends StatelessWidget {
    final List<String> photos;
    const _PhotoWall({required this.photos});

    @override
    Widget build(BuildContext context) {
      if (photos.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 120, // 调整高度
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.horizontal, // 使用统一的水平间距
          itemCount: photos.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12), // 调整间距
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
              borderRadius: AppBorderRadius.large, // 使用统一圆角
              boxShadow: [AppShadows.light], // 添加柔和阴影
              border: Border.all(color: AppColors.borderLight, width: 1), // 添加边框
            ),
            child: ClipRRect(
              borderRadius: AppBorderRadius.large, // 使用统一圆角
              child: (() {
                // 统一使用私有签名 URL 解析，兼容完整 URL 与资源 key
                final resolved = OssService().resolvePrivateUrl(photos[i]);
                if (resolved == null || resolved.isEmpty) {
                  return Container(
                    width: 140,
                    height: 120,
                    color: AppColors.backgroundGrey,
                    child: Icon(Icons.image_not_supported, color: AppColors.textTertiary, size: 32),
                  );
                }
                return Image.network(
                  resolved,
                  width: 140,
                  height: 120,
                  fit: BoxFit.cover,
                );
              })(),
            ),
          ),
        ),
      );
    }
  }

  class _ChartPainter extends CustomPainter {
    final List<_DataPoint> data;
    _ChartPainter({required this.data});
  
    @override
    void paint(Canvas canvas, Size size) {
      final double padding = 12; // 调整内边距
      final Rect plot = Rect.fromLTWH(padding, padding, size.width - padding * 2, size.height - padding * 2);
      final maxY = [
        ...data.map((e) => e.distance),
        ...data.map((e) => e.ascent),
        ...data.map((e) => e.descent),
      ].fold<double>(0, (p, e) => e > p ? e : p);
      final maxValue = maxY == 0 ? 1 : maxY;
      final dx = plot.width / (data.length - 1).clamp(1, 1000);
  
      Path buildPath(List<double> values) {
        final path = Path();
        for (int i = 0; i < data.length; i++) {
          final x = plot.left + dx * i;
          final y = plot.bottom - (values[i] / maxValue) * plot.height;
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        return path;
      }
  
      void drawSeries(List<double> values, Color color) {
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 // 调整线条宽度
          ..isAntiAlias = true
          ..strokeCap = StrokeCap.round; // 添加圆角
        canvas.drawPath(buildPath(values), paint);
      }
  
      drawSeries(data.map((e) => e.distance).toList(), AppColors.primaryBlue);
      drawSeries(data.map((e) => e.ascent).toList(), AppColors.secondaryGreen);
      drawSeries(data.map((e) => e.descent).toList(), AppColors.warning);
    }
  
    @override
    bool shouldRepaint(covariant _ChartPainter oldDelegate) => oldDelegate.data != data;
  }

  class _SessionRecord {
    final String? title;
    final DateTime date;
    final double distanceKm;
    final double ascentM;
    final double descentM;
    final int durationMin;
    final int calories;
    _SessionRecord({required this.title, required this.date, required this.distanceKm, required this.ascentM, required this.descentM, required this.durationMin, required this.calories});
  }

  class _SessionListCard extends StatelessWidget {
    final List<_SessionRecord> sessions;
    final Future<void> Function() onLoadMore;
    final bool loadingMore;
    const _SessionListCard({required this.sessions, required this.onLoadMore, required this.loadingMore});
    
    @override
    Widget build(BuildContext context) {
      String fmtDuration(int minutes) {
        final h = minutes ~/ 60;
        final m = minutes % 60;
        return '$h时$m分';
      }
      return Column(
        children: [
          for (final s in sessions)
            Builder(builder: (context) {
              final dateStr = '${s.date.year}-${s.date.month.toString().padLeft(2, '0')}-${s.date.day.toString().padLeft(2, '0')} ${s.date.hour.toString().padLeft(2, '0')}:${s.date.minute.toString().padLeft(2, '0')}';
              final displayTitle = (s.title != null && s.title!.trim().isNotEmpty)
                  ? s.title!
                  : '$dateStr · ${s.distanceKm.toStringAsFixed(2)} km';
               return Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 调整水平间距
                 child: SectionCard(
                   title: displayTitle,
                   children: [
                     Row(
                       children: [
                         Icon(Icons.directions_walk, size: 18, color: AppColors.primaryDarkBlue),
                         const SizedBox(width: 8),
                         Expanded(child: Text('${s.distanceKm.toStringAsFixed(2)} km', style: TextStyle(color: AppColors.textPrimary, fontSize: AppFontSizes.body))),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         Icon(Icons.access_time, size: 18, color: AppColors.primaryDarkBlue),
                         const SizedBox(width: 8),
                         Expanded(child: Text('$dateStr · 时长 ${fmtDuration(s.durationMin)}', style: TextStyle(color: AppColors.textPrimary, fontSize: AppFontSizes.body))),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         Icon(Icons.stacked_line_chart, size: 18, color: AppColors.primaryDarkBlue),
                         const SizedBox(width: 8),
                         Expanded(child: Text('爬升 ${s.ascentM.toStringAsFixed(0)} m · 下降 ${s.descentM.toStringAsFixed(0)} m', style: TextStyle(color: AppColors.textPrimary, fontSize: AppFontSizes.body))),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         Icon(Icons.local_fire_department, size: 18, color: AppColors.primaryDarkBlue),
                         const SizedBox(width: 8),
                         Expanded(child: Text('${s.calories} kcal', style: TextStyle(color: AppColors.textPrimary, fontSize: AppFontSizes.body))),
                       ],
                     ),
                   ],
                 ),
               );
            }),
          if (loadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16), // 调整间距
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))),
            ),
        ],
      );
    }
  }
