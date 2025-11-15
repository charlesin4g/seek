import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../utils/responsive.dart';
import '../../../models/gear.dart';

/// 改进的装备表格组件
/// 支持水平滚动和更好的装备名称显示
class ImprovedGearTable extends StatelessWidget {
  final String category;
  final List<Gear> data;
  final Map<String, String> brandDict;
  
  const ImprovedGearTable({
    super.key,
    required this.category,
    required this.data,
    required this.brandDict,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.9),
        borderRadius: AppBorderRadius.large,
        boxShadow: [AppShadows.light],
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Padding(
            padding: Responsive.responsivePadding(context),
            child: Text(
              category,
              style: TextStyle(
                fontSize: Responsive.value(context,
                  small: AppFontSizes.title - 2, // 18px
                  medium: AppFontSizes.title,    // 20px
                  large: AppFontSizes.title + 2,  // 22px
                ),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // 可滚动的表格区域
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: Responsive.width(context) - 32, // 减去左右边距
              ),
              child: DataTable(
                headingRowHeight: 48,
                dataRowHeight: 56,
                horizontalMargin: 16,
                columnSpacing: 16,
                dividerThickness: 1,
                decoration: const BoxDecoration(),
                border: TableBorder(
                  horizontalInside: BorderSide(color: AppColors.divider, width: 1),
                ),
                columns: [
                  DataColumn(
                    label: SizedBox(
                      width: _getNameColumnWidth(context),
                      child: Text(
                        '装备名称',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: Responsive.value(context,
                            small: AppFontSizes.body,      // 14px
                            medium: AppFontSizes.body,      // 14px
                            large: AppFontSizes.bodyLarge,  // 16px
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 60,
                      child: Text(
                        '数量',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: Responsive.value(context,
                            small: AppFontSizes.body,
                            medium: AppFontSizes.body,
                            large: AppFontSizes.bodyLarge,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 80,
                      child: Text(
                        '重量(g)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: Responsive.value(context,
                            small: AppFontSizes.body,
                            medium: AppFontSizes.body,
                            large: AppFontSizes.bodyLarge,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 80,
                      child: Text(
                        '价格',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: Responsive.value(context,
                            small: AppFontSizes.body,
                            medium: AppFontSizes.body,
                            large: AppFontSizes.bodyLarge,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 80,
                      child: Text(
                        '购入时间',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: Responsive.value(context,
                            small: AppFontSizes.body,
                            medium: AppFontSizes.body,
                            large: AppFontSizes.bodyLarge,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
                rows: data.map((item) => DataRow(
                  cells: [
                    // 装备名称单元格 - 支持长文本显示
                    DataCell(
                      Container(
                        width: _getNameColumnWidth(context),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${brandDict[item.brand] ?? item.brand} ${item.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: Responsive.value(context,
                                  small: AppFontSizes.body,
                                  medium: AppFontSizes.bodyLarge,
                                  large: AppFontSizes.bodyLarge + 1,
                                ),
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.name.length > 20) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: Responsive.value(context,
                                    small: AppFontSizes.body - 1,
                                    medium: AppFontSizes.body,
                                    large: AppFontSizes.body,
                                  ),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // 数量
                    DataCell(
                      Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          item.quantity.toString(),
                          style: TextStyle(
                            fontSize: Responsive.value(context,
                              small: AppFontSizes.body,
                              medium: AppFontSizes.bodyLarge,
                              large: AppFontSizes.bodyLarge,
                            ),
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // 重量
                    DataCell(
                      Container(
                        width: 80,
                        alignment: Alignment.center,
                        child: Text(
                          item.weight.toString(),
                          style: TextStyle(
                            fontSize: Responsive.value(context,
                              small: AppFontSizes.body,
                              medium: AppFontSizes.bodyLarge,
                              large: AppFontSizes.bodyLarge,
                            ),
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // 价格
                    DataCell(
                      Container(
                        width: 80,
                        alignment: Alignment.center,
                        child: Text(
                          '${item.price.toInt()}',
                          style: TextStyle(
                            fontSize: Responsive.value(context,
                              small: AppFontSizes.body,
                              medium: AppFontSizes.bodyLarge,
                              large: AppFontSizes.bodyLarge,
                            ),
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // 购入时间
                    DataCell(
                      Container(
                        width: 80,
                        alignment: Alignment.center,
                        child: Text(
                          '${(item.purchaseDate.year % 100).toString().padLeft(2, '0')}-${item.purchaseDate.month.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: Responsive.value(context,
                              small: AppFontSizes.body,
                              medium: AppFontSizes.bodyLarge,
                              large: AppFontSizes.bodyLarge,
                            ),
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 获取装备名称列的宽度 - 响应式处理
  double _getNameColumnWidth(BuildContext context) {
    final screenWidth = Responsive.width(context);
    
    if (screenWidth < Responsive.mobileMedium) {
      // 小屏手机：最小宽度，确保其他列也能显示
      return 120;
    } else if (screenWidth < Responsive.mobileLarge) {
      // 标准手机：适中的宽度
      return 160;
    } else {
      // 大屏手机：更宽的名称列
      return 200;
    }
  }
}