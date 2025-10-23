import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/storage_service.dart';
import '../../services/user_api.dart';
import '../../services/activity_api.dart';
import '../../widgets/section_card.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _displayName = '加载中...';
  String _signature = '加载中...';
  String? _avatarUrl;

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
              final avatar = userProfile['avatarUrl'] ?? userProfile['avatar'];
              _avatarUrl = avatar == null ? null : avatar.toString();
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
     // 初始化照片墙示例图片，可后续替换为真实用户照片
     _photoUrls = List.generate(12, (i) => 'https://picsum.photos/seed/seek_photo_$i/300/200');
     _scrollController.addListener(_onScroll);
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

  void _generateDataForScope(String scope) {
    _buildStatsForScope(scope);
  }

  void _recomputeTotals() {
    _totalDistance = _statsData.fold(0.0, (p, e) => p + e.distance);
    _totalAscent = _statsData.fold(0.0, (p, e) => p + e.ascent);
    _totalDescent = _statsData.fold(0.0, (p, e) => p + e.descent);
  }

  void _initSessionRecords() {
    // 已改为从后端加载活动，不再使用本地模拟数据
    _sessions = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人主页'),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: _showFeatureHint),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像/昵称/签名
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                        ? Icon(Icons.person, size: 28, color: Colors.blue.shade700)
                        : null,
                  ),
                  const SizedBox(width: 26),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(_signature, style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _PhotoWall(photos: _photoUrls),
            const SizedBox(height: 10),
            const Divider(height: 1),

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
    );
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
    const _OverviewCard({super.key, required this.totalDistanceKm, required this.totalAscentM, required this.totalDescentM});
  
    @override
    Widget build(BuildContext context) {
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
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
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      );
    }
  }

  class _DistanceChartCard extends StatelessWidget {
    final String scope;
    final ValueChanged<String> onScopeChange;
    final List<_DataPoint> data;
    const _DistanceChartCard({super.key, required this.scope, required this.onScopeChange, required this.data});
  
    @override
    Widget build(BuildContext context) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('徒步距离（km）', style: Theme.of(context).textTheme.titleMedium),
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
            const SizedBox(height: 10),
            SizedBox(
              height: 130,
              width: double.infinity,
              child: CustomPaint(
                painter: _ChartPainter(data: data),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                _LegendDot(color: Colors.blue, label: '距离'),
                SizedBox(width: 12),
                _LegendDot(color: Colors.green, label: '爬升'),
                SizedBox(width: 12),
                _LegendDot(color: Colors.orange, label: '下降'),
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
    const _LegendDot({super.key, required this.color, required this.label});
    @override
    Widget build(BuildContext context) {
      return Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label),
        ],
      );
    }
  }

  // 照片墙组件：横向滑动的图片缩略图列表
  class _PhotoWall extends StatelessWidget {
    final List<String> photos;
    const _PhotoWall({super.key, required this.photos});

    @override
    Widget build(BuildContext context) {
      if (photos.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: photos.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              photos[i],
              width: 140,
              height: 110,
              fit: BoxFit.cover,
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
      final double padding = 10;
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
          ..strokeWidth = 2.0
          ..isAntiAlias = true;
        canvas.drawPath(buildPath(values), paint);
      }
  
      drawSeries(data.map((e) => e.distance).toList(), Colors.blue);
      drawSeries(data.map((e) => e.ascent).toList(), Colors.green);
      drawSeries(data.map((e) => e.descent).toList(), Colors.orange);
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
    const _SessionListCard({super.key, required this.sessions, required this.onLoadMore, required this.loadingMore});
    
    @override
    Widget build(BuildContext context) {
      String fmtDuration(int minutes) {
        final h = minutes ~/ 60;
        final m = minutes % 60;
        return '${h}时${m}分';
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
                 padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                 child: SectionCard(
                   title: displayTitle,
                   children: [
                     Row(
                       children: [
                         const Icon(Icons.directions_walk, size: 18, color: Colors.blue),
                         const SizedBox(width: 6),
                         Expanded(child: Text('${s.distanceKm.toStringAsFixed(2)} km')),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         const Icon(Icons.access_time, size: 18, color: Colors.blue),
                         const SizedBox(width: 6),
                         Expanded(child: Text('$dateStr · 时长 ${fmtDuration(s.durationMin)}')),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         const Icon(Icons.stacked_line_chart, size: 18, color: Colors.blue),
                         const SizedBox(width: 6),
                         Expanded(child: Text('爬升 ${s.ascentM.toStringAsFixed(0)} m · 下降 ${s.descentM.toStringAsFixed(0)} m')),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         const Icon(Icons.local_fire_department, size: 18, color: Colors.blue),
                         const SizedBox(width: 6),
                         Expanded(child: Text('${s.calories} kcal')),
                       ],
                     ),
                   ],
                 ),
               );
            }),
          if (loadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
        ],
      );
    }
  }