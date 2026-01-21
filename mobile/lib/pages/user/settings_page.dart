import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/icloud_sync_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _progress = 0.0;
  String _status = '未开始';
  bool _syncing = false;
  StreamSubscription<dynamic>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = IcloudSyncService.instance.statusStream.listen((event) {
      final String state = event['state']?.toString() ?? '';
      if (state == 'progress') {
        final num p = event['progress'] ?? 0;
        setState(() {
          _progress = (p.toDouble()).clamp(0.0, 1.0);
          _status = event['message']?.toString() ?? '同步中';
          _syncing = true;
        });
      } else if (state == 'success') {
        setState(() {
          _progress = 1.0;
          _status = '同步成功';
          _syncing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('同步成功')),
        );
      } else if (state == 'error') {
        setState(() {
          _syncing = false;
          _status = event['message']?.toString() ?? '同步失败';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_status)),
        );
      } else if (state == 'disabled') {
        setState(() {
          _syncing = false;
          _status = 'iCloud不可用';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('iCloud不可用或未登录')),
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _startSync() async {
    if (_syncing) return;
    setState(() {
      _syncing = true;
      _progress = 0.0;
      _status = '准备中';
    });
    try {
      await IcloudSyncService.instance.startFullSync();
    } catch (e) {
      setState(() {
        _syncing = false;
        _status = '启动失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            '设置',
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: AppBorderRadius.extraLarge,
                  boxShadow: const [AppShadows.light],
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'iCloud 同步',
                      style: TextStyle(
                        fontSize: AppFontSizes.subtitle,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _syncing ? _progress : null,
                      backgroundColor: AppColors.borderLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _status,
                          style: const TextStyle(
                            fontSize: AppFontSizes.body,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${(_progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: AppFontSizes.body,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.large),
                        ),
                        onPressed: _syncing ? null : _startSync,
                        child: const Text('同步到iCloud'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

