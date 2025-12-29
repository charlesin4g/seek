import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/repository/travel_plan_repository.dart';

typedef TravelPlanCardTapCallback = Future<void> Function(
  BuildContext context,
  TravelPlanRecord plan,
);

class PlanCardList extends StatelessWidget {
  const PlanCardList({
    super.key,
    required this.onCardTap,
  });

  final TravelPlanCardTapCallback onCardTap;

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
              '暂无徒步计划，点击右上角添加',
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
            // 右侧卡片
            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < plans.length; i++)
                    PlanCard(
                      plan: plans[i],
                      isLast: i == plans.length - 1,
                      onTap: () => onCardTap(context, plans[i]),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.isLast,
    required this.onTap,
  });

  final TravelPlanRecord plan;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 卡片下间距
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片
          Expanded(
            child: InkWell(
              borderRadius: AppBorderRadius.extraLarge,
              onTap: onTap,
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
