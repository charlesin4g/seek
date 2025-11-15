package com.charles.seek.controller;

import com.charles.seek.config.TestConfig;
import com.charles.seek.service.HealthDownException;
import com.charles.seek.service.HealthService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * HealthController WebMvc 单元测试
 *
 * @author SOLO Coding
 * @since 2025-11-14
 */
@WebMvcTest(HealthController.class)
class HealthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private HealthService healthService;

    @Test
    void healthCheck_success() throws Exception {
        when(healthService.check()).thenReturn(Map.of("status", "UP", "db", "UP", "disk", "UP"));

        mockMvc.perform(get("/health/check"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"));
    }

    @Test
    void healthCheck_serviceDown_returns503() throws Exception {
        when(healthService.check()).thenThrow(new HealthDownException(Map.of("status", "DOWN", "db", "DOWN")));

        mockMvc.perform(get("/health/check"))
                .andExpect(status().isServiceUnavailable())
                .andExpect(jsonPath("$.code").value(503));
    }
}
