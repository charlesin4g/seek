/// 阿里云 OSS 配置文件（代码内静态配置，不依赖启动参数）
///
/// 使用说明：直接编辑本文件设置你的 OSS 参数，前端会通过
/// OssService 读取这些配置来拼接资源 URL。
class OssConfig {
  /// 是否启用 OSS 资源引入（为 false 时直接使用后端返回值）
  static const bool enabled = true;

  /// OSS 访问域名（例如：oss-cn-shanghai.aliyuncs.com）
  static const String endpoint = 'oss-cn-hangzhou.aliyuncs.com';

  /// OSS Bucket 名称（例如：my-bucket），为空则不拼接 bucket 子域
  static const String bucket = 'seek-bucket';

  /// 可选：自定义 CDN 域名（例如：cdn.example.com），优先使用该域名
  static const String publicDomain = '';

  /// 可选：资源统一的路径前缀（例如：seek/ 或 images/）
  static const String prefix = '';

  /// 可选：图片处理样式参数（例如：x-oss-process=image/resize,w_256）
  static const String imageStyle = '';

  /// 访问凭证（注意：前端存储敏感凭证存在安全风险，建议改为后端签名或 STS）
  /// AccessKeyId 与 AccessKeySecret 用于生成查询签名访问私有资源
  static const String accessKeyId = '';
  static const String accessKeySecret = '';

  /// 可选：STS 临时凭证的 security token（若使用 STS）
  static const String securityToken = '';

  /// 默认签名有效期（秒），用于生成私有资源的临时访问 URL
  static const int defaultExpirySeconds = 300;
}