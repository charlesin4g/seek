package com.charles.seek.service;

/**
 * OSS 服务接口
 *
 * 说明：
 * - 仅在后端持有 AccessKey 与密钥；
 * - 对外提供生成私有资源 GET 访问的临时签名 URL；
 * - 同时提供解析私有资源完整 URL 的方法（兼容绝对 URL）。
 */
public interface OssService {
    /**
     * 生成 GET 方式的私有访问签名 URL。
     *
     * @param objectKey      对象 key（例如：avatar/abc.png 或 abc.png），不接受绝对 URL
     * @param expiresSeconds 过期秒数，null 则使用默认配置
     * @param style          可选图片样式（例如：x-oss-process=image/resize,w_256），null/空不追加
     * @return 完整的临时签名访问 URL
     */
    String signGetUrl(String objectKey, Integer expiresSeconds, String style);

    /**
     * 生成 PUT 方式的临时签名 URL，用于前端直传。
     *
     * 说明：
     * - 使用 Query String Authentication 生成 PUT 的签名；
     * - 前端可直接对该 URL 进行 HTTP PUT 上传二进制内容；
     * - content-type 不参与签名，可由前端自行设置；
     *
     * @param objectKey      目标对象 key（不接受绝对 URL）
     * @param expiresSeconds 过期秒数，null 则使用默认配置
     * @return 完整的临时签名上传 URL
     */
    String signPutUrl(String objectKey, Integer expiresSeconds);

    /**
     * 解析私有资源的完整 URL：
     * - 若传入为绝对 URL 则直接返回；
     * - 若为 key 则生成签名 URL；
     *
     * @param keyOrUrl       资源 key 或绝对 URL
     * @param expiresSeconds 过期秒数，null 则使用默认配置
     * @param style          可选图片样式
     * @return 完整 URL
     */
    String resolvePrivateUrl(String keyOrUrl, Integer expiresSeconds, String style);
}