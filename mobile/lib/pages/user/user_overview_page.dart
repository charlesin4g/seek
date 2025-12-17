import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../utils/responsive.dart';
import '../ticket/ticket_page.dart';
import '../gear/gear_assets_page.dart';

class UserOverviewPage extends StatefulWidget {
  const UserOverviewPage({super.key});

  @override
  State<UserOverviewPage> createState() => _UserOverviewPageState();
}

class _UserOverviewPageState extends State<UserOverviewPage> {
  late String _displayName;

  @override
  void initState() {
    super.initState();
    final cached = StorageService().getCachedUserSync();
    _displayName = (cached?['displayName'] ?? cached?['username'] ?? AuthService().currentUser ?? '旅行者').toString();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('功能开发中，敬请期待')), 
    );
  }

  @override
  Widget build(BuildContext context) {
    final Gradient headerGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF7B5CFF),
        Color(0xFFB178FF),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: headerGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: Responsive.responsivePadding(context).copyWith(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // 头像
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                    boxShadow: const [AppShadows.light],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'lib/assests/avatar.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSizes.titleLarge,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '热爱徒步的旅行达人',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: AppFontSizes.body,
                  ),
                ),
                const SizedBox(height: 24),
                // 顶部统计
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _ProfileStatItem(label: '总行程', value: '2,856'),
                    _ProfileStatItem(label: '总天数', value: '89'),
                    _ProfileStatItem(label: '访问城市', value: '23'),
                    _ProfileStatItem(label: '总花费', value: '45,600'),
                  ],
                ),
                const SizedBox(height: 24),
                // 功能卡片
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: AppBorderRadius.extraLarge,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.inventory_2_outlined,
                              iconBackground: AppColors.primaryGradient,
                              title: '个人资产',
                              subtitle: '装备清单管理',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const GearAssetsPage()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.receipt_long,
                              iconBackground: AppColors.secondaryGradient,
                              title: '车票记录',
                              subtitle: '交通出行历史',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TicketPage()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.pie_chart_outline,
                              iconBackground: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
                              ),
                              title: '消费分析',
                              subtitle: '支出统计报告',
                              onTap: _showComingSoon,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.settings_outlined,
                              iconBackground: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)],
                              ),
                              title: '设置选项',
                              subtitle: '账户与偏好设置',
                              onTap: _showComingSoon,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 最近记录
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '最近记录',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: AppFontSizes.subtitle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: AppBorderRadius.extraLarge,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: AppBorderRadius.large,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '03',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppFontSizes.subtitle,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '15',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppFontSizes.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          '华山西峰徒步',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppFontSizes.bodyLarge,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '¥680',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppFontSizes.bodyLarge,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _ProfileStatItem extends StatelessWidget {
  const _ProfileStatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppFontSizes.titleLarge,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: AppFontSizes.body,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Gradient iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.large,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: AppBorderRadius.large,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: iconBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppFontSizes.bodyLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: AppFontSizes.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
