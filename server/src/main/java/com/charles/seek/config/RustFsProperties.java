package com.charles.seek.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Getter
@Setter
@Component
@ConfigurationProperties(prefix = "rustfs")
public class RustFsProperties {

    /** 是否启用 RustFS 上传（关闭后接口将返回 503） */
    private boolean enabled = true;

    /** RustFS HTTP Endpoint，例如 http://172.16.115.42:9000 */
    private String endpoint;

    /** S3 兼容的 Region，RustFS 没有强制要求时可以用任意非空字符串，例如 "us-east-1" */
    private String region = "us-east-1";

    /** 访问 Key（仅在服务端保存，不下发到客户端） */
    private String accessKey;

    /** 访问 Secret（仅在服务端保存，不下发到客户端） */
    private String secretKey;

    /** 默认 Bucket 名称，例如 seek-activity-images */
    private String bucket;
}
