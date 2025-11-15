package com.charles.seek.serviceImpl;

import com.charles.seek.service.HealthDownException;
import com.charles.seek.service.HealthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.io.File;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 健康检查业务实现<br>
 * 检查项：数据库连通性、磁盘剩余空间<br>
 * 任一失败抛 {@link HealthDownException}，由全局异常处理器转 503
 *
 * @author SOLO Coding
 * @since 2025-11-14
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class HealthServiceImpl implements HealthService {

    private final DataSource dataSource;

    @Value("${health.disk.path:/}")
    private String diskPath;

    @Value("${health.disk.minFreeGB:1}")
    private long minFreeGB;

    @Override
    public Map<String, Object> check() throws HealthDownException {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("timestamp", Instant.now().toString());

        // 1. 数据库检查
        String dbStatus = checkDatabase();
        result.put("db", dbStatus);

        // 2. 磁盘检查
        String diskStatus = checkDisk();
        result.put("disk", diskStatus);

        // 3. 总状态
        boolean isUp = "UP".equals(dbStatus) && "UP".equals(diskStatus);
        result.put("status", isUp ? "UP" : "DOWN");

        if (!isUp) {
            log.warn("健康检查未通过: {}", result);
            throw new HealthDownException(result);
        }

        log.debug("健康检查通过: {}", result);
        return result;
    }

    /**
     * 数据库连通性探测
     */
    private String checkDatabase() {
        try (Connection conn = dataSource.getConnection()) {
            if (conn.isValid(2)) {
                return "UP";
            }
        } catch (SQLException e) {
            log.warn("数据库健康检查失败", e);
        }
        return "DOWN";
    }

    /**
     * 磁盘剩余空间检查
     */
    private String checkDisk() {
        try {
            File root = new File(diskPath);
            long freeGB = root.getFreeSpace() / 1024 / 1024 / 1024;
            return freeGB >= minFreeGB ? "UP" : "DOWN";
        } catch (Exception e) {
            log.warn("磁盘健康检查失败", e);
            return "DOWN";
        }
    }
}