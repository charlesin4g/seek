# mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Aliyun OSS 资源引入配置（代码内配置文件方式）

前端通过 `OssService` 解析/拼接资源 URL，实现从阿里云 OSS 引入头像、背景图等资源。

不使用启动参数重配置。请编辑配置文件：`lib/config/oss_config.dart`。

### 配置文件位置与示例

- 路径：`mobile/lib/config/oss_config.dart`
- 示例内容：

```dart
class OssConfig {
  static const bool enabled = true; // 是否启用 OSS 资源引入
  static const String endpoint = 'oss-cn-shanghai.aliyuncs.com'; // OSS 访问域名
  static const String bucket = ''; // Bucket 名称（可留空）
  static const String publicDomain = ''; // 自定义 CDN 域名（可选）
  static const String prefix = ''; // 统一资源前缀（可选）
  static const String imageStyle = ''; // 图片样式处理（可选）
}
```

### 使用说明

- 后端若返回资源 key（如 `avatar/abc.png`），`OssService.resolveUrl(key)` 会拼接为完整 URL：
  - 优先 `https://{publicDomain}/{prefix}/{key}`（当配置了 `publicDomain`）
  - 其次 `https://{bucket}.{endpoint}/{prefix}/{key}`（当配置了 `bucket`）
  - 其后 `https://{endpoint}/{prefix}/{key}`
- 若后端已返回完整 `http(s)` URL，`OssService` 原样返回。
- 若配置了 `imageStyle`，将以查询参数形式追加（自动处理 `?` 或 `&`）。

### 私有访问与签名（不允许外部访问）

当 OSS 资源设置为私有（禁止外部直接访问），可通过在 `oss_config.dart` 中配置访问密钥，前端生成临时签名 URL（仅示例用途）。

强烈建议：生产环境使用后端生成签名或 STS 临时凭证，避免在前端存储 `AccessKeySecret`。

#### 配置示例（私有访问字段）

```dart
class OssConfig {
  // ... 基础配置同上
  static const String accessKeyId = '';
  static const String accessKeySecret = '';
  static const String securityToken = ''; // 若使用 STS，可填写临时 token
  static const int defaultExpirySeconds = 300; // 默认签名有效期（秒）
}
```

#### 使用签名 URL 访问私有对象

- 当后端返回对象 key（如 `avatar/abc.png`），使用：
  - `OssService().resolvePrivateUrl(key)` 生成 `GET` 临时签名 URL。
- 当已返回完整 `http(s)` URL（例如后端已生成签名），前端原样使用。

#### 安全提示

- 前端存储 `AccessKeySecret` 存在泄漏风险，适用于演示或本地环境；生产环境请改为：
  - 后端生成签名 URL 返回给前端；或
  - 前端从后端获取 STS 临时凭证，仅持有 `AccessKeyId` 与 `SecurityToken`。
