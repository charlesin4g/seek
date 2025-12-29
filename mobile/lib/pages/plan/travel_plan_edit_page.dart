import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/repository/travel_plan_repository.dart';
import '../../utils/responsive.dart';

/// 旅行计划编辑页
///
/// 由列表页点击卡片进入，整体视觉参考设计稿：
/// 顶部大卡片展示标题与日期，下方为预算卡片、其他信息以及行程明细占位。
class TravelPlanEditPage extends StatefulWidget {
  const TravelPlanEditPage({super.key, required this.plan});

  final TravelPlanRecord plan;

  @override
  State<TravelPlanEditPage> createState() => _TravelPlanEditPageState();
}

class _TravelPlanEditPageState extends State<TravelPlanEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _dateRangeController;
  late final TextEditingController _budgetController;
  late final TextEditingController _companionsController;
  late final TextEditingController _daysLabelController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.plan.title);
    _dateRangeController = TextEditingController(text: widget.plan.dateRange);
    _budgetController = TextEditingController(text: widget.plan.budgetLabel);
    _companionsController = TextEditingController(text: widget.plan.companionsLabel);
    _daysLabelController = TextEditingController(text: widget.plan.daysLabel);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateRangeController.dispose();
    _budgetController.dispose();
    _companionsController.dispose();
    _daysLabelController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标题不能为空')),
      );
      return;
    }

    await TravelPlanRepository.instance.updatePlan(
      id: widget.plan.id,
      title: title,
      dateRange: _dateRangeController.text.trim(),
      daysLabel: _daysLabelController.text.trim().isEmpty
          ? widget.plan.daysLabel
          : _daysLabelController.text.trim(),
      budgetLabel: _budgetController.text.trim().isEmpty
          ? widget.plan.budgetLabel
          : _budgetController.text.trim(),
      companionsLabel: _companionsController.text.trim().isEmpty
          ? widget.plan.companionsLabel
          : _companionsController.text.trim(),
    );

    // 返回上一个页面并告知已更新
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ResponsiveContainer(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 16),
                  _buildMainCard(),
                  const SizedBox(height: 16),
                  _buildBudgetCard(),
                  const SizedBox(height: 16),
                  _buildExtraInfoCard(),
                  const SizedBox(height: 24),
                  _buildItineraryPlaceholder(),
                  const SizedBox(height: 24),
                  _buildAddSegmentButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            '编辑中',
            style: TextStyle(
              fontSize: AppFontSizes.body,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.check, color: AppColors.textPrimary),
          onPressed: _handleSave,
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB0B8FF),
            Color(0xFFE0E7FF),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [AppShadows.medium],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 2,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '输入行程标题',
              hintStyle: TextStyle(
                fontSize: AppFontSizes.subtitle,
                color: Colors.white70,
              ),
              isCollapsed: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _dateRangeController,
                  style: const TextStyle(
                    fontSize: AppFontSizes.body,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '开始日期 - 结束日期',
                    hintStyle: TextStyle(
                      fontSize: AppFontSizes.body,
                      color: Colors.white70,
                    ),
                    isCollapsed: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.98),
        borderRadius: AppBorderRadius.extraLarge,
        boxShadow: const [AppShadows.light],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '当前预计预算',
                  style: TextStyle(
                    fontSize: AppFontSizes.body,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _budgetController,
                  style: const TextStyle(
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixStyle: TextStyle(
                      fontSize: AppFontSizes.bodyLarge,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    isCollapsed: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 229, 241, 219),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                size: 22, color: AppColors.primaryDarkBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.98),
        borderRadius: AppBorderRadius.extraLarge,
        boxShadow: const [AppShadows.light],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '其他信息',
            style: TextStyle(
              fontSize: AppFontSizes.subtitle,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildLabeledField(
            label: '行程状态 / 天数字段',
            hint: '例如：25天 / 已完成 / 计划中',
            controller: _daysLabelController,
          ),
          const SizedBox(height: 12),
          _buildLabeledField(
            label: '同行信息',
            hint: '例如：独行 / 3人同行',
            controller: _companionsController,
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '行程详情',
          style: TextStyle(
            fontSize: AppFontSizes.subtitle,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite.withValues(alpha: 0.98),
            borderRadius: AppBorderRadius.extraLarge,
            boxShadow: const [AppShadows.light],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '行程明细编辑功能后续可在此扩展',
                style: TextStyle(
                  fontSize: AppFontSizes.body,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '当前版本仅支持修改标题、日期、预算和基本信息。',
                style: TextStyle(
                  fontSize: AppFontSizes.body,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddSegmentButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('行程分段编辑功能开发中')),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: BorderSide(color: AppColors.borderLight),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: AppBorderRadius.large,
          ),
        ),
        child: const Text('添加下一站行程'),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: AppFontSizes.body,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.backgroundGrey,
            border: OutlineInputBorder(
              borderRadius: AppBorderRadius.medium,
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.medium,
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppBorderRadius.medium,
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
