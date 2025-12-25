import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../utils/responsive.dart';
import '../../services/repository/gear_assets_repository.dart';
import 'add_gear_page.dart';

class GearAssetsPage extends StatefulWidget {
  const GearAssetsPage({super.key});

  @override
  State<GearAssetsPage> createState() => _GearAssetsPageState();
}

class _GearAssetsPageState extends State<GearAssetsPage> {
  void refreshAssets() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF041C3F),
            Color(0xFF063B73),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context, rootNavigator: true).maybePop();
              }
            },
          ),
          title: const Text(
            '我的装备',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: FutureBuilder<List<GearAssetRecord>>(
            future: GearAssetsRepository.instance.getAllAssets(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final List<GearAssetRecord> assets =
                  snapshot.data ?? const <GearAssetRecord>[];
              final int totalCount = assets.length;
              final double totalValue =
                  assets.fold(0, (num sum, GearAssetRecord e) => sum + e.price);
              final String totalValueLabel = '¥${_formatPrice2(totalValue)}';

              if (assets.isEmpty) {
                return Center(
                  child: Text(
                    '暂无装备，点击右下角 + 按钮添加一件吧',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: AppFontSizes.body,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding:
                    Responsive.responsivePadding(context).copyWith(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 总价值卡片
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF123A7A),
                        borderRadius: AppBorderRadius.extraLarge,
                        boxShadow: const [AppShadows.medium],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '总价值',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: AppFontSizes.body,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            totalValueLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '共 $totalCount 件装备',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: AppFontSizes.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 分类筛选条（静态 UI）
                    const _CategoryFilterBar(),
                    const SizedBox(height: 16),
                    // 装备网格
                    _GearGrid(assets: assets),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.secondaryGreen,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () async {
            final bool? added = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const AddEquipmentPage()),
            );
            if (added == true) {
              refreshAssets();
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _CategoryChip(label: '全部', icon: Icons.ac_unit, selected: true),
          SizedBox(width: 8),
          _CategoryChip(label: '背包', icon: Icons.backpack_outlined),
          SizedBox(width: 8),
          _CategoryChip(label: '帐篷', icon: Icons.terrain),
          SizedBox(width: 8),
          _CategoryChip(label: '服装', icon: Icons.checkroom_outlined),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected ? Colors.white : Colors.white.withValues(alpha: 0.4);
    final Color backgroundColor = selected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent;
    final Color textColor = Colors.white.withValues(alpha: selected ? 1.0 : 0.85);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppBorderRadius.large,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: AppFontSizes.body,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GearGrid extends StatelessWidget {
  const _GearGrid({required this.assets});

  final List<GearAssetRecord> assets;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.64,
      ),
      itemCount: assets.length + 1,
      itemBuilder: (context, index) {
        if (index == assets.length) {
          return const _AddGearCard();
        }
        final asset = assets[index];
        return _GearAssetCard(asset: asset);
      },
    );
  }
}

class _GearAssetCard extends StatelessWidget {
  const _GearAssetCard({required this.asset});

  final GearAssetRecord asset;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final TextEditingController nameController =
            TextEditingController(text: asset.name);
        final TextEditingController priceController =
            TextEditingController(text: _formatPrice2(asset.price));
        final TextEditingController usageCountController =
            TextEditingController(text: asset.usageCount.toString());
        final TextEditingController purchaseDateController =
            TextEditingController(text: asset.purchaseDateLabel);
        String status = asset.status.isNotEmpty ? asset.status : '在用';

        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('编辑装备'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '名称'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '价格 (¥)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: usageCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '使用次数'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: purchaseDateController,
                      decoration:
                          const InputDecoration(labelText: '购入日期标签'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: '状态'),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: '在用',
                          child: Text('在用'),
                        ),
                        DropdownMenuItem<String>(
                          value: '备用',
                          child: Text('备用'),
                        ),
                        DropdownMenuItem<String>(
                          value: '已出手',
                          child: Text('已出手'),
                        ),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          status = value;
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final String name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('名称不能为空')),
                      );
                      return;
                    }

                    final double? newPrice =
                        double.tryParse(priceController.text.trim());
                    final int? newUsage =
                        int.tryParse(usageCountController.text.trim());

                    await GearAssetsRepository.instance.updateAsset(
                      id: asset.id,
                      name: name,
                      brand: asset.brand,
                      purchaseDateLabel:
                          purchaseDateController.text.trim(),
                      price: newPrice ?? asset.price,
                      usageCount: newUsage ?? asset.usageCount,
                      status: status,
                    );

                    final _GearAssetsPageState? state =
                        context.findAncestorStateOfType<_GearAssetsPageState>();
                    state?.refreshAssets();

                    Navigator.of(dialogContext).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已更新装备信息')),
                    );
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );

        nameController.dispose();
        priceController.dispose();
        usageCountController.dispose();
        purchaseDateController.dispose();
      },
      borderRadius: AppBorderRadius.extraLarge,
      child: ClipRRect(
        borderRadius: AppBorderRadius.extraLarge,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                asset.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            // 状态标签
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '在用',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // 文本信息
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppFontSizes.bodyLarge,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    asset.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: AppFontSizes.body,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    asset.purchaseDateLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: AppFontSizes.body - 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¥${_formatPrice2(asset.price)}',
                        style: const TextStyle(
                          color: Color(0xFFFFD54F),
                          fontSize: AppFontSizes.bodyLarge,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '使用${asset.usageCount}次',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: AppFontSizes.body - 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice2(double price) {
  final int cents = (price * 100).truncate();
  final int yuan = cents ~/ 100;
  final int remainder = cents % 100;
  final String centsStr = remainder.toString().padLeft(2, '0');
  return '$yuan.$centsStr';
}

class _AddGearCard extends StatelessWidget {
  const _AddGearCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final bool? added = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const AddEquipmentPage()),
        );
        if (added == true) {
          final _GearAssetsPageState? state =
              context.findAncestorStateOfType<_GearAssetsPageState>();
          state?.refreshAssets();
        }
      },
      borderRadius: AppBorderRadius.extraLarge,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.extraLarge,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryLightBlue,
              AppColors.primaryBlue,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: Icon(Icons.add, size: 30, color: AppColors.primaryDarkBlue),
              ),
              SizedBox(height: 10),
              Text(
                '添加装备',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSizes.bodyLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

