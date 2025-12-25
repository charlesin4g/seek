# 双版本架构设计（在线/离线）

## 架构目标
- 保持在线版本与现有后端 API 100% 兼容；
- 离线版本提供本地等效实现（SQLite/SQLCipher），支持事务与加密；
- 同步机制支持增量、断点续传与冲突解决；

## 模块划分
- 在线服务：`HttpClient.shared` 管理 baseUrl/Headers；
- 模式管理：`OfflineModeManager` 提供在线/离线切换与状态；
- 本地存储：`LocalDatabase`（SQLite/SQLCipher）统一初始化与事务；
- 离线仓储：`TicketRepository`、`StationRepository` 等等；
- 同步服务：`SyncService` 增量同步/断点续传/冲突策略；
- UI：个人信息页提供模式指示与切换控件；

## 数据流
1. 离线模式：Controller 调用 Service → Repository → LocalDatabase；
2. 在线模式：Controller 调用 Service → HttpClient → 后端

## 事务与加密
- 使用 SQLCipher 提供数据库文件级加密；
- `LocalDatabase.runInTransaction` 封装事务；

## 冲突策略
- 默认“最后修改优先”；
- 可扩展“手动合并”：将冲突条目下发到客户端 UI 进行交互处理；