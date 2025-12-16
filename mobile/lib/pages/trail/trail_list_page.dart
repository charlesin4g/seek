import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../utils/responsive.dart';
import 'trail_detail_page.dart';
import 'trail_trip.dart';

class TrailListPage extends StatelessWidget {
  const TrailListPage({super.key});

  static const List<TrailTrip> _trips = [
    TrailTrip(
      id: 'alpine-summit',
      title: 'Alpine Summit Hike',
      location: 'Swiss Alps',
      dateLabel: 'Oct 12, 2024',
      durationText: '4h 30m',
      distanceText: '12.5 km',
      photosText: '12 Photos',
      description:
          'An unforgettable journey through the heart of the Alps. We started at dawn to catch the sunrise over the peaks. The trail was challenging but the views were absolutely worth every step.',
      coverImageUrl:
          'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg?auto=compress&cs=tinysrgb&w=800',
      galleryImageUrls: [
        'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/2252039/pexels-photo-2252039.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/2252039/pexels-photo-2252039.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/2252039/pexels-photo-2252039.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/2252039/pexels-photo-2252039.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/2252039/pexels-photo-2252039.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/2252039/pexels-photo-2252039.jpeg?auto=compress&cs=tinysrgb&w=800',
      ],
    ),
    TrailTrip(
      id: 'misty-forest',
      title: 'Misty Forest Trail',
      location: 'Black Forest',
      dateLabel: 'Nov 05, 2024',
      durationText: '2h 15m',
      distanceText: '8.2 km',
      photosText: '12 Photos',
      description:
          'A tranquil walk among towering pines and soft moss paths. Light fog rolled through the forest, making every beam of sunlight feel magical.',
      coverImageUrl:
          'https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=800',
      galleryImageUrls: [
        'https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/167684/pexels-photo-167684.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/167684/pexels-photo-167684.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/167684/pexels-photo-167684.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/167684/pexels-photo-167684.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/167684/pexels-photo-167684.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/167684/pexels-photo-167684.jpeg?auto=compress&cs=tinysrgb&w=800',
      ],
    ),
    TrailTrip(
      id: 'coastal-cliff',
      title: 'Coastal Cliff Walk',
      location: 'Dover Coast',
      dateLabel: 'Sep 20, 2024',
      durationText: '3h 00m',
      distanceText: '10.0 km',
      photosText: '12 Photos',
      description:
          'A breezy coastal walk along dramatic white cliffs and turquoise waters. Perfect mix of ocean views, sea breeze and gentle ascents.',
      coverImageUrl:
          'https://images.pexels.com/photos/210205/pexels-photo-210205.jpeg?auto=compress&cs=tinysrgb&w=800',
      galleryImageUrls: [
        'https://images.pexels.com/photos/210205/pexels-photo-210205.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/462162/pexels-photo-462162.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/210205/pexels-photo-210205.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/462162/pexels-photo-462162.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/210205/pexels-photo-210205.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/462162/pexels-photo-462162.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/210205/pexels-photo-210205.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/462162/pexels-photo-462162.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/210205/pexels-photo-210205.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/462162/pexels-photo-462162.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/210205/pexels-photo-210205.jpeg?auto=compress&cs=tinysrgb&w=800',
        'https://images.pexels.com/photos/462162/pexels-photo-462162.jpeg?auto=compress&cs=tinysrgb&w=800',
      ],
    ),
  ];

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
          child: ListView.builder(
            padding: Responsive.responsivePadding(context),
            itemCount: _trips.length,
            itemBuilder: (context, index) {
              final trip = _trips[index];
              return _TrailCard(trip: trip);
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
