# 同步协议规范

## 目标
- 增量同步，支持断点续传；
- 压缩与加密传输；
- 状态报告与错误处理；

## 增量拉取/推送
- 客户端维护 `_lastSyncedLogId`；
- 推送：按 `id > lastId` 逐条推送；
- 失败重试：指数退避；

## 断点续传
- 每次成功推送后更新 `_lastSyncedLogId`；
- 崩溃恢复后继续从最新位置推送；

## 压缩与加密
- 压缩：`Content-Encoding: gzip`；
- 加密：可选 AES 层（需与后端协商）；

## 冲突解决
- 默认策略：最后修改优先（以 `updatedAt` 或日志顺序为准）；
- 手动合并：冲突条目返回客户端，用户选择保留/合并；

## 状态报告
- `SyncService.statusStream` 输出：`state/progress/count/message`；
- UI 可订阅显示进度或错误信息；