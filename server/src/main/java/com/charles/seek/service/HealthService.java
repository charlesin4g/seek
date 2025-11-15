package com.charles.seek.service;

import java.util.Map;

/**
 * 健康检查业务接口
 *
 * @author SOLO Coding
 * @since 2025-11-14
 */
public interface HealthService {

    /**
     * 聚合健康检查：数据库、磁盘等
     *
     * @return 健康详情 map，含 status、db、disk、timestamp
     * @throws HealthDownException 任一依赖异常时抛出，由全局处理器转 503
     */
    Map<String, Object> check() throws HealthDownException;
}