import 'package:flutter/material.dart';
import '../../models/gear.dart';
import '../../models/gear_statistics.dart';
import '../../widgets/section_card.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/gear_api.dart';
import 'add_gear_page.dart';
import 'select_gear_page.dart';
import '../login_page.dart';

class GearPage extends StatefulWidget {
  const GearPage({super.key});

  @override
  State<GearPage> createState() => _GearPageState();
}

class _GearPageState extends State<GearPage> {
  @override
  Widget build(BuildContext context) {
    final Future<Map<String, dynamic>?> adminFuture = StorageService()
        .getCachedAdminUser();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3F2FD), Color(0xFFF8F9FA)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.hiking, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '徒步装备',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  FutureBuilder<Map<String, dynamic>?>(
                    future: adminFuture,
                    builder: (context, snapshot) {
                      final name =
                          snapshot.data?['name'] ?? snapshot.data?['username'];
                      if (name == null) return const SizedBox.shrink();
                      return Text(
                        '管理员: $name',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey.shade600,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                final changed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EquipmentSelectionPage(),
                  ),
                );
                if (changed == true && mounted) {
                  setState(() {});
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEquipmentPage(),
                  ),
                );
                if (added == true && mounted) {
                  setState(() {});
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) async {
                if (value == 'logout') {
                  await AuthService().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('退出登录'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            GearApi().getMyGear(),
            GearApi().getCategoryDict(),
            GearApi().getBrands(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('加载装备失败: ${snapshot.error}'));
            }
            final results = snapshot.data ?? [];
            final rawList = results.isNotEmpty ? (results[0] as List) : <dynamic>[];
            final Map<String, String> categoryDict = (results.length > 1 && results[1] is Map)
                ? (results[1] as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
                : <String, String>{};
            // 品牌字典：name -> displayName
            final List<dynamic> rawBrands = results.length > 2 && results[2] is List
                ? (results[2] as List)
                : <dynamic>[];
            final Map<String, String> brandDict = {};
            for (final e in rawBrands) {
              if (e is Map) {
                final code = e['name']?.toString();
                final display = e['displayName']?.toString();
                if (code != null && display != null) {
                  brandDict[code] = display;
                }
              }
            }
            final List<Gear> gearList = rawList.map((m) {
              final name = m['name']?.toString() ?? '';
              final category = m['category']?.toString() ?? '';
              final weight = (m['weight'] as num?)?.toDouble() ?? 0;
              final price = (m['price'] as num?)?.toDouble() ?? 0;
              final quantity = (m['quantity'] as num?)?.toInt() ?? 1;
              final dateStr = m['purchaseDate']?.toString() ?? '';
              final dt = _parsePurchaseDate(dateStr);
              final brand = m['brand']?.toString() ?? 'Other';
              return Gear(
                id: m['id']?.toString() ?? '$name-$dateStr-$category',
                name: name,
                category: category,
                brand: brand,
                weight: weight,
                weightUnit: 'g',
                price: price,
                quantity: quantity,
                purchaseDate: dt,
              );
            }).toList();

            final stats = GearStatistics.fromGearList(gearList);

            final Map<String, List<Gear>> grouped = {};
            for (final gear in gearList) {
              (grouped[gear.category] ??= []).add(gear);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryCard(stats),
                  const SizedBox(height: 16),
                  ...grouped.entries.expand(
                    (entry) => [
                      _buildGearTableCard(
                        categoryDict[entry.key] ?? entry.key,
                        entry.value,
                        brandDict,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 合并所有类别（包括当前没有装备的类别）用于完整统计展示
                  _buildValueStatsCard(
                    stats,
                    categoryDict,
                    _buildCompleteCategoryValues(stats.categoryValues, categoryDict),
                  ),
                  const SizedBox(height: 16),
                  _buildBrandValueCard(stats),
                  const SizedBox(height: 16),
                  _buildBrandQuantityCard(stats),
                  
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(GearStatistics stats) {
    return SectionCard(
      title: '',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('${stats.totalValue.toInt()}', '装备总价值'),
            _buildStatItem('${stats.totalCount}件', '装备总数目'),
            _buildStatItem(
              '${stats.totalWeight.toStringAsFixed(2)}kg',
              '装备总重量',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildValueStatsCard(
    GearStatistics stats,
    Map<String, String> categoryDict,
    Map<String, double> categoryValues,
  ) {
    final totalValue = stats.totalValue;
    // 过滤掉价值为 0 的类别
    final entries = categoryValues.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SectionCard(
      title: '装备价值统计',
      children: [
        ...entries.expand((entry) => [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(categoryDict[entry.key] ?? entry.key),
              Text(
                '${entry.value.toInt()}',
                style: TextStyle(color: Colors.blue.shade700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: totalValue > 0 ? entry.value / totalValue : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
          ),
          const SizedBox(height: 16),
        ]),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${totalValue.toInt()}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // 构建完整类别价值映射：包含所有类别代码，缺失的填0
  Map<String, double> _buildCompleteCategoryValues(
    Map<String, double> statsValues,
    Map<String, String> categoryDict,
  ) {
    final Map<String, double> complete = {};
    // 先把所有类别填0
    for (final code in categoryDict.keys) {
      complete[code] = 0;
    }
    // 叠加已有统计值（可能包含字典中不存在的类别代码）
    statsValues.forEach((code, value) {
      complete[code] = (complete[code] ?? 0) + value;
    });
    return complete;
  }

  Widget _buildBrandValueCard(GearStatistics stats) {
    final brandValues = stats.brandValues;
    // 过滤掉价值为 0 的品牌
    final nonZeroEntries = brandValues.entries.where((e) => e.value > 0).toList();
    final filteredValues = nonZeroEntries.map((e) => e.value).toList();
    final maxValue = filteredValues.isNotEmpty
        ? filteredValues.reduce((a, b) => a > b ? a : b)
        : 1.0;
    // 统计已拥有的品牌总价值
    final totalBrandValue = brandValues.values.fold<double>(0, (sum, v) => sum + v);

    return SectionCard(
      title: '品牌价值统计（总价值：${totalBrandValue.toInt()}）',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: nonZeroEntries.map((entry) {
            final height = maxValue > 0 ? entry.value / maxValue : 0.0;
            final color = entry.key == '神秘农场' ? Colors.blue : Colors.green;
            return _buildBrandBar(
              entry.key,
              entry.value.toInt(),
              color,
              height,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 品牌统计栏
  Widget _buildBrandBar(String brand, int value, Color color, double height) {
    return Column(
      children: [
        Text(
          '$value¥',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: height * 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(brand, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  /// 品牌数量统计
  Widget _buildBrandQuantityCard(GearStatistics stats) {
    final brandCounts = stats.brandCounts;
    // 统计已拥有的品牌总数量
    final totalBrandCount = brandCounts.values.fold<int>(0, (sum, v) => sum + v);

    return SectionCard(
      title: '品牌数量统计（总数量：$totalBrandCount件）',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: brandCounts.entries.map((entry) {
            final color = entry.key == '神秘农场' ? Colors.blue : Colors.green;
            return _buildQuantityBar(entry.key, entry.value, color);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantityBar(String brand, int quantity, Color color) {
    return Column(
      children: [
        Text(
          '$quantity件',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(brand, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  /// 装备分类表，按装备类别进行分类并分别展示
  Widget _buildGearTableCard(String category, List<Gear> data, Map<String, String> brandDict) {
    return SectionCard(
      title: category,
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1.5),
          },
          children: [
            const TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '装备名字',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '数目',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '重量 (g)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '价格',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '购入时间',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...data.map(
              (item) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('${brandDict[item.brand] ?? item.brand} ${item.name}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(item.quantity.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(item.weight.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(item.price.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '${(item.purchaseDate.year % 100).toString().padLeft(2, '0')}-${item.purchaseDate.month.toString().padLeft(2, '0')}',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  DateTime _parsePurchaseDate(String s) {
    final parts = s.split('-');
    if (parts.length == 2) {
      final yy = int.tryParse(parts[0]) ?? 0;
      final mm = int.tryParse(parts[1]) ?? 1;
      return DateTime(2000 + yy, mm, 1);
    }
    // 尝试标准日期解析
    try {
      return DateTime.parse(s);
    } catch (_) {
      return DateTime.now();
    }
  }
}
