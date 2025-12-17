import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../utils/responsive.dart';
import 'add_gear_page.dart';

class GearAssetsPage extends StatelessWidget {
  const GearAssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const List<_MockGearAsset> assets = _mockGearAssets;
    final int totalCount = assets.length;
    final double totalValue = assets.fold(0, (sum, e) => sum + e.price);

    final String totalValueLabel = '¥${totalValue.toStringAsFixed(0)}';

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
          child: SingleChildScrollView(
            padding: Responsive.responsivePadding(context).copyWith(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 总价值卡片
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
          ),
        ),
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

  final List<_MockGearAsset> assets;

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

  final _MockGearAsset asset;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('装备详情功能开发中')), 
        );
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
                        '¥${asset.price.toStringAsFixed(0)}',
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

class _AddGearCard extends StatelessWidget {
  const _AddGearCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEquipmentPage()),
        );
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

class _MockGearAsset {
  const _MockGearAsset({
    required this.name,
    required this.brand,
    required this.purchaseDateLabel,
    required this.price,
    required this.usageCount,
    required this.imageUrl,
  });

  final String name;
  final String brand;
  final String purchaseDateLabel;
  final double price;
  final int usageCount;
  final String imageUrl;
}

const List<_MockGearAsset> _mockGearAssets = [
  _MockGearAsset(
    name: 'Osprey Atmos AG 65',
    brand: 'Osprey',
    purchaseDateLabel: '2024-01-15',
    price: 2680,
    usageCount: 12,
    imageUrl: 'https://images.pexels.com/photos/884788/pexels-photo-884788.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _MockGearAsset(
    name: '北面四季帐篷',
    brand: 'The North Face',
    purchaseDateLabel: '2023-11-20',
    price: 3200,
    usageCount: 8,
    imageUrl: 'https://images.pexels.com/photos/618848/pexels-photo-618848.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _MockGearAsset(
    name: '防水冲锋衣',
    brand: "Arc'teryx",
    purchaseDateLabel: '2023-09-05',
    price: 1800,
    usageCount: 15,
    imageUrl: 'https://images.pexels.com/photos/4492042/pexels-photo-4492042.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
  _MockGearAsset(
    name: '户外登山表',
    brand: 'Garmin',
    purchaseDateLabel: '2023-06-12',
    price: 2380,
    usageCount: 20,
    imageUrl: 'https://images.pexels.com/photos/2774062/pexels-photo-2774062.jpeg?auto=compress&cs=tinysrgb&w=800',
  ),
];
