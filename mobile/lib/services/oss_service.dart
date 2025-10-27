import '../config/oss_config.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 阿里云 OSS 资源 URL 解析与构造工具
///
/// 用途：
/// - 当后端返回的是资源 key（如：avatar/abc.png），前端通过本工具拼接为完整可访问的 URL；
/// - 当后端直接返回完整 URL（http/https），本工具会原样返回；
/// - 可选追加统一前缀（OssConfig.prefix）与图片处理样式（OssConfig.imageStyle）。
class OssService {
  /// 判断字符串是否为完整的 http/https URL
  bool _isAbsoluteUrl(String s) {
    return s.startsWith('http://') || s.startsWith('https://');
  }

  /// 获取 OSS 访问基础域名
  /// 优先使用自定义 CDN 域名，其次使用 bucket.endpoint，最后仅 endpoint
  String _baseDomain() {
    if (OssConfig.publicDomain.isNotEmpty) {
      return 'https://${OssConfig.publicDomain}';
    }
    if (OssConfig.bucket.isNotEmpty) {
      return 'https://${OssConfig.bucket}.${OssConfig.endpoint}';
    }
    return 'https://${OssConfig.endpoint}';
  }

  /// 拼接路径，确保只有一个斜杠分隔
  String _joinPath(String a, String b) {
    final aTrim = a.endsWith('/') ? a.substring(0, a.length - 1) : a;
    final bTrim = b.startsWith('/') ? b.substring(1) : b;
    return '$aTrim/$bTrim';
  }

  /// 构造 CanonicalizedResource（用于签名）：必须包含 /bucket/object
  String _canonicalizedResource(String objectKeyWithPrefix) {
    final bucket = OssConfig.bucket;
    final obj = objectKeyWithPrefix.startsWith('/')
        ? objectKeyWithPrefix.substring(1)
        : objectKeyWithPrefix;
    return '/$bucket/$obj';
  }

  /// 解析资源的完整 URL
  ///
  /// - `keyOrUrl`: 后端返回的资源字段，可能是完整 URL 或相对 key
  /// - `style`: 可选图片处理样式（若不传则使用 OssConfig.imageStyle）
  /// 返回：完整的可访问 URL；若传入为空则返回 null
  String? resolveUrl(String? keyOrUrl, {String? style}) {
    if (keyOrUrl == null) return null;
    final v = keyOrUrl.trim();
    if (v.isEmpty) return null;

    // 已是绝对 URL，直接返回
    if (_isAbsoluteUrl(v)) {
      return v;
    }

    if (!OssConfig.enabled) {
      // 未启用 OSS，引入资源按相对路径处理（保留原值）
      return v;
    }

    // 计算基础域名
    var base = _baseDomain();
    // 追加统一前缀（如：seek/ 或 images/）
    if (OssConfig.prefix.isNotEmpty) {
      base = _joinPath(base, OssConfig.prefix);
    }

    // 拼接完整路径
    final url = _joinPath(base, v);

    // 追加图片处理样式（若提供）
    final effectiveStyle = (style != null && style.isNotEmpty)
        ? style
        : OssConfig.imageStyle;
    if (effectiveStyle.isNotEmpty) {
      // 若已有查询参数，追加方式需兼容，这里简单处理为追加 '&' 或 '?'。
      final hasQuery = url.contains('?');
      final sep = hasQuery ? '&' : '?';
      return '$url$sep$effectiveStyle';
    }

    return url;
  }

  /// 生成查询签名（Query String Authentication）访问私有对象的 URL
  /// 参考：https://help.aliyun.com/zh/oss/developer-reference/signature-for-oss
  ///
  /// 注意：前端持有 AccessKeySecret 存在高风险，建议采用后端签名或 STS 临时凭证。
  String? _generateSignedUrlForGet(String objectKey, {int? expiresSeconds}) {
    if (OssConfig.accessKeyId.isEmpty || OssConfig.accessKeySecret.isEmpty) {
      return null;
    }
    if (OssConfig.bucket.isEmpty) {
      return null; // 无 bucket 无法进行签名
    }

    final base = 'https://${OssConfig.bucket}.${OssConfig.endpoint}';
    final keyWithPrefix = OssConfig.prefix.isNotEmpty
        ? _joinPath('', _joinPath(OssConfig.prefix, objectKey)).substring(1)
        : objectKey;

    // 过期时间（秒级时间戳）
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expires = nowSec + (expiresSeconds ?? OssConfig.defaultExpirySeconds);

    // StringToSign 格式
    final stringToSign = [
      'GET',
      '', // Content-MD5
      '', // Content-Type
      expires.toString(),
      _canonicalizedResource(keyWithPrefix),
    ].join('\n');

    // HMAC-SHA1 签名并 base64 编码
    final hmacSha1 = Hmac(sha1, utf8.encode(OssConfig.accessKeySecret));
    final digest = hmacSha1.convert(utf8.encode(stringToSign));
    final signature = base64Encode(digest.bytes);

    // 构造最终 URL 与查询参数
    final objectUrl = _joinPath(base, keyWithPrefix);
    final params = <String, String>{
      'OSSAccessKeyId': OssConfig.accessKeyId,
      'Expires': expires.toString(),
      'Signature': signature,
    };
    if (OssConfig.securityToken.isNotEmpty) {
      params['x-oss-security-token'] = OssConfig.securityToken;
    }

    final query = params.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');

    return '$objectUrl?$query';
  }

  /// 解析私有资源的临时访问 URL（若配置了 access key 则生成签名）
  ///
  /// 当传入为完整 URL 时直接返回；当为资源 key 时：
  /// - 若配置了 access key 且 bucket 存在，则生成签名 URL；
  /// - 否则回退到 `resolveUrl` 的公共拼接逻辑。
  String? resolvePrivateUrl(String? keyOrUrl, {int? expiresSeconds, String? style}) {
    if (keyOrUrl == null) return null;
    final v = keyOrUrl.trim();
    if (v.isEmpty) return null;
    if (_isAbsoluteUrl(v)) {
      return v; // 已是完整 URL
    }
    // 优先尝试签名访问
    final signed = _generateSignedUrlForGet(v, expiresSeconds: expiresSeconds);
    if (signed != null) {
      // 若配置了图片样式，追加查询参数
      final effectiveStyle = (style != null && style.isNotEmpty)
          ? style
          : OssConfig.imageStyle;
      if (effectiveStyle.isNotEmpty) {
        final sep = signed.contains('?') ? '&' : '?';
        return '$signed$sep$effectiveStyle';
      }
      return signed;
    }
    // 未配置签名或无法签名，回退公共 URL
    return resolveUrl(v, style: style);
  }
}