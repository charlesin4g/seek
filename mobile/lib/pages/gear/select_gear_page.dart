import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/gear.dart';
import '../../services/repository/gear_assets_repository.dart';
import 'edit_gear_page.dart';

class EquipmentSelectionPage extends StatelessWidget {
  const EquipmentSelectionPage({super.key});

  Future<List<Gear>> _loadLocalGears() async {
    final assets = await GearAssetsRepository.instance.getAllAssets();
    return assets.map((asset) {
      final DateTime date = _parsePurchaseDate(asset.purchaseDateLabel);
      final String category = asset.category.isEmpty ? '全部装备' : asset.category;
      return Gear(
        id: asset.id.toString(),
        name: asset.name,
        category: category,
        brand: asset.brand,
        weight: 0,
        weightUnit: 'g',
        price: asset.price,
        quantity: 1,
        purchaseDate: date,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight.withValues(alpha: 0.2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primaryBlue,
          ),
        ),
        title: const Text(
          '选择要编辑的装备',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('删除功能待实现'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Gear>>(
        future: _loadLocalGears(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载装备失败: ${snapshot.error}'));
          }

          final List<Gear> gearList = snapshot.data ?? <Gear>[];
          if (gearList.isEmpty) {
            return const Center(child: Text('暂无装备'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: gearList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final Gear gear = gearList[index];
              return _buildEquipmentCard(context, gear);
            },
          );
        },
      ),
    );
  }

  Widget _buildEquipmentCard(BuildContext context, Gear gear) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          onTap: () async {
            final bool? changed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => EquipmentEditPage(gear: gear),
              ),
            );
            if (changed == true) {
              Navigator.pop(context, true);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${gear.brand} ${gear.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

DateTime _parsePurchaseDate(String s) {
  final List<String> parts = s.split('-');
  if (parts.length == 3) {
    final int year = int.tryParse(parts[0]) ?? 2000;
    final int month = int.tryParse(parts[1]) ?? 1;
    final int day = int.tryParse(parts[2]) ?? 1;
    return DateTime(year, month, day);
  }
  if (parts.length == 2) {
    final int yy = int.tryParse(parts[0]) ?? 0;
    final int mm = int.tryParse(parts[1]) ?? 1;
    return DateTime(2000 + yy, mm, 1);
  }
  try {
    return DateTime.parse(s);
  } catch (_) {
    return DateTime.now();
  }
}
