import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../utils/responsive.dart';
import 'trail_trip.dart';

class TrailDetailPage extends StatelessWidget {
  const TrailDetailPage({super.key, required this.trip});

  final TrailTrip trip;

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
            child: Column(
              children: [
                _buildHeroHeader(context),
                const SizedBox(height: 16),
                _buildMainCard(context),
                const SizedBox(height: 16),
                _buildGallerySection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'trail-cover-${trip.id}',
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                trip.coverImageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.backgroundWhite.withValues(alpha: 0.9),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -32),
      child: Padding(
        padding: Responsive.responsivePadding(context).copyWith(top: 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: AppBorderRadius.extraLarge,
            boxShadow: const [AppShadows.light],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.title,
                          style: const TextStyle(
                            fontSize: AppFontSizes.titleLarge,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.place, size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                trip.location,
                                style: const TextStyle(
                                  fontSize: AppFontSizes.body,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightBlue,
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
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    icon: Icons.access_time,
                    label: 'DURATION',
                    value: trip.durationText,
                  ),
                  _buildStatItem(
                    icon: Icons.directions_walk,
                    label: 'DISTANCE',
                    value: trip.distanceText,
                  ),
                  _buildStatItem(
                    icon: Icons.photo_library_outlined,
                    label: 'PHOTOS',
                    value: trip.photosText,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.divider),
              const SizedBox(height: 16),
              const Text(
                'About this trip',
                style: TextStyle(
                  fontSize: AppFontSizes.subtitle,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trip.description,
                style: const TextStyle(
                  fontSize: AppFontSizes.body,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryDarkBlue),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: AppFontSizes.body,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGallerySection(BuildContext context) {
    final int totalCount = trip.galleryImageUrls.length;
    if (totalCount == 0) {
      return const SizedBox.shrink();
    }

    const int maxVisibleItems = 4;
    final int visibleCount = totalCount <= maxVisibleItems ? totalCount : maxVisibleItems;

    return Padding(
      padding: Responsive.responsivePadding(context).copyWith(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gallery',
            style: TextStyle(
              fontSize: AppFontSizes.subtitle,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 4 / 3,
            ),
            itemCount: visibleCount,
            itemBuilder: (context, index) {
              final bool isLastVisibleItem = index == visibleCount - 1;
              final bool hasMoreItems = totalCount > maxVisibleItems;

              void openGallery() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _FullScreenGalleryPage(
                      images: trip.galleryImageUrls,
                      initialIndex: index,
                    ),
                  ),
                );
              }

              if (hasMoreItems && isLastVisibleItem) {
                final int remainingCount = totalCount - maxVisibleItems;

                return GestureDetector(
                  onTap: openGallery,
                  child: ClipRRect(
                    borderRadius: AppBorderRadius.large,
                    child: Container(
                      color: Colors.black87,
                      alignment: Alignment.center,
                      child: Text(
                        '+$remainingCount more',
                        style: const TextStyle(
                          fontSize: AppFontSizes.subtitle,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final String url = trip.galleryImageUrls[index];
              return GestureDetector(
                onTap: openGallery,
                child: ClipRRect(
                  borderRadius: AppBorderRadius.large,
                  child: Image.network(url, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FullScreenGalleryPage extends StatefulWidget {
  const _FullScreenGalleryPage({
    required this.images,
    this.initialIndex = 0,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<_FullScreenGalleryPage> createState() => _FullScreenGalleryPageState();
}

class _FullScreenGalleryPageState extends State<_FullScreenGalleryPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    int initialIndex = widget.initialIndex;
    if (initialIndex < 0) {
      initialIndex = 0;
    }
    if (widget.images.isNotEmpty && initialIndex >= widget.images.length) {
      initialIndex = widget.images.length - 1;
    }
    _currentIndex = initialIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalCount = widget.images.length;

    if (totalCount == 0) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'No photos',
            style: TextStyle(
              fontSize: AppFontSizes.subtitle,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${_currentIndex + 1} / $totalCount',
          style: const TextStyle(
            fontSize: AppFontSizes.subtitle,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: totalCount,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final String url = widget.images[index];
          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                url,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
