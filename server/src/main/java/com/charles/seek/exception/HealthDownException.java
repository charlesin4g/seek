package com.charles.seek.exception;

/**
 * 健康检查失败异常
 * 当系统健康检查失败时抛出此异常
 */
public class HealthDownException extends RuntimeException {
    
    public HealthDownException(String message) {
        super(message);
    }
    
    public HealthDownException(String message, Throwable cause) {
        super(message, cause);
    }
}