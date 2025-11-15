## 问题表现与错误信息
- 日志显示 `NoResourceFoundException: No static resource .`，请求被静态资源处理器接管但路径为 `.`（根目录），导致 404。
- 被 `GlobalExceptionHandler` 兜底捕获为“未知异常”，记录 ERROR 并返回 500，而不是预期的 404。
- 代码位置：`server/src/main/java/com/charles/seek/config/GlobalExceptionHandler.java:77-81` 会将所有未明确处理的异常返回 500。

## 相关配置与环境检查
- 操作系统：macOS，内嵌 Tomcat（端口 8080）。
- Spring Boot 版本：`3.3.3`；Spring MVC 6.1；springdoc 版本：`2.5.0`（`server/build.gradle:36-41`）。
- 应用配置：`server/src/main/resources/application.properties` 未自定义静态资源映射（无 `spring.web.resources.*` / `spring.mvc.static-path-pattern`）。
- Swagger 配置：`springdoc.swagger-ui.path=/swagger-ui.html`（可能与 springdoc 2 的默认 `swagger-ui/index.html` 不一致，但本问题的路径为根 `/`）。
- 项目未提供 `classpath:/static/index.html`，访问 `/` 会命中默认静态资源处理器并解析为 `.` 而被拒绝。

## 触发路径与执行流程定位
- 请求 `/` → `DispatcherServlet` → 默认静态资源 `ResourceHttpRequestHandler`（匹配 `/**`）→ 解析根为 `.` → 抛出 `NoResourceFoundException`。
- 异常被 `@RestControllerAdvice` 的兜底 `@ExceptionHandler(Exception.class)` 捕获并返回 500（错误日志“未知异常”）。
- 控制器无根路径映射（经检索未发现 `@RequestMapping("/")` / `GetMapping("/")`）。

## 解决方案（代码与配置调整）
- 为静态资源未找到提供专门异常处理，返回 404 且降低日志等级：
  - 在 `GlobalExceptionHandler` 中新增 `@ExceptionHandler(NoResourceFoundException.class)`（`org.springframework.web.servlet.resource.NoResourceFoundException`），返回 `404`，日志使用 `warn` 或 `debug`，避免误报 ERROR 与 500。
- 为根路径提供明确入口，避免命中静态处理器：
  - 方案 A：新增控制器 `GetMapping("/")`，`return redirect:/swagger-ui/index.html`（与 springdoc 2 路径一致）。
  - 方案 B：实现 `WebMvcConfigurer#addViewControllers`，`addRedirectViewController("/", "/swagger-ui/index.html")`，零代码控制器更简洁。
- 校正 Swagger UI 路径以适配 springdoc 2：
  - 将 `springdoc.swagger-ui.path` 改为 `"/swagger-ui/index.html"`，确保重定向目标存在并可用。
- 保持默认静态资源映射开启（不要设置 `spring.web.resources.add-mappings=false` 以免影响 swagger/webjars）。

## 验证步骤（确保完全解决）
- 自动化用例（建议新增 `@SpringBootTest` + `MockMvc`）：
  - `GET /` 返回 302/301 重定向到 `/swagger-ui/index.html` 或 200 主页；日志不含“未知异常”。
  - `GET /no-such-file.js` 返回 404，响应体为统一错误格式 code=404；日志等级为 `WARN/DEBUG`，不出现 ERROR。
- 手工验证：
  - `curl -i http://localhost:8080/` 查看响应码与 `Location`。
  - 访问 `http://localhost:8080/swagger-ui/index.html` 与 `http://localhost:8080/api-docs` 确认 swagger 正常。
  - 重复之前触发路径，确认不再出现 `No static resource .` 的 ERROR 级日志。

## 兼容性与注意事项
- Spring Boot 3 + springdoc 2 在 UI 路径上采用 `/swagger-ui/index.html`；旧的 `/swagger-ui.html` 可能重定向但不稳定，建议统一到新路径。
- 不建议关闭全局静态映射；如需托管前端 SPA，可另外在 `static/` 或使用反向代理。
- 当前 `application.properties` 中存在 OSS 访问密钥，建议迁移到环境变量或外部配置源，避免泄露（与本次问题无直接关联）。

## 拟实施改动清单
- 修改 `GlobalExceptionHandler`：新增 `handleNoResourceFound(NoResourceFoundException ex)`，返回 404。
- 新增根路径入口：
  - 选 B：创建 `WebMvcConfig` 实现 `WebMvcConfigurer#addViewControllers`，映射 `/` → `/swagger-ui/index.html`。
- 更新 `application.properties`：将 `springdoc.swagger-ui.path` 改为 `/swagger-ui/index.html`。
- 添加集成测试：覆盖上述两类请求与日志行为。

请确认上述方案，确认后我将按照清单实施并验证。