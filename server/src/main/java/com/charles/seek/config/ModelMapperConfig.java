package com.charles.seek.config;

import org.modelmapper.ModelMapper;
import org.modelmapper.convention.MatchingStrategies;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ModelMapperConfig {

    @Bean
    @Primary
    public ModelMapper modelMapper() {
        ModelMapper modelMapper = new ModelMapper();

        // 可选：配置全局映射规则
        modelMapper.getConfiguration()
                // 启用字段匹配
                .setFieldMatchingEnabled(true)
                // 严格匹配策略
                .setMatchingStrategy(MatchingStrategies.STRICT)
                // 允许访问私有字段
                .setFieldAccessLevel(org.modelmapper.config.Configuration.AccessLevel.PRIVATE)
                // 跳过null值，避免覆盖已有数据
                .setSkipNullEnabled(true);

        return modelMapper;
    }
}
