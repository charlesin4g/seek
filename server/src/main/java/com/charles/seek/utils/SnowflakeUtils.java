package com.charles.seek.utils;

import java.util.concurrent.atomic.AtomicLong;

/**
 * 雪花算法静态工具类
 */
public class SnowflakeUtils {
    // 起始时间戳（2020-01-01 00:00:00）
    private static final long TWEPOCH = 1577808000000L;

    // 机器ID所占位数
    private static final long WORKER_ID_BITS = 5L;
    // 数据中心ID所占位数
    private static final long DATACENTER_ID_BITS = 5L;
    // 序列号所占位数
    private static final long SEQUENCE_BITS = 12L;

    // 最大机器ID
    private static final long MAX_WORKER_ID = ~(-1L << WORKER_ID_BITS);
    // 最大数据中心ID
    private static final long MAX_DATACENTER_ID = ~(-1L << DATACENTER_ID_BITS);
    // 序列号掩码
    private static final long SEQUENCE_MASK = ~(-1L << SEQUENCE_BITS);

    // 机器ID左移位数
    private static final long WORKER_ID_SHIFT = SEQUENCE_BITS;
    // 数据中心ID左移位数
    private static final long DATACENTER_ID_SHIFT = SEQUENCE_BITS + WORKER_ID_BITS;
    // 时间戳左移位数
    private static final long TIMESTAMP_LEFT_SHIFT = SEQUENCE_BITS + WORKER_ID_BITS + DATACENTER_ID_BITS;

    // 默认机器ID（可通过系统属性设置）
    private static final long DEFAULT_WORKER_ID = Long.parseLong(
            System.getProperty("snowflake.worker.id", "1"));
    // 默认数据中心ID（可通过系统属性设置）
    private static final long DEFAULT_DATACENTER_ID = Long.parseLong(
            System.getProperty("snowflake.datacenter.id", "1"));

    // 序列号
    private static final AtomicLong SEQUENCE = new AtomicLong(0L);
    // 上次生成ID的时间戳
    private static volatile long LAST_TIMESTAMP = -1L;

    // 静态初始化，验证配置
    static {
        validateConfig(DEFAULT_WORKER_ID, DEFAULT_DATACENTER_ID);
    }

    /**
     * 验证配置参数
     */
    private static void validateConfig(long workerId, long datacenterId) {
        if (workerId > MAX_WORKER_ID || workerId < 0) {
            throw new IllegalArgumentException(String.format(
                    "Worker ID can't be greater than %d or less than 0", MAX_WORKER_ID));
        }
        if (datacenterId > MAX_DATACENTER_ID || datacenterId < 0) {
            throw new IllegalArgumentException(String.format(
                    "Datacenter ID can't be greater than %d or less than 0", MAX_DATACENTER_ID));
        }
    }

    /**
     * 生成下一个ID（使用默认配置）
     * @return 雪花算法ID
     */
    public static long nextId() {
        return nextId(DEFAULT_WORKER_ID, DEFAULT_DATACENTER_ID);
    }

    /**
     * 生成下一个ID（指定机器ID和数据中心ID）
     * @param workerId 机器ID (0-31)
     * @param datacenterId 数据中心ID (0-31)
     * @return 雪花算法ID
     */
    public static synchronized long nextId(long workerId, long datacenterId) {
        validateConfig(workerId, datacenterId);

        long timestamp = timeGen();

        // 如果当前时间小于上次ID生成的时间戳，说明系统时钟回退过
        if (timestamp < LAST_TIMESTAMP) {
            throw new RuntimeException(
                    String.format("Clock moved backwards. Refusing to generate id for %d milliseconds",
                            LAST_TIMESTAMP - timestamp));
        }

        long sequence;
        // 如果是同一时间生成的，则进行序列号自增
        if (LAST_TIMESTAMP == timestamp) {
            sequence = SEQUENCE.incrementAndGet() & SEQUENCE_MASK;
            // 序列号超出范围，等待下一毫秒
            if (sequence == 0) {
                timestamp = tilNextMillis(LAST_TIMESTAMP);
            }
        } else {
            // 时间戳改变，序列号重置
            SEQUENCE.set(0L);
            sequence = 0L;
        }

        // 更新上次生成ID的时间戳
        LAST_TIMESTAMP = timestamp;

        // 生成ID
        return ((timestamp - TWEPOCH) << TIMESTAMP_LEFT_SHIFT)
                | (datacenterId << DATACENTER_ID_SHIFT)
                | (workerId << WORKER_ID_SHIFT)
                | sequence;
    }

    /**
     * 等待下一毫秒
     */
    private static long tilNextMillis(long lastTimestamp) {
        long timestamp = timeGen();
        while (timestamp <= lastTimestamp) {
            timestamp = timeGen();
        }
        return timestamp;
    }

    /**
     * 获取当前时间戳
     */
    private static long timeGen() {
        return System.currentTimeMillis();
    }

    /**
     * 解析雪花算法ID（使用默认配置）
     * @param id 雪花算法ID
     * @return 解析结果字符串
     */
    public static String parseId(long id) {
        return parseId(id, DEFAULT_WORKER_ID, DEFAULT_DATACENTER_ID);
    }

    /**
     * 解析雪花算法ID
     * @param id 雪花算法ID
     * @param workerId 机器ID
     * @param datacenterId 数据中心ID
     * @return 解析结果字符串
     */
    public static String parseId(long id, long workerId, long datacenterId) {
        long timestamp = (id >> TIMESTAMP_LEFT_SHIFT) + TWEPOCH;
        long actualDatacenterId = (id >> DATACENTER_ID_SHIFT) & MAX_DATACENTER_ID;
        long actualWorkerId = (id >> WORKER_ID_SHIFT) & MAX_WORKER_ID;
        long sequence = id & SEQUENCE_MASK;

        return String.format(
                "ID解析结果: 时间戳=%d, 数据中心ID=%d, 机器ID=%d, 序列号=%d",
                timestamp, actualDatacenterId, actualWorkerId, sequence);
    }

    /**
     * 批量生成ID
     * @param count 生成数量
     * @return ID数组
     */
    public static long[] batchNextId(int count) {
        return batchNextId(count, DEFAULT_WORKER_ID, DEFAULT_DATACENTER_ID);
    }

    /**
     * 批量生成ID
     * @param count 生成数量
     * @param workerId 机器ID
     * @param datacenterId 数据中心ID
     * @return ID数组
     */
    public static synchronized long[] batchNextId(int count, long workerId, long datacenterId) {
        if (count <= 0) {
            throw new IllegalArgumentException("Count must be greater than 0");
        }

        validateConfig(workerId, datacenterId);

        long[] ids = new long[count];
        for (int i = 0; i < count; i++) {
            ids[i] = nextId(workerId, datacenterId);
        }
        return ids;
    }

    /**
     * 测试用例
     */
    public static void main(String[] args) {
        // 使用默认配置生成ID
        System.out.println("=== 使用默认配置生成ID ===");
        for (int i = 0; i < 5; i++) {
            long id = SnowflakeUtils.nextId();
            System.out.println("生成的ID: " + id);
            System.out.println(SnowflakeUtils.parseId(id));
            System.out.println("------------------------");
        }

        // 使用指定配置生成ID
        System.out.println("=== 使用指定配置生成ID ===");
        for (int i = 0; i < 3; i++) {
            long id = SnowflakeUtils.nextId(2, 3);
            System.out.println("生成的ID: " + id);
            System.out.println(SnowflakeUtils.parseId(id, 2, 3));
            System.out.println("------------------------");
        }

        // 批量生成ID
        System.out.println("=== 批量生成ID ===");
        long[] batchIds = SnowflakeUtils.batchNextId(3);
        for (long id : batchIds) {
            System.out.println("批量ID: " + id);
        }
    }
}