package com.charles.seek.service;

import com.charles.seek.config.RustFsProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Configuration;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;

import java.net.URI;
import java.time.Duration;

@Service
@RequiredArgsConstructor
public class RustFsService {

    private final RustFsProperties properties;

    /**
     * 为指定对象 key 生成预签名 PUT URL。
     * 客户端可以在有效期内使用该 URL 直接向 RustFS 上传文件。
     */
    public String generatePresignedPutUrl(String objectKey, Duration ttl) {
        if (!properties.isEnabled()) {
            throw new IllegalStateException("RustFS is disabled");
        }

        AwsBasicCredentials credentials = AwsBasicCredentials.create(
                properties.getAccessKey(),
                properties.getSecretKey()
        );

        S3Configuration s3Configuration = S3Configuration.builder()
                .pathStyleAccessEnabled(true) // http://host:9000/bucket/object 这种路径风格
                .build();

        try (S3Presigner presigner = S3Presigner.builder()
                .credentialsProvider(StaticCredentialsProvider.create(credentials))
                .region(Region.of(properties.getRegion()))
                .endpointOverride(URI.create(properties.getEndpoint()))
                .serviceConfiguration(s3Configuration)
                .build()) {

            PutObjectPresignRequest presignRequest = PutObjectPresignRequest.builder()
                    .signatureDuration(ttl)
                    .putObjectRequest(builder -> builder
                            .bucket(properties.getBucket())
                            .key(objectKey)
                    )
                    .build();

            PresignedPutObjectRequest presigned = presigner.presignPutObject(presignRequest);
            return presigned.url().toString();
        }
    }
}
