package com.charles.seek.dto.rustfs;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class PresignUploadResponse {

    /** 预签名 PUT URL，客户端直接向该地址上传文件 */
    private final String uploadUrl;

    /** 客户端在上传时应携带的 Content-Type（可选） */
    private final String contentType;
}
