import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../utils/responsive.dart';
import '../../services/repository/travel_plan_repository.dart';

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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.backgroundWhite.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.add, color: AppColors.primaryDarkBlue),
                  onPressed: _openCreatePlanDialog,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ResponsiveContainer(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _TimelineHeader(),
                        const SizedBox(height: 16),
                        _TimelineList(),
                        const SizedBox(height: 24),
                        _PlanCTASection(onCreatePressed: _openCreatePlanDialog),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openCreatePlanDialog,
          backgroundColor: AppColors.secondaryGreen,
          foregroundColor: AppColors.textWhite,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          '旅行计划',
          style: TextStyle(
            fontSize: AppFontSizes.subtitle,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _TimelineList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TravelPlanRecord>>(
      future: TravelPlanRepository.instance.getAllPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final plans = snapshot.data ?? const <TravelPlanRecord>[];
        if (plans.isEmpty) {
          return const Center(
            child: Text(
              '暂无旅行计划，点击右上角添加',
              style: TextStyle(
                fontSize: AppFontSizes.body,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧时间线
            Column(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightBlue,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Container(
                  width: 4,
                  height: (plans.length * 160).toDouble(),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryLightBlue,
                        AppColors.secondaryLightGreen,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // 右侧卡片
            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < plans.length; i++)
                    _TimelineItem(plan: plans[i], isLast: i == plans.length - 1),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.plan, required this.isLast});

  final TravelPlanRecord plan;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间线节点
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.secondaryGreen, width: 3),
                  shape: BoxShape.circle,
                  boxShadow: const [AppShadows.light],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 120,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightBlue.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // 卡片
          Expanded(
            child: InkWell(
              borderRadius: AppBorderRadius.extraLarge,
              onTap: () {
                _showEditPlanDialog(
                  context,
                  plan,
                  onUpdated: () {
                    final _TravelPlanPageState? state =
                        context.findAncestorStateOfType<_TravelPlanPageState>();
                    state?.refreshPlans();
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE5F9F6),
                      Color(0xFFE9F6FF),
                    ],
                  ),
                  borderRadius: AppBorderRadius.extraLarge,
                  boxShadow: const [AppShadows.light],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.title,
                              style: const TextStyle(
                                fontSize: AppFontSizes.subtitle,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plan.dateRange,
                              style: const TextStyle(
                                fontSize: AppFontSizes.body,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB9C6FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            plan.daysLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.currency_yen, size: 18, color: AppColors.secondaryGreen),
                        const SizedBox(width: 4),
                        Text(
                          plan.budgetLabel,
                          style: const TextStyle(
                            fontSize: AppFontSizes.bodyLarge,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          plan.companionsLabel,
                          style: const TextStyle(
                            fontSize: AppFontSizes.body,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        _PlanIcon(icon: Icons.flight_takeoff),
                        SizedBox(width: 8),
                        _PlanIcon(icon: Icons.directions_car),
                        SizedBox(width: 8),
                        _PlanIcon(icon: Icons.park),
                        SizedBox(width: 8),
                        _PlanIcon(icon: Icons.camera_alt),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanIcon extends StatelessWidget {
  const _PlanIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.light],
      ),
      child: Icon(icon, size: 18, color: AppColors.primaryDarkBlue),
    );
  }
}

class _PlanCTASection extends StatelessWidget {
  const _PlanCTASection({required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
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
                  '规划新的旅程',
                  style: TextStyle(
                    fontSize: AppFontSizes.subtitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '让 AI 助手帮您制定完整的旅行计划',
            style: TextStyle(
              fontSize: AppFontSizes.body,
              color: AppColors.textSecondary,
            ),
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

Future<void> _showEditPlanDialog(
  BuildContext context,
  TravelPlanRecord plan, {
  VoidCallback? onUpdated,
}) async {
  final TextEditingController titleController =
      TextEditingController(text: plan.title);
  final TextEditingController dateRangeController =
      TextEditingController(text: plan.dateRange);
  final TextEditingController daysLabelController =
      TextEditingController(text: plan.daysLabel);
  final TextEditingController budgetLabelController =
      TextEditingController(text: plan.budgetLabel);
  final TextEditingController companionsLabelController =
      TextEditingController(text: plan.companionsLabel);

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('编辑旅行计划'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '标题'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dateRangeController,
                decoration: const InputDecoration(labelText: '日期范围'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: daysLabelController,
                decoration: const InputDecoration(labelText: '天数字段'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: budgetLabelController,
                decoration: const InputDecoration(labelText: '预算标签'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: companionsLabelController,
                decoration: const InputDecoration(labelText: '同行标签'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final String title = titleController.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('标题不能为空')),
                );
                return;
              }

              await TravelPlanRepository.instance.updatePlan(
                id: plan.id,
                title: title,
                dateRange: dateRangeController.text.trim(),
                daysLabel: daysLabelController.text.trim(),
                budgetLabel: budgetLabelController.text.trim(),
                companionsLabel: companionsLabelController.text.trim(),
              );

              onUpdated?.call();

              Navigator.of(dialogContext).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已更新旅行计划')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      );
    },
  );

  titleController.dispose();
  dateRangeController.dispose();
  daysLabelController.dispose();
  budgetLabelController.dispose();
  companionsLabelController.dispose();
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
