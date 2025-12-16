# Seek Codebase: AI Development Guidelines

## Project Overview

**Seek** is an offline-first, real-time sync multi-platform data management tool built with:
- **Mobile**: Flutter (iOS/Android/macOS/Windows/Linux/Web)
- **Backend**: Spring Boot 3.3 + PostgreSQL
- **Key Feature**: Seamless offline-online switching with encrypted SQLCipher local storage and automatic sync via vector clocks

## Architecture & Core Patterns

### Layered Architecture (Controllers → Services → Repositories)

**Backend (Spring Boot)**:
- `controller/`: REST endpoints, request validation (Jakarta annotations)
- `serviceImpl/`: Business logic, transactions, conflict resolution
- `repository/`: JPA data access with custom queries
- `dto/`: Immutable request/response DTOs (use Lombok `@Data`)
- `model/`: JPA entities, relationships, constraints

**Mobile (Flutter)**:
- `pages/`: UI screens with state management (stateful widgets)
- `services/`: Business logic (API clients, offline sync, auth)
- `models/`: Data models using `json_serializable` for serialization
- `widgets/`: Reusable components
- No dependency injection framework; use singletons (e.g., `AuthService._instance`)

### Offline-Online Dual Mode

**Key Services**:
- `OfflineModeManager`: Singleton controlling `isOffline` ValueNotifier for UI subscription
- `LocalDatabase`: SQLite+SQLCipher wrapper with passphrase demo key (use PBKDF2 in production)
- `SyncService`: Incremental sync via `change_log` table tracking (id, entity, entityId, op, payload, vectorClock)
- Network detection: `connectivity_plus` → automatic Repository source switching

**Data Flow**:
1. All writes append to local `change_log` before business table
2. On network recovery: `SyncService.triggerManualSync()` reads logs → POST to `/api/{entity}/add` or `/api/{entity}/edit`
3. Conflict resolution: "last-write-wins" by default (vector clock comparison)

### API Communication

**Backend Response Format**:
```java
// Unified Result<T> wrapper (see GlobalExceptionHandler)
{ "code": 200, "message": "success", "data": {...} }
{ "code": 400, "message": "Invalid param", "errors": [...] }
```

**Frontend Error Handling** (see `http_client.dart`, `user_api.dart`):
- Catch `ApiException` for 4xx/5xx status codes
- Exponential backoff retry on 500 (max 3 attempts)
- Map HTTP errors to business exceptions (409 Conflict, etc.)

## Critical Developer Workflows

### Backend Build & Test

```bash
cd server/
./gradlew bootRun                    # Start Spring Boot on :8080
./gradlew test                       # Run all tests (WebMvcTest + integration)
./gradlew test --tests=*IntegrationTest  # Integration tests only
```

- **Test Structure**: Unit tests use `@WebMvcTest` + MockBean; integration tests use `@SpringBootTest`
- **Swagger UI**: http://127.0.0.1:8080/swagger-ui/index.html (root redirects here)
- **DB Migration**: Flyway scripts in `src/main/resources/db/migration/`

### Mobile Build & Test

```bash
cd mobile/
flutter pub get
flutter run                          # Debug on connected device
flutter test                         # Unit tests (test/*.dart)
```

- **Manual Testing Scripts**: `test/offline_mode_test.dart`, `test/manual_user_flow.dart`
- **Network Simulation**: Use `OfflineModeManager.setOffline(true)` to test sync behavior
- **Platform Conditionals**: Use `if (kIsWeb) { ... } else { ... }` for web/native divergence

## Project-Specific Conventions

### Naming & Organization

**Backend**:
- Service interface in `service/` folder, implementation in `serviceImpl/`
- Repository interfaces extend `JpaRepository<Entity, ID>`
- Request/response DTOs in `dto/{domain}/request/` and `dto/{domain}/response/`
- Use `@RequiredArgsConstructor` (Lombok) for constructor injection

**Frontend**:
- Service classes use private constructor + static singleton: `static final instance = _internal()`
- Page filenames: `{entity}_{action}_page.dart` (e.g., `ticket_page.dart`, `add_ticket_page.dart`)
- Widget files: `{purpose}_widget.dart` or `{purpose}_card.dart`
- Config centralized in `lib/config/` (colors, themes, OSS settings)

### Key Files to Reference

**Offline-Online Pattern**:
- [OfflineModeManager](mobile/lib/services/offline_mode.dart): Mode switching logic
- [SyncService](mobile/lib/services/sync_service.dart): Incremental sync & retry framework
- [LocalDatabase](mobile/lib/services/local_db.dart): SQLCipher initialization & schema versioning

**API Layer**:
- [UserServiceImpl](server/src/main/java/com/charles/seek/serviceImpl/UserServiceImpl.java): Service → DTO mapping with ModelMapper
- [UserControllerTest](server/src/test/java/com/charles/seek/controller/UserControllerTest.java): WebMvcTest pattern
- [UserIntegrationTest](server/src/test/java/com/charles/seek/integration/UserIntegrationTest.java): Full lifecycle testing

**UI/Forms**:
- [AddTicketPage](mobile/lib/pages/ticket/add_ticket_page.dart): Complex form with dropdowns, date pickers, validations
- [SnapshotService](mobile/lib/services/snapshot_service.dart): Form state restoration across navigation

### Database & Encryption

**Local Storage** (mobile):
- Password derivation: PBKDF2 via `crypto` package (currently using demo passphrase)
- Database versioning: Increment `_dbVersion` in `LocalDatabase` and add `onUpgrade` callback
- Change log table schema: `id, entity, entityId, op (INSERT/UPDATE/DELETE), payload, vectorClock, createdAt`

**Backend Database**:
- PostgreSQL with Flyway migrations (version-controlled DDL)
- JPA entity constraints: `@Column(unique=true)`, `@OneToMany(cascade=CascadeType.ALL)`

## Common Integration Points

### OSS Resource Handling

**Backend**: Returns resource keys (e.g., `avatar/abc.png`)
**Frontend**: `OssService.resolveUrl(key)` builds full URL respecting custom CDN domains and image styles
- Config in [lib/config/oss_config.dart](mobile/lib/config/oss_config.dart)
- Production: Use backend-generated signatures or STS tokens (never store secrets in frontend)

### Cross-Platform Conditionals

```dart
// Web uses IndexedDB; native uses SQLite
if (kIsWeb) {
  await WebLocalStore.instance.readChangeLogsAfter(_lastSyncedLogId);
} else {
  final db = await LocalDatabase.instance.init();
  await db.query('change_log', ...);
}
```

### Error Handling & Logging

**Backend**: `GlobalExceptionHandler` catches all exceptions and returns structured error responses
**Frontend**: Wrap API calls in try-catch; log to console; optionally bind to `ErrorWidget.builder` for UI fallbacks (see [main.dart](mobile/lib/main.dart))

## Testing & Validation

- **Backend**: All service methods tested via `@SpringBootTest` with real DB; controllers tested with `@WebMvcTest` mocking services
- **Frontend**: Manual test scripts for end-to-end flows; unit tests for services and models via `mockito`
- **Offline Scenario**: Use `OfflineModeManager.setOffline(true)` to verify sync queueing and replay

## Common Gotchas

1. **Change Log Ordering**: Always query `change_log` ordered by `id ASC` to maintain causality
2. **Vector Clock Comparison**: Both client and server must implement identical comparison logic for conflict detection
3. **Passphrase Leakage**: Demo passphrase in `LocalDatabase._demoPassphrase` is for development only; use device keystore in production
4. **Web Platform**: `sqflite_sqlcipher` throws `UnsupportedError` on web; fallback to `WebLocalStore` (IndexedDB wrapper)
5. **OSS Secret Storage**: Never embed access keys in frontend code; use backend-signed URLs or STS tokens

## Useful References

- **Architecture Docs**: [docs/architecture_offline_online.md](docs/architecture_offline_online.md)
- **API Report**: [SUMMARY.md](SUMMARY.md) (recent API fixes and test patterns)
- **Sync Protocol**: [docs/sync_protocol_spec.md](docs/sync_protocol_spec.md)
- **Android/iOS Build Issues**: See [mobile/README.md](mobile/README.md) and Aliyun OSS config section
