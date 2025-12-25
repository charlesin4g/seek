package com.charles.seek.integration;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest
@Import({com.charles.seek.config.WebMvcConfig.class, com.charles.seek.config.GlobalExceptionHandler.class})
class StaticResourceAndRootPathTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void root_redirects_to_swagger_ui() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/swagger-ui/index.html"));
    }

    @Test
    void missing_static_resource_returns_404_json() throws Exception {
        mockMvc.perform(get("/no-such-file.js"))
                .andExpect(status().isNotFound());
    }
}
