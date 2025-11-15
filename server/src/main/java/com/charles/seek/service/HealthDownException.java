package com.charles.seek.service;

/**
 * 健康检查未通过时抛出，由全局异常处理器统一转 503
 *
 * @author SOLO Coding
 * @since 2025-11-14
 */
public class HealthDownException extends RuntimeException {

    private final Object detail;

    public HealthDownException(Object detail) {
        super("Health check failed");
        this.detail = detail;
    }

    public Object getDetail() {
        return detail;
    }
}