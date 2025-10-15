import 'package:flutter/material.dart';
import '../models/gear.dart';
import '../widgets/section_card.dart';
import '../widgets/form_field.dart';
import '../widgets/selector_field.dart';

class AddEquipmentPage extends StatefulWidget {
  const AddEquipmentPage({super.key});

  @override
  State<AddEquipmentPage> createState() => _AddEquipmentPageState();
}

class _AddEquipmentPageState extends State<AddEquipmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCategory = '背负';
  String _selectedBrand = '神秘农场';
  String _selectedWeightUnit = 'g';
  int _quantity = 1;
  DateTime _selectedDate = DateTime(2025, 10, 15);

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          '添加新装备',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveEquipment,
            child: const Text(
              '保存',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SectionCard(
                title: '基本信息',
                children: [
                  CustomFormField(
                    label: '装备名称',
                    controller: _nameController,
                    hintText: '请输入装备名称',
                  ),
                  const SizedBox(height: 16),
                  SelectorField(
                    label: '所属类别',
                    value: _selectedCategory,
                    onTap: _showCategoryPicker,
                  ),
                  const SizedBox(height: 16),
                  SelectorField(
                    label: '品牌',
                    value: _selectedBrand,
                    onTap: _showBrandPicker,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: '详细数据',
                children: [
                  _buildWeightField(),
                  const SizedBox(height: 16),
                  CustomFormField(
                    label: '单价(元)',
                    controller: _priceController,
                    hintText: '请输入单价',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildQuantityField(),
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: '购买/办理日期',
                children: [
                  _buildDateField(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightField() {
    return Row(
      children: [
        const Expanded(
          flex: 2,
          child: Text(
            '单件重量',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '请输入...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Row(
            children: WeightUnit.units.map((unit) {
              final isSelected = _selectedWeightUnit == unit;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWeightUnit = unit;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      unit,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityField() {
    return Row(
      children: [
        const Expanded(
          flex: 2,
          child: Text(
            '数量',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_quantity > 1) {
                    setState(() {
                      _quantity--;
                    });
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.remove, size: 16),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _quantity.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _quantity++;
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Row(
      children: [
        const Expanded(
          flex: 2,
          child: Text(
            '日期',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: GearCategory.categories.map((category) {
            return ListTile(
              title: Text(category),
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                Navigator.pop(context);
              },
              trailing: _selectedCategory == category
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBrandPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: GearBrand.brands.map((brand) {
            return ListTile(
              title: Text(brand),
              onTap: () {
                setState(() {
                  _selectedBrand = brand;
                });
                Navigator.pop(context);
              },
              trailing: _selectedBrand == brand
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveEquipment() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically save the equipment data
      // For now, just show a success message and go back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('装备添加成功！'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
