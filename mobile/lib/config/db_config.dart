/// 本地数据库相关配置
///
/// 通过修改这里的开关，控制应用启动时是否用打包在 assets 中的
/// `seek_offline.db` 覆盖本地数据库文件。
class DbConfig {
  /// 是否在每次应用启动时重置本地数据库
  ///
  /// - 为 `true` 时：每次启动都会用 `assets/seek_offline.db` 覆盖
  ///   本地 `getDatabasesPath()` 目录下的 `seek_offline.db`，
  ///   等于每次回到打包时的初始状态（本地修改不会保留）。
  /// - 为 `false` 时：仅在本地没有数据库文件时，从 assets 拷贝一次，
  ///   之后保留用户在本地的所有修改。
  static const bool resetDbOnStartup = true;
}
