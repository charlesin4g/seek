import 'package:flutter/material.dart';
import '../services/offline_mode.dart';
import '../services/sync_service.dart';

/// 统一的离线模式切换提示
///
/// 用途：当接口调用失败时，提示用户切换到离线模式继续操作。
Future<void> showOfflineSwitchPrompt(BuildContext context) async {
  // 弹窗文案与动作：切换到离线或取消
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('网络不可用或接口调用失败'),
      content: const Text('是否切换到离线模式以继续本地操作？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () async {
            // 切换到离线模式，切换前执行一致性检查（此处 toOffline=true，直接通过）
            await SyncService.instance.ensureConsistencyBeforeSwitch(toOffline: true);
            await OfflineModeManager.instance.setOffline(true);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已切换到离线模式'), backgroundColor: Colors.blue),
              );
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text('切换到离线模式'),
        ),
      ],
    ),
  );
}