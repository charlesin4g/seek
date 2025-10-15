package com.charles.seek.config;

import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.net.InetAddress;
import java.net.UnknownHostException;

@Component
public class SwaggerUrlPrinter implements ApplicationListener<ApplicationReadyEvent> {

    private final Environment environment;

    public SwaggerUrlPrinter(Environment environment) {
        this.environment = environment;
    }

    @SuppressWarnings("NullableProblems")
    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        try {
            String protocol = environment.getProperty("server.ssl.key-store") != null ? "https" : "http";
            String hostAddress = InetAddress.getLocalHost().getHostAddress();
            String port = environment.getProperty("server.port", "8080");
            String contextPath = environment.getProperty("server.servlet.context-path", "");

            String swaggerUrl = protocol + "://" + hostAddress + ":" + port + contextPath + "/swagger-ui.html";

            System.out.println("\n================================================");
            System.out.println("🚀 Swagger UI 地址: " + swaggerUrl);
            System.out.println("📖 API 文档地址: " + protocol + "://" + hostAddress + ":" + port + contextPath + "/v3/api-docs");
            System.out.println("================================================\n");

        } catch (UnknownHostException e) {
            System.err.println("无法获取主机地址: " + e.getMessage());
        }
    }
}
