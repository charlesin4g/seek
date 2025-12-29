import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../utils/responsive.dart';
import '../../services/repository/travel_plan_repository.dart';
import 'travel_plan_cards.dart';
import 'travel_plan_edit_page.dart';

class TravelPlanPage extends StatefulWidget {
  const TravelPlanPage({super.key});

  @override
  State<TravelPlanPage> createState() => _TravelPlanPageState();
}

class _TravelPlanPageState extends State<TravelPlanPage> {
  void refreshPlans() {
    setState(() {});
  }

  void _openCreatePlanDialog() {
    _showCreatePlanDialog(
      context,
      onCreated: refreshPlans,
    );
  }

  Future<void> _onEditPlan(BuildContext context, TravelPlanRecord plan) async {
    final bool? updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TravelPlanEditPage(plan: plan),
      ),
    );

    if (updated == true) {
      refreshPlans();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已更新旅行计划')),
        );
      }
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            '旅行计划',
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: ResponsiveContainer(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NewPlanSection(onCreatePressed: _openCreatePlanDialog),
                        const SizedBox(height: 10),
                        PlanCardList(onCardTap: _onEditPlan),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _NewPlanSection extends StatelessWidget {
  const _NewPlanSection({required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.9),
        borderRadius: AppBorderRadius.extraLarge,
        boxShadow: const [AppShadows.light],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(Icons.map, color: AppColors.primaryDarkBlue),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '新的计划',
                  style: TextStyle(
                    fontSize: AppFontSizes.subtitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppBorderRadius.large,
              ),
              child: TextButton(
                onPressed: onCreatePressed,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.large,
                  ),
                ),
                child: const Text(
                  '开始规划',
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


void _showCreatePlanDialog(BuildContext context, {VoidCallback? onCreated}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return _CreatePlanDialog(onCreated: onCreated);
    },
  );
}


class _CreatePlanDialog extends StatefulWidget {
  const _CreatePlanDialog({this.onCreated});

  final VoidCallback? onCreated;

  @override
  State<_CreatePlanDialog> createState() => _CreatePlanDialogState();
}

class _CreatePlanDialogState extends State<_CreatePlanDialog> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController(text: '5000');
  final TextEditingController _companionsController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  @override
  void dispose() {
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _budgetController.dispose();
    _companionsController.dispose();
    _typeController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite.withValues(alpha: 0.96),
              borderRadius: AppBorderRadius.extraLarge,
              boxShadow: const [AppShadows.medium],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '新增旅行计划',
                      style: TextStyle(
                        fontSize: AppFontSizes.subtitle,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInputField('目的地', '请输入旅行目的地', _destinationController),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField('出发日期', '年 / 月 / 日', _startDateController, suffixIcon: Icons.calendar_today),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField('结束日期', '年 / 月 / 日', _endDateController, suffixIcon: Icons.calendar_today),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField('预计预算', '5000', _budgetController, keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField('同行人数', '选择人数', _companionsController, suffixIcon: Icons.arrow_drop_down),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInputField('旅行类型', '选择旅行类型', _typeController, suffixIcon: Icons.arrow_drop_down),
                const SizedBox(height: 12),
                _buildInputField(
                  '备注说明',
                  '请描述您的旅行需求和特殊要求...',
                  _remarkController,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: AppColors.borderLight),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppBorderRadius.large,
                          ),
                        ),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppBorderRadius.large,
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final String destination = _destinationController.text.trim();
                            if (destination.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('请填写目的地')),
                              );
                              return;
                            }

                            final String start = _startDateController.text.trim();
                            final String end = _endDateController.text.trim();

                            String dateRange;
                            if (start.isEmpty && end.isEmpty) {
                              dateRange = '日期待定';
                            } else if (start.isEmpty || end.isEmpty) {
                              dateRange = '$start$end';
                            } else {
                              dateRange = '$start - $end';
                            }

                            final String budgetText = _budgetController.text.trim();
                            final double? budgetValue = double.tryParse(
                              budgetText.replaceAll(',', '').replaceAll('¥', ''),
                            );
                            final String budgetLabel =
                                budgetValue != null ? '¥${budgetValue.toStringAsFixed(0)}' : '预算待定';

                            final String companionsText = _companionsController.text.trim();
                            final int? companionsCount = int.tryParse(companionsText);
                            final String companionsLabel;
                            if (companionsCount == null || companionsCount <= 1) {
                              companionsLabel = '独行';
                            } else {
                              companionsLabel = '$companionsCount人同行';
                            }

                            const String daysLabel = '计划中';

                            await TravelPlanRepository.instance.addPlan(
                              title: destination,
                              dateRange: dateRange,
                              daysLabel: daysLabel,
                              budgetLabel: budgetLabel,
                              companionsLabel: companionsLabel,
                            );

                            widget.onCreated?.call();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已创建旅行计划')),
                            );

                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppBorderRadius.large,
                            ),
                          ),
                          child: const Text(
                            '创建计划',
                            style: TextStyle(
                              fontSize: AppFontSizes.bodyLarge,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
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
            focusedBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.medium,
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, size: 18, color: AppColors.textSecondary)
                : null,
          ),
        ),
      ],
    );
  }
}
