package com.charles.seek.controller;

import com.charles.seek.dto.user.request.CreateUserRequest;
import com.charles.seek.dto.user.request.UpdateUserRequest;
import com.charles.seek.dto.user.response.UserProfile;
import com.charles.seek.service.OssService;
import com.charles.seek.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * UserController WebMvc 单元测试<br>
 * 仅测试 Controller 层，Service 用 Mock
 *
 * @author SOLO Coding
 * @since 2025-11-14
 */
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private UserService userService;

    @MockBean
    private OssService ossService;

    @Test
    void createUser_success() throws Exception {
        CreateUserRequest request = new CreateUserRequest();
        request.setUsername("alice");
        request.setPassword("123456");
        request.setDisplayName("Alice");
        request.setEmail("alice@example.com");

        UserProfile profile = new UserProfile();
        profile.setUsername("alice");
        profile.setDisplayName("Alice");

        when(userService.createUser(any(CreateUserRequest.class))).thenReturn(profile);

        mockMvc.perform(post("/api/user")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.username").value("alice"))
                .andExpect(jsonPath("$.displayName").value("Alice"));

        verify(userService, times(1)).createUser(any(CreateUserRequest.class));
    }

    @Test
    void createUser_validationFail() throws Exception {
        CreateUserRequest request = new CreateUserRequest();
        request.setUsername("a"); // 长度不足
        request.setPassword("123"); // 长度不足

        mockMvc.perform(post("/api/user")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400));
    }

    @Test
    void updateUser_success() throws Exception {
        String username = "alice";
        UpdateUserRequest request = new UpdateUserRequest();
        request.setDisplayName("Alice2");
        request.setEmail("alice2@example.com");

        UserProfile profile = new UserProfile();
        profile.setUsername(username);
        profile.setDisplayName("Alice2");

        when(userService.updateUser(eq(username), any(UpdateUserRequest.class))).thenReturn(profile);

        mockMvc.perform(put("/api/user/{username}", username)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value(username))
                .andExpect(jsonPath("$.displayName").value("Alice2"));

        verify(userService, times(1)).updateUser(eq(username), any(UpdateUserRequest.class));
    }

    @Test
    void deleteUser_success() throws Exception {
        String username = "alice";

        doNothing().when(userService).deleteUser(username);

        mockMvc.perform(delete("/api/user/{username}", username))
                .andExpect(status().isNoContent());

        verify(userService, times(1)).deleteUser(username);
    }
}
