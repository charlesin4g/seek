import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../utils/responsive.dart';
import '../../services/repository/activity_repository.dart';
import 'activity_detail_page.dart';
import 'activity_trip.dart';

class ActivityListPage extends StatefulWidget {
  const ActivityListPage({super.key});

  @override
  State<ActivityListPage> createState() => _ActivityListPageState();
}

class _ActivityListPageState extends State<ActivityListPage> {
  static const int _pageSize = 5;

  final List<ActivityTrip> _trips = <ActivityTrip>[];
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<ActivityTrip>? _tripUpdatesSub;

  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);

    _tripUpdatesSub = ActivityRepository.instance.tripUpdates.listen((trip) {
      if (!mounted) return;
      final int index = _trips.indexWhere((e) => e.id == trip.id);
      if (index == -1) return;
      setState(() {
        _trips[index] = trip;
      });
    });
  }

  @override
  void dispose() {
    _tripUpdatesSub?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoadingInitial = true;
      _trips.clear();
      _offset = 0;
      _hasMore = true;
    });
    await _loadMore();
    if (!mounted) return;
    setState(() {
      _isLoadingInitial = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) {
      return;
    }
    setState(() {
      _isLoadingMore = true;
    });
      try {
      final List<ActivityTrip> page = await ActivityRepository.instance.getActivityTripsPage(
        limit: _pageSize,
        offset: _offset,
      );

      if (!mounted) return;
      setState(() {
        _trips.addAll(page);
        _offset += page.length;
        _hasMore = page.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _hasMore = false;
      });
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
          title: const Text('活动'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_trips.isEmpty) {
      return const Center(
        child: Text(
          '暂无活动，先去添加一条吧',
          style: TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: Responsive.responsivePadding(context),
      itemCount: _hasMore ? _trips.length + 1 : _trips.length,
      itemBuilder: (context, index) {
        if (index >= _trips.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: _isLoadingMore
                  ? const CircularProgressIndicator()
                  : const Text(
                      '没有更多活动了',
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
          );
        }

        final ActivityTrip trip = _trips[index];
        return _ActivityCard(trip: trip);
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.trip});

  final ActivityTrip trip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ActivityDetailPage(trip: trip)),

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
    final String coverPath = trip.starImageUrl ?? trip.coverImageUrl;
    return Hero(
      tag: 'activity-cover-${trip.id}',
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildCoverImage(coverPath),
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
          if (trip.starImageUrl != null && trip.starImageUrl!.isNotEmpty)
            Positioned(
              left: 16,
              top: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      '星标',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
          _ActivityStat(icon: Icons.access_time, label: trip.durationText),
          _ActivityStat(icon: Icons.directions_walk, label: trip.distanceText),
          _ActivityStat(icon: Icons.photo_library_outlined, label: trip.photosText),
        ],
      ),
    );
  }
}

Widget _buildCoverImage(String path) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(path, fit: BoxFit.cover);
  }
  if (path.startsWith('/')) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
    );
  }
  return Image.asset(path, fit: BoxFit.cover);
}

class _ActivityStat extends StatelessWidget {
  const _ActivityStat({required this.icon, required this.label});

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
