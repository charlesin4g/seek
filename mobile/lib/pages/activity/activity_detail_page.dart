import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../utils/responsive.dart';
import '../../services/repository/activity_repository.dart';
// 条件导入上传助手：Web 使用 dart:html 实现，IO 平台使用 image_picker 实现
import '../../utils/upload_helper_stub.dart'
    if (dart.library.html) '../../utils/upload_helper_web.dart'
    if (dart.library.io) '../../utils/upload_helper_mobile.dart';
// 条件导入本地图片存储服务：IO 平台使用文件系统实现
import '../../services/local_image_storage_stub.dart'
    if (dart.library.io) '../../services/local_image_storage_mobile.dart';
import 'activity_trip.dart';

class ActivityDetailPage extends StatefulWidget {
  const ActivityDetailPage({super.key, required this.trip});

  final ActivityTrip trip;

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  late ActivityTrip _trip;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _refreshFromDb();
  }

  Future<void> _refreshFromDb() async {
    try {
      final ActivityTrip? refreshed =
          await ActivityRepository.instance.getActivityById(_trip.id);
      if (!mounted) return;
      if (refreshed == null) return;
      setState(() {
        _trip = refreshed;
      });
    } catch (e, st) {
      if (!kReleaseMode) {
        debugPrint('ActivityDetailPage._refreshFromDb failed: $e');
        debugPrint(st.toString());
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

  /// 选择图片并保存到本地设备（当前版本仅在 IO 平台生效）
  Future<void> _uploadActivityImage() async {
    try {
      final helper = UploadHelper();
      final Uint8List? bytes = await helper.pickImageBytes();
      if (bytes == null || bytes.isEmpty) return;

      setState(() {
        _uploading = true;
      });

      // 保存到本地活动图片目录
      final storage = const LocalImageStorage();
      final String filePath = await storage.saveTrailActivityImage(
        activityId: _trip.id,
        bytes: bytes,
      );

      await ActivityRepository.instance.appendActivityImage(
        activityId: _trip.id,
        imageUrl: filePath,
        setAsStar: _trip.galleryImageUrls.isEmpty,
      );

      final ActivityTrip? refreshed =
          await ActivityRepository.instance.getActivityById(_trip.id);
      if (!mounted) return;
      setState(() {
        _trip = refreshed ?? _trip;
        _uploading = false;
      });


    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    }
  }

  // 长按图片
  Future<void> _onImageLongPress(String imageUrl) async {
    final String? action = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text('设为星标'),
                onTap: () => Navigator.of(context).pop('star'),
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  '删除照片',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.of(context).pop('delete'),
              ),
            ],
          ),
        );
      },
    );

    if (action == null) {
      return;
    }

    if (action == 'star') {
      try {
        await ActivityRepository.instance.appendActivityImage(
          activityId: _trip.id,
          imageUrl: imageUrl,
          setAsStar: true,
        );
        final ActivityTrip? refreshed =
            await ActivityRepository.instance.getActivityById(_trip.id);
        if (!mounted) return;
        setState(() {
          _trip = refreshed ?? _trip;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已设为星标图片')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('设置星标失败: $e')),
        );
      }
    } else if (action == 'delete') {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除这张照片吗？此操作不可恢复。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  '删除',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        await _deleteActivityImage(imageUrl);
      }
    }
  }

  Future<void> _deleteActivityImage(String imageUrl) async {
    try {
      // 删除本地文件（如果是本地路径）
      try {
        final storage = const LocalImageStorage();
        await storage.deleteLocalImageIfExists(imageUrl);
      } catch (e) {
        if (!kReleaseMode) {
          debugPrint('删除本地图片失败: $e');
        }
      }

      await ActivityRepository.instance.deleteActivityImage(
        activityId: _trip.id,
        imageUrl: imageUrl,
      );

      final ActivityTrip? refreshed =
          await ActivityRepository.instance.getActivityById(_trip.id);
      if (!mounted) return;
      setState(() {
        _trip = refreshed ?? _trip;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已删除照片')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除照片失败: $e')),
      );
    }
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'activity-cover-${_trip.id}',
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: _buildImageWidget(
                  _trip.starImageUrl ?? _trip.coverImageUrl,
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
                          _trip.title,
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
                                _trip.location,
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
                      _trip.dateLabel,
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
                    label: '耗时',
                    value: _trip.durationText,
                  ),
                  _buildStatItem(
                    icon: Icons.directions_walk,
                    label: '距离',
                    value: _trip.distanceText,
                  ),
                  _buildStatItem(
                    icon: Icons.photo_library_outlined,
                    label: '照片',
                    value: _trip.photosText,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    icon: Icons.terrain,
                    label: '爬升',
                    value: _formatMeters(_trip.elevationGain),
                  ),
                  _buildStatItem(
                    icon: Icons.terrain,
                    label: '下降',
                    value: _formatMeters(_trip.elevationLoss),
                  ),
                  _buildStatItem(
                    icon: Icons.terrain,
                    label: '最高',
                    value:  _formatNullableMeters(_trip.maxElevation),
                  ),
                ],
              ),
              //_buildMetricsModules(),
              const SizedBox(height: 16),
              Divider(color: AppColors.divider),
              const SizedBox(height: 16),
              const Text(
                '活动详情',
                style: TextStyle(
                  fontSize: AppFontSizes.subtitle,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _trip.description,
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
  return Expanded(                     // 让三列宽度相等
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
      mainAxisSize: MainAxisSize.min,
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
    ),
  );
}

  String _formatMeters(double meters) {
    return '${meters.toStringAsFixed(0)} m';
  }

  String _formatNullableMeters(double? meters) {
    if (meters == null) return '-';
    return '${meters.toStringAsFixed(0)} m';
  }

  Widget _buildGallerySection(BuildContext context) {
    final int totalCount = _trip.galleryImageUrls.length;

    const int maxVisibleItems = 10;
    final int visibleCount = totalCount <= maxVisibleItems ? totalCount : maxVisibleItems;

    return Padding(
      padding: Responsive.responsivePadding(context).copyWith(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gallery',
                style: TextStyle(
                  fontSize: AppFontSizes.subtitle,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: _uploading ? null : _uploadActivityImage,
                icon: _uploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined, size: 18),
                label: const Text(
                  '上传图片',
                  style: TextStyle(
                    fontSize: AppFontSizes.body,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (totalCount == 0)
            const Text(
              '暂无图片，点击右上角按钮上传',
              style: TextStyle(
                fontSize: AppFontSizes.body,
                color: AppColors.textSecondary,
              ),
            )
          else
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
                      images: _trip.galleryImageUrls,
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

              final String url = _trip.galleryImageUrls[index];
              final bool isStar = _trip.starImageUrl != null &&
                  _trip.starImageUrl!.isNotEmpty &&
                  _trip.starImageUrl == url;
              return GestureDetector(
                onTap: openGallery,
                onLongPress: () => _onImageLongPress(url),
                child: ClipRRect(
                  borderRadius: AppBorderRadius.large,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _buildImageWidget(url),
                      ),
                      if (isStar)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildImageWidget(String path, {BoxFit fit = BoxFit.cover}) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(path, fit: fit);
  }
  if (path.startsWith('/')) {
    return Image.file(
      File(path),
      fit: fit,
    );
  }
  // 其他情况按 asset 资源处理
  return Image.asset(path, fit: fit);
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
              child: _buildImageWidget(url, fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}
