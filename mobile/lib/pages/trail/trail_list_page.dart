import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../utils/responsive.dart';
import '../../services/repository/trail_repository.dart';
import 'trail_detail_page.dart';
import 'trail_trip.dart';

class TrailListPage extends StatelessWidget {
  const TrailListPage({super.key});


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
          title: const Text('足迹'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: FutureBuilder<List<TrailTrip>>(
            future: TrailRepository.instance.getAllTrips(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final trips = snapshot.data ?? const <TrailTrip>[];
              if (trips.isEmpty) {
                return const Center(
                  child: Text(
                    '暂无足迹，先去添加一条吧',
                    style: TextStyle(
                      fontSize: AppFontSizes.body,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: Responsive.responsivePadding(context),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return _TrailCard(trip: trip);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TrailCard extends StatelessWidget {
  const _TrailCard({required this.trip});

  final TrailTrip trip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TrailDetailPage(trip: trip)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [AppShadows.light],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(),
              _buildStatsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Hero(
      tag: 'trail-cover-${trip.id}',
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              trip.coverImageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                trip.dateLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.title,
                  style: const TextStyle(
                    fontSize: AppFontSizes.title,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place, size: 16, color: AppColors.textWhite),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        trip.location,
                        style: const TextStyle(
                          fontSize: AppFontSizes.body,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TrailStat(icon: Icons.access_time, label: trip.durationText),
          _TrailStat(icon: Icons.directions_walk, label: trip.distanceText),
          _TrailStat(icon: Icons.photo_library_outlined, label: trip.photosText),
        ],
      ),
    );
  }
}

class _TrailStat extends StatelessWidget {
  const _TrailStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.brightness_1, size: 0), // layout placeholder
        Icon(icon, size: 18, color: AppColors.primaryDarkBlue),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
