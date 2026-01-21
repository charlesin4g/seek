import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_colors.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 全屏地图
          FlutterMap(
            options: MapOptions(
              center: LatLng(34.2345, 108.9313), // 秦岭附近
              zoom: 11,
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.charles.seek.mobile',
                // 使用较暗的底图风格或自定义样式会更好，这里暂时用 OSM
              ),
              // 模拟一条轨迹
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      LatLng(34.2200, 108.9200),
                      LatLng(34.2250, 108.9250),
                      LatLng(34.2300, 108.9300),
                      LatLng(34.2350, 108.9350),
                      LatLng(34.2400, 108.9400),
                    ],
                    color: AppColors.primaryGreen,
                    strokeWidth: 4,
                  ),
                ],
              ),
              // 起终点标记
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(34.2200, 108.9200),
                    width: 40,
                    height: 40,
                    builder: (ctx) => const Icon(Icons.trip_origin, color: AppColors.primaryGreen, size: 30),
                  ),
                  Marker(
                    point: LatLng(34.2400, 108.9400),
                    width: 40,
                    height: 40,
                    builder: (ctx) => const Icon(Icons.location_on, color: AppColors.error, size: 36),
                  ),
                ],
              ),
            ],
          ),

          // 2. 顶部渐变遮罩 + 搜索栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundLight.withOpacity(0.9),
                    AppColors.backgroundLight.withOpacity(0.0),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: AppBorderRadius.extraLarge,
                  boxShadow: [AppShadows.medium],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '搜索地点、路线...',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: AppFontSizes.body,
                        ),
                      ),
                    ),
                    const Icon(Icons.mic_none, color: AppColors.primaryGreen),
                  ],
                ),
              ),
            ),
          ),

          // 3. 右侧功能按钮
          Positioned(
            right: 16,
            bottom: 120, // 给底部导航栏留出空间
            child: Column(
              children: [
                _buildMapButton(Icons.layers_outlined, () {}),
                const SizedBox(height: 12),
                _buildMapButton(Icons.my_location, () {}),
                const SizedBox(height: 12),
                _buildMapButton(Icons.add, () {}),
                const SizedBox(height: 12),
                _buildMapButton(Icons.remove, () {}),
              ],
            ),
          ),
          
          // 4. 底部浮动卡片 (模拟轨迹记录状态)
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: AppBorderRadius.extraLarge,
                boxShadow: [AppShadows.dark],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '开始记录轨迹',
                        style: TextStyle(
                          fontSize: AppFontSizes.title,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '记录你的每一步精彩',
                        style: TextStyle(
                          fontSize: AppFontSizes.body,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppShadows.light],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary, size: 22),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
