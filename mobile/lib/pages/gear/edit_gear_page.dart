// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../models/gear.dart';
import '../../config/app_colors.dart';
import '../../widgets/section_card.dart';
import '../../widgets/form_field.dart';
import '../../widgets/selector_field.dart';
import '../../services/gear_api.dart';

class EquipmentEditPage extends StatefulWidget {
  final Gear gear;

  const EquipmentEditPage({
    super.key,
    required this.gear,
  });

  @override
  State<EquipmentEditPage> createState() => _EquipmentEditPageState();
}

class _EquipmentEditPageState extends State<EquipmentEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _priceController;
  
  late String _selectedCategory;
  late String _selectedBrand;
  late String _selectedWeightUnit;
  late int _quantity;
  late DateTime _selectedDate;
  
  List<Brand> _brands = [];
  List<String> _categories = [];
  Map<String, String> _categoryDict = {};
  bool _isLoadingBrands = false;
  bool _isLoadingCategories = false;
  final GearApi _gearApi = GearApi();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gear.name);
    _weightController = TextEditingController(text: widget.gear.weight.toString());
    _priceController = TextEditingController(text: widget.gear.price.toString());
    
    _selectedCategory = widget.gear.category;
    _selectedBrand = widget.gear.brand;
    _selectedWeightUnit = widget.gear.weightUnit;
    _quantity = widget.gear.quantity;
    _selectedDate = widget.gear.purchaseDate;
    
    _fetchBrands();
    _fetchCategories();
  }
  
  Future<void> _fetchBrands() async {
    setState(() {
      _isLoadingBrands = true;
    });
    
    try {
      final brandsData = await _gearApi.getBrands();
      setState(() {
        _brands = brandsData.map((data) => Brand.fromJson(data)).toList();
        _isLoadingBrands = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBrands = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取品牌数据失败: $e')),
      );
    }
  }
  
  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    
    try {
      final categoryDict = await _gearApi.getCategoryDict();
      setState(() {
        _categoryDict = categoryDict;
        _categories = categoryDict.keys.toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取类别数据失败: $e')),
      );
    }
  }

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
        title: const Text(
          '编辑装备',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
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
                    value: _categoryDict[_selectedCategory] ?? _selectedCategory,
                    onTap: _showCategoryPicker,
                  ),
                  const SizedBox(height: 16),
                  SelectorField(
                    label: '品牌',
                    value: _getBrandDisplayName(_selectedBrand),
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
      // 将底部操作区改为 bottomSheet 以与其他页面风格一致
      bottomSheet: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 25,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 75,
                child: ElevatedButton(
                  onPressed: _saveEquipment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('保存'),
                ),
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
                borderSide: const BorderSide(color: AppColors.primaryBlue),
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
                      color: isSelected ? AppColors.primaryBlue : Colors.grey.shade200,
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

  String _getBrandDisplayName(String name) {
    try {
      final brand = _brands.firstWhere((b) => b.name == name);
      return brand.displayName;
    } catch (_) {
      return name;
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : (_categories.isEmpty
                    ? const Center(child: Text('没有可用的类别数据'))
                    : ListView.separated(
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const Divider(height: 0),
                        itemBuilder: (_, index) {
                          final code = _categories[index];
                          final name = _categoryDict[code] ?? code;
                          return ListTile(
                            title: Text(name),
                            onTap: () {
                              setState(() {
                                _selectedCategory = code;
                              });
                              Navigator.pop(context);
                            },
                            trailing: _selectedCategory == code
                                ? const Icon(Icons.check, color: AppColors.primaryBlue)
                                : null,
                          );
                        },
                      ))
          ),
        ),
      ),
    );
  }

  void _showBrandPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoadingBrands
                ? const Center(child: CircularProgressIndicator())
                : (_brands.isEmpty
                    ? const Center(child: Text('没有可用的品牌数据'))
                    : ListView.separated(
                        itemCount: _brands.length,
                        separatorBuilder: (_, __) => const Divider(height: 0),
                        itemBuilder: (_, index) {
                          final brand = _brands[index];
                          return ListTile(
                            title: Text(brand.displayName),
                            onTap: () {
                              setState(() {
                                // 选择时保存真实品牌 name，UI 显示使用 displayName
                                _selectedBrand = brand.name;
                              });
                              Navigator.pop(context);
                            },
                            // 高亮逻辑基于保存的 name
                            trailing: _selectedBrand == brand.name
                                ? const Icon(Icons.check, color: AppColors.primaryBlue)
                                : null,
                          );
                        },
                      ))
          ),
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
    if (!_formKey.currentState!.validate()) return;

    final double rawWeight = double.tryParse(_weightController.text) ?? 0.0;
    double weightInGrams = rawWeight;
    if (_selectedWeightUnit == 'kg') {
      weightInGrams = rawWeight * 1000.0;
    } else if (_selectedWeightUnit == '斤') {
      weightInGrams = rawWeight * 500.0;
    }

    final double price = double.tryParse(_priceController.text) ?? 0.0;

    final payload = {
      'name': _nameController.text.trim(),
      'description': '',
      'category': _selectedCategory,
      'brand': _selectedBrand,
      'color': '',
      'size': '',
      'weight': weightInGrams.round(),
      'purchaseDate': _selectedDate.toIso8601String(),
      'price': price,
      'essential': false,
      'quantity': _quantity,
    };

    () async {
      try {
        final String gearId = await _resolveGearIdFromBackendIfNeeded();
        await _gearApi.editGear(gearId, payload);
        // 确认后端已更新，顺便拉取最新列表（不直接使用，只为保证接口成功）
        await _gearApi.getMyGear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('装备更新成功！'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }();
  }

  Future<String> _resolveGearIdFromBackendIfNeeded() async {
    final String currentId = widget.gear.id;
    // 优先使用更稳健的数值判断，避免受正则换行渲染影响
    if (currentId.isNotEmpty && int.tryParse(currentId) != null) {
      return currentId;
    }
    // 如果当前 id 看起来是后端真实 ID（例如纯数字），直接使用
    if (currentId.isNotEmpty && RegExp(r'^\d+$').hasMatch(currentId)) {
      return currentId;
    }

    try {
      final list = await _gearApi.getMyGear();
      for (final m in list) {
        final name = m['name']?.toString() ?? '';
        final category = m['category']?.toString() ?? '';
        final dateStr = m['purchaseDate']?.toString() ?? '';
        final dt = _parsePurchaseDate(dateStr);
        if (name == widget.gear.name && category == widget.gear.category &&
            dt.year == widget.gear.purchaseDate.year && dt.month == widget.gear.purchaseDate.month) {
          final String? realId = (m['id'] ?? m['gearId'] ?? m['gid'])?.toString();
          if (realId != null && realId.isNotEmpty) {
            return realId;
          }
        }
      }
    } catch (e) {
      // 解析失败时，记录到控制台并回退使用现有 id
      // ignore: avoid_print
      print('resolve gear id failed: $e');
    }

    // 回退：使用当前携带的 id（可能是旧逻辑生成的占位符）
    return currentId;
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
