import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/gear.dart';
import '../../services/gear_api.dart';
import 'edit_gear_page.dart';

class EquipmentSelectionPage extends StatelessWidget {
  const EquipmentSelectionPage({super.key});

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

          final Map<String, List<Gear>> groupedGear = {};
          for (final gear in gearList) {
            (groupedGear[gear.category] ??= []).add(gear);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: groupedGear.entries.expand((entry) {
                final title = categoryDict[entry.key] ?? entry.key;
                return [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  ...entry.value.map((gear) => _buildEquipmentCard(context, gear, brandDict)),
                  const SizedBox(height: 8),
                ];
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEquipmentCard(BuildContext context, Gear gear, Map<String, String> brandDict) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          onTap: () async {
            final changed = await Navigator.push(
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
                    '${brandDict[gear.brand] ?? gear.brand} ${gear.name}',
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

  DateTime _parsePurchaseDate(String s) {
    final parts = s.split('-');
    if (parts.length == 2) {
      final yy = int.tryParse(parts[0]) ?? 0;
      final mm = int.tryParse(parts[1]) ?? 1;
      return DateTime(2000 + yy, mm, 1);
    }
    try {
      return DateTime.parse(s);
    } catch (_) {
      return DateTime.now();
    }
  }
}
