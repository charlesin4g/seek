// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../models/gear.dart';
import '../../config/app_colors.dart';
import '../../widgets/section_card.dart';
import '../../widgets/form_field.dart';
import '../../widgets/selector_field.dart';
import '../../services/repository/gear_brand_repository.dart';
import '../../services/repository/gear_assets_repository.dart';

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
    
    _fetchBrands('');
    _fetchCategories();
  }
  
  Future<void> _fetchBrands(keyword) async {
    setState(() {
      _isLoadingBrands = true;
    });
    
    try {
      final brands = await GearBrandRepository.instance.getBrandIdNameList(keyword);
      setState(() {
        _brands = brands.map((data) => Brand.fromJson(data)).toList();
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

    const List<String> categories = <String>['服装', '背包', '睡眠', '炊具', '照明', '防护', '电子'];

    setState(() {
      _categories = categories;
      _categoryDict = <String, String>{
        for (final String name in categories) name: name,
      };
      _isLoadingCategories = false;
      if (_selectedCategory.isEmpty && categories.isNotEmpty) {
        _selectedCategory = categories.first;
      }
    });
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
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.primaryLightBlue,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          title: const Text(
            '编辑装备',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
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
        bottomNavigationBar: SafeArea(
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
                                _selectedBrand = brand.displayName;
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double price = double.tryParse(_priceController.text) ?? 0.0;
    final String purchaseDateLabel =
        '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    () async {
      try {
        final int assetId = int.tryParse(widget.gear.id) ?? 0;
        if (assetId <= 0) {
          throw Exception('无效的装备 ID');
        }

        await GearAssetsRepository.instance.updateAsset(
          id: assetId,
          name: _nameController.text.trim(),
          brand: _selectedBrand,
          category: _selectedCategory,
          purchaseDateLabel: purchaseDateLabel,
          price: price,
        );

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

}
