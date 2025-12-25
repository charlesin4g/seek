/// RustFS 对象存储配置
///
/// 说明：
/// - 为了减少敏感凭证在代码中的暴露，推荐通过 `--dart-define` 注入密钥；
/// - 本文件中的默认 key/secret 仅用于本地开发，请勿在生产环境中使用。
class RustFsConfig {
  RustFsConfig._();

  /// 是否启用 RustFS 客户端
  static const bool enabled = bool.fromEnvironment(
    'RUSTFS_ENABLED',
    defaultValue: true,
  );

  /// RustFS 服务地址，默认指向本地开发环境实例
  static const String endpoint = String.fromEnvironment(
    'RUSTFS_ENDPOINT',
    defaultValue: 'http://172.16.115.42:9000',
  );

  /// RustFS 访问密钥（Access Key）
  ///
  /// 默认值仅用于本地开发，生产环境请务必通过 dart-define 覆盖：
  ///   --dart-define=RUSTFS_ACCESS_KEY=xxxxx
  static const String accessKey = String.fromEnvironment(
    'RUSTFS_ACCESS_KEY',
    defaultValue: 'h2SD7Va1PJXusvGRcTiU',
  );

  /// RustFS 访问密钥（Secret Key）
  ///
  /// 默认值仅用于本地开发，生产环境请务必通过 dart-define 覆盖：
  ///   --dart-define=RUSTFS_SECRET_KEY=xxxxx
  static const String secretKey = String.fromEnvironment(
    'RUSTFS_SECRET_KEY',
    defaultValue: 'S3jEqtCbBUKysaM2fLc5lp1kw6WOxP40JeGgTFvX',
  );

  /// 可选：默认 bucket 名称
  static const String defaultBucket = String.fromEnvironment(
    'RUSTFS_BUCKET',
    defaultValue: 'seek-activity-images',
  );
}
