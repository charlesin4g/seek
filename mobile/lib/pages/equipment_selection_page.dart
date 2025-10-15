import 'package:flutter/material.dart';
import '../models/gear.dart';
import 'equipment_edit_page.dart';

class EquipmentSelectionPage extends StatelessWidget {
  const EquipmentSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
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

    // Group gear by category
    final Map<String, List<Gear>> groupedGear = {};
    for (final gear in sampleGear) {
      if (!groupedGear.containsKey(gear.category)) {
        groupedGear[gear.category] = [];
      }
      groupedGear[gear.category]!.add(gear);
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '取消',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
            ),
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
              // TODO: Implement delete functionality
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: groupedGear.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ...entry.value.map((gear) => _buildEquipmentCard(context, gear)),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
        ),
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EquipmentEditPage(gear: gear),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    gear.name,
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
