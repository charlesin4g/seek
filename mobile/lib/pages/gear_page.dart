import 'package:flutter/material.dart';
import '../models/gear.dart';
import '../models/gear_statistics.dart';
import '../widgets/section_card.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'add_equipment_page.dart';
import 'equipment_selection_page.dart';
import 'login_page.dart';

class GearPage extends StatelessWidget {
  const GearPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Read cached admin user globally (if exists)
    // This is just an example of global access; UI remains functional without it
    final Future<Map<String, dynamic>?> adminFuture = StorageService().getCachedAdminUser();

    // Sample data - in a real app, this would come from a service or state management
    final sampleGear = [
      Gear(
        id: '1',
        name: '帐篷',
        category: '睡眠',
        brand: '牧高笛',
        weight: 1,
        weightUnit: 'g',
        price: 980,
        quantity: 1,
        purchaseDate: DateTime(2025, 10, 1),
      ),
      Gear(
        id: '2',
        name: 'radix 57',
        category: '背负',
        brand: '神秘农场',
        weight: 2,
        weightUnit: 'g',
        price: 2400,
        quantity: 1,
        purchaseDate: DateTime(2025, 9, 1),
      ),
    ];

    final statistics = GearStatistics.fromGearList(sampleGear);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFF8F9FA),
          ],
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
                      final name = snapshot.data?['name'] ?? snapshot.data?['username'];
                      if (name == null) return const SizedBox.shrink();
                      return Text(
                        '管理员: $name',
                        style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade600),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EquipmentSelectionPage()),
                );
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddEquipmentPage()),
                );
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
                      MaterialPageRoute(builder: (context) => const LoginPage()),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSummaryCard(statistics),
              const SizedBox(height: 16),
              _buildValueStatsCard(statistics),
              const SizedBox(height: 16),
              _buildBrandValueCard(statistics),
              const SizedBox(height: 16),
              _buildBrandQuantityCard(statistics),
              const SizedBox(height: 16),
              _buildGearTableCard('睡眠', _getGearByCategory(sampleGear, '睡眠')),
              const SizedBox(height: 16),
              _buildGearTableCard('背负', _getGearByCategory(sampleGear, '背负')),
            ],
          ),
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
            _buildStatItem('${stats.totalWeight.toStringAsFixed(2)}kg', '装备总重量'),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildValueStatsCard(GearStatistics stats) {
    final totalValue = stats.totalValue;
    final carryValue = stats.categoryValues['背负'] ?? 0;
    final sleepValue = stats.categoryValues['睡眠'] ?? 0;

    return SectionCard(
      title: '装备价值统计',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('背负'),
            Text('${carryValue.toInt()}', style: TextStyle(color: Colors.blue.shade700)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: totalValue > 0 ? carryValue / totalValue : 0,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('睡眠'),
            Text('${sleepValue.toInt()}', style: TextStyle(color: Colors.blue.shade700)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: totalValue > 0 ? sleepValue / totalValue : 0,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
        ),
        const SizedBox(height: 8),
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

  Widget _buildBrandValueCard(GearStatistics stats) {
    final brandValues = stats.brandValues;
    final maxValue = brandValues.values.isNotEmpty ? brandValues.values.reduce((a, b) => a > b ? a : b) : 1.0;

    return SectionCard(
      title: '品牌价值统计',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: brandValues.entries.map((entry) {
            final height = maxValue > 0 ? entry.value / maxValue : 0.0;
            final color = entry.key == '神秘农场' ? Colors.blue : Colors.green;
            return _buildBrandBar(entry.key, entry.value.toInt(), color, height);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBrandBar(String brand, int value, Color color, double height) {
    return Column(
      children: [
        Text(
          '$value¥',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
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
        Text(
          brand,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBrandQuantityCard(GearStatistics stats) {
    final brandCounts = stats.brandCounts;

    return SectionCard(
      title: '品牌数量统计',
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
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
        Text(
          brand,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildGearTableCard(String category, List<Gear> data) {
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
                  child: Text('装备名字', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('数目', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('重量 (g)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('价格', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('购入时间', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...data.map((item) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(item.name),
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
                  child: Text('${item.purchaseDate.year}-${item.purchaseDate.month.toString().padLeft(2, '0')}'),
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }

  List<Gear> _getGearByCategory(List<Gear> gearList, String category) {
    return gearList.where((gear) => gear.category == category).toList();
  }
}
