import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../ticket/ticket_page.dart';
import '../gear/gear_assets_page.dart';
import '../../services/repository/activity_repository.dart';
import '../activity/activity_trip.dart';
import '../activity/activity_detail_page.dart';
import 'settings_page.dart';

class UserOverviewPage extends StatefulWidget {
  const UserOverviewPage({super.key});

  @override
  State<UserOverviewPage> createState() => _UserOverviewPageState();
}

class _UserOverviewPageState extends State<UserOverviewPage> {
  late String _displayName;
  late Future<List<ActivityTrip>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    final cached = StorageService().getCachedUserSync();
    _displayName = (cached?['displayName'] ??
            cached?['username'] ??
            AuthService().currentUser ??
            '旅行者')
        .toString();
    _tripsFuture = ActivityRepository.instance.getActivityTripsPage(limit: 5, offset: 0);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Profile Card
                _ProfileCard(displayName: _displayName),
                const SizedBox(height: 20),

                // Shortcuts Card (Assets & Tickets)
                _ShortcutsCard(
                  onAssetsTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GearAssetsPage()),
                    );
                  },
                  onTicketsTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TicketPage()),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Recent Trips Header
                const Text(
                  '近期行程',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Recent Trips List
                FutureBuilder<List<ActivityTrip>>(
                  future: _tripsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('加载失败: ${snapshot.error}', style: const TextStyle(color: AppColors.error));
                    }
                    final trips = snapshot.data ?? [];
                    if (trips.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            '暂无行程记录',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: trips.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        final dt = trip.activityTime ?? DateTime.now();
                        return _TripItem(
                          month: '${dt.month}月',
                          day: '${dt.day}',
                          title: trip.title,
                          trip: trip,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 40), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String displayName;

  const _ProfileCard({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [AppShadows.medium],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Header: Avatar, Name, Settings
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.person, color: Colors.black, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  displayName.isNotEmpty ? displayName : 'seek user',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Metrics Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('105', '出行次数'),
              _buildStatItem('598', '总里程(km)'),
              _buildStatItem('65476m', '总爬升(m)'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('1255', '运动天数'),
              _buildStatItem('34', '访问城市'),
              _buildStatItem('77543', '总资产(元)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return SizedBox(
      width: 80, // Fixed width for alignment
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutsCard extends StatelessWidget {
  final VoidCallback onAssetsTap;
  final VoidCallback onTicketsTap;

  const _ShortcutsCard({
    required this.onAssetsTap,
    required this.onTicketsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [AppShadows.light],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildShortcutItem(
            Icons.account_balance_wallet_outlined, // Using similar icon
            '我的资产',
            onAssetsTap,
          ),
          const Divider(height: 1, color: AppColors.divider),
          _buildShortcutItem(
            Icons.confirmation_number_outlined, // Ticket icon
            '我的车票',
            onTicketsTap,
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _TripItem extends StatelessWidget {
  final String month;
  final String day;
  final String title;
  final ActivityTrip trip;

  const _TripItem({
    required this.month,
    required this.day,
    required this.title,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ActivityDetailPage(trip: trip)),
        );
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(30), // Pill shape
          boxShadow: const [AppShadows.light],
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            // Date Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    month,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Placeholder Box (or image if available)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_walk, color: AppColors.primaryGreen, size: 24),
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
