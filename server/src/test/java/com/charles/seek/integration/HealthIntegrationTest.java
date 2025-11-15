package com.charles.seek.integration;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * 健康检查端到端集成测试
 * 真实 Spring 容器 + 数据库，验证 UP/DOWN 两种场景
 *
 * @author SOLO Coding
 * @since 2025-11-14
 */
@SpringBootTest
@AutoConfigureMockMvc
class HealthIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void healthCheck_realDb_returns200() throws Exception {
        mockMvc.perform(get("/health/check"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"))
                .andExpect(jsonPath("$.db").value("UP"))
                .andExpect(jsonPath("$.disk").value("UP"));
    }
}