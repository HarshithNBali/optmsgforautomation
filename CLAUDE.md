# CLAUDE.md — OptMsg Flutter App

## Build & Run

```bash
flutter pub get                  # Install dependencies
flutter analyze                  # Lint — must pass with zero issues
flutter run                      # Run on connected device/emulator
flutter build web                # Web build
flutter build ios                # iOS build
flutter build appbundle          # Android AAB
```

No test suite exists yet. Verify changes with `flutter analyze` and manual testing.

## Project Structure

```
lib/
├── main.dart                    # App entry, lifecycle observer, Firebase init
├── common/                      # Shared utilities (responsive, logger, app_cache)
├── constant/                    # App config, string constants, styles, image paths
├── model/                       # Data models (auth/, inbox_list_model, etc.)
├── repositories/                # API layer — one folder per feature
│   ├── base/                    #   base_api_service.dart, refreshable_api.dart
│   ├── email/                   #   inbox_api.dart, email_detail_repository.dart
│   └── {feature}/               #   {feature}_api.dart or {feature}_repository.dart
├── router/                      # GoRouter config
│   ├── app_router.dart          #   Router + redirect guards
│   └── app_routes.dart          #   Static route path constants
├── screens/                     # Feature screens — one folder per feature
│   ├── auth/                    #   login/, createAccount/, enterOtp/, passKey/
│   ├── email/                   #   inbox_riverpod/, archive_riverpod/, draft_riverpod/
│   ├── settings/                #   setting_riverpod/
│   └── {feature}/               #   Screen + riverpod subfolder
├── services/                    # Business logic services (api, socket, storage, etc.)
├── widgets/                     # Shared reusable UI components
└── webPackerHandler/            # Web-specific platform handling
```

## Architecture & Patterns

### State Management — Riverpod Notifier

All state management uses `NotifierProvider<T, S>` (NOT `StateNotifierProvider`).

```dart
// Provider declaration
final featureProvider = NotifierProvider<FeatureNotifier, FeatureState>(FeatureNotifier.new);

// Notifier class
class FeatureNotifier extends Notifier<FeatureState> {
  bool _disposed = false;

  @override
  FeatureState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    Future.microtask(_initialize);
    return FeatureState.initial();
  }
}
```

- State classes use `copyWith` (some use Freezed: `_state.freezed.dart`)
- Guard every async gap with `if (_disposed) return;`
- Use `ref.watch()` in `build()`, `ref.read()` in callbacks/methods
- Global `providerContainer` in `main.dart` for service-layer provider access

### Screen Feature Folder Pattern

Each feature in `screens/` follows this structure:

```
screens/{feature}/
├── {feature}_screen.dart            # ConsumerStatefulWidget entry point
├── {feature}_riverpod/              # State management
│   ├── {feature}_notifier.dart      #   NotifierProvider + business logic
│   ├── {feature}_state.dart         #   Immutable state class
│   └── {feature}_responsive.dart    #   Responsive layout switcher (if needed)
└── widgets/                         # Feature-specific widgets
    ├── {feature}_mobile_layout.dart
    ├── {feature}_desktop_layout.dart
    └── {feature}_form_widget.dart
```

### Responsive Layout

- Use `ResponsiveLayoutBuilder` with `mobile:` and `desktop:` callbacks
- Breakpoints in `lib/common/responsive/breakpoints.dart` (`AppBreakpoints`)
  - Mobile: <600, Tablet: 600–1023, Desktop: ≥1024, LargeDesktop: ≥1440
- Context extensions: `context.isMobile`, `context.isTablet`, `context.isDesktop`

### Routing — GoRouter

- Routes defined as static constants in `app_routes.dart`
- Dynamic paths via helper methods: `AppRoutes.emailDetailPath(id)`
- Redirect guard in `app_router.dart` checks `authProvider` (`isInitialized` → `isAuthenticated`)

### API Layer

- **Repositories** (`lib/repositories/{feature}/`): Return `Result<T>` for error handling
- **Services** (`lib/services/`): Low-level HTTP (`ApiService`), storage (`SecureStorageService`), socket (`SocketService`)
- `BaseAPIService.make()` for authenticated requests with session refresh
- `ApiService().post()` uses `globalVariableProvider` for loading indicator
- Auth errors (401/session expiry) handled centrally — don't duplicate in callers

### Auth Flow

- `authProvider` = `NotifierProvider<AuthNotifier, AuthState>`
- `AuthState.initial()` → uninitialized; `AuthState.unauthenticated()` → initialized, not logged in
- Login: `userVerify()` → OTP screen → `verifyDescopeOtp()` → `userLogin()` → authenticated
- Logout: `setAuthenticated(false)` FIRST → router redirects → background cleanup
- `clearSession()` does NOT call `setAuthenticated(false)` (prevents mid-login reset)

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Files | `snake_case.dart` | `inbox_notifier.dart` |
| Classes | `PascalCase` | `InboxNotifier` |
| Providers | `camelCase` + `Provider` | `inboxProvider` |
| Screens | `{Feature}Screen` | `LoginScreen` |
| Notifiers | `{Feature}Notifier` | `AuthNotifier` |
| States | `{Feature}State` | `InboxState` |
| Repositories | `{Feature}Api` or `{Feature}Repository` | `InboxApi` |
| Widgets | `{Descriptive}Widget` or `Custom{Type}` | `OtpFormWidget`, `CustomGradientButton` |
| Routes | `static const` in `AppRoutes` | `AppRoutes.inbox` |
| Feature folders | `camelCase` | `enterOtp/`, `passKey/` |

## Key Singletons & Globals

- `providerContainer` — global `ProviderContainer` (main.dart) for service-layer access
- `SocketService()` — singleton via factory constructor
- `SecureStorageService()` — singleton for flutter_secure_storage
- `AppCache()` — in-memory cache singleton
- `SessionRefreshMutex` — static flags guarding concurrent JWT refresh

## Important Rules

- Never call `setAuthenticated(false)` inside `clearSession()` — it breaks mid-login flows
- Never refresh Descope session during passkey enrollment — JWT mismatch breaks WebAuthn
- `flutter_secure_storage.deleteAll()` on iOS can be slow — never call concurrently
- Socket reconnect must happen AFTER JWT refresh on app resume
- Always use `mounted` checks after `await` in `ConsumerState` widgets
- Always use `_disposed` checks after `await` in Notifiers
