package com.charles.seek.config;

import org.modelmapper.ModelMapper;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;

/**
 * 测试专用配置，补充缺失的 Bean
 *
 * @author SOLO Coding
 * @since 2025-11-14
 */
@TestConfiguration
public class TestConfig {

    @Bean(name = "testModelMapper")
    public ModelMapper modelMapper() {
        return new ModelMapper();
    }
}
