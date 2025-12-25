package com.charles.seek.integration;

import com.charles.seek.dto.user.request.CreateUserRequest;
import com.charles.seek.dto.user.request.UpdateUserRequest;
import com.charles.seek.dto.user.response.UserProfile;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 用户管理端到端集成测试<br>
 * 使用真实数据库与全量容器，验证完整业务流程
 *
 * @author SOLO Coding
 * @since 2025-11-14
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class UserIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void userLifeCycle_success() throws Exception {
        // 1. 创建用户
        CreateUserRequest createReq = new CreateUserRequest();
        createReq.setUsername("testuser");
        createReq.setPassword("123456");
        createReq.setDisplayName("Test User");
        createReq.setEmail("test@example.com");
        createReq.setPhone("13800138000");

        String createResp = mockMvc.perform(post("/api/user")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createReq)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.username").value("testuser"))
                .andReturn().getResponse().getContentAsString();

        UserProfile created = objectMapper.readValue(createResp, UserProfile.class);
        assertThat(created.getDisplayName()).isEqualTo("Test User");

        // 2. 查询用户
        mockMvc.perform(get("/api/user/{username}", "testuser"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("testuser"));

        // 3. 更新用户
        UpdateUserRequest updateReq = new UpdateUserRequest();
        updateReq.setDisplayName("Updated Name");
        updateReq.setEmail("updated@example.com");

        mockMvc.perform(put("/api/user/{username}", "testuser")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.displayName").value("Updated Name"))
                .andExpect(jsonPath("$.email").value("updated@example.com"));

        // 4. 删除用户
        mockMvc.perform(delete("/api/user/{username}", "testuser"))
                .andExpect(status().isNoContent());

        // 5. 确认删除
        mockMvc.perform(get("/api/user/{username}", "testuser"))
                .andExpect(status().isBadRequest()); // 业务异常：用户不存在
    }

    @Test
    void createUser_duplicateUsername_conflict() throws Exception {
        CreateUserRequest req = new CreateUserRequest();
        req.setUsername("dupuser");
        req.setPassword("123456");

        // 第一次创建成功
        mockMvc.perform(post("/api/user")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated());

        // 第二次创建冲突
        mockMvc.perform(post("/api/user")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value(409));
    }
}