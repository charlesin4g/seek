import 'package:flutter/material.dart';
import '../../models/gear.dart';
import '../../models/gear_statistics.dart';
import '../../widgets/section_card.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/repository/gear_assets_repository.dart';
import 'add_gear_page.dart';
import 'select_gear_page.dart';
import '../login_page.dart';
import '../../widgets/refresh_and_empty.dart';
import '../../widgets/gear/improved_gear_table.dart';
import '../../config/app_colors.dart';
import '../../utils/responsive.dart';

class GearPage extends StatefulWidget {
  const GearPage({super.key});

  @override
  State<GearPage> createState() => _GearPageState();
}

class _GearPageData {
  const _GearPageData({
    required this.gearList,
    required this.categoryDict,
    required this.brandDict,
  });

  final List<Gear> gearList;
  final Map<String, String> categoryDict;
  final Map<String, String> brandDict;
}

class _GearPageState extends State<GearPage> {
  Future<_GearPageData> _loadGearPageData() async {
    final List<GearAssetRecord> assets =
        await GearAssetsRepository.instance.getAllAssets();

    final List<Gear> gearList = <Gear>[];
    final Map<String, String> brandDict = <String, String>{};

    for (final GearAssetRecord asset in assets) {
      final DateTime date = _parsePurchaseDate(asset.purchaseDateLabel);
      final String brand = asset.brand;
      if (brand.isNotEmpty) {
        brandDict[brand] = brand;
      }
      final String category = asset.category.isEmpty ? '全部装备' : asset.category;
      gearList.add(
        Gear(
          id: asset.id.toString(),
          name: asset.name,
          category: category,
          brand: brand,
          weight: 0,
          weightUnit: 'g',
          price: asset.price,
          quantity: 1,
          purchaseDate: date,
        ),
      );
    }

    final Map<String, String> categoryDict = <String, String>{};
    for (final Gear gear in gearList) {
      categoryDict[gear.category] = gear.category;
    }

    return _GearPageData(
      gearList: gearList,
      categoryDict: categoryDict,
      brandDict: brandDict,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Future<Map<String, dynamic>?> adminFuture = StorageService()
        .getCachedAdminUser();

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient, // 使用新的渐变背景
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, // 透明背景
          foregroundColor: AppColors.textPrimary, // 文字颜色
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient, // 使用主色调渐变
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.hiking, color: Colors.black), // 黑色图标
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '徒步装备',
                    style: TextStyle(
                      fontSize: AppFontSizes.title, // 20px
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
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
                          fontSize: AppFontSizes.body - 2, // 12px
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
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
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        '退出登录',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppFontSizes.body,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: FutureBuilder<_GearPageData>(
          future: _loadGearPageData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('加载装备失败: ${snapshot.error}'));
            }
            final _GearPageData? data = snapshot.data;
            final List<Gear> gearList = data?.gearList ?? <Gear>[];
            final Map<String, String> categoryDict = data?.categoryDict ?? <String, String>{};
            final Map<String, String> brandDict = data?.brandDict ?? <String, String>{};

            final stats = GearStatistics.fromGearList(gearList);

            final Map<String, List<Gear>> grouped = <String, List<Gear>>{};
            for (final Gear gear in gearList) {
              (grouped[gear.category] ??= <Gear>[]).add(gear);
            }

            return RefreshAndEmpty(
              isEmpty: gearList.isEmpty,
              onRefresh: () async {
                // 统一刷新：重新执行加载逻辑并触发重建
                try {
                  if (mounted) setState(() {});
                  return true;
                } catch (_) {
                  return false;
                }
              },
              emptyIcon: Icons.hiking,
              emptyTitle: '暂无装备',
              emptySubtitle: '下拉刷新或点击右下角 + 添加装备',
              emptyActionText: null,
              onEmptyAction: null,
              child: SingleChildScrollView(
                padding: Responsive.responsivePadding(context).copyWith(bottom: 140),
                child: Column(
                  children: [
                    _buildSummaryCard(stats),
                    const SizedBox(height: 16),
                    ...grouped.entries.expand(
                      (entry) => [
                        ImprovedGearTable(
                          category: categoryDict[entry.key] ?? entry.key,
                          data: entry.value,
                          brandDict: brandDict,
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
              ),
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              backgroundColor: AppColors.primaryBlue,
              heroTag: 'fab-edit',
              child: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
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
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              backgroundColor: AppColors.secondaryGreen,
              heroTag: 'fab-add',
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
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
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  String _formatPrice2(double price) {
    final int cents = (price * 100).truncate();
    final int yuan = cents ~/ 100;
    final int remainder = cents % 100;
    final String centsStr = remainder.toString().padLeft(2, '0');
    return '$yuan.$centsStr';
  }

  Widget _buildSummaryCard(GearStatistics stats) {
    return SectionCard(
      title: '',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(_formatPrice2(stats.totalValue), '装备总价值'),
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label, 
          style: TextStyle(
            fontSize: 12, 
            color: AppColors.textSecondary,
          ),
        ),
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
                _formatPrice2(entry.value),
                style: const TextStyle(color: AppColors.secondaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: totalValue > 0 ? entry.value / totalValue : 0,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryLightBlue),
          ),
          const SizedBox(height: 16),
        ]),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _formatPrice2(totalValue),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryBlue,
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
      title: '品牌价值统计（总价值：${_formatPrice2(totalBrandValue)}）',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: nonZeroEntries.map((entry) {
            final height = maxValue > 0 ? entry.value / maxValue : 0.0;
            final color = entry.key == '神秘农场' ? AppColors.secondaryBlue : AppColors.primaryGreen;
            return _buildBrandBar(
              entry.key,
              entry.value,
              color,
              height,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 品牌统计栏
  Widget _buildBrandBar(String brand, double value, Color color, double height) {
    return Column(
      children: [
        Text(
          '${_formatPrice2(value)}¥',
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
            final color = entry.key == '神秘农场' ? AppColors.secondaryBlue : AppColors.primaryGreen;
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

  /// 装备分类表，按装备类别进行分类并分别展示 - 已废弃，使用ImprovedGearTable替代
  // Widget _buildGearTableCard(String category, List<Gear> data, Map<String, String> brandDict) {
  //   return SectionCard(
  //     title: category,
  //     children: [
  //       SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         child: Table(
  //           columnWidths: const {
  //             0: IntrinsicColumnWidth(),
  //             1: FixedColumnWidth(72),
  //             2: FixedColumnWidth(100),
  //             3: FixedColumnWidth(100),
  //             4: FixedColumnWidth(100),
  //           },
  //           children: [
  //             const TableRow(
  //               children: [
  //                 Padding(
  //                   padding: EdgeInsets.only(top: 8, bottom: 8, right: 12),
  //                   child: Text(
  //                     '装备名字',
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: EdgeInsets.symmetric(vertical: 8),
  //                   child: Text(
  //                     '数目',
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: EdgeInsets.symmetric(vertical: 8),
  //                   child: Text(
  //                     '重量 (g)',
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: EdgeInsets.symmetric(vertical: 8),
  //                   child: Text(
  //                     '价格',
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: EdgeInsets.symmetric(vertical: 8),
  //                   child: Text(
  //                     '购入时间',
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             ...data.map(
  //               (item) => TableRow(
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.only(top: 8, bottom: 8, right: 12),
  //                     child: Text(
  //                       '${brandDict[item.brand] ?? item.brand} ${item.name}',
  //                       maxLines: 1,
  //                       softWrap: false,
  //                       overflow: TextOverflow.visible,
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(vertical: 8),
  //                     child: Text(
  //                       item.quantity.toString(),
  //                       maxLines: 1,
  //                       softWrap: false,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(vertical: 8),
  //                     child: Text(
  //                       item.weight.toString(),
  //                       maxLines: 1,
  //                       softWrap: false,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(vertical: 8),
  //                     child: Text(
  //                       item.price.toString(),
  //                       maxLines: 1,
  //                       softWrap: false,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(vertical: 8),
  //                     child: Text(
  //                       '${(item.purchaseDate.year % 100).toString().padLeft(2, '0')}-${item.purchaseDate.month.toString().padLeft(2, '0')}',
  //                       maxLines: 1,
  //                       softWrap: false,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
