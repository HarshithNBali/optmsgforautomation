# OptMsg Flutter App — Comprehensive Test Case Documentation

**Generated:** 2026-02-17 | **Last Validated:** 2026-03-09
**App Version:** 1.0.7 (branch optmsg_1.0.7_27feb)
**Flutter:** 3.27.1 | Dart 3.6.0

---

## Executive Summary

### Current Test Coverage Status
- **Existing test files:** 2 (`test/auth_notifier_test.dart`, `test/sample_test.dart` — placeholder `2 + 2 = 4`)
- **Existing integration tests:** None
- **Estimated current coverage:** ~1% (auth_notifier_test.dart covers basic auth state)
- **Target coverage:** 80%+ (unit + widget), 60%+ (integration)

### Test Case Totals

| Type | Count |
|------|-------|
| Unit Tests | 790 |
| Widget Tests | 426 |
| Integration Tests | 59 |
| E2E Tests | 102 |
| Infrastructure & DevOps Tests | 18 |
| **Total Test Cases** | **1,395** |
| Snackbar/Toast Validation Entries (Appendix D) | 99 |

### Breakdown by Platform

| Platform | Count |
|----------|-------|
| All | 1,253 |
| Web | 53 |
| iOS | 7 |
| Android | 6 |
| iOS, Android | 76 |

### Breakdown by Screen Size

| Screen Size | Count |
|-------------|-------|
| All | 1,250 |
| Small | 90 |
| Medium | 10 |
| Large | 45 |

### Top 10 Priority Gaps to Address First

1. **Session management unit tests** — SessionExpiryManager, SessionRefreshMutex newly centralized with zero coverage
2. **Analytics service unit tests** — AnalyticsService (30+ event helpers) with zero coverage
3. **Security utility unit tests** — secure_url_helper, stripe_url_validator, secure_print_helper with zero coverage
4. **LoginPostProcessor unit tests** — Shared post-login navigation logic with zero coverage
5. **PlatformSecureStorage unit tests** — Cross-platform storage abstraction with zero coverage
6. **DelayedLoadingOverlay widget tests** — New loading UX component with zero coverage
7. **Route extras unit tests** — GoRouter safe extraction helpers with zero coverage
8. **ConnectivityService unit tests** — Network detection service with zero coverage
9. **Deep linking E2E tests** — mailto: and app link handling still untested
10. **App lifecycle tests** — Biometric on resume, background handling still untested

### New Files with Zero Test Coverage (Added Since v1.0.3)

- `lib/screens/auth/login_post_processor.dart` — Shared post-login navigation
- `lib/services/session_expiry_manager.dart` — Centralized session expiry handling
- `lib/services/session_refresh_mutex.dart` — JWT refresh serialization
- `lib/services/analytics_service.dart` — Firebase Analytics wrapper (30+ events)
- `lib/common/utilites/secure_print_helper.dart` — Secure print preview
- `lib/common/utilites/secure_url_helper.dart` — JWT URL stripping
- `lib/common/utilites/stripe_url_validator.dart` — Payment URL validation
- `lib/router/route_extras.dart` — Safe GoRouter extras extraction
- `lib/services/storage/platform_secure_storage.dart` — Cross-platform storage
- `lib/widgets/load_container/delayed_loading_overlay.dart` — Debounced spinner
- `lib/services/connectivity_service.dart` — Network connectivity detection

### Recommended Golden Test Candidates

1. **SkeletonLoader** — Custom shimmer animation painter
2. **DashedBorder** — CustomPainter implementation
3. **GradientAppBar** — Complex gradient with free trial banner
4. **EmailPlan cards** — Intricate card layout with ribbons
5. **SideMenu** — Complex collapsed/expanded states
6. **CreditCardWidget** — Fixed-dimension card display
7. **CustomToast** — Color-coded toast variants

### Suggested Test Execution Order

1. Core utilities: `Result<T>`, `FormValidationService`, `RegExpService`, `AppCache`, `AppEnvironment`
2. Responsive framework: `Breakpoints`, `ResponsiveLayoutBuilder`, `BaseResponsiveScreen`, `AdaptiveService`
3. Models: All 34 model fromJson/toJson
4. Services: `StorageService`, `BiometricService`, `CommonService`, `OverlayManager`, `TagsProvider`
5. API layer: `BaseAPIService`, `RefreshableService`, repositories
6. State management: All 13 Riverpod notifiers
7. Router & Navigation: `AppNavigator`, route wrappers, `RouteObserverService`
8. Widgets: Reusable widgets (buttons, form fields, lists, `CustomDismissible`, `TagInputField`)
9. Screens: Auth flow → Inbox → Compose → Contacts → Settings → Subscription Management → Onboarding
10. Auth support: Breach check, OTP profile, payment success
11. Integration: Auth + API, Inbox + Socket, Contacts + API, Opt-in flows, Responsive/adaptive
12. E2E: Full login flow, compose email, manage contacts, onboarding, attachments, send/receive
13. Infrastructure: Environment flavors, CI/CD pipelines, JMeter performance tests

### Known Testing Challenges

1. **Descope SDK** — Cannot easily mock; requires wrapper/abstraction layer
2. **Socket.IO** — Requires mock socket server or service abstraction
3. **Firebase services** — Need firebase_core mock initialization
4. **Platform channels** — Biometric, file picker, contacts need platform mocks
5. **Cross-device passkey (QR code)** — Requires Descope/WebAuthn abstraction; QR flow difficult to test in isolation
6. **Video player** — Requires platform channel mock for video_player package
7. **Scheduled push notifications** — Day 1–10 onboarding notifications require time-based scheduling mocks
8. **JMeter/Performance tests** — External to Flutter; require separate JMeter test plans and backend access
9. **Environment flavors** — Require build-time verification; not standard unit tests
10. **Attachment downloads** — Require file system mocks and platform-specific download manager abstraction
11. **Secure storage** — Requires `FlutterSecureStorage` mock or test doubles
12. **Web conditional imports** — `kIsWeb` checks need `debugDefaultTargetPlatformOverride`
13. **Device info caching** — `AppBreakpoints._isPhysicalTabletCached` is static
14. **Overlay management** — Toast/modal overlays need careful lifecycle handling
15. **Static singleton guards** — `SessionExpiryManager._isHandling` and `SessionRefreshMutex._refreshCompleter` are static; must reset between tests
16. **Firebase Analytics** — `AnalyticsService` guards behind `firebaseReady` global flag; needs mock or flag override
17. **InAppWebView** — `secure_print_helper.dart` uses InAppWebView which requires platform channel mocks
18. **PlatformSecureStorage** — Web implementation uses `dart:js_interop`; only stub variant testable in standard Flutter tests

### Recommended Shared Test Infrastructure

1. **MockApiService** — Mock HTTP client returning canned JSON responses
2. **MockSecureStorageService** — In-memory key-value store
3. **MockSocketService** — Fake socket with event emission/subscription
4. **MockDescopeSession** — Fake Descope session with configurable tokens
5. **FakeAuthNotifier** — Pre-configured auth states (logged in/out/error)
6. **TestProviderScope** — Pre-wired ProviderScope with all mock overrides
7. **FakeNavigatorObserver** — Route tracking for navigation assertions
8. **MockFirebaseMessaging** — Fake FCM token and message handling
9. **TestPumpHelper** — Extension on WidgetTester with common pump patterns
10. **SampleDataFactory** — Factory methods for all model test data

---

## 1. Authentication Module

### Current Coverage Status
- **Existing tests:** None
- **Files involved:**
  - `lib/screens/auth/login/` (login_screen.dart, login.dart, login_form_widget.dart, login_desktop_layout.dart, login_mobile_layout.dart)
  - `lib/screens/auth/enterOtp/` (otp_screen.dart, otp_form_widget.dart, otp_desktop_layout.dart, otp_mobile_layout.dart, enter_otp_notifier.dart, enter_otp_provider.dart)
  - `lib/screens/auth/createAccount/` (create_account_screen.dart, create_account_form_widget.dart, create_account_desktop_layout.dart, create_account_mobile_layout.dart)
  - `lib/screens/auth/setupProfile/` (setup_profile_screen.dart, setup_profile_form_widget.dart, setup_profile_desktop_layout.dart, setup_profile_mobile_layout.dart)
  - `lib/screens/auth/forgotUserName/` (forgot_user_name.dart, forgot_form_widget.dart, forgot_desktop_layout.dart, forgot_mobile_layout.dart)
  - `lib/screens/auth/passKey/` (add_pass_key.dart, passkey_notifier.dart)
  - `lib/screens/auth/login_post_processor.dart`
  - `lib/screens/auth/userNameSuccess/`
  - `lib/screens/auth/web/` (web-specific auth screens)
  - `lib/model/auth/` (auth_state.dart, enter_otp_state.dart, passkey_state.dart, biometric_accept_result.dart, biometric_denied_result.dart)
  - `lib/repositories/auth/auth_api.dart`
  - `lib/services/biometric_service.dart`
  - `lib/services/descope_api_service.dart`
- **Gaps:** Complete — no test coverage exists

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| AUTH-U001 | Auth/AuthState | should create unauthenticated state by default | Verify AuthState factory creates correct initial state | None | status=unauthenticated, errorMessage=null, verifyUser=null | P0 | No |
| AUTH-U002 | Auth/AuthState | should create authenticated state with user data | Verify authenticated factory sets all fields | verifyUser map with user data | status=authenticated, isAuthenticated=true, verifyUser populated | P0 | No |
| AUTH-U003 | Auth/AuthState | should create error state with message | Verify error factory captures message | Error string "Session expired" | status=error, hasError=true, errorMessage="Session expired" | P0 | No |
| AUTH-U004 | Auth/AuthState | should create authenticating state | Verify authenticating factory | None | status=authenticating, isAuthenticating=true | P0 | No |
| AUTH-U005 | Auth/AuthState | should return correct boolean getters for each status | Verify computed properties | Each AuthStatus value | isAuthenticated/isAuthenticating/isUnauthenticated/hasError correct for each | P1 | No |
| AUTH-U006 | Auth/AuthState | should handle setDescope factory | Verify Descope flag state | bool true/false | isDescopeEnabled matches input | P1 | No |
| AUTH-U007 | Auth/EnterOtpState | should have correct defaults when created | Verify default state values | None | loading=false, formattedPhone='', mobile='', countryCode='+1', userData=null | P0 | No |
| AUTH-U008 | Auth/EnterOtpState | should return isValid=true when mobile and userData present | Verify validation computed property | mobile='5551234567', userData={...} | isValid=true | P0 | No |
| AUTH-U009 | Auth/EnterOtpState | should return isValid=false when mobile empty | Verify validation rejects empty mobile | mobile='', userData={...} | isValid=false | P0 | Yes |
| AUTH-U010 | Auth/EnterOtpState | should return isValid=false when userData null | Verify validation rejects null user | mobile='5551234567', userData=null | isValid=false | P0 | Yes |
| AUTH-U011 | Auth/EnterOtpState | should compute fullPhone correctly | Verify phone concatenation | countryCode='+1', mobile='5551234567' | fullPhone='+15551234567' | P1 | No |
| AUTH-U012 | Auth/EnterOtpState | should prefer formattedPhone for displayPhone | Verify displayPhone computed property | formattedPhone='(555) 123-4567' | displayPhone='(555) 123-4567' | P1 | No |
| AUTH-U013 | Auth/PasskeyState | should have correct defaults | Verify default passkey state | None | isLoading=false, isEnabling=false, isEnabled=false, passkeySupported=false | P0 | No |
| AUTH-U014 | Auth/PasskeyState | should compute canEnable correctly | Verify canEnable logic | passkeySupported=true, isEnabled=false, isLoading=false | canEnable=true | P1 | No |
| AUTH-U015 | Auth/PasskeyState | should extract userName from userData | Verify data extraction | userData={'firstName':'John','lastName':'Doe'} | userName='John Doe' | P1 | No |
| AUTH-U016 | Auth/PasskeyState | should handle null userData gracefully | Verify null safety | userData=null | userName=null, userEmail=null, loginId=null | P1 | Yes |
| AUTH-U017 | Auth/BiometricAcceptResult | should store all fields correctly | Verify DTO construction | All fields provided | All fields match input | P1 | No |
| AUTH-U018 | Auth/BiometricDeniedResult | should store all fields correctly | Verify DTO construction | All fields provided | All fields match input | P1 | No |
| AUTH-U019 | Auth/AuthNotifier | should start in unauthenticated state | Verify initial notifier state | New AuthNotifier | state.isUnauthenticated=true | P0 | No |
| AUTH-U020 | Auth/AuthNotifier | should transition to authenticating on userVerify | Verify state transition on login start | Valid username | state transitions to authenticating then authenticated or error | P0 | No |
| AUTH-U021 | Auth/AuthNotifier | should set error state on API failure | Verify error handling | API returns error response | state.hasError=true, errorMessage populated | P0 | No |
| AUTH-U022 | Auth/AuthNotifier | should set error state on network failure | Verify NoInternetException handling | No network connectivity | state.hasError=true, toast shown | P0 | Yes |
| AUTH-U023 | Auth/AuthNotifier | should handle Descope passkey timeout | Verify timeout fallback | Passkey times out | Falls back to OTP flow | P1 | Yes |
| AUTH-U024 | Auth/AuthNotifier | should handle DescopeException gracefully | Verify SDK error handling | Descope throws exception | Error logged, toast shown, state=error | P1 | Yes |
| AUTH-U025 | Auth/EnterOtpNotifier | should initialize with user data from storage | Verify init loads stored data | Secure storage has userData | state.userData populated, state.mobile set | P0 | No |
| AUTH-U026 | Auth/EnterOtpNotifier | should submit OTP via Descope | Verify OTP submission | Valid OTP '123456' | Descope.otp.verify called, success state | P0 | No |
| AUTH-U027 | Auth/EnterOtpNotifier | should handle invalid OTP | Verify error on wrong OTP | Invalid OTP '000000' | Error toast shown, state.loading=false | P0 | Yes |
| AUTH-U028 | Auth/EnterOtpNotifier | should resend OTP successfully | Verify resend flow | Valid loginId in state | Descope.otp.signIn called, success toast | P1 | No |
| AUTH-U029 | Auth/EnterOtpNotifier | should handle biometricAccept result | Verify biometric accept flow | BiometricAcceptResult with authenticated=true | Navigation to inbox | P1 | No |
| AUTH-U030 | Auth/EnterOtpNotifier | should handle biometricDenied result | Verify biometric deny flow | BiometricDeniedResult | Falls back to appropriate screen | P1 | No |
| AUTH-U031 | Auth/PasskeyNotifier | should check passkey support | Verify platform capability check | Device supports passkey | passkeySupported=true | P1 | No |
| AUTH-U032 | Auth/PasskeyNotifier | should enable passkey for user | Verify passkey registration | User logged in, passkey supported | isEnabled=true after success | P1 | No |
| AUTH-U033 | Auth/PasskeyNotifier | should handle passkey enable failure | Verify error on enable failure | Descope throws error | errorMessage set, isEnabled=false | P1 | Yes |
| AUTH-U034 | Auth/AuthAPI | should call userVerify endpoint | Verify API call construction | Request body with username | POST to /auth/descope-login-step-first | P0 | No |
| AUTH-U035 | Auth/AuthAPI | should call userLogin endpoint with refreshable auth | Verify refreshable header injection | Request body + Descope session | POST with authorization header | P0 | No |
| AUTH-U036 | Auth/AuthAPI | should call resendOTP endpoint | Verify resend API call | Request body with loginId | POST to /auth/resend-otp | P1 | No |
| AUTH-U037 | Auth/AuthAPI | should call verifyOTP endpoint | Verify OTP verification API | Request body with OTP | POST to /auth/verify-otp | P0 | No |
| AUTH-U038 | Auth/BiometricService | should return true when biometrics available | Verify availability check | Device has fingerprint/face | isBiometricAvailable()=true | P1 | No |
| AUTH-U039 | Auth/BiometricService | should return false when no biometrics | Verify fallback | No biometric hardware | isBiometricAvailable()=false | P1 | No |
| AUTH-U040 | Auth/BiometricService | should authenticate successfully | Verify auth flow | User confirms biometric | authenticate()=true | P1 | No |
| AUTH-U041 | Auth/BiometricService | should return false on auth failure | Verify rejection | User cancels biometric | authenticate()=false | P1 | Yes |
| AUTH-U042 | Auth/BiometricService | should handle platform exception | Verify error handling | Platform throws error | Returns false, no crash | P1 | Yes |
| AUTH-U043 | Auth/PasskeyNotifier | should validate passkey on-device (platform authenticator) | Verify local passkey auth uses device's own biometric/PIN | Device supports platform authenticator | Passkey validated locally without QR code prompt | P1 | No |
| AUTH-U044 | Auth/PasskeyNotifier | should validate passkey via another device using QR code | Verify cross-device passkey flow shows QR code | Primary device lacks passkey; secondary device available | QR code displayed, cross-device auth completes | P1 | No |
| AUTH-U045 | Auth/PasskeyNotifier | should skip passkey prompt when passkey already registered | Verify no duplicate setup prompt | User already has passkey enabled (isEnabled=true) | Passkey setup screen skipped, navigates directly to inbox | P0 | No |
| AUTH-U046 | Auth/PasskeyNotifier | should skip passkey prompt when device does not support passkeys | Verify graceful skip on unsupported devices | passkeySupported=false | Passkey setup screen skipped, no error, navigates to inbox | P0 | No |
| AUTH-U047 | Auth/ForgotUsername | should reject invalid phone number format | Verify phone validation | Phone number "12345" (less than 10 digits) | Validation error: "Please enter a valid phone number" | P1 | Yes |
| AUTH-U048 | Auth/ForgotUsername | should reject unregistered phone number | Verify API response for unknown phone | Phone not in system, API returns not found | Error message: "No account found with this phone number" | P1 | Yes |
| AUTH-U049 | Auth/ForgotUsername | should reject empty phone number field | Verify empty field validation | Empty phone field, tap Submit | Validation error: "Please enter your phone number" | P1 | Yes |
| AUTH-U050 | Auth/ForgotUsername | should handle inactive account phone lookup | Verify inactive account response | Phone linked to inactive account | Error: "Your account is currently inactive, please contact support" | P1 | Yes |
| AUTH-U051 | Auth/ForgotUsername | should reject incorrect OTP on forgot username flow | Verify OTP validation | Valid phone, incorrect OTP entered | Error: "Invalid OTP, please try again" | P1 | Yes |
| AUTH-U052 | Auth/ForgotUsername | should reject expired OTP on forgot username flow | Verify OTP expiry | Valid phone, OTP expired (>10 min) | Error: "OTP has expired, please request a new OTP" | P1 | Yes |
| AUTH-U053 | Auth/ForgotUsername | should resend OTP on forgot username flow | Verify resend | Valid phone, OTP expired, tap Resend | New OTP sent, confirmation shown | P1 | No |
| AUTH-U054 | Auth/ForgotUsername | should limit failed OTP attempts | Verify attempt limiting | Multiple incorrect OTP entries | Error: "Too many failed attempts. Please try again after some time" | P1 | Yes |
| AUTH-U055 | Auth/ForgotUsername | should reject empty OTP field | Verify empty OTP validation | Valid phone, empty OTP field, tap Submit | Validation error: "Please enter the OTP sent to your phone" | P1 | Yes |
| AUTH-U056 | Auth/ForgotUsername | should display correct username after successful OTP verification | Verify username returned | Valid phone + correct OTP | Username displayed matches account associated with phone number | P0 | No |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| AUTH-W001 | Auth/Login | should render login form with username field | Verify initial render | LoginScreen | Default (unauthenticated) | None | Username field visible, Login button visible | All | All | Both | P0 | No |
| AUTH-W002 | Auth/Login | should show validation error when username empty | Verify form validation | LoginScreen | Empty username | Tap Login button | Validation error message shown | All | All | Both | P0 | Yes |
| AUTH-W003 | Auth/Login | should call userVerify on valid form submit | Verify login action | LoginScreen | Valid username entered | Tap Login button | authProvider.userVerify called | All | All | Both | P0 | No |
| AUTH-W004 | Auth/Login | should show loader during authentication | Verify loading state | LoginScreen | loaderProvider.isLoading=true | None | CircularProgressIndicator visible | All | All | Both | P0 | No |
| AUTH-W005 | Auth/Login | should navigate to OTP screen on success | Verify navigation | LoginScreen | Auth returns success with OTP required | Submit valid form | GoRouter pushes /enter-otp | All | All | Both | P0 | No |
| AUTH-W006 | Auth/Login | should navigate to forgot username | Verify navigation | LoginScreen | Default state | Tap "Forgot Username?" link | GoRouter pushes /forgot-username | All | All | Both | P1 | No |
| AUTH-W007 | Auth/Login | should navigate to signup | Verify signup navigation | LoginScreen | Default state | Tap "No account? Click here" | Web: GoRouter to /signup; Mobile: URL launcher | All | All | Both | P1 | No |
| AUTH-W008 | Auth/Login | should show SnackBar on API error | Verify error display | LoginScreen | API returns error | Submit form | SnackBar with error message | All | All | Both | P0 | No |
| AUTH-W009 | Auth/Login | should render mobile layout on small screen | Verify responsive layout | LoginScreen | Mobile viewport | None | Mobile layout widget rendered | All | Small | Portrait | P1 | No |
| AUTH-W010 | Auth/Login | should render desktop layout on large screen | Verify responsive layout | LoginScreen | Desktop viewport | None | Desktop layout widget rendered | All | Large | Both | P1 | No |
| AUTH-W011 | Auth/Login | should append email domain to username | Verify domain suffix | LoginFormWidget | Username without @optmsg.com | Type username | Domain suffix displayed | All | All | Both | P1 | No |
| AUTH-W012 | Auth/OTP | should render OTP input field | Verify initial render | OtpScreen | pageKey, loginId params | None | OTP input field visible, Submit button visible | All | All | Both | P0 | No |
| AUTH-W013 | Auth/OTP | should show error on empty OTP submit | Verify validation | OtpScreen | Empty OTP | Tap Submit | Error message shown | All | All | Both | P0 | Yes |
| AUTH-W014 | Auth/OTP | should submit OTP and navigate on success | Verify submit flow | OtpScreen | Valid 6-digit OTP entered | Tap Submit | Navigation to inbox or passkey | All | All | Both | P0 | No |
| AUTH-W015 | Auth/OTP | should resend OTP on tap | Verify resend | OtpScreen | State loaded | Tap Resend | enterOtpProvider.resendOtp called, toast shown | All | All | Both | P1 | No |
| AUTH-W016 | Auth/OTP | should render mobile layout | Verify responsive | OtpScreen | Mobile viewport | None | OTP mobile layout rendered | All | Small | Portrait | P1 | No |
| AUTH-W017 | Auth/OTP | should render desktop layout | Verify responsive | OtpScreen | Desktop viewport | None | OTP desktop layout rendered | All | Large | Both | P1 | No |
| AUTH-W018 | Auth/CreateAccount | should render account creation form | Verify initial render | CreateAccountScreen | Default state | None | Username, phone, terms checkboxes visible | All | All | Both | P0 | No |
| AUTH-W019 | Auth/CreateAccount | should validate required fields | Verify validation | CreateAccountScreen | All fields empty | Tap Submit | Validation errors on all required fields | All | All | Both | P0 | Yes |
| AUTH-W020 | Auth/CreateAccount | should check username availability | Verify async validation | CreateAccountScreen | Username entered | Tap out of field | API check for availability | All | All | Both | P1 | No |
| AUTH-W021 | Auth/CreateAccount | should require terms acceptance | Verify checkbox validation | CreateAccountScreen | Form filled, terms unchecked | Tap Submit | Error: must accept terms | All | All | Both | P0 | Yes |
| AUTH-W022 | Auth/CreateAccount | should navigate to login | Verify navigation | CreateAccountScreen | Default state | Tap Login link | GoRouter to /login | All | All | Both | P1 | No |
| AUTH-W023 | Auth/SetupProfile | should render profile form fields | Verify initial render | SetupProfileScreen | Default state | None | First name, last name, DOB fields visible | All | All | Both | P0 | No |
| AUTH-W024 | Auth/SetupProfile | should validate name fields | Verify validation | SetupProfileScreen | Empty names | Tap Submit | Validation errors shown | All | All | Both | P0 | Yes |
| AUTH-W025 | Auth/SetupProfile | should open date picker on DOB tap | Verify date interaction | SetupProfileScreen | Default state | Tap DOB field calendar icon | Date picker dialog shown | All | All | Both | P1 | No |
| AUTH-W026 | Auth/SetupProfile | should validate DOB format | Verify date validation | SetupProfileScreen | Invalid date "13/32/2025" | Submit form | DOB validation error | All | All | Both | P1 | Yes |
| AUTH-W027 | Auth/SetupProfile | should reject future dates | Verify date boundary | SetupProfileScreen | Future date selected | Submit form | Error: date cannot be in future | All | All | Both | P1 | Yes |
| AUTH-W028 | Auth/ForgotUsername | should render recovery form | Verify initial render | ForgotUserName | Default state | None | Phone number field visible | All | All | Both | P1 | No |
| AUTH-W029 | Auth/ForgotUsername | should validate phone number | Verify validation | ForgotUserName | Invalid phone "abc" | Tap Submit | Phone validation error | All | All | Both | P1 | Yes |
| AUTH-W030 | Auth/ForgotUsername | should navigate back to login | Verify navigation | ForgotUserName | Default state | Tap Back | GoRouter to /login | All | All | Both | P1 | No |
| AUTH-W031 | Auth/Passkey | should render passkey setup screen | Verify initial render | AddPassKey | userData with passkey support | None | Enable passkey button visible | iOS, Android | All | Both | P1 | No |
| AUTH-W032 | Auth/Passkey | should show skip option | Verify skip | AddPassKey | Default state | None | Skip button visible | iOS, Android | All | Both | P1 | No |
| AUTH-W033 | Auth/Passkey | should enable passkey on tap | Verify enable flow | AddPassKey | passkeySupported=true | Tap Enable | passkeyNotifier.enablePasskey called | iOS, Android | All | Both | P1 | No |
| AUTH-W034 | Auth/WebLogin | should render web-specific login layout | Verify web layout | WebLogin | Web platform | None | Web container, background, layout rendered | Web | Large | Both | P1 | No |
| AUTH-W035 | Auth/WebOTP | should render web OTP layout | Verify web layout | WebEnterOtp | Web platform | None | Web-styled OTP form rendered | Web | Large | Both | P1 | No |
| AUTH-W036 | Auth/Passkey | should show QR code option for cross-device passkey authentication | Verify cross-device UI | AddPassKey | Device lacks local passkey, cross-device available | None | QR code scan option visible alongside local auth | iOS, Android | All | Both | P1 | No |
| AUTH-W037 | Auth/Passkey | should not show passkey setup when already registered | Verify skip logic in UI | AddPassKey | isEnabled=true (passkey already set) | None | Screen skipped or shows "already configured" state | iOS, Android | All | Both | P0 | No |
| AUTH-W038 | Auth/Passkey | should not show passkey setup when device does not support passkeys | Verify skip logic in UI | AddPassKey | passkeySupported=false | None | Screen skipped, user proceeds without passkey prompt | iOS, Android | All | Both | P0 | No |
| AUTH-W039 | Auth/ForgotUsername | should show OTP screen after valid phone submission | Verify OTP navigation | ForgotUserName | Valid phone entered | Tap Submit | OTP entry screen displayed | All | All | Both | P1 | No |
| AUTH-W040 | Auth/ForgotUsername | should show error for unregistered phone number | Verify error display | ForgotUserName | Unregistered phone | Tap Submit | Error message visible: "No account found" | All | All | Both | P1 | Yes |
| AUTH-W041 | Auth/ForgotUsername | should show resend OTP option on forgot username OTP screen | Verify resend UI | ForgotUsernameOTP | OTP screen displayed | None | Resend OTP link visible | All | All | Both | P1 | No |
| AUTH-W042 | Auth/ForgotUsername | should display recovered username after correct OTP | Verify success display | ForgotUsernameSuccess | Correct OTP entered | Tap Submit | Username displayed with success message | All | All | Both | P0 | No |

### Integration Test Cases

| ID | Feature/Module | Test Case | Description | Components Involved | Preconditions | Expected Outcome | Platform | Screen Size | Orientation | Priority |
|----|----------------|-----------|-------------|---------------------|---------------|------------------|----------|-------------|-------------|----------|
| AUTH-I001 | Auth/LoginFlow | should complete OTP login flow end-to-end | Full login with OTP verification | AuthNotifier + AuthAPI + EnterOtpNotifier + Navigation | Mock API returns success | User navigates Login → OTP → Inbox | All | All | Both | P0 |
| AUTH-I002 | Auth/LoginFlow | should handle expired session and redirect to login | Session expiration flow | AuthNotifier + ApiService + Navigation | API returns 401 | Session cleared, redirected to /login | All | All | Both | P0 |
| AUTH-I003 | Auth/LoginFlow | should complete passkey authentication | Passkey auth flow | AuthNotifier + PasskeyNotifier + Descope | Passkey supported, registered | User authenticates via passkey, navigates to inbox | iOS, Android | All | Both | P1 |
| AUTH-I004 | Auth/LoginFlow | should fall back to OTP when passkey times out | Timeout fallback | AuthNotifier + PasskeyNotifier + EnterOtpNotifier | Passkey times out after threshold | OTP screen shown with pre-filled data | iOS, Android | All | Both | P1 |
| AUTH-I005 | Auth/BiometricFlow | should prompt biometric on app resume | App lifecycle biometric | BiometricService + SecureStorageService + AppLifecycle | Biometric enabled in settings | Biometric prompt shown on resume | iOS, Android | All | Both | P1 |
| AUTH-I006 | Auth/CreateAccountFlow | should complete registration flow | Full signup flow | CreateAccountScreen + AuthAPI + Navigation | Mock API success | User creates account → OTP → Profile Setup → Inbox | All | All | Both | P0 |
| AUTH-I007 | Auth/ForgotFlow | should recover username via phone | Recovery flow | ForgotUserName + AuthAPI + Navigation | Mock API returns username | Phone entered → OTP → Username displayed | All | All | Both | P1 |
| AUTH-I008 | Auth/StorageIntegration | should persist auth state across app restarts | Storage persistence | AuthNotifier + SecureStorageService | Previous successful login | App reads stored auth, skips login | All | All | Both | P0 |

### Flutter Test Notes — Auth Module
- **Required mocks:** MockAuthApi, MockDescopeSession, MockBiometricService, MockSecureStorageService
- **ProviderScope overrides:** `authProvider`, `enterOtpProvider`, `loaderProvider`
- **Wrapper:** `MaterialApp.router` with GoRouter for navigation tests
- **pumpAndSettle:** Required after form submissions (API calls are async)
- **Platform mocks:** `local_auth` platform channel for biometric tests
- **SharedPreferences:** `SharedPreferences.setMockInitialValues({})` for storage tests
- **Descope SDK:** Wrap in abstraction layer; mock the wrapper, not SDK directly

---

## 2. Email / Inbox Module

### Current Coverage Status
- **Existing tests:** None
- **Files involved:**
  - `lib/screens/email/inbox_riverpod/` (inbox_responsive.dart, inbox_notifier.dart, inbox_provider.dart, inbox_state.dart + 8 widget files)
  - `lib/screens/email/draft_riverpod/` (draft_responsive.dart, draft_notifier.dart, draft_provider.dart, draft_state.dart + 3 widget files)
  - `lib/screens/email/archive_riverpod/` (archive_responsive.dart, archive_notifier.dart, archive_provider.dart, archive_state.dart + 6 widget files)
  - `lib/screens/inbox/` (inbox.dart, view_inbox.dart, custom_file_downloader_manager.dart + 3 widget files)
  - `lib/repositories/email/` (inbox_api.dart, draft_api.dart, archive_api.dart)
  - `lib/repositories/inbox/` (inbox_repository.dart, email_detail_repository.dart)
  - `lib/repositories/draft/` (draft_repository.dart)
  - `lib/model/inbox_list_model.dart`, `draft_list_modal.dart`, `sent_list_model.dart`, `view_email_model.dart`, `view_draft_model.dart`
  - `lib/widgets/email_list.dart`, `draft_email_list.dart`, `sent_email_list.dart`, `custom_dismissible.dart`
- **Gaps:** Complete — no test coverage exists

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| EMAIL-U001 | Email/InboxNotifier | should bootstrap with clean state | Verify initial state on bootstrap | New InboxNotifier | items=[], currentPage=1, isLoading=false, selectedEmailIds=[] | P0 | No |
| EMAIL-U002 | Email/InboxNotifier | should load first page of emails | Verify getAllEmails pagination | Mock API returns 20 emails | items.length=20, currentPage=1, isLoading=false | P0 | No |
| EMAIL-U003 | Email/InboxNotifier | should paginate to next page | Verify pagination | Page 1 loaded, nextPage=true | currentPage=2, items appended | P0 | No |
| EMAIL-U004 | Email/InboxNotifier | should stop pagination when no next page | Verify pagination end | API returns nextPage=false | No additional API call on scroll | P1 | No |
| EMAIL-U005 | Email/InboxNotifier | should handle empty inbox | Verify empty state | API returns empty list | items=[], no error | P0 | Yes |
| EMAIL-U006 | Email/InboxNotifier | should mark email as read | Verify status update | Email ID, isRead=true | API called, local state updated | P0 | No |
| EMAIL-U007 | Email/InboxNotifier | should mark email as unread | Verify status toggle | Email ID, isRead=false | API called, local state updated | P0 | No |
| EMAIL-U008 | Email/InboxNotifier | should archive email with undo | Verify archive + undo buffer | Email ID | Email removed from list, undo callback stored | P0 | No |
| EMAIL-U009 | Email/InboxNotifier | should restore email on undo | Verify undo operation | Email archived, undo triggered | Email restored to list | P0 | No |
| EMAIL-U010 | Email/InboxNotifier | should delete email (move to trash) | Verify trash operation | Email ID | Email removed, API called with trash status | P0 | No |
| EMAIL-U011 | Email/InboxNotifier | should add tags to emails | Verify tag addition | Email IDs, tag IDs | API called, local tags updated | P1 | No |
| EMAIL-U012 | Email/InboxNotifier | should remove tags from emails | Verify tag removal | Email IDs, tag IDs to remove | API called, local tags updated | P1 | No |
| EMAIL-U013 | Email/InboxNotifier | should search emails by keyword | Verify search | searchKey='invoice' | Filtered list returned, isSearch=true | P1 | No |
| EMAIL-U014 | Email/InboxNotifier | should clear search and reload | Verify search clear | isSearch=true | searchKey cleared, full list reloaded | P1 | No |
| EMAIL-U015 | Email/InboxNotifier | should select email for reading pane | Verify reading pane selection | Email ID | selectedEmailIdForReadingPane set, selectedEmailIndex set | P0 | No |
| EMAIL-U016 | Email/InboxNotifier | should toggle checkbox selection | Verify multi-select | Email ID toggled | selectedEmailIds includes/excludes ID | P1 | No |
| EMAIL-U017 | Email/InboxNotifier | should select all emails | Verify select all | allEmailIdsFlag=true | All current items selected | P1 | No |
| EMAIL-U018 | Email/InboxNotifier | should handle bulk mark as read | Verify bulk action | 5 emails selected | All 5 marked as read, selection cleared | P1 | No |
| EMAIL-U019 | Email/InboxNotifier | should handle NoInternetException | Verify offline handling | Network unavailable | Toast shown, state preserved | P0 | Yes |
| EMAIL-U020 | Email/InboxNotifier | should handle API error response | Verify error handling | API returns {success:false, message:'error'} | Toast with error, items unchanged | P0 | Yes |
| EMAIL-U021 | Email/InboxNotifier | should refresh list on pull-to-refresh | Verify refresh | Current state with emails | Page reset to 1, fresh data loaded | P1 | No |
| EMAIL-U022 | Email/InboxNotifier | should filter by tag IDs | Verify tag filter | tagIdFilter=[1,2] | API called with tag filter, filtered list returned | P1 | No |
| EMAIL-U023 | Email/InboxNotifier | should toggle filter overlay | Verify UI toggle | showFilter=false | showFilter=true after toggle | P2 | No |
| EMAIL-U024 | Email/InboxNotifier | should toggle tag list overlay | Verify UI toggle | showTagList=false | showTagList=true after toggle | P2 | No |
| EMAIL-U025 | Email/InboxNotifier | should toggle menu options overlay | Verify UI toggle | showMenuOptions=false | showMenuOptions=true after toggle | P2 | No |
| EMAIL-U026 | Email/InboxNotifier | should update reading pane settings | Verify preference persistence | readingPaneEnabled=true | Setting stored, state updated | P1 | No |
| EMAIL-U027 | Email/DraftNotifier | should bootstrap with clean state | Verify initial state | New DraftNotifier | items=[], currentPage=1 | P0 | No |
| EMAIL-U028 | Email/DraftNotifier | should load draft list | Verify draft fetch | Mock API returns drafts | items populated, pagination set | P0 | No |
| EMAIL-U029 | Email/DraftNotifier | should delete selected drafts | Verify bulk delete | 3 draft IDs selected | API called, drafts removed from list | P0 | No |
| EMAIL-U030 | Email/DraftNotifier | should handle empty draft list | Verify empty state | No drafts | items=[], no error | P1 | Yes |
| EMAIL-U031 | Email/DraftNotifier | should reject free user compose | Verify subscription check | isFreeUser=true | Warning toast shown, compose blocked | P1 | No |
| EMAIL-U032 | Email/ArchiveNotifier | should resolve initial route for archive | Verify route-based loading | parentRoute='/archive' | Correct endpoint called for archive | P0 | No |
| EMAIL-U033 | Email/ArchiveNotifier | should resolve initial route for sent | Verify route-based loading | parentRoute='/sent' | Correct endpoint called for sent | P0 | No |
| EMAIL-U034 | Email/ArchiveNotifier | should resolve initial route for trash | Verify route-based loading | parentRoute='/trash' | Correct endpoint called for trash | P0 | No |
| EMAIL-U035 | Email/ArchiveNotifier | should load archive emails | Verify archive fetch | Mock API returns archive emails | items populated | P0 | No |
| EMAIL-U036 | Email/ArchiveNotifier | should update email status (unarchive) | Verify status change | Email ID, isArchive=false | API called, email removed from archive list | P1 | No |
| EMAIL-U037 | Email/EmailDetailNotifier | should load email detail by ID | Verify detail fetch | emailId=123 | ViewEmailModel populated in state | P0 | No |
| EMAIL-U038 | Email/EmailDetailNotifier | should auto-mark as read in background | Verify background read | Email loaded, isRead=false | _markAsReadInBackground called | P0 | No |
| EMAIL-U039 | Email/EmailDetailNotifier | should mark email as unread | Verify unread toggle | Email loaded | markedAsUnread=true, API called | P1 | No |
| EMAIL-U040 | Email/EmailDetailNotifier | should move email to archive | Verify archive action | Email loaded | movedToArchive=true, API called | P1 | No |
| EMAIL-U041 | Email/EmailDetailNotifier | should move email to trash | Verify delete action | Email loaded | movedToTrash=true, API called | P1 | No |
| EMAIL-U042 | Email/EmailDetailNotifier | should add tags to email | Verify tag management | Email loaded, tagIds | updatedTags reflects changes | P1 | No |
| EMAIL-U043 | Email/EmailDetailNotifier | should prepare compose params for reply | Verify reply data | Email with sender info | Compose params include sender as recipient | P1 | No |
| EMAIL-U044 | Email/EmailDetailNotifier | should prepare compose params for forward | Verify forward data | Email with attachments | Compose params include body and attachments | P1 | No |
| EMAIL-U045 | Email/EmailDetailNotifier | should prepare print URL | Verify print URL generation | Email loaded | Valid URL for print preview | P2 | No |
| EMAIL-U046 | Email/EmailDetailNotifier | should handle detail load failure | Verify error state | API returns error | Error message in state | P0 | Yes |
| EMAIL-U047 | Email/InboxRepository | should fetch emails with pagination params | Verify repository call | page=1, limit=20, type='inbox' | InboxApi.getInboxEmails called, Result.success | P0 | No |
| EMAIL-U048 | Email/InboxRepository | should return Result.failure on API error | Verify error wrapping | API throws exception | Result.failure with error message | P0 | Yes |
| EMAIL-U049 | Email/InboxRepository | should return Result.failure on NoInternetException | Verify offline error | Network unavailable | Result.failure('No Internet') | P0 | Yes |
| EMAIL-U050 | Email/InboxRepository | should update email status | Verify status update | key='isRead', emailIds=[1], value=true | API called, Result.success | P0 | No |
| EMAIL-U051 | Email/InboxRepository | should manage email tags | Verify tag operations | emailIds=[1], tagIds=[2], type='add' | API called, Result.success | P1 | No |
| EMAIL-U052 | Email/InboxRepository | should permanently delete emails | Verify permanent delete | emailIds=[1,2] | API called with delete endpoint | P1 | No |
| EMAIL-U053 | Email/InboxRepository | should restore emails from trash | Verify restore | emailIds=[1], restoreType='inbox' | API called, Result.success | P1 | No |
| EMAIL-U054 | Email/DraftRepository | should fetch drafts with pagination | Verify draft fetch | page=1, limit=20 | DraftApi called, Result.success with DraftListModel | P0 | No |
| EMAIL-U055 | Email/DraftRepository | should delete drafts | Verify draft delete | draftIds=[1,2] | DraftApi.deleteDraft called, Result.success | P0 | No |
| EMAIL-U056 | Email/EmailDetailRepository | should fetch email detail | Verify detail fetch | emailId=123 | ApiService.post called, Result.success with ViewEmailModel | P0 | No |
| EMAIL-U057 | Email/InboxListModel | should deserialize from valid JSON | Verify fromJson | Valid inbox JSON | Model fields match JSON | P0 | No |
| EMAIL-U058 | Email/InboxListModel | should handle null data field | Verify null safety | JSON with data=null | Model created with data=null | P0 | Yes |
| EMAIL-U059 | Email/InboxListModel | should serialize to JSON | Verify toJson | Populated model | JSON output matches expected | P1 | No |
| EMAIL-U060 | Email/InboxListModel | should handle email with no attachments | Verify empty arrays | Email JSON with attachments=[] | Model has empty attachments list | P1 | Yes |
| EMAIL-U061 | Email/InboxListModel | should handle email with no tags | Verify empty tags | Email JSON with emailRecipientTags=[] | Model has empty tags list | P1 | Yes |
| EMAIL-U062 | Email/SentListModel | should deserialize from valid JSON | Verify fromJson | Valid sent JSON | Model fields match | P0 | No |
| EMAIL-U063 | Email/SentListModel | should handle nullable receiver fields | Verify null safety | Receiver with null firstName | No crash, firstName=null | P1 | Yes |
| EMAIL-U064 | Email/ViewEmailModel | should deserialize from valid JSON | Verify fromJson | Valid email detail JSON | All nested models populated | P0 | No |
| EMAIL-U065 | Email/ViewEmailModel | should handle email with attachments | Verify attachment parsing | JSON with 3 attachments | attachments.length=3, fields correct | P0 | No |
| EMAIL-U066 | Email/ViewDraftModel | should deserialize from valid JSON | Verify fromJson | Valid draft JSON | All fields correct | P0 | No |
| EMAIL-U067 | Email/DraftListModel | should deserialize from valid JSON | Verify fromJson | Valid draft list JSON | items populated, nextPage correct | P0 | No |
| EMAIL-U068 | Email/OptIn | should trigger opt-in action for unknown sender | Verify opt-in prompt on unknown sender action | Email from sender not in contacts, user taps opt-in | AddEmailModal shown with sender info pre-filled | P1 | No |
| EMAIL-U069 | Email/OptIn | should trigger opt-in via email click (swipe/hover action) | Verify opt-in from email list interaction | Email item, user clicks/swipes opt-in action | Opt-in flow triggered, contact add modal shown | P1 | No |
| EMAIL-U070 | Email/OptIn | should handle opt-in on send for single recipient | Verify opt-in prompt when sending to non-contact | Compose with 1 recipient not in contacts | AddEmailModal shown for single recipient before send | P0 | No |
| EMAIL-U071 | Email/OptIn | should handle opt-in on send for multiple recipients | Verify sequential opt-in for each non-contact recipient | Compose with 3 recipients, 2 not in contacts | AddEmailModal shown sequentially for each non-contact | P0 | No |
| EMAIL-U072 | Email/OptIn | should handle cancel during opt-in on send | Verify cancel aborts send | Opt-in modal shown, user taps Cancel | Email send aborted, returned to compose | P1 | No |
| EMAIL-U073 | Email/OptIn | should handle skip during opt-in on send | Verify skip proceeds without saving contact | Opt-in modal shown, user taps Skip | Contact not saved, proceeds to next recipient or sends | P1 | No |
| EMAIL-U074 | Email/OptIn | should handle skip all during opt-in on send | Verify skip all bypasses remaining opt-in prompts | Multiple non-contact recipients, user taps Skip All | All remaining opt-in modals skipped, email sent | P1 | No |
| EMAIL-U075 | Email/InternalMessaging | should send internal OptMsg message | Verify internal message delivery | Compose to OptMsg user, tap Send | Socket emit called, message appears in recipient inbox | P0 | No |
| EMAIL-U076 | Email/InternalMessaging | should receive internal OptMsg message | Verify internal message receipt via socket | Socket emits newMessage for internal msg | Email appears in inbox list, unread count updates | P0 | No |
| EMAIL-U077 | Email/ExternalMessaging | should send external email | Verify external email delivery | Compose to external address, tap Send | API called to send external email, success toast | P0 | No |
| EMAIL-U078 | Email/ExternalMessaging | should receive external email | Verify external email receipt | External email arrives via API/socket | Email appears in inbox list with external sender info | P0 | No |
| EMAIL-U079 | Email/Attachments | should download single attachment | Verify single file download | Email with attachment, tap download | File downloaded, success indicator shown | P1 | No |
| EMAIL-U080 | Email/Attachments | should download all attachments | Verify batch download | Email with 3 attachments, tap Download All | All files downloaded, progress/completion shown | P1 | No |
| EMAIL-U081 | Email/Attachments | should open attachment | Verify file open/preview | Downloaded attachment, tap Open | File opens in appropriate viewer/app | P1 | No |
| EMAIL-U082 | Email/MoveMessage | should move email from Inbox to Archive | Verify folder move | Email in Inbox, move to Archive | Email removed from Inbox, appears in Archive, API called | P0 | No |
| EMAIL-U083 | Email/MoveMessage | should move email from Inbox to Trash | Verify folder move | Email in Inbox, move to Trash | Email removed from Inbox, appears in Trash | P0 | No |
| EMAIL-U084 | Email/MoveMessage | should move email from Trash to Inbox | Verify restore | Email in Trash, move to Inbox | Email removed from Trash, appears in Inbox | P0 | No |
| EMAIL-U085 | Email/MoveMessage | should move email from Archive to Inbox | Verify restore | Email in Archive, move to Inbox | Email removed from Archive, appears in Inbox | P1 | No |
| EMAIL-U086 | Email/MoveMessage | should undo move action | Verify undo | Email moved to Archive, tap Undo | Email restored to original folder | P1 | No |
| EMAIL-U087 | Email/MoveMessage | should move multiple emails between folders | Verify batch move | 3 emails selected, move to Archive | All 3 removed from Inbox, appear in Archive | P1 | No |
| EMAIL-U088 | Email/Compose/CC_BCC | should add CC recipients to compose | Verify CC field | Compose with CC recipient added | CC field populated, included in API send payload | P1 | No |
| EMAIL-U089 | Email/Compose/CC_BCC | should add BCC recipients to compose | Verify BCC field | Compose with BCC recipient added | BCC field populated, recipients hidden from other recipients | P1 | No |
| EMAIL-U090 | Email/Compose/CC_BCC | should add multiple CC and BCC recipients | Verify multi-recipient | 2 CC + 2 BCC | All recipients included in send payload correctly | P1 | No |
| EMAIL-U091 | Email/Compose/CC_BCC | should validate CC/BCC email formats | Verify email validation | Invalid CC email entered | Validation error for invalid CC/BCC addresses | P1 | Yes |
| EMAIL-U092 | Email/Search | should sort search results by date | Verify sort order | searchKey='invoice', sort=date | Results returned sorted by most recent first | P1 | No |
| EMAIL-U093 | Email/Search | should return search results within performance threshold | Verify search performance | Large inbox (500+ emails), searchKey='test' | Results returned within 2 seconds | P1 | No |
| EMAIL-U094 | Email/Search | should display search suggestions/autocomplete | Verify suggestions | Partial search term typed | Suggestion list appears with matching contacts/subjects | P2 | No |
| EMAIL-U095 | Email/Search | should dismiss suggestion list on blur | Verify dismiss | Suggestion list visible, user taps outside | Suggestion list disappears | P2 | No |
| EMAIL-U096 | Email/Compose/Paste | should format pasted text with default font style | Verify paste formatting | Text copied from external source with different font | Pasted text matches app's default font style | P1 | No |
| EMAIL-U097 | Email/Compose/Paste | should render pasted HTML content correctly | Verify HTML paste | HTML content pasted into compose body | HTML elements render correctly (bold, links, images) | P1 | No |
| EMAIL-U098 | Email/Print | should generate print URL for email | Verify print URL | Email loaded, user taps Print | Valid print-preview URL generated | P2 | No |
| EMAIL-U099 | Email/Print | should handle print to PDF | Verify PDF print | Email loaded, user selects Print to PDF | Email content formatted correctly for PDF output | P2 | No |
| EMAIL-U100 | Email/Sent | should display sent email with correct recipient details | Verify sent details | Sent email with To, CC, BCC | All recipient fields displayed correctly in sent view | P1 | No |
| EMAIL-U101 | Email/Sent | should forward a sent email | Verify forward | Sent email selected, tap Forward | Compose opens with original body and attachments pre-filled | P1 | No |
| EMAIL-U102 | Email/BouncedMessage | should return bounced message for Lapsed user (internal) | Verify bounce | Internal sender sends to Lapsed user | Sender receives bounced message indicating delivery failure | P1 | No |
| EMAIL-U103 | Email/BouncedMessage | should return bounced message for Inactive user (internal) | Verify bounce | Internal sender sends to Inactive user | Sender receives bounced message | P1 | No |
| EMAIL-U104 | Email/BouncedMessage | should return bounced message for Suspended user (internal) | Verify bounce | Internal sender sends to Suspended user | Sender receives bounced message | P1 | No |
| EMAIL-U105 | Email/BouncedMessage | should return bounced message for Deleted user (internal) | Verify bounce | Internal sender sends to Deleted user | Sender receives bounced message | P1 | No |
| EMAIL-U106 | Email/BouncedMessage | should return bounced message for Lapsed user (external) | Verify bounce | External sender sends to Lapsed user | External sender receives bounced message | P1 | No |
| EMAIL-U107 | Email/BouncedMessage | should return bounced message for Inactive user (external) | Verify bounce | External sender sends to Inactive user | External sender receives bounced message | P1 | No |
| EMAIL-U108 | Email/BouncedMessage | should not return bounced message for Active user | Verify no bounce | Sender sends to Active user | Email delivered successfully, no bounce | P0 | No |
| EMAIL-U109 | Email/BouncedMessage | should return bounced message for invalid email address | Verify invalid bounce | Sender sends to invalid@example.com | Bounced message returned indicating invalid address | P1 | Yes |
| EMAIL-U110 | Email/UndoAction | should restore trashed email on undo | Verify trash undo | Email moved to trash, undo triggered within timeout | Email restored to inbox, trash count decremented, inbox count incremented | P0 | No |
| EMAIL-U111 | Email/UndoAction | should restore all bulk-archived emails on undo | Verify bulk archive undo | 5 emails archived via bulk action, undo triggered | All 5 emails restored to inbox, archive count decremented by 5 | P1 | No |
| EMAIL-U112 | Email/UndoAction | should restore all bulk-trashed emails on undo | Verify bulk trash undo | 3 emails trashed via bulk action, undo triggered | All 3 emails restored to inbox, trash count decremented by 3 | P1 | No |
| EMAIL-U113 | Email/UndoAction | should make action permanent after undo timeout expires | Verify undo expiry | Email archived, undo timeout (e.g., 5 seconds) elapses without tap | Undo callback invalidated, email permanently archived, no restore possible | P1 | Yes |
| EMAIL-U114 | Email/UndoAction | should undo move-to-folder and restore to original folder | Verify folder move undo | Email moved from Sent to Archive, undo triggered | Email restored to Sent (original folder), not Inbox | P1 | No |
| EMAIL-U115 | Email/UndoAction | should handle rapid undo-redo correctly | Verify undo idempotency | Email archived, undo triggered, then same email archived again immediately | Each action produces a valid undo, no duplicate entries | P2 | Yes |
| EMAIL-U116 | Email/UndoAction | should only allow single undo per action (no double-undo) | Verify single undo | Email trashed, undo triggered, undo tapped again | Second undo tap has no effect, email remains in inbox | P1 | Yes |
| EMAIL-U117 | Email/DefaultClient | should process valid mailto URI and store email in SecureStorage | Verify _processEmailUri stores email | mailto:user@example.com URI received | CommonService.isValidEmail passes, secureStorageService.writeData('mailto', 'user@example.com') called | P0 | No |
| EMAIL-U118 | Email/DefaultClient | should reject invalid mailto URI and not store | Verify _processEmailUri validates email | mailto:not-an-email URI received | CommonService.isValidEmail fails, secureStorageService.writeData NOT called | P0 | Yes |
| EMAIL-U119 | Email/DefaultClient | should handle empty mailto URI path | Verify _processEmailUri handles empty | mailto: URI with empty path | No data stored, no crash | P1 | Yes |
| EMAIL-U120 | Email/DefaultClient | should handle initial deep link on app launch (AppLinks.getInitialLink) | Verify _handleIncomingLinks processes initial URI | App launched via mailto: deep link | _processEmailUri called with initial URI | P0 | No |
| EMAIL-U121 | Email/DefaultClient | should listen for incoming mailto URIs via AppLinks stream | Verify _handleIncomingLinks stream listener | App running, new mailto: URI arrives | _processEmailUri called for each incoming URI | P0 | No |
| EMAIL-U122 | Email/DefaultClient | should ignore non-mailto URIs from AppLinks stream | Verify URI scheme filtering | https://example.com URI arrives via AppLinks | _processEmailUri NOT called | P1 | Yes |
| EMAIL-U123 | Email/DefaultClient | should retrieve initial email via Android platform channel | Verify _retrieveInitialEmail on Android | Android, platform.invokeMethod('getInitialEmail') returns 'test@example.com' | _processEmailUri called with mailto:test@example.com | P0 | No |
| EMAIL-U124 | Email/DefaultClient | should handle null initial email on Android | Verify _retrieveInitialEmail null case | Android, platform.invokeMethod('getInitialEmail') returns null | No _processEmailUri call, no crash | P1 | Yes |
| EMAIL-U125 | Email/DefaultClient | should handle Android newIntent with email | Verify newIntent method handler | Android, platform method handler receives 'newIntent' with email argument | _processEmailUri called with mailto email | P0 | No |
| EMAIL-U126 | Email/DefaultClient | should read stored mailto and build compose URL on inbox start | Verify _handleMailToOnStart | SecureStorage contains 'mailto'='user@example.com', authenticated | Compose URL built with toEmail=user@example.com, mailto key cleared from storage | P0 | No |
| EMAIL-U127 | Email/DefaultClient | should skip mailto handling when storage is empty | Verify _handleMailToOnStart with no mailto | SecureStorage 'mailto' is null or empty | No compose URL built, no navigation | P1 | Yes |
| EMAIL-U128 | Email/DefaultClient | should skip mailto handling when user is not authenticated | Verify _handleMailToOnStart unauthenticated | SecureStorage has mailto, userData or token is null | No navigation, mailto remains cleared | P1 | Yes |
| EMAIL-U129 | Email/DefaultClient | should handle mailto link tapped in email body (view_inbox) | Verify mailto link handler in email detail | Email body contains mailto:recipient@example.com link, user taps | Email address copied to clipboard or compose opened with recipient | P1 | No |
| EMAIL-U130 | Email/DefaultClient | should handle mailto link tapped in static pages | Verify mailto handler in StaticPages | Static page HTML contains mailto:support@optmsg.com, user taps | Compose URL built with toEmail=support@optmsg.com | P1 | No |
| EMAIL-U131 | Email/Draft/AutoSave | should auto-save draft after inactivity period | Verify auto-save | Compose with content, user stops typing for auto-save interval | Draft saved automatically without user action | P1 | No |
| EMAIL-U132 | Email/Draft/AutoSave | should handle auto-save failure on network disconnect | Verify auto-save offline | Compose with content, network disconnected during auto-save | Warning shown, draft retained locally for retry | P1 | Yes |
| EMAIL-U133 | Email/Compose/Attachments | should reject unsupported file types | Verify file type filtering | User attaches .php or .java file not in allowed extensions | Error message shown, file not attached | P1 | Yes |
| EMAIL-U134 | Email/Inbox/Sync | should sync unread status across multiple devices | Verify cross-device sync | Email marked as unread on Device A | Device B shows same email as unread after sync | P1 | No |
| EMAIL-U135 | Email/Compose/Keyboard | should move focus to next field on Tab key press | Verify Tab navigation | Compose screen, cursor in To field | Press Tab | Focus moves to Subject field | P2 | No |
| EMAIL-U136 | Email/Compose/Keyboard | should move focus to previous field on Shift+Tab | Verify reverse Tab navigation | Compose screen, cursor in Subject field | Press Shift+Tab | Focus moves to To field | P2 | No |
| EMAIL-U137 | Email/Compose/Keyboard | should Tab through all compose fields sequentially | Verify full Tab cycle | Compose screen, cursor in first field | Press Tab repeatedly | Focus moves through To → CC → BCC → Subject → Body | P2 | No |
| EMAIL-U138 | Email/Compose/Keyboard | should handle Tab on last input field | Verify Tab boundary | Compose screen, cursor in last field (Body) | Press Tab | Focus moves to next interactive element (e.g., Send button) or stays | P2 | No |
| EMAIL-U139 | Email/Trash/NonContact | should route email from non-contact sender to Trash | Verify unknown sender routing | New email arrives from sender not in user contacts | Email appears in Trash folder instead of Inbox | P1 | No |
| EMAIL-U140 | Email/Print/OfflinePrinter | should handle print failure when printer is offline | Verify offline printer error | Email loaded, user taps Print, printer offline | Error message displayed indicating printer offline | P2 | Yes |
| EMAIL-U141 | Email/Print/PrinterQueue | should handle print when printer queue is full | Verify queue handling | Email loaded, user taps Print, printer queue full | Email added to queue or informational message shown | P2 | Yes |
| EMAIL-U142 | Email/Print/CorruptedEmail | should handle print failure for corrupted email content | Verify corrupted content | Email with incomplete/unreadable format, user taps Print | Error message or print prevented | P2 | Yes |
| EMAIL-U143 | Email/Inbox/ConcurrentDeletion | should handle race condition when email is deleted from another session during read | Verify concurrent deletion | Email visible in inbox list, deleted from another device/session, user taps to open | API returns 404/not found; error message shown ("Message not found" or similar), user redirected to inbox | P1 | Yes |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| EMAIL-W001 | Email/Inbox | should render inbox email list | Verify list rendering | InboxResponsive | State with 5 emails | None | 5 EmailList items visible | All | Small | Portrait | P0 | No |
| EMAIL-W002 | Email/Inbox | should show skeleton loader while loading | Verify loading state | InboxResponsive | isLoading=true | None | SkeletonLoader visible | All | All | Both | P0 | No |
| EMAIL-W003 | Email/Inbox | should show empty state when no emails | Verify empty state | InboxResponsive | items=[] | None | NoData widget visible | All | All | Both | P0 | Yes |
| EMAIL-W004 | Email/Inbox | should navigate to compose on FAB tap | Verify compose navigation | InboxResponsive | Default state | Tap FAB | Navigation to /compose | All | Small | Portrait | P0 | No |
| EMAIL-W005 | Email/Inbox | should show search bar | Verify search presence | InboxResponsive | Default state | None | SearchBar visible | All | All | Both | P1 | No |
| EMAIL-W006 | Email/Inbox | should filter emails on search | Verify search interaction | InboxResponsive | Emails loaded | Type in search bar | inboxProvider.getAllEmails called with searchKey | All | All | Both | P1 | No |
| EMAIL-W007 | Email/Inbox | should show desktop layout with reading pane | Verify desktop layout | InboxResponsive | Desktop viewport, readingPaneEnabled=true | None | SideMenu + EmailList + ReadingPane visible | Web | Large | Both | P0 | No |
| EMAIL-W008 | Email/Inbox | should show mobile layout without reading pane | Verify mobile layout | InboxResponsive | Mobile viewport | None | Full-width email list, bottom nav | All | Small | Portrait | P0 | No |
| EMAIL-W009 | Email/Inbox | should show tablet landscape with reading pane | Verify tablet layout | InboxResponsive | Tablet landscape | None | List + reading pane side by side | iOS, Android | Medium | Landscape | P1 | No |
| EMAIL-W010 | Email/Inbox | should show tablet portrait as mobile | Verify tablet portrait fallback | InboxResponsive | Native tablet portrait | None | Mobile layout (no reading pane) | iOS, Android | Medium | Portrait | P1 | No |
| EMAIL-W011 | Email/Inbox | should select email and show in reading pane | Verify reading pane | InboxResponsive | Desktop with emails | Tap email item | Email content shown in reading pane | Web | Large | Both | P0 | No |
| EMAIL-W012 | Email/Inbox | should enter multi-select mode on long press | Verify selection | InboxResponsive | Emails loaded | Long-press email | Checkboxes appear, action bar shows | All | Small | Portrait | P1 | No |
| EMAIL-W013 | Email/Inbox | should show action bar with archive/delete/tag | Verify action bar | InboxResponsive | Emails selected | None | Archive, Delete, Tag buttons visible | All | All | Both | P1 | No |
| EMAIL-W014 | Email/Inbox | should show upgrade popup for free users | Verify upgrade prompt | InboxResponsive | isFreeUser=true, first login | None | UpgradePlanPopup shown | All | All | Both | P1 | No |
| EMAIL-W015 | Email/Inbox | should show filter overlay on filter tap | Verify filter UI | InboxResponsive | Default state | Tap filter icon | Filter overlay visible | All | All | Both | P1 | No |
| EMAIL-W016 | Email/Inbox | should show notification badge | Verify badge | InboxResponsive | newNotification=true | None | Notification icon has badge | All | All | Both | P2 | No |
| EMAIL-W017 | Email/Draft | should render draft list | Verify draft rendering | DraftResponsive | State with 3 drafts | None | 3 DraftEmailList items visible | All | Small | Portrait | P0 | No |
| EMAIL-W018 | Email/Draft | should navigate to compose on draft tap | Verify draft resume | DraftResponsive | Draft loaded | Tap draft | Navigation to compose with draft data | All | All | Both | P0 | No |
| EMAIL-W019 | Email/Draft | should delete drafts on selection | Verify delete | DraftResponsive | 2 drafts selected | Tap delete | draftProvider.deleteDrafts called | All | All | Both | P0 | No |
| EMAIL-W020 | Email/Draft | should show empty state for no drafts | Verify empty | DraftResponsive | items=[] | None | NoData widget | All | All | Both | P1 | Yes |
| EMAIL-W021 | Email/Archive | should render archive email list | Verify archive rendering | ArchiveResponsive | parentRoute='/archive', 5 items | None | 5 SentEmailList items | All | Small | Portrait | P0 | No |
| EMAIL-W022 | Email/Archive | should render sent email list | Verify sent rendering | ArchiveResponsive | parentRoute='/sent', 3 items | None | 3 SentEmailList items | All | Small | Portrait | P0 | No |
| EMAIL-W023 | Email/Archive | should render trash email list | Verify trash rendering | ArchiveResponsive | parentRoute='/trash', 2 items | None | 2 SentEmailList items | All | Small | Portrait | P0 | No |
| EMAIL-W024 | Email/Archive | should show restore option in trash | Verify trash action | ArchiveResponsive | parentRoute='/trash', email selected | None | Restore button visible | All | All | Both | P1 | No |
| EMAIL-W025 | Email/Archive | should show permanent delete in trash | Verify permanent delete | ArchiveResponsive | parentRoute='/trash', email selected | None | Permanent Delete visible | All | All | Both | P1 | No |
| EMAIL-W026 | Email/EmailList | should render email item with sender name | Verify rendering | EmailList | item=Emails with sender | None | Sender name, subject, preview visible | All | All | Both | P0 | No |
| EMAIL-W027 | Email/EmailList | should show unread indicator dot | Verify unread | EmailList | item.isRead=false | None | Blue dot visible | All | All | Both | P0 | No |
| EMAIL-W028 | Email/EmailList | should not show dot for read emails | Verify read state | EmailList | item.isRead=true | None | No blue dot | All | All | Both | P0 | No |
| EMAIL-W029 | Email/EmailList | should show attachment icon when attachments exist | Verify attachment indicator | EmailList | item with 2 attachments | None | Attachment icon visible | All | All | Both | P1 | No |
| EMAIL-W030 | Email/EmailList | should show tag chips | Verify tag display | EmailList | item with 2 tags | None | 2 tag chips visible | All | All | Both | P1 | No |
| EMAIL-W031 | Email/EmailList | should show hover actions on desktop | Verify hover | EmailList | Desktop, hovering | Mouse hover | Archive, Delete, Opt-In icons appear | Web | Large | Both | P1 | No |
| EMAIL-W032 | Email/EmailList | should trigger long press selection | Verify long press | EmailList | Default | Long press | Checkbox appears, onLongPress called | All | Small | Portrait | P1 | No |
| EMAIL-W033 | Email/EmailList | should handle community status flag | Verify community | EmailList | item with communityStatus=true | None | Community flag icon visible | All | All | Both | P2 | No |
| EMAIL-W034 | Email/DraftEmailList | should render draft item | Verify rendering | DraftEmailList | item=Draft email | None | Subject, preview, date visible | All | All | Both | P0 | No |
| EMAIL-W035 | Email/DraftEmailList | should show hover delete on desktop | Verify hover | DraftEmailList | Desktop hover | Mouse hover | Delete icon appears | Web | Large | Both | P1 | No |
| EMAIL-W036 | Email/SentEmailList | should render sent item with recipients | Verify rendering | SentEmailList | item=Sent email | None | Recipient name, subject visible | All | All | Both | P0 | No |
| EMAIL-W037 | Email/SentEmailList | should show context-appropriate actions | Verify actions | SentEmailList | emailType='trash' | Hover/Select | Move to Inbox visible | All | All | Both | P1 | No |
| EMAIL-W038 | Email/CustomDismissible | should swipe left for actions | Verify swipe left | CustomDismissible | Email item | Swipe left | Action buttons revealed | iOS, Android | Small | Portrait | P1 | No |
| EMAIL-W039 | Email/CustomDismissible | should swipe right for opt-in | Verify swipe right | CustomDismissible | Email item | Swipe right | Opt-In action triggered | iOS, Android | Small | Portrait | P1 | No |
| EMAIL-W040 | Email/ReadingPane | should render email content in reading pane | Verify reading pane content | ReadingPaneWidget | selectedEmail data | None | Subject, sender, body, attachments visible | Web | Large | Both | P0 | No |
| EMAIL-W041 | Email/ReadingPane | should show empty state when no email selected | Verify empty pane | ReadingPaneWidget | No selection | None | "Select an email" message | Web | Large | Both | P1 | Yes |
| EMAIL-W042 | Email/ReadingPane | should toggle reading pane on and off | Verify reading pane toggle | InboxResponsive | Desktop viewport, readingPaneEnabled=true | Tap reading pane toggle | Reading pane hides/shows, email list adjusts width | Web | Large | Both | P1 | No |
| EMAIL-W043 | Email/EmailList | should toggle message between read and unread states | Verify read/unread toggle via UI action | EmailList | item.isRead=false | Tap read/unread toggle action | Blue dot appears/disappears, API called to update status | All | All | Both | P1 | No |
| EMAIL-W044 | Email/Attachments | should show attachment bar with icons for each attachment | Verify attachment bar rendering | AttachmentBar/EmailDetail | Email with 3 attachments | None | 3 attachment icons visible with filenames | All | All | Both | P1 | No |
| EMAIL-W045 | Email/Attachments | should wrap attachment icons correctly when exceeding row width | Verify attachment bar wrapping | AttachmentBar/EmailDetail | Email with 8+ attachments | None | Icons wrap to next row, all visible via scroll/wrap | All | Small | Both | P1 | Yes |
| EMAIL-W046 | Email/Attachments | should show download all button when multiple attachments | Verify batch download button | AttachmentBar/EmailDetail | Email with 2+ attachments | None | "Download All" button visible | All | All | Both | P1 | No |
| EMAIL-W047 | Email/Attachments | should trigger single attachment download on tap | Verify download action | AttachmentBar/EmailDetail | Email with attachment | Tap attachment download icon | Download initiated, progress indicator shown | All | All | Both | P1 | No |
| EMAIL-W048 | Email/Attachments | should open attachment on tap | Verify open action | AttachmentBar/EmailDetail | Downloaded attachment | Tap attachment | File opens in viewer/browser | All | All | Both | P1 | No |
| EMAIL-W049 | Email/Compose | should hide CC/BCC fields by default in compose | Verify CC/BCC hidden | ComposeScreen | Default compose state | None | CC/BCC fields collapsed/hidden, expand option visible | All | All | Both | P1 | No |
| EMAIL-W050 | Email/Compose | should expand CC/BCC fields on demand | Verify CC/BCC expand | ComposeScreen | CC/BCC hidden | Tap CC/BCC expand option | CC/BCC input fields become visible and editable | All | All | Both | P1 | No |
| EMAIL-W051 | Email/Compose | should collapse CC/BCC fields when empty and unfocused | Verify auto-collapse | ComposeScreen | CC/BCC expanded, fields empty | Tap outside CC/BCC | CC/BCC fields collapse back to hidden | All | All | Both | P1 | No |
| EMAIL-W052 | Email/Compose | should retain CC/BCC fields when populated | Verify retention | ComposeScreen | CC=test@example.com | Tap outside CC | CC field remains visible with address | All | All | Both | P1 | No |
| EMAIL-W053 | Email/Compose | should hide CC/BCC in direct reply | Verify reply compose | ComposeScreen | Reply to email (no original CC/BCC) | None | CC/BCC hidden for direct reply | All | All | Both | P1 | No |
| EMAIL-W054 | Email/Compose | should pre-fill CC on reply-all | Verify reply-all | ComposeScreen | Reply-all to email with CC recipients | None | CC field pre-populated with original CC recipients | All | All | Both | P1 | No |
| EMAIL-W055 | Email/MoveMessage | should show undo toast after moving email to Archive | Verify undo UI | InboxResponsive | Email moved to Archive | None | Undo toast appears with "Moved to Archive" + Undo button | All | All | Both | P1 | No |
| EMAIL-W056 | Email/MoveMessage | should show undo toast after moving email to Trash | Verify undo UI | InboxResponsive | Email moved to Trash | None | Undo toast appears with "Moved to Trash" + Undo button | All | All | Both | P1 | No |
| EMAIL-W057 | Email/Search | should show search suggestion list on input | Verify suggestions UI | CustomSearchBar/InboxResponsive | Text entered in search | Type search text | Suggestion/autocomplete list visible below search bar | All | All | Both | P2 | No |
| EMAIL-W058 | Email/Search | should dismiss suggestion list when search bar loses focus | Verify dismiss | CustomSearchBar/InboxResponsive | Suggestion list visible | Tap outside search | Suggestion list disappears | All | All | Both | P2 | No |
| EMAIL-W059 | Email/Print | should show print option in email detail actions | Verify print button | EmailDetailScreen | Email loaded | None | Print action/icon visible in action bar | Web | Large | Both | P2 | No |
| EMAIL-W060 | Email/Sent | should display recipient To, CC, BCC details in sent email | Verify sent details | SentEmailDetail | Sent email with CC+BCC | None | To, CC visible; BCC labeled appropriately | All | All | Both | P1 | No |
| EMAIL-W061 | Email/Sent | should show Forward button in sent email detail | Verify forward action | SentEmailDetail | Sent email loaded | None | Forward button visible | All | All | Both | P1 | No |
| EMAIL-W062 | Email/UndoAction | should restore archived email to inbox list on undo tap | Verify archive undo action | InboxResponsive | Email archived, undo toast visible | Tap Undo button | Email re-appears in inbox list, toast dismisses | All | All | Both | P0 | No |
| EMAIL-W063 | Email/UndoAction | should restore trashed email to inbox list on undo tap | Verify trash undo action | InboxResponsive | Email trashed, undo toast visible | Tap Undo button | Email re-appears in inbox list, toast dismisses | All | All | Both | P0 | No |
| EMAIL-W064 | Email/UndoAction | should restore all bulk-archived emails on undo tap | Verify bulk archive undo | InboxResponsive | 3 emails archived, undo toast "[3] emails archived" | Tap Undo button | All 3 emails re-appear in inbox list | All | All | Both | P1 | No |
| EMAIL-W065 | Email/UndoAction | should restore all bulk-trashed emails on undo tap | Verify bulk trash undo | InboxResponsive | 3 emails trashed, undo toast "[3] emails moved to trash" | Tap Undo button | All 3 emails re-appear in inbox list | All | All | Both | P1 | No |
| EMAIL-W066 | Email/UndoAction | should auto-dismiss undo toast after timeout | Verify undo expiry UI | InboxResponsive | Email archived, undo toast visible | Wait for toast timeout (pump 5s) | Toast auto-dismisses, undo no longer available | All | All | Both | P1 | Yes |
| EMAIL-W067 | Email/UndoAction | should restore moved email to original folder on undo tap | Verify move undo action | InboxResponsive | Email moved from Inbox to Archive, undo toast visible | Tap Undo button | Email re-appears in Inbox (not just any folder) | All | All | Both | P1 | No |
| EMAIL-W068 | Email/UndoAction | should update sidebar/drawer counts after undo | Verify count sync on undo | InboxResponsive + SideMenu/MyDrawer | Email archived (inbox count -1, archive count +1), undo toast visible | Tap Undo button | Inbox count +1, archive count -1, counts match actual email positions | All | All | Both | P1 | No |
| EMAIL-W069 | Email/DefaultClient | should render mailto link in email body as tappable | Verify mailto rendering | ViewInbox | Email body contains mailto:user@example.com | None | mailto link rendered as tappable/clickable element | All | All | Both | P1 | No |
| EMAIL-W070 | Email/DefaultClient | should open compose on mailto link tap in email body | Verify mailto tap | ViewInbox | Email body with mailto link | Tap mailto link | Compose screen opens with recipient pre-filled | All | All | Both | P1 | No |
| EMAIL-W071 | Email/DefaultClient | should render mailto link in static page HTML as tappable | Verify mailto in static pages | StaticPages | HTML content with mailto:support@optmsg.com | None | mailto link rendered as tappable element | All | All | Both | P1 | No |
| EMAIL-W072 | Email/DefaultClient | should open compose on mailto link tap in static page | Verify static page mailto tap | StaticPages | HTML with mailto link | Tap mailto link | Compose URL built with toEmail, navigation triggered | All | All | Both | P1 | No |

### Flutter Test Notes — Email Module
- **Required mocks:** MockInboxApi, MockDraftApi, MockArchiveApi, MockInboxRepository, MockEmailDetailRepository, MockDraftRepository, MockSocketService, MockAppLinks (for mailto deep link tests), MockSecureStorageService (for mailto storage), MockMethodChannel (for Android platform channel)
- **ProviderScope overrides:** `inboxProvider`, `draftProvider`, `archiveProvider`, `emailDetailProvider`, `bottomNavProvider`, `tagsNotifierProvider`, `loaderProvider`
- **Wrapper:** `MaterialApp.router` with GoRouter, `ProviderScope`
- **pumpAndSettle:** Required after loading states (600ms delay), search debounce
- **pump(Duration):** Use `pump(Duration(milliseconds: 700))` for loading delay
- **Window size overrides for responsive tests:**
  - Small: `Size(375, 667)` portrait
  - Medium: `Size(768, 1024)` portrait, `Size(1024, 768)` landscape
  - Large: `Size(1440, 900)`
- **Socket mock:** Need to emit events like 'unReadCount', 'newMessage', 'notificationExists'
- **Golden test candidates:** SkeletonLoader variants, ReadingPane layout, EmailList item

---

## 3. Contacts Module

### Current Coverage Status
- **Existing tests:** None
- **Files involved:**
  - `lib/screens/contacts/contacts_riverpod/` (contact_list_river_prod.dart, contact_list_notifier.dart, contact_list_provider.dart, contact_state.dart + layout files)
  - `lib/screens/contacts/add_contact_riverpod/` (add_contact_riverpod.dart, add_contact_notifier.dart, add_contact_provider.dart + layouts)
  - `lib/screens/contacts/edit_contact_riverpod/` (edit_contct_riverpod.dart, edit_contact_notifier.dart, edit_contact_provider.dart + layouts)
  - `lib/screens/contacts/view_contact_riverpod/` (view_contact_riverpod.dart, view_contact_notifier.dart, view_contact_provider.dart + layouts)
  - `lib/screens/contacts/import_contact.dart`
  - `lib/repositories/contact/` (contact_api.dart, contact_repository.dart)
  - `lib/model/contact_list_model.dart`, `contact_email_details.dart`, `request_add_contact_modal.dart`, `search_email_model.dart`
- **Gaps:** Complete — no test coverage exists

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| CONT-U001 | Contact/ContactListNotifier | should initialize with empty state | Verify initial state | New notifier | contacts=[], filteredContacts=[], isLoading=false | P0 | No |
| CONT-U002 | Contact/ContactListNotifier | should load all contacts | Verify fetch | Mock API returns 10 contacts | contacts.length=10 | P0 | No |
| CONT-U003 | Contact/ContactListNotifier | should handle empty contact list | Verify empty state | API returns no contacts | contacts=[], no error | P0 | Yes |
| CONT-U004 | Contact/ContactListNotifier | should search contacts by name | Verify search filter | search='John' | filteredContacts contains matching contacts | P1 | No |
| CONT-U005 | Contact/ContactListNotifier | should search contacts by company | Verify company search | search='Acme' | filteredContacts contains matching contacts | P1 | No |
| CONT-U006 | Contact/ContactListNotifier | should clear search and show all | Verify search clear | search='' after previous search | filteredContacts=all contacts | P1 | No |
| CONT-U007 | Contact/ContactListNotifier | should select contact for reading pane | Verify selection | Contact ID | selectedContact set, reading pane updates | P1 | No |
| CONT-U008 | Contact/ContactListNotifier | should enable reading pane for tablet landscape | Verify adaptive setting | Native tablet + landscape | readingPaneEnabled=true | P1 | No |
| CONT-U009 | Contact/ContactListNotifier | should handle network error on fetch | Verify error handling | No internet | Toast shown, contacts unchanged | P0 | Yes |
| CONT-U010 | Contact/AddContactNotifier | should initialize with empty form state | Verify initial state | New notifier | firstName='', lastName='', emails=[] | P0 | No |
| CONT-U011 | Contact/AddContactNotifier | should add contact successfully | Verify create | Valid form data | API called, Result.success, navigation back | P0 | No |
| CONT-U012 | Contact/AddContactNotifier | should handle duplicate email on add | Verify validation | Email already exists in contacts | Error toast, no API call | P1 | Yes |
| CONT-U013 | Contact/AddContactNotifier | should add dynamic email field | Verify dynamic form | Tap add email | Additional email controller added | P1 | No |
| CONT-U014 | Contact/AddContactNotifier | should remove dynamic email field | Verify removal | Tap remove on email field | Controller removed from list | P1 | No |
| CONT-U015 | Contact/AddContactNotifier | should validate required fields | Verify validation | Empty firstName | Validation error returned | P0 | Yes |
| CONT-U016 | Contact/AddContactNotifier | should validate email format | Verify email validation | Invalid email 'notanemail' | Email validation error | P0 | Yes |
| CONT-U017 | Contact/EditContactNotifier | should load existing contact data | Verify pre-fill | Contact with data | Controllers populated with existing values | P0 | No |
| CONT-U018 | Contact/EditContactNotifier | should update contact successfully | Verify edit | Modified data | API called with updated fields, Result.success | P0 | No |
| CONT-U019 | Contact/EditContactNotifier | should handle edit API failure | Verify error | API returns failure | Toast shown, form preserved | P1 | Yes |
| CONT-U020 | Contact/ViewContactNotifier | should load contact details | Verify detail fetch | contactId=123 | Contact details populated in state | P0 | No |
| CONT-U021 | Contact/ViewContactNotifier | should delete contact | Verify delete | Confirm delete | API called, navigation back | P0 | No |
| CONT-U022 | Contact/ViewContactNotifier | should add email to contact | Verify email addition | New email address | API called (add-delete-email with type='add') | P1 | No |
| CONT-U023 | Contact/ViewContactNotifier | should delete email from contact | Verify email removal | Existing email | API called (add-delete-email with type='delete') | P1 | No |
| CONT-U024 | Contact/ContactRepository | should fetch contacts with pagination | Verify repo | page=1, limit=20 | ContactApi called, Result.success with ContactListModel | P0 | No |
| CONT-U025 | Contact/ContactRepository | should fetch contact details | Verify repo | contactId=123 | ContactApi called, Result.success | P0 | No |
| CONT-U026 | Contact/ContactRepository | should delete contact | Verify repo | contactId=123 | ContactApi.contactDelete called, Result.success | P0 | No |
| CONT-U027 | Contact/ContactRepository | should add/delete email | Verify repo | email, contactId, type='add' | ContactApi.addDeleteEmail called | P1 | No |
| CONT-U028 | Contact/ContactRepository | should handle NoInternetException | Verify offline | Network unavailable | Result.failure with network message | P0 | Yes |
| CONT-U029 | Contact/ContactListModel | should deserialize from valid JSON | Verify fromJson | Valid contacts JSON | Model populated correctly | P0 | No |
| CONT-U030 | Contact/ContactListModel | should compute contact initials | Verify computed property | firstName='John', lastName='Doe' | initials='JD' | P1 | No |
| CONT-U031 | Contact/ContactListModel | should handle null emails list | Verify null safety | Contact with emails=null | No crash, emails=null | P1 | Yes |
| CONT-U032 | Contact/ContactListModel | should serialize to JSON | Verify toJson | Populated model | JSON matches expected | P1 | No |
| CONT-U033 | Contact/SearchEmailModel | should deserialize from valid JSON | Verify fromJson | Valid search results JSON | emails list populated | P1 | No |
| CONT-U034 | Contact/ContactEmailDetailsModel | should deserialize from valid JSON | Verify fromJson | Valid contact email details JSON | contacts list with email details | P1 | No |
| CONT-U035 | Contact/SettingsNotifier | should enable contact sync via toggleSyncContacts(true) | Verify sync enable | Authenticated, permission granted | SettingApi().toggleContactSynch called with contactSynch=true, storage updated, filterContactsToJson triggered | P1 | No |
| CONT-U036 | Contact/SettingsNotifier | should disable contact sync via toggleSyncContacts(false) | Verify sync disable | Contact sync currently enabled | SettingApi().toggleContactSynch called with contactSynch=false, storage updated | P1 | No |
| CONT-U037 | Contact/SettingsNotifier | should handle toggleSyncContacts API failure | Verify error handling | API returns failure | Toast shown with error, state may revert | P1 | Yes |
| CONT-U038 | Contact/SettingsNotifier | should handle toggleSyncContacts network error | Verify offline handling | No network connectivity | catchError toast shown | P1 | Yes |
| CONT-U041 | Contact/Security | should sanitize SQL injection in contact name fields | Verify SQL injection prevention | First Name = "' OR '1'='1", Last Name = "Doe" | Input sanitized, not executed as SQL; contact saved with literal text or error shown | P1 | Yes |
| CONT-U042 | Contact/Security | should sanitize XSS script in contact fields | Verify XSS prevention | First Name = "<script>alert('test')</script>" | Script not executed, input sanitized or rejected | P1 | Yes |
| CONT-U043 | Contact/Validation | should reject numeric values in name fields | Verify name validation | First Name = "123", Last Name = "456" | Validation error: names must contain letters | P1 | Yes |
| CONT-U044 | Contact/Validation | should reject special characters in name fields | Verify name character validation | First Name = "@l!c#", Last Name = "D*e&" | Validation error: invalid characters in name | P1 | Yes |
| CONT-U045 | Contact/MultipleEmails | should prevent removing the last email from a contact | Verify last email protection | Contact with 1 email, attempt to delete | Error: "Cannot remove the last email address" | P1 | Yes |
| CONT-U046 | Contact/DeviceSync | should re-sync contacts when a device contact is updated | Verify update sync | Contact sync enabled, existing synced contact updated on device | App detects change on next sync cycle, updates contact info in app | P1 | No |
| CONT-U047 | Contact/DeviceSync | should re-sync contacts when a new device contact is added | Verify add sync | Contact sync enabled, new contact added on device | App detects new contact on next sync cycle, adds to app contact list | P1 | No |
| CONT-U048 | Contact/DeviceSync | should re-sync contacts when a device contact is deleted | Verify delete sync | Contact sync enabled, existing synced contact deleted on device | App detects deletion on next sync cycle, removes contact from app | P1 | No |
| CONT-U039 | Contact/ImportContact | should handle denied contacts permission gracefully | Verify permission denied | User denies device contacts access | Import skipped, no error, user can manually add contacts | P1 | Yes |
| CONT-U040 | Contact/ImportContact | should import device contacts via flutter_contacts | Verify import flow | Permission granted, device contacts available | Contacts fetched from device, displayed for selection | P1 | No |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| CONT-W001 | Contact/List | should render contact list | Verify rendering | ContactListriverpod | 5 contacts in state | None | 5 contact items visible | All | Small | Portrait | P0 | No |
| CONT-W002 | Contact/List | should show empty state | Verify empty | ContactListriverpod | contacts=[] | None | NoData widget | All | All | Both | P0 | Yes |
| CONT-W003 | Contact/List | should navigate to add contact | Verify navigation | ContactListriverpod | Default | Tap Add button | Navigation to /contacts/add | All | All | Both | P0 | No |
| CONT-W004 | Contact/List | should search contacts | Verify search | ContactListriverpod | Contacts loaded | Type in search bar | Filtered list displayed | All | All | Both | P1 | No |
| CONT-W005 | Contact/List | should show reading pane on desktop | Verify desktop layout | ContactListriverpod | Desktop viewport | None | List + reading pane side by side | Web | Large | Both | P1 | No |
| CONT-W006 | Contact/List | should show reading pane on tablet landscape | Verify tablet layout | ContactListriverpod | Native tablet landscape | None | List + reading pane | iOS, Android | Medium | Landscape | P1 | No |
| CONT-W007 | Contact/List | should show mobile layout on portrait | Verify mobile | ContactListriverpod | Mobile viewport | None | Full-width list only | All | Small | Portrait | P1 | No |
| CONT-W008 | Contact/List | should select contact and show in reading pane | Verify selection | ContactListriverpod | Desktop with contacts | Tap contact | Contact details in reading pane | Web | Large | Both | P1 | No |
| CONT-W009 | Contact/Add | should render add contact form | Verify rendering | AddContactriverpod | Default state | None | First name, last name, company, email fields | All | All | Both | P0 | No |
| CONT-W010 | Contact/Add | should show validation errors on empty submit | Verify validation | AddContactriverpod | All fields empty | Tap Save | Validation errors on required fields | All | All | Both | P0 | Yes |
| CONT-W011 | Contact/Add | should add email field dynamically | Verify dynamic form | AddContactriverpod | 1 email field | Tap Add Email | 2 email fields visible | All | All | Both | P1 | No |
| CONT-W012 | Contact/Add | should remove email field | Verify removal | AddContactriverpod | 2 email fields | Tap remove on second | 1 email field visible | All | All | Both | P1 | No |
| CONT-W013 | Contact/Add | should scroll to new email field | Verify scroll | AddContactriverpod | Form scrolled up | Add email | Scrolls to bottom | All | Small | Portrait | P2 | No |
| CONT-W014 | Contact/Add | should save contact and pop | Verify save | AddContactriverpod | Valid form filled | Tap Save | API called, navigator pops with result | All | All | Both | P0 | No |
| CONT-W015 | Contact/Add | should navigate back on cancel | Verify cancel | AddContactriverpod | Form partially filled | Tap Back | Navigator pops, no save | All | All | Both | P1 | No |
| CONT-W016 | Contact/View | should render contact details | Verify rendering | ViewContactriverpod | contact with 2 emails | None | Name, company, 2 emails visible | All | All | Both | P0 | No |
| CONT-W017 | Contact/View | should navigate to edit | Verify navigation | ViewContactriverpod | Contact loaded | Tap Edit button | Navigation to edit screen | All | All | Both | P0 | No |
| CONT-W018 | Contact/View | should show delete confirmation | Verify delete dialog | ViewContactriverpod | Contact loaded | Tap Delete | Confirmation dialog shown | All | All | Both | P0 | No |
| CONT-W019 | Contact/View | should delete contact on confirm | Verify delete action | ViewContactriverpod | Confirmation shown | Tap Confirm | API called, navigator pops | All | All | Both | P0 | No |
| CONT-W020 | Contact/View | should show email action menu on mobile | Verify mobile menu | ViewContactriverpod | Contact with emails | Tap email address | CupertinoActionSheet with copy/compose options | iOS | Small | Portrait | P1 | No |
| CONT-W021 | Contact/View | should show popup menu on desktop | Verify desktop menu | ViewContactriverpod | Contact with emails | Tap email address | PopupMenu with options | Web | Large | Both | P1 | No |
| CONT-W022 | Contact/View | should compose email to contact | Verify compose | ViewContactriverpod | Email menu open | Tap Compose | Navigation to /compose with email | All | All | Both | P1 | No |
| CONT-W023 | Contact/View | should render in reading pane mode | Verify reading pane | ViewContactriverpod | hideAppBar=true | None | No AppBar, content fits reading pane | Web | Large | Both | P1 | No |
| CONT-W024 | Contact/Edit | should render edit form pre-filled | Verify pre-fill | EditContactriverpod | Existing contact data | None | Fields pre-filled with contact data | All | All | Both | P0 | No |
| CONT-W025 | Contact/Edit | should save changes and pop | Verify edit save | EditContactriverpod | Modified form | Tap Save | API called, navigator pops with result | All | All | Both | P0 | No |
| CONT-W026 | Contact/Edit | should show validation on invalid email | Verify validation | EditContactriverpod | Invalid email entered | Tap Save | Email validation error | All | All | Both | P1 | Yes |
| CONT-W027 | Contact/Import | should render import contact screen | Verify rendering | ImportContact | Default | None | Import options visible | iOS, Android | Small | Portrait | P1 | No |
| CONT-W028 | Contact/SyncToggle | should show contact sync toggle in settings screen | Verify toggle | Settingriverpod | Settings loaded | None | Contact sync toggle visible with current state | iOS, Android | All | Both | P1 | No |
| CONT-W029 | Contact/SyncToggle | should toggle contact sync on/off | Verify toggle action | Settingriverpod | Settings loaded | Tap sync toggle | toggleSyncContacts called, state updates | iOS, Android | All | Both | P1 | No |
| CONT-W030 | Contact/Import | should show permission request dialog for device contacts access | Verify permission prompt | ImportContact | Permission not yet granted | None | Permission dialog explaining why contact access is needed | iOS, Android | Small | Portrait | P1 | No |
| CONT-W031 | Contact/Import | should render import contact mobile layout | Verify mobile layout | ImportContact | Default | None | Import options and contact list visible | iOS, Android | Small | Portrait | P1 | No |

### Integration Test Cases

| ID | Feature/Module | Test Case | Description | Components Involved | Preconditions | Expected Outcome | Platform | Screen Size | Orientation | Priority |
|----|----------------|-----------|-------------|---------------------|---------------|------------------|----------|-------------|-------------|----------|
| CONT-I001 | Contact/CRUDFlow | should create and view new contact | Full add flow | AddContactNotifier + ContactApi + Navigation | Authenticated | Contact created, appears in list | All | All | Both | P0 |
| CONT-I002 | Contact/CRUDFlow | should edit existing contact | Full edit flow | EditContactNotifier + ContactApi + Navigation | Contact exists | Contact updated, changes visible | All | All | Both | P0 |
| CONT-I003 | Contact/CRUDFlow | should delete contact with confirmation | Full delete flow | ViewContactNotifier + ContactApi + Navigation | Contact exists | Contact deleted, removed from list | All | All | Both | P0 |
| CONT-I004 | Contact/EmailManagement | should add email to existing contact | Email add flow | ViewContactNotifier + ContactApi | Contact loaded | Email added, details updated | All | All | Both | P1 |
| CONT-I005 | Contact/EmailManagement | should remove email from contact | Email remove flow | ViewContactNotifier + ContactApi | Contact with 2+ emails | Email removed, details updated | All | All | Both | P1 |
| CONT-I006 | Contact/SearchFlow | should search and select contact | Search integration | ContactListNotifier + ContactApi | Contacts loaded | Search filters list, selection works | All | All | Both | P1 |

### Flutter Test Notes — Contacts Module
- **Required mocks:** MockContactApi, MockContactRepository
- **ProviderScope overrides:** `contactListProvider`, `addContactProvider`, `editContactProvider`, `viewContactProvider`
- **Wrapper:** `MaterialApp.router` with GoRouter
- **pumpAndSettle:** Required after save/delete API calls
- **Platform channel mocks:** `flutter_contacts` for import feature
- **SharedPreferences:** `SharedPreferences.setMockInitialValues({})` for sort preferences

---

## 4. Settings Module

### Current Coverage Status
- **Existing tests:** None
- **Files involved:**
  - `lib/screens/settings/setting_riverpod/` (setting_riverpod.dart, setting_notifier.dart, setting_provider.dart, setting_state.dart + layouts)
  - `lib/screens/settings/profile_riverpod/` (profile_riverpod.dart, profile_notifier.dart, profile_provider.dart, profile_state.dart + layouts)
  - `lib/screens/settings/account_riverpod/` (account_riverpod.dart, account_notifier.dart, account_provider.dart, account_state.dart + layouts)
  - `lib/repositories/setting/setting_api.dart`
  - `lib/repositories/account/account_api.dart`
  - `lib/model/profile_model.dart`
- **Gaps:** Complete

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| SET-U001 | Settings/SettingsNotifier | should initialize and fetch user data | Verify init | User authenticated | User data loaded in state | P0 | No |
| SET-U002 | Settings/SettingsNotifier | should toggle biometric setting | Verify biometric toggle | Current=enabled | API called, setting flipped | P1 | No |
| SET-U003 | Settings/SettingsNotifier | should toggle notification setting | Verify notification toggle | Current=enabled | API called, setting flipped | P1 | No |
| SET-U004 | Settings/SettingsNotifier | should toggle contact sync | Verify sync toggle | Current=disabled | API called, sync enabled | P1 | No |
| SET-U005 | Settings/SettingsNotifier | should toggle contact sort order | Verify sort toggle | sortLastName=false | API called, sortLastName=true | P2 | No |
| SET-U006 | Settings/SettingsNotifier | should perform logout | Verify logout | User authenticated | Storage cleared, socket disconnected, navigate to login | P0 | No |
| SET-U007 | Settings/ProfileNotifier | should fetch profile data | Verify fetch | Authenticated user | Profile fields populated | P0 | No |
| SET-U008 | Settings/ProfileNotifier | should enable edit mode | Verify mode toggle | isEdit=false | isEdit=true | P1 | No |
| SET-U009 | Settings/ProfileNotifier | should disable edit and revert changes | Verify cancel | Modified data, isEdit=true | Controllers reverted, isEdit=false | P1 | No |
| SET-U010 | Settings/ProfileNotifier | should submit profile changes | Verify save | Valid form data | AccountApi.editProfile called, success | P0 | No |
| SET-U011 | Settings/ProfileNotifier | should validate profile form | Verify validation | Empty required fields | Validation errors returned | P0 | Yes |
| SET-U012 | Settings/ProfileNotifier | should pick date of birth | Verify DOB picker | User taps DOB | Date picker shown, DOB controller updated | P1 | No |
| SET-U013 | Settings/AccountNotifier | should load account info | Verify fetch | Authenticated user | Subscription data loaded | P0 | No |
| SET-U014 | Settings/AccountNotifier | should show delete account dialog | Verify dialog | User taps delete | Confirmation dialog shown | P0 | No |
| SET-U015 | Settings/AccountNotifier | should delete account and logout | Verify delete | User confirms | API called, storage cleared, navigate to login | P0 | No |
| SET-U016 | Settings/AccountNotifier | should navigate to billing details | Verify navigation | Subscribed user | Navigation to subscription screen | P1 | No |
| SET-U017 | Settings/AccountAPI | should call deleteAccount endpoint | Verify API | Request data | GET to /user/delete-account with refreshable auth | P0 | No |
| SET-U018 | Settings/AccountAPI | should call getProfile endpoint | Verify API | Request data | GET to /user/get-profile | P0 | No |
| SET-U019 | Settings/AccountAPI | should call editProfile endpoint | Verify API | Profile data | POST to /user/edit-profile | P0 | No |
| SET-U020 | Settings/SettingAPI | should call toggleNotification endpoint | Verify API | Toggle data | POST to /user/toggle-notification | P1 | No |
| SET-U021 | Settings/SettingAPI | should call deviceBiometric endpoint | Verify API | Toggle data | POST to /user/toggle-device-biometrics | P1 | No |
| SET-U022 | Settings/SettingAPI | should call logout endpoint | Verify API | Logout data | GET to /user/logout | P0 | No |
| SET-U023 | Settings/ProfileModel | should deserialize from valid JSON | Verify fromJson | Valid profile JSON | All fields match | P0 | No |
| SET-U024 | Settings/ProfileModel | should handle nullable fields | Verify null safety | JSON with otp=null, deviceToken=null | No crash | P1 | Yes |
| SET-U025 | Settings/ProfileModel | should serialize to JSON | Verify toJson | Populated model | JSON matches | P1 | No |
| SET-U026 | Settings/SettingsNotifier | should toggle Face ID setting on Face ID capable device | Verify Face ID toggle | Device supports Face ID, faceId=disabled | API called, Face ID setting enabled | P1 | No |
| SET-U027 | Settings/SettingsNotifier | should toggle Touch ID setting on Touch ID capable device | Verify Touch ID toggle | Device supports Touch ID, touchId=disabled | API called, Touch ID setting enabled | P1 | No |
| SET-U028 | Settings/SettingsNotifier | should display appropriate biometric label based on device capability | Verify label detection | Device with Face ID vs Touch ID vs none | Label reads "Face ID" / "Touch ID" / hidden based on hardware | P1 | No |
| SET-U029 | Settings/ContactSort | should sort contacts by first name when toggle is ON | Verify first name sort | Sort by First Name toggle=ON, contacts loaded | Contacts list sorted alphabetically by first name ascending | P1 | No |
| SET-U030 | Settings/ContactSort | should sort contacts by last name when toggle is OFF | Verify last name sort | Sort by First Name toggle=OFF, contacts loaded | Contacts list sorted alphabetically by last name ascending | P1 | No |
| SET-U031 | Settings/ContactSort | should switch from first name to last name sort on toggle change | Verify sort switch | Toggle changed from ON to OFF | Contacts re-sorted by last name immediately | P1 | No |
| SET-U032 | Settings/ContactSort | should switch from last name to first name sort on toggle change | Verify reverse sort switch | Toggle changed from OFF to ON | Contacts re-sorted by first name immediately | P1 | No |
| SET-U033 | Settings/ProfileNotifier | should reject future date of birth | Verify DOB future date validation | DOB set to date in the future | Validation error, profile not saved | P1 | Yes |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| SET-W001 | Settings/Main | should render settings options | Verify rendering | Settingriverpod | User data loaded | None | All setting toggles visible | All | All | Both | P0 | No |
| SET-W002 | Settings/Main | should navigate to profile | Verify navigation | Settingriverpod | Default | Tap Profile option | Navigation to /settings/profile | All | All | Both | P1 | No |
| SET-W003 | Settings/Main | should navigate to account | Verify navigation | Settingriverpod | Default | Tap Account option | Navigation to /settings/account | All | All | Both | P1 | No |
| SET-W004 | Settings/Main | should toggle biometric switch | Verify toggle | Settingriverpod | biometric=off | Tap biometric switch | Switch toggles, API called | iOS, Android | All | Both | P1 | No |
| SET-W005 | Settings/Main | should toggle notification switch | Verify toggle | Settingriverpod | notification=on | Tap notification switch | Switch toggles, API called | All | All | Both | P1 | No |
| SET-W006 | Settings/Main | should show logout confirmation | Verify logout | Settingriverpod | Default | Tap Logout | Confirmation or direct logout | All | All | Both | P0 | No |
| SET-W007 | Settings/Main | should render mobile layout | Verify responsive | Settingriverpod | Mobile viewport | None | Mobile layout rendered | All | Small | Portrait | P1 | No |
| SET-W008 | Settings/Main | should render desktop layout with sidebar | Verify responsive | Settingriverpod | Desktop viewport | None | Desktop layout with sidebar | Web | Large | Both | P1 | No |
| SET-W009 | Settings/Profile | should render profile view | Verify rendering | Profileriverpod | Profile loaded | None | Name, DOB, phone, email displayed | All | All | Both | P0 | No |
| SET-W010 | Settings/Profile | should show edit button on mobile | Verify edit button | Profileriverpod | Mobile viewport | None | Edit button visible | All | Small | Portrait | P1 | No |
| SET-W011 | Settings/Profile | should switch to edit mode | Verify mode change | Profileriverpod | View mode | Tap Edit | Form fields become editable | All | All | Both | P1 | No |
| SET-W012 | Settings/Profile | should save profile changes | Verify save | Profileriverpod | Edit mode, valid data | Tap Save | API called, back to view mode | All | All | Both | P0 | No |
| SET-W013 | Settings/Profile | should cancel edit and revert | Verify cancel | Profileriverpod | Edit mode, data changed | Tap Back/Cancel | Data reverted to original | All | All | Both | P1 | No |
| SET-W014 | Settings/Account | should render account details | Verify rendering | Accountriverpod | Account loaded | None | Subscription info visible | All | All | Both | P0 | No |
| SET-W015 | Settings/Account | should show loading spinner | Verify loading | Accountriverpod | isLoading=true | None | CircularProgressIndicator visible | All | All | Both | P1 | No |
| SET-W016 | Settings/Account | should show delete account option | Verify delete button | Accountriverpod | Default | None | Delete Account button visible | All | All | Both | P0 | No |
| SET-W017 | Settings/Account | should show delete confirmation dialog | Verify dialog | Accountriverpod | Default | Tap Delete Account | AlertDialog with confirm/cancel | All | All | Both | P0 | No |
| SET-W018 | Settings/Main | should show Face ID toggle on Face ID capable devices | Verify Face ID UI | Settingriverpod | Device supports Face ID | None | "Face ID" label and toggle switch visible | iOS | All | Both | P1 | No |
| SET-W019 | Settings/Main | should show Touch ID toggle on Touch ID capable devices | Verify Touch ID UI | Settingriverpod | Device supports Touch ID | None | "Touch ID" label and toggle switch visible | iOS | All | Both | P1 | No |

### Flutter Test Notes — Settings Module
- **Required mocks:** MockSettingApi, MockAccountApi, MockSecureStorageService, MockSocketService
- **ProviderScope overrides:** `settingsProvider`, `profileProvider`, `accountProvider`, `authNotifier`
- **Wrapper:** `MaterialApp.router`
- **pumpAndSettle:** Required after toggle/save operations

---

## 5. Tags Module

### Current Coverage Status
- **Existing tests:** None
- **Gaps:** Complete

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| TAG-U001 | Tags/TagsNotifier | should initialize and load tags | Verify init | Authenticated | Tags list populated | P1 | No |
| TAG-U002 | Tags/TagsNotifier | should add new tag | Verify creation | tagName='Important' | API called, tag added to list | P1 | No |
| TAG-U003 | Tags/TagsNotifier | should reject tag name over 20 chars | Verify validation | tagName='This is way too long tag name' | Validation error | P1 | Yes |
| TAG-U004 | Tags/TagsNotifier | should edit existing tag | Verify edit | tagId=1, newName='Updated' | API called, list updated | P1 | No |
| TAG-U005 | Tags/TagsNotifier | should delete tag | Verify delete | tagId=1 | API called, tag removed from list | P1 | No |
| TAG-U006 | Tags/TagsNotifier | should sync with legacy TagsProvider | Verify sync | Tags updated via notifier | TagsProvider.tagsList also updated | P2 | No |
| TAG-U007 | Tags/TagsNotifier | should refresh if user changed | Verify account switch | Different userId detected | Tags list refreshed | P2 | Yes |
| TAG-U008 | Tags/TagsNotifier | should handle API error on add | Verify error | API returns failure | Toast shown, list unchanged | P1 | Yes |
| TAG-U009 | Tags/TagsNotifier | should handle NoInternetException | Verify offline | No network | Toast shown | P1 | Yes |
| TAG-U010 | Tags/TagAPI | should call getTagsList endpoint | Verify API | Request data | POST to /email/tags | P1 | No |
| TAG-U011 | Tags/TagAPI | should call addTags endpoint | Verify API | Tag data | POST to /email/add-tags | P1 | No |
| TAG-U012 | Tags/TagAPI | should call editTag endpoint | Verify API | Tag data | POST to /email/edit-tag | P1 | No |
| TAG-U013 | Tags/TagAPI | should call deleteTag endpoint | Verify API | Tag data | POST to /email/delete-tag | P1 | No |
| TAG-U014 | Tags/TagsListModel | should deserialize from valid JSON | Verify fromJson | Valid tags JSON | tags list populated | P1 | No |
| TAG-U015 | Tags/TagsListModel | should serialize to JSON | Verify toJson | Populated model | JSON matches | P1 | No |
| TAG-U016 | Tags/TagsListModel | should handle empty tags array | Verify empty | JSON with tags=[] | tags=[], no error | P1 | Yes |
| TAG-U017 | Tags/CommunityRecommendations | should display Community Recommendations tag in email body | Verify tag display | Admin marks email as Community Recommendations, sender not in user contacts | "Community Recommendations" tag visible in email body | P1 | No |
| TAG-U018 | Tags/CommunityRecommendations | should display Community Recommendations tag in notification | Verify notification tag | Admin-tagged email received | "Community Recommendations" tag shown in notification center | P1 | No |
| TAG-U019 | Tags/CommunityRecommendations | should not display Community Recommendations tag when admin has not set it | Verify tag absence | Email received without admin Community Recommendations flag | No "Community Recommendations" tag in email body or notification | P1 | No |
| TAG-U020 | Tags/CommunityRecommendations | should open email with Community Recommendations tag from notification tap | Verify notification tap | Notification with Community Recommendations email | Tap notification opens email, tag visible in body | P1 | No |
| TAG-U021 | Tags/CommunityRecommendations | should not tag email from invalid/misconfigured sender as Community Recommendations | Verify invalid sender | Admin tags email but sender email is invalid/misconfigured | Email does not arrive or tag not displayed | P2 | Yes |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| TAG-W001 | Tags/List | should render tags list | Verify rendering | TagsListriverpod | 3 tags in state | None | 3 tag items visible | All | All | Both | P1 | No |
| TAG-W002 | Tags/List | should show empty state | Verify empty | TagsListriverpod | tags=[] | None | NoData widget | All | All | Both | P1 | Yes |
| TAG-W003 | Tags/List | should add new tag | Verify add | TagsListriverpod | Default | Tap Add button | Tag creation form/dialog shown | All | All | Both | P1 | No |
| TAG-W004 | Tags/List | should edit tag name | Verify edit | TagsListriverpod | Tags loaded | Tap Edit on tag | Edit form shown with current name | All | All | Both | P1 | No |
| TAG-W005 | Tags/List | should delete tag with confirmation | Verify delete | TagsListriverpod | Tags loaded | Tap Delete on tag | Confirmation dialog, then API called | All | All | Both | P1 | No |
| TAG-W006 | Tags/List | should render mobile layout | Verify responsive | TagsListriverpod | Mobile viewport | None | Mobile layout | All | Small | Portrait | P2 | No |
| TAG-W007 | Tags/List | should render desktop layout with sidebar | Verify responsive | TagsListriverpod | Desktop viewport | None | Desktop layout with sidebar | Web | Large | Both | P2 | No |

---

## 6. Notifications Module

### Current Coverage Status
- **Existing tests:** None
- **Gaps:** Complete

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| NOTIF-U001 | Notification/NotificationNotifier | should fetch first page of notifications | Verify fetch | Authenticated | notifications populated, counts set | P1 | No |
| NOTIF-U002 | Notification/NotificationNotifier | should paginate notifications | Verify pagination | Page 1 loaded | Page 2 fetched, items appended | P1 | No |
| NOTIF-U003 | Notification/NotificationNotifier | should delete notification | Verify delete | notification ID | API called, item removed | P1 | No |
| NOTIF-U004 | Notification/NotificationNotifier | should toggle read status | Verify toggle | isRead=false | isRead=true after toggle, API called | P1 | No |
| NOTIF-U005 | Notification/NotificationNotifier | should handle empty notifications | Verify empty | No notifications | Empty list, no error | P1 | Yes |
| NOTIF-U006 | Notification/NotificationAPI | should call getNotification endpoint | Verify API | Request data | POST to /user/notification | P1 | No |
| NOTIF-U007 | Notification/NotificationAPI | should call notificationDelete endpoint | Verify API | Notification ID | POST to /user/notification-delete | P1 | No |
| NOTIF-U008 | Notification/NotificationAPI | should call notificationRead endpoint | Verify API | Notification ID | POST to /user/notification-read | P1 | No |
| NOTIF-U009 | Notification/NotificationListModel | should deserialize from valid JSON | Verify fromJson | Valid JSON | notifications list populated | P1 | No |
| NOTIF-U010 | Notification/NotificationListModel | should handle notification with null emailId | Verify null safety | info.emailId=null | No crash | P1 | Yes |
| NOTIF-U011 | Notification/PushNotification | should display push notification for new email from contact | Verify contact push | New email arrives from saved contact | Push notification shown with sender name and subject line | P1 | No |
| NOTIF-U012 | Notification/PushNotification | should display push notification for new email from non-contact | Verify non-contact push | New email arrives from unknown sender | Push notification shown with email address and subject line | P1 | No |
| NOTIF-U013 | Notification/PushNotification | should navigate to email detail on push notification tap | Verify tap navigation | User taps push notification | App opens to specific email detail screen matching notification emailId | P1 | No |
| NOTIF-U014 | Notification/PushNotification | should navigate to login if not authenticated on push notification tap | Verify unauthenticated tap | User taps push notification while logged out | App opens to login screen, deep link preserved for post-login | P1 | Yes |
| NOTIF-U015 | Notification/AppIconBadge | should display app icon badge count on iOS | Verify iOS badge | Unread notifications exist (count=5) | iOS app icon shows badge with number 5 | P1 | No |
| NOTIF-U016 | Notification/AppIconBadge | should display app icon badge count on Android | Verify Android badge | Unread notifications exist (count=3) | Android launcher icon shows badge/dot with count 3 | P1 | No |
| NOTIF-U017 | Notification/AppIconBadge | should clear app icon badge when all notifications read | Verify badge clear | All notifications marked as read | App icon badge removed (count=0) | P1 | No |
| NOTIF-U018 | Notification/AppIconBadge | should update badge count in real time via socket event | Verify real-time badge | Socket emits unReadCount with new notification count | Badge count updates without app restart | P1 | No |
| NOTIF-U019 | Notification/AppIconBadge | should persist badge count across app backgrounding | Verify badge persistence | App backgrounded with badge count=3 | Badge still shows 3 when viewing home screen | P1 | No |
| NOTIF-U020 | Notification/PushNotification | should display push notification for email with attachment | Verify attachment notification | New email arrives with attachment from contact | Push notification shown indicating email has attachment | P1 | No |
| NOTIF-U021 | Notification/PushNotification | should not display push notification for already-read emails | Verify no duplicate notification | Email already marked as read on another device | No push notification generated for already-read email | P1 | Yes |
| NOTIF-U022 | Notification/PushNotification | should display push notification when email is replied to | Verify reply notification | Contact replies to an existing email thread | Push notification shown with reply indicator and sender name | P1 | No |
| NOTIF-U023 | Notification/PushNotification | should not display push notification for emails moved to archive | Verify archived email suppression | Email moved to archive by user | No push notification for archived email activity | P1 | Yes |
| NOTIF-U024 | Notification/PushNotification | should display push notification when email is forwarded to user | Verify forwarded notification | Email forwarded to user from a contact | Push notification shown with forwarded indicator | P1 | No |
| NOTIF-U025 | Notification/PushNotification | should navigate to Trash when tapping notification for non-contact email | Verify non-contact navigation | Push notification tapped for email from unknown sender (non-contact) | App navigates to Trash folder where non-contact email resides | P1 | No |
| NOTIF-U026 | Notification/PushNotification | should show Add Contact popup when tapping notification from unknown sender | Verify Add Contact prompt | Push notification tapped for email from unknown sender | Add Contact popup appears offering to save sender as contact | P1 | No |
| NOTIF-U027 | Notification/PushNotification | should revert to non-contact notification behavior when contact is removed | Verify removed contact handling | Previously saved contact is deleted, new email arrives from that sender | Email treated as non-contact; notification navigates to Trash | P1 | Yes |
| NOTIF-U028 | Notification/PushNotification | should take no action if email is deleted before notification tap | Verify deleted email handling | Email deleted between notification receipt and tap | No navigation or error; notification dismissed gracefully | P1 | Yes |
| NOTIF-U029 | Notification/PushNotification | should display correct contact details in Add Contact popup from notification | Verify contact details | Notification tapped for unknown sender | Add Contact popup pre-populates sender email address and name (if available) | P1 | No |
| NOTIF-U030 | Notification/PushNotification | should not show Add Contact popup if sender already in contacts | Verify known sender bypass | Notification tapped for email from saved contact | Navigates directly to email detail; no Add Contact popup | P1 | No |
| NOTIF-U031 | Notification/PushNotification | should mark email as read after push notification click | Verify read status update | User taps push notification for unread email | Email isRead set to true, notification badge count decremented | P1 | No |
| NOTIF-U032 | Notification/AppIconBadge | should update badge count after marking email as read from email detail | Verify badge decrement on read | Badge count=5, user opens email and marks as read | Badge count decrements to 4 immediately | P1 | No |
| NOTIF-U033 | Notification/AppIconBadge | should restore correct badge count after re-login | Verify badge on re-login | User logs out with badge count=3, then logs back in | Badge count fetched from server and restored correctly | P1 | No |
| NOTIF-U034 | Notification/AppIconBadge | should handle badge count discrepancy between server and local state | Verify badge sync | Local badge=5 but server unread count=3 | Badge corrected to server value on next sync | P1 | Yes |
| NOTIF-U035 | Notification/AppIconBadge | should not display badge when iOS notification permission is disabled | Verify iOS permission disabled | User disables notification badge in iOS Settings for OptMsg | No badge appears on iOS app icon; badge restored when permission re-enabled | P1 | Yes |
| NOTIF-U036 | Notification/AppIconBadge | should not display badge when user is logged out | Verify logged-out state | User logs out of app, new messages sent to that account | No badge appears; app does not receive background push when logged out | P1 | Yes |
| NOTIF-U037 | Notification/AppIconBadge | should not display badge when Android OS-level notification is blocked | Verify Android notification blocked | User blocks notifications for app in Android system settings | No badge appears on Android app icon; badge restored when unblocked | P1 | Yes |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| NOTIF-W001 | Notification/List | should render notification list | Verify rendering | riverpodNotificationList | 5 notifications | None | 5 NotificationItem widgets | All | All | Both | P1 | No |
| NOTIF-W002 | Notification/List | should show empty state | Verify empty | riverpodNotificationList | notifications=[] | None | NoData or empty message | All | All | Both | P1 | Yes |
| NOTIF-W003 | Notification/List | should swipe to delete | Verify swipe delete | riverpodNotificationList | Notifications loaded | Swipe left on item | Delete action triggered | iOS, Android | Small | Portrait | P1 | No |
| NOTIF-W004 | Notification/List | should swipe to mark read/unread | Verify swipe toggle | riverpodNotificationList | Notification isRead=false | Swipe right on item | Read toggle action | iOS, Android | Small | Portrait | P1 | No |
| NOTIF-W005 | Notification/List | should expand notification on tap | Verify expand | NotificationItem | Collapsed notification | Tap | Body text expanded | All | All | Both | P1 | No |
| NOTIF-W006 | Notification/List | should show unread indicator dot | Verify unread | NotificationItem | isRead=false | None | Blue dot visible | All | All | Both | P1 | No |
| NOTIF-W007 | Notification/List | should pull to refresh | Verify refresh | riverpodNotificationList | Notifications loaded | Pull down | List refreshed from API | All | Small | Portrait | P2 | No |
| NOTIF-W008 | Notification/List | should load more on scroll to end | Verify infinite scroll | riverpodNotificationList | First page loaded | Scroll to bottom | Next page fetched | All | All | Both | P2 | No |
| NOTIF-W009 | Notification/PushBanner | should display in-app push notification banner for new email | Verify in-app banner | riverpodNotificationList / InboxScreen | App in foreground, new email arrives via FCM | None (auto-shown) | Banner slides in at top with sender, subject, and dismiss button | All | All | Both | P1 | No |
| NOTIF-W010 | Notification/PushBanner | should navigate to email on in-app banner tap | Verify banner tap | In-app notification banner | Banner visible | Tap banner | Navigation to email detail screen | All | All | Both | P1 | No |
| NOTIF-W011 | Notification/PushBanner | should auto-dismiss in-app banner after timeout | Verify auto-dismiss | In-app notification banner | Banner visible | Wait 5 seconds | Banner auto-dismisses | All | All | Both | P2 | No |
| NOTIF-W012 | Notification/Badge | should display notification bell badge count in app bar | Verify bell badge | GradientAppBar/NotificationBell | Unread notification count=7 | None | Bell icon shows red badge with "7" | All | All | Both | P1 | No |
| NOTIF-W013 | Notification/Badge | should hide notification bell badge when count is zero | Verify badge hidden | GradientAppBar/NotificationBell | Unread count=0 | None | Bell icon with no badge | All | All | Both | P1 | No |

---

## 7. Dashboard & Navigation Module

### Current Coverage Status
- **Existing tests:** None
- **Gaps:** Complete

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| NAV-U001 | Dashboard/BottomNavNotifier | should initialize with correct default index | Verify initial state | New notifier | currentIndex=0, initialized=false | P0 | No |
| NAV-U002 | Dashboard/BottomNavNotifier | should set index only once on init | Verify single init | setInitialIndex called twice | Second call ignored | P1 | Yes |
| NAV-U003 | Dashboard/BottomNavNotifier | should change tab index | Verify tab switch | currentIndex=0 | After setIndex(2), currentIndex=2 | P0 | No |
| NAV-U004 | Dashboard/BottomNavNotifier | should show/hide nav bar | Verify visibility toggle | navBar visible | hideNavBar → navBar hidden, showNavBar → visible | P1 | No |
| NAV-U005 | Dashboard/BottomNavNotifier | should update counts from socket | Verify socket sync | Socket emits unReadCount | inbox/draft/trash/archive counts updated | P0 | No |
| NAV-U006 | Dashboard/BottomNavState | should have correct defaults | Verify Freezed state | New state | currentIndex=0, loading=false | P0 | No |
| NAV-U007 | Navigation/AuthNotifier | should check auth status from storage | Verify auth check | SecureStorage has isAuthenticated=true | isAuthenticated=true | P0 | No |
| NAV-U008 | Navigation/AuthNotifier | should return false when not authenticated | Verify unauthenticated | SecureStorage empty | isAuthenticated=false | P0 | No |
| NAV-U009 | Navigation/Router | should include all route paths | Verify route registration | GoRouter config | All AppRoutes paths registered | P0 | No |
| NAV-U010 | Navigation/Router | should redirect unauthenticated to login | Verify auth guard | isAuthenticated=false, path=/inbox | Redirected to /login | P0 | No |
| NAV-U011 | Navigation/Router | should allow authenticated access to inbox | Verify auth pass | isAuthenticated=true, path=/inbox | No redirect, inbox rendered | P0 | No |
| NAV-U012 | Navigation/AppRoutes | should define all required route constants | Verify constants | None | All route strings defined and non-empty | P1 | No |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| NAV-W001 | Dashboard/BottomNav | should render bottom navigation bar | Verify rendering | MyBottomNavigationBarApp | Default state | None | Bottom nav with tabs visible | All | Small | Portrait | P0 | No |
| NAV-W002 | Dashboard/BottomNav | should switch pages on tab tap | Verify tab switching | MyBottomNavigationBarApp | Index 0 (Inbox) | Tap Drafts tab | DraftResponsive rendered | All | Small | Portrait | P0 | No |
| NAV-W003 | Dashboard/BottomNav | should show loading scaffold when loading | Verify loading | MyBottomNavigationBarApp | state.loading=true | None | Loading scaffold shown | All | All | Both | P1 | No |
| NAV-W004 | Dashboard/BottomNav | should display correct page for each index | Verify all tabs | MyBottomNavigationBarApp | Each index 0-5 | Set each index | Correct widget rendered (Inbox/Draft/Archive/Sent/Trash/Contacts) | All | Small | Portrait | P0 | No |
| NAV-W005 | Dashboard/SideMenu | should render side menu with all items | Verify rendering | SideMenu | Expanded state | None | All menu items visible with labels | Web | Large | Both | P0 | No |
| NAV-W006 | Dashboard/SideMenu | should show badge counts | Verify badges | SideMenu | inbox=5, draft=2, trash=1 | None | Badge numbers visible | Web | Large | Both | P1 | No |
| NAV-W007 | Dashboard/SideMenu | should collapse to icons only | Verify collapse | SideMenu | isCollapsed=true | None | Only icons visible, no labels | Web | Large | Both | P1 | No |
| NAV-W008 | Dashboard/SideMenu | should toggle collapse on button | Verify toggle | SideMenu | isCollapsed=false | Tap collapse button | Menu collapses | Web | Large | Both | P1 | No |
| NAV-W009 | Dashboard/SideMenu | should highlight selected item | Verify selection | SideMenu | selectedItem='inbox' | None | Inbox item highlighted | Web | Large | Both | P1 | No |
| NAV-W010 | Dashboard/SideMenu | should call onCompose callback | Verify compose | SideMenu | Default | Tap Compose button | onCompose callback fired | Web | Large | Both | P0 | No |
| NAV-W011 | Dashboard/Drawer | should render drawer with menu items | Verify rendering | MyDrawer | Default | None | All menu items visible | All | Small | Portrait | P1 | No |
| NAV-W012 | Dashboard/Drawer | should show real-time count updates | Verify socket | MyDrawer | Socket emitting counts | None | Counts update in real time | All | Small | Portrait | P1 | No |
| NAV-W013 | Dashboard/Drawer | should close on item tap | Verify dismiss | MyDrawer | Open | Tap menu item | Drawer closes, navigation occurs | All | Small | Portrait | P1 | No |
| NAV-W014 | Dashboard/ActionBar | should render action bar on medium screens | Verify medium layout | ActionBar/InboxResponsive | Medium viewport, emails selected | None | Action bar visible with archive, delete, tag actions | All | Medium | Both | P1 | No |
| NAV-W015 | Dashboard/ActionBar | should render action bar on large screens | Verify large layout | ActionBar/InboxResponsive | Large viewport, emails selected | None | Action bar visible with full set of actions (archive, delete, tag, mark read/unread) | Web | Large | Both | P1 | No |
| NAV-W016 | Dashboard/SideMenu | should render collapsed menu on small screens (show less) | Verify small menu | SideMenu | Small viewport or collapsed state | None | Only icons visible, labels hidden, minimal items shown | Web | Small | Both | P1 | No |
| NAV-W017 | Dashboard/SideMenu | should render medium menu with icons and labels | Verify medium menu | SideMenu | Medium viewport | None | Icons with labels, standard menu items visible | Web | Medium | Both | P1 | No |
| NAV-W018 | Dashboard/SideMenu | should render fully expanded menu on large screens | Verify large menu | SideMenu | Large viewport | None | All menu items, labels, badges, compose button visible | Web | Large | Both | P1 | No |
| NAV-W019 | Dashboard/SideMenu | should toggle show less / show more for menu items | Verify show less toggle | SideMenu | Expanded with all items | Tap "Show Less" | Menu collapses to essential items; "Show More" appears | Web | Large | Both | P1 | No |
| NAV-W020 | Dashboard/FAB | should show floating compose icon on inbox screen | Verify FAB visibility | MyBottomNavigationBarApp | Inbox tab active | None | Floating compose icon visible (bottom-right) | All | Small | Portrait | P0 | No |
| NAV-W021 | Dashboard/FAB | should show floating compose icon on all main screens | Verify FAB across screens | MyBottomNavigationBarApp | Each main tab (Inbox, Drafts, Sent, etc.) | Navigate tabs | FAB visible on all main email screens | All | Small | Portrait | P1 | No |
| NAV-W022 | Dashboard/FAB | should not show floating compose icon on Login or Onboarding screens | Verify FAB hidden | LoginScreen/OnboardingScreen | Unauthenticated state | None | FAB not visible on login, onboarding, or settings screens | All | All | Both | P1 | No |
| NAV-W023 | Dashboard/FAB | should open compose screen on FAB tap | Verify FAB action | MyBottomNavigationBarApp | Inbox loaded | Tap FAB | Navigation to compose screen | All | Small | Portrait | P0 | No |
| NAV-W024 | Dashboard/FAB | should not open multiple compose screens on rapid FAB taps | Verify debounce | MyBottomNavigationBarApp | Inbox loaded | Tap FAB 5 times rapidly | Only one compose screen opens, no duplicates | All | All | Both | P1 | Yes |
| NAV-W025 | Dashboard/FAB | should remain visible in landscape mode | Verify landscape FAB | MyBottomNavigationBarApp | Phone landscape orientation | Rotate to landscape | FAB remains visible and tappable | iOS, Android | Small | Landscape | P1 | No |
| NAV-W026 | Dashboard/FAB | should be correctly positioned (bottom-right) across orientations | Verify FAB position | MyBottomNavigationBarApp | Portrait and landscape | Rotate device | FAB stays at bottom-right corner in both orientations | All | All | Both | P2 | No |
| NAV-W027 | Dashboard/FAB | should remain functional after app resumes from background | Verify FAB after resume | MyBottomNavigationBarApp | App backgrounded and resumed | Resume app | FAB visible and functional | iOS, Android | All | Both | P1 | No |
| NAV-W028 | Dashboard/LeftMenuCounts | should display correct Inbox count matching actual email count | Verify count accuracy | SideMenu/MyDrawer | Inbox has 15 emails | None | Inbox badge shows 15 | All | All | Both | P1 | No |
| NAV-W029 | Dashboard/LeftMenuCounts | should update counts dynamically when emails move between folders | Verify dynamic update | SideMenu/MyDrawer | Move 1 email from Inbox to Archive | Move email | Inbox count decrements, Archive count increments | All | All | Both | P1 | No |
| NAV-W030 | Dashboard/LeftMenuCounts | should display correct Draft count matching actual draft count | Verify draft count accuracy | SideMenu/MyDrawer | Drafts folder has 3 emails | None | Draft badge shows 3 | All | All | Both | P1 | No |
| NAV-W031 | Dashboard/LeftMenuCounts | should display correct Archive count matching actual archive count | Verify archive count accuracy | SideMenu/MyDrawer | Archive folder has 7 emails | None | Archive badge shows 7 | All | All | Both | P1 | No |
| NAV-W032 | Dashboard/LeftMenuCounts | should display correct Trash count matching actual trash count | Verify trash count accuracy | SideMenu/MyDrawer | Trash folder has 5 emails | None | Trash badge shows 5 | All | All | Both | P1 | No |
| NAV-W033 | Dashboard/LeftMenuCounts | should update Draft count when draft sent | Verify draft count on send | SideMenu/MyDrawer | Send draft email | Send draft | Draft count decrements by 1 | All | All | Both | P1 | No |
| NAV-W034 | Dashboard/LeftMenuCounts | should update Trash count when email moved from Trash to Inbox | Verify trash to inbox count | SideMenu/MyDrawer | Move email from Trash to Inbox | Move email | Trash count decrements, Inbox count increments | All | All | Both | P1 | No |
| NAV-W035 | Dashboard/LeftMenuCounts | should update Archive count when email moved from Archive to Inbox | Verify archive to inbox count | SideMenu/MyDrawer | Move email from Archive to Inbox | Move email | Archive count decrements, Inbox count increments | All | All | Both | P1 | No |

---

## 8. Subscription & Payment Module

### Current Coverage Status
- **Existing tests:** None
- **Gaps:** Complete

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| SUB-U001 | Subscription/PaymentListModel | should deserialize from valid JSON | Verify fromJson | Valid payment JSON | plan and paymentList populated | P1 | No |
| SUB-U002 | Subscription/PaymentListModel | should handle empty payment list | Verify empty | JSON with paymentList=[] | Empty list, no error | P1 | Yes |
| SUB-U003 | Subscription/PlanListModel | should deserialize from valid JSON | Verify fromJson | Valid plans JSON | plans list populated | P1 | No |
| SUB-U004 | Subscription/PlanListModel | should handle nullable stripeProductId | Verify null safety | stripeProductId=null | No crash | P1 | Yes |
| SUB-U005 | Subscription/PlanListModel | should parse features list | Verify array parsing | JSON with features=['Feature1','Feature2'] | features.length=2 | P1 | No |
| SUB-U006 | Subscription/CheckOut | should use correct platform implementation | Verify platform check | Web vs Mobile | WebCheckOut or MobileCheckOut used | P1 | No |
| SUB-U007 | Subscription/Renewal | should process account renewal successfully | Verify renewal flow | Active subscription nearing expiration | API called, subscription renewed, new expiration date set | P0 | No |
| SUB-U008 | Subscription/Renewal | should handle renewal with updated payment method | Verify payment method change on renewal | Expired card, user updates payment | New payment method saved, renewal completes | P1 | No |
| SUB-U009 | Subscription/Renewal | should handle failed renewal gracefully | Verify failed renewal | Payment method declined | Error toast shown, account reverts to free tier with grace period | P0 | Yes |
| SUB-U010 | Subscription/Upgrade | should upgrade account from free to paid plan | Verify upgrade flow | Free user selects paid plan | API called with upgrade, subscription active immediately | P0 | No |
| SUB-U011 | Subscription/Downgrade | should downgrade account from paid to lower tier | Verify downgrade flow | Paid user selects lower plan | API called, downgrade scheduled at billing cycle end | P1 | No |
| SUB-U012 | Subscription/Upgrade | should handle prorated billing on mid-cycle upgrade | Verify proration | User upgrades mid-billing-cycle | Prorated charge calculated, shown to user before confirmation | P1 | No |
| SUB-U013 | Subscription/PromoCode | should apply valid percentage-based promo code | Verify % promo | Valid promo code "SAVE20" (20% off) | Discount applied, total recalculated showing 20% reduction | P1 | No |
| SUB-U014 | Subscription/PromoCode | should apply valid dollar-amount promo code | Verify $ promo | Valid promo code "SAVE5" ($5 off) | Discount applied, total reduced by $5.00 | P1 | No |
| SUB-U015 | Subscription/PromoCode | should apply valid time-limited promo code before expiry | Verify time-limited promo | Valid promo code with expiry in future | Discount applied successfully | P1 | No |
| SUB-U016 | Subscription/PromoCode | should reject expired promo code | Verify expired promo | Promo code past expiration date | Error: "This promo code has expired" | P1 | Yes |
| SUB-U017 | Subscription/PromoCode | should reject promo code exceeding usage cap | Verify usage cap | Promo code at max redemptions | Error: "This promo code has reached its usage limit" | P1 | Yes |
| SUB-U018 | Subscription/PromoCode | should reject invalid/nonexistent promo code | Verify invalid promo | Promo code "INVALID123" | Error: "Invalid promo code" | P1 | Yes |
| SUB-U019 | Subscription/PromoCode | should enforce minimum purchase requirement for promo code | Verify min purchase | Promo code requires min $10, plan costs $5 | Error: "Minimum purchase of $10 required for this promo code" | P1 | Yes |
| SUB-U020 | Subscription/PaymentMethod | should add new credit/debit card via Stripe | Verify add card | Valid card details entered | Card added to payment methods, confirmed via API | P1 | No |
| SUB-U021 | Subscription/PaymentMethod | should delete existing payment method | Verify delete card | User has 2 cards on file | Selected card deleted via API, removed from list | P1 | No |
| SUB-U022 | Subscription/PaymentMethod | should update default payment method | Verify update default | User has multiple cards | Selected card set as default, API updated | P1 | No |
| SUB-U023 | Subscription/PaymentMethod | should prevent deletion of last payment method on active subscription | Verify delete guard | User has 1 card, active paid subscription | Error: "Cannot remove last payment method with active subscription" | P1 | Yes |
| SUB-U024 | Subscription/PaymentMethod | should handle declined card on add | Verify declined card | Card number that Stripe declines | Error: "Card was declined. Please try a different card." | P1 | Yes |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| SUB-W001 | Subscription/Plans | should render plan selection cards | Verify rendering | SubscriptionScreen | Plans loaded | None | Plan cards visible | All | All | Both | P1 | No |
| SUB-W002 | Subscription/Plans | should highlight annual plan with savings badge | Verify badge | SubscriptionScreen | Annual plan in list | None | "30% SAVINGS" ribbon visible on annual | All | All | Both | P1 | No |
| SUB-W003 | Subscription/Plans | should select plan on tap | Verify selection | SubscriptionScreen | Plans loaded | Tap plan card | Plan highlighted, Get Plan button active | All | All | Both | P1 | No |
| SUB-W004 | Subscription/Plans | should navigate to checkout | Verify navigation | SubscriptionScreen | Plan selected | Tap Get Plan | Navigation to /checkout with plan data | All | All | Both | P1 | No |
| SUB-W005 | Subscription/Plans | should show payment history | Verify history | SubscriptionScreen | Payment list loaded | None | Payment history table/cards visible | All | All | Both | P1 | No |
| SUB-W006 | Subscription/Plans | should show loading spinner | Verify loading | SubscriptionScreen | isLoading=true | None | Spinner visible | All | All | Both | P2 | No |
| SUB-W007 | Subscription/EmailPlan | should render plan card with features | Verify rendering | Plan widget | title, price, features | None | Title, price, feature list visible | All | All | Both | P1 | No |
| SUB-W008 | Subscription/EmailPlan | should show check icons for included features | Verify icons | Plan widget | features with/without limitations | None | Check for included, cross for limited | All | All | Both | P2 | No |
| SUB-W009 | Subscription/Account | should show renewal date and subscription status | Verify renewal info | Accountriverpod/SubscriptionDetail | Active subscription | None | Renewal date, current plan, status visible | All | All | Both | P1 | No |
| SUB-W010 | Subscription/Account | should navigate to renewal flow | Verify renewal navigation | Accountriverpod | Subscription expiring soon | Tap Renew | Navigation to renewal/checkout screen with current plan | All | All | Both | P1 | No |
| SUB-W011 | Subscription/Plans | should show upgrade and downgrade options relative to current plan | Verify plan comparison | SubscriptionScreen | User on mid-tier plan | None | Higher plans show "Upgrade", lower plans show "Downgrade" | All | All | Both | P1 | No |
| SUB-W012 | Subscription/Plans | should confirm plan change on upgrade or downgrade | Verify confirmation dialog | SubscriptionScreen | User taps upgrade/downgrade | Tap plan change | Confirmation dialog with price difference and effective date | All | All | Both | P1 | No |
| SUB-W013 | Subscription/PromoCode | should render promo code input field on checkout screen | Verify promo UI | CheckoutScreen | Checkout loaded | None | Promo code text field with "Apply" button visible | All | All | Both | P1 | No |
| SUB-W014 | Subscription/PromoCode | should show discount applied message and updated total | Verify discount UI | CheckoutScreen | Valid promo applied | Enter code + tap Apply | Green success text "20% discount applied", total updated | All | All | Both | P1 | No |
| SUB-W015 | Subscription/PromoCode | should show error message for invalid promo code | Verify promo error UI | CheckoutScreen | Invalid promo code entered | Tap Apply | Red error text below promo field | All | All | Both | P1 | Yes |
| SUB-W016 | Subscription/PaymentMethod | should render list of saved payment methods | Verify payment list UI | PaymentMethodsScreen | User has 2 cards on file | None | Two card items visible with last4, expiry, card brand | All | All | Both | P1 | No |
| SUB-W017 | Subscription/PaymentMethod | should show add payment method form | Verify add card UI | PaymentMethodsScreen | Default | Tap "Add Card" | Stripe card input form rendered (card number, expiry, CVC) | All | All | Both | P1 | No |
| SUB-W018 | Subscription/PaymentMethod | should show delete confirmation for payment method | Verify delete confirm UI | PaymentMethodsScreen | Cards on file | Tap delete icon on card | Confirmation dialog: "Remove this payment method?" | All | All | Both | P1 | No |
| SUB-W019 | Subscription/PaymentMethod | should highlight default payment method | Verify default indicator | PaymentMethodsScreen | 2 cards, one default | None | Default card shows "Default" badge or checkmark | All | All | Both | P2 | No |

---

## 9. Help Center & Static Pages Module

### Current Coverage Status
- **Existing tests:** None
- **Gaps:** Complete

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| HELP-U001 | HelpCenter/HelpCenterNotifier | should select FAQ category | Verify category selection | categoryId=2 | selectedCategory=2 | P2 | No |
| HELP-U002 | HelpCenter/HelpCenterNotifier | should search FAQs | Verify search | query='payment' | Filtered FAQ items | P2 | No |
| HELP-U003 | HelpCenter/HelpCenterNotifier | should toggle expand item | Verify toggle | itemId=1 expanded | itemId=1 collapsed after toggle | P2 | No |
| HELP-U004 | HelpCenter/HelpCenterNotifier | should collapse all items | Verify collapse all | Multiple expanded | All collapsed | P2 | No |
| HELP-U005 | HelpCenter/StaticPageModel | should deserialize from valid JSON | Verify fromJson | Valid static page JSON | page data populated | P2 | No |
| HELP-U006 | HelpCenter/FaqStaticPageModel | should deserialize from valid JSON | Verify fromJson | Valid FAQ JSON | faq list populated | P2 | No |
| HELP-U007 | HelpCenter/FaqStaticPageModel | should handle null fields | Verify null safety | JSON with null optional fields | No crash | P2 | Yes |
| HELP-U008 | HelpCenter/VersionDisplay | should return current app version string | Verify version retrieval | App built with version 1.0.3+1 | Version string matches pubspec version | P1 | No |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| HELP-W001 | HelpCenter/Main | should render help center | Verify rendering | HelpCenterriverpod | FAQ data loaded | None | Categories and FAQ items visible | All | All | Both | P2 | No |
| HELP-W002 | HelpCenter/Main | should expand FAQ item on tap | Verify expand | HelpCenterriverpod | FAQ loaded | Tap FAQ item | Answer text visible | All | All | Both | P2 | No |
| HELP-W003 | HelpCenter/Main | should render mobile layout | Verify responsive | HelpCenterriverpod | Mobile viewport | None | Mobile layout | All | Small | Portrait | P2 | No |
| HELP-W004 | HelpCenter/StaticPage | should render HTML content | Verify HTML rendering | StaticPages | Static page data | None | HTML content rendered | All | All | Both | P2 | No |
| HELP-W005 | HelpCenter/Main | should display current app version in help center | Verify version rendering | HelpCenterriverpod | App version loaded | None | Version number (e.g., "v1.0.3") visible in help center footer/header | All | All | Both | P1 | No |
| HELP-W006 | HelpCenter/Navigation | should navigate to Contact Us page from help center | Verify Contact Us navigation | HelpCenterriverpod | Help center loaded | Tap Contact Us | Contact Us page content rendered | All | All | Both | P1 | No |
| HELP-W007 | HelpCenter/Navigation | should navigate to FAQ page from help center | Verify FAQ navigation | HelpCenterriverpod | Help center loaded | Tap FAQ | FAQ page with categories rendered | All | All | Both | P1 | No |
| HELP-W008 | HelpCenter/Navigation | should navigate to Privacy Policy page from help center | Verify Privacy Policy navigation | HelpCenterriverpod | Help center loaded | Tap Privacy Policy | Privacy Policy HTML content rendered | All | All | Both | P1 | No |
| HELP-W009 | HelpCenter/Navigation | should navigate to Terms & Conditions page from help center | Verify Terms navigation | HelpCenterriverpod | Help center loaded | Tap Terms & Conditions | Terms HTML content rendered | All | All | Both | P1 | No |
| HELP-W010 | HelpCenter/Navigation | should navigate back to help center from sub-page | Verify back navigation | StaticPages | Sub-page (e.g., FAQ) loaded | Tap Back | Help center main screen rendered | All | All | Both | P1 | No |

---

## 10. Core Services & Utilities

### Current Coverage Status
- **Existing tests:** None
- **Gaps:** Complete

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| CORE-U001 | Core/Result | should create success result with data | Verify factory | data='hello' | isSuccess=true, data='hello', error=null | P0 | No |
| CORE-U002 | Core/Result | should create failure result with error | Verify factory | error='Network error' | isSuccess=false, isFailure=true, error='Network error' | P0 | No |
| CORE-U003 | Core/Result | should map success data | Verify map | Result.success(5), transform: x*2 | Result.success(10) | P0 | No |
| CORE-U004 | Core/Result | should not map failure data | Verify map skip | Result.failure('err'), transform: x*2 | Result.failure('err') | P0 | No |
| CORE-U005 | Core/Result | should handle map exception | Verify map error | Result.success(null), transform throws | Result.failure with exception message | P0 | Yes |
| CORE-U006 | Core/Result | should mapError on failure | Verify mapError | Result.failure('err'), transform: prefix | Result.failure with transformed message | P1 | No |
| CORE-U007 | Core/Result | should not mapError on success | Verify mapError skip | Result.success(5) | Same result unchanged | P1 | No |
| CORE-U008 | Core/Result | should fold success | Verify fold | Result.success(5) | onSuccess called with 5 | P0 | No |
| CORE-U009 | Core/Result | should fold failure | Verify fold | Result.failure('err') | onFailure called with 'err' | P0 | No |
| CORE-U010 | Core/Result | should handle fold with null data success | Verify edge | Result.success but data=null internally | onFailure called with 'Unknown error' | P0 | Yes |
| CORE-U011 | Core/RequestResponse | should hold data and null error | Verify DTO | data={...}, error=null | data accessible, error=null | P0 | No |
| CORE-U012 | Core/RequestResponse | should hold error and null data | Verify DTO | data=null, error=RequestError | error accessible, data=null | P0 | No |
| CORE-U013 | Core/RequestError | should deserialize from JSON | Verify fromJson | Valid error JSON | statusCode and error populated | P0 | No |
| CORE-U014 | Core/RequestError | should create from singleMessage factory | Verify factory | message='Not found' | error='Not found' | P0 | No |
| CORE-U015 | Core/RequestError | should handle errors array format | Verify multi-error | JSON with errors=[{field,message},...] | errors list populated | P1 | Yes |
| CORE-U016 | Core/RequestError | should handle detail format | Verify format variant | JSON with 'detail' key | error extracted from detail | P1 | Yes |
| CORE-U017 | Core/RequestError | should handle match_format format | Verify format variant | JSON with 'match_format' key | error extracted | P1 | Yes |
| CORE-U018 | Service/ApiService | should make GET request with auth headers | Verify GET | Valid path, active session | GET request with authorization header | P0 | No |
| CORE-U019 | Service/ApiService | should make POST request with body | Verify POST | Path, body data | POST request with JSON body | P0 | No |
| CORE-U020 | Service/ApiService | should inject Descope refresh JWT | Verify token injection | Active Descope session | authorization: refreshJwt header set | P0 | No |
| CORE-U021 | Service/ApiService | should handle no Descope session | Verify no session | No active session | Request made without auth header | P1 | Yes |
| CORE-U022 | Service/ApiService | should throw NoInternetException on SocketException | Verify offline handling | SocketException thrown | NoInternetException propagated | P0 | Yes |
| CORE-U023 | Service/ApiService | should throw NoInternetException on TimeoutException | Verify timeout | Request times out | NoInternetException propagated | P0 | Yes |
| CORE-U024 | Service/ApiService | should handle 401 status code | Verify session expiry | API returns 401 | Session expiration dialog triggered | P0 | Yes |
| CORE-U025 | Service/ApiService | should handle 405 status code | Verify session expiry | API returns 405 | Session expiration dialog triggered | P0 | Yes |
| CORE-U026 | Service/ApiService | should include platform header | Verify headers | Request made | x-opt-platform header set correctly | P1 | No |
| CORE-U027 | Service/ApiService | should include version header | Verify headers | Request made | x-opt-version header set | P1 | No |
| CORE-U028 | Service/BaseAPIService | should make request with correct method type | Verify method dispatch | RequestType.GET/POST/DELETE/PATCH/PUT | Correct HTTP method used | P0 | No |
| CORE-U029 | Service/BaseAPIService | should check internet before request (non-web) | Verify connectivity check | NetworkService check | Internet check performed before request | P0 | No |
| CORE-U030 | Service/BaseAPIService | should skip internet check on web | Verify web bypass | kIsWeb=true | No NetworkService check | P1 | No |
| CORE-U031 | Service/BaseAPIService | should return RequestResponse with data on success | Verify success response | API returns 200 | RequestResponse with data, null error | P0 | No |
| CORE-U032 | Service/BaseAPIService | should return RequestResponse with error on failure | Verify error response | API returns 500 | RequestResponse with error | P0 | No |
| CORE-U033 | Service/RefreshableService | should inject refresh JWT header | Verify Descope header | Active Descope session | authorization: refreshJwt, tokentype: descope | P0 | No |
| CORE-U034 | Service/RefreshableService | should handle missing Descope session | Verify fallback | No session | Request made without auth | P1 | Yes |
| CORE-U035 | Service/StorageService | should write and read string data | Verify write/read | key='test', value='hello' | readData returns 'hello' | P0 | No |
| CORE-U036 | Service/StorageService | should return null for missing key | Verify missing | key='nonexistent' | readData returns null | P0 | Yes |
| CORE-U037 | Service/StorageService | should delete data | Verify delete | Existing key | After delete, readData returns null | P0 | No |
| CORE-U038 | Service/StorageService | should write and read object data | Verify object storage | key='user', value={name:'John'} | readObjectData returns same map | P0 | No |
| CORE-U039 | Service/StorageService | should update specific object field | Verify partial update | Existing object, update one field | Only specified field changed | P1 | No |
| CORE-U040 | Service/StorageService | should clear all data | Verify logout cleanup | Multiple stored items | All keys cleared | P0 | No |
| CORE-U041 | Service/StorageService | should handle PlatformException -25308 | Verify iOS error | Secure storage throws -25308 | Error handled gracefully | P1 | Yes |
| CORE-U042 | Service/SocketService | should initialize socket with URL and token | Verify init | Valid URL, token, userId | Socket connected, login event emitted | P0 | No |
| CORE-U043 | Service/SocketService | should emit event with acknowledgment | Verify emit | Event name, data | Event emitted, ack callback invoked | P1 | No |
| CORE-U044 | Service/SocketService | should listen to events | Verify subscription | Event 'unReadCount' | Callback fired when event received | P0 | No |
| CORE-U045 | Service/SocketService | should return stream for event | Verify stream | Event 'newMessage' | Stream yields data on event | P1 | No |
| CORE-U046 | Service/SocketService | should disconnect cleanly | Verify disconnect | Connected socket | isConnected()=false after disconnect | P1 | No |
| CORE-U047 | Service/SocketService | should attempt reconnection | Verify reconnect | Connection lost | Up to 10 reconnection attempts | P1 | Yes |
| CORE-U048 | Service/SocketService | should update CountNotifier on unReadCount | Verify count sync | Socket receives unReadCount event | CountNotifier updated with new counts | P0 | No |
| CORE-U049 | Service/CommonService | should format date string correctly | Verify date format | '2026-01-15T10:30:00Z' | Formatted date string | P1 | No |
| CORE-U050 | Service/CommonService | should handle null date string | Verify null safety | null input | Returns empty or default string | P1 | Yes |
| CORE-U051 | Service/CommonService | should detect platform correctly | Verify getPlatform | Running on web/ios/android | Returns 'web'/'ios'/'android' | P1 | No |
| CORE-U052 | Service/CommonService | should validate email format | Verify isValidEmail | Various email strings | true for valid, false for invalid | P0 | No |
| CORE-U053 | Service/CommonService | should validate invalid emails | Verify email rejection | 'not-email', '@.com', 'a@' | isValidEmail returns false | P0 | Yes |
| CORE-U054 | Service/CommonService | should capitalize string | Verify capitalize | 'hello world' | 'Hello world' | P2 | No |
| CORE-U055 | Service/CommonService | should handle empty string capitalize | Verify edge | '' | '' (no crash) | P2 | Yes |
| CORE-U056 | Service/CommonService | should format file size | Verify formatFileSize | 1024 KB | '1 MB' or equivalent | P2 | No |
| CORE-U057 | Service/CommonService | should truncate with ellipsis | Verify truncate | maxLength=10, text='Hello World!' | 'Hello W...' | P2 | No |
| CORE-U058 | Service/CommonService | should sanitize email message | Verify sanitize | HTML with scripts | Sanitized output | P1 | No |
| CORE-U059 | Service/CommonService | should convert plain URL to HTML link | Verify URL detection | Text with https://example.com | HTML anchor tag wrapping URL | P2 | No |
| CORE-U060 | Service/FormValidation | should validate required name | Verify validateName | null or '' | Error message returned | P0 | No |
| CORE-U061 | Service/FormValidation | should accept valid name | Verify validateName | 'John' | null (no error) | P0 | No |
| CORE-U062 | Service/FormValidation | should validate email format | Verify validateEmail | 'invalid' | Error message | P0 | No |
| CORE-U063 | Service/FormValidation | should accept valid email | Verify validateEmail | 'user@example.com' | null (no error) | P0 | No |
| CORE-U064 | Service/FormValidation | should validate phone number (10 digits) | Verify validatePhoneNumber | '123' | Error message | P0 | No |
| CORE-U065 | Service/FormValidation | should reject non-numeric phone | Verify phone | 'abc1234567' | Error message | P0 | Yes |
| CORE-U066 | Service/FormValidation | should accept valid phone | Verify phone | '5551234567' | null (no error) | P0 | No |
| CORE-U067 | Service/FormValidation | should validate DOB format | Verify validateDob | '13/32/2025' | Error message | P1 | Yes |
| CORE-U068 | Service/FormValidation | should reject future DOB | Verify validateDob | Future date string | Error message | P1 | Yes |
| CORE-U069 | Service/FormValidation | should validate tag name max length | Verify validateTagName | 21-char string | Error message | P1 | Yes |
| CORE-U070 | Service/FormValidation | should accept valid tag name | Verify validateTagName | 'Important' | null (no error) | P1 | No |
| CORE-U071 | Service/FormValidation | should confirm matching emails | Verify confirmEmail | Both 'a@b.com' | null (no error) | P1 | No |
| CORE-U072 | Service/FormValidation | should reject non-matching emails | Verify confirmEmail | 'a@b.com' vs 'x@y.com' | Error message | P1 | Yes |
| CORE-U073 | Service/NetworkService | should detect internet connectivity | Verify connectivity | Connected to network | Returns true | P0 | No |
| CORE-U074 | Service/NetworkService | should detect no internet | Verify offline | No connectivity | Returns false | P0 | No |
| CORE-U075 | Service/FilePickerService | should return file path on selection | Verify pick | User selects file | File path string returned | P1 | No |
| CORE-U076 | Service/FilePickerService | should return null on cancel | Verify cancel | User cancels picker | null returned | P1 | Yes |
| CORE-U077 | Service/NotificationService | should initialize FCM | Verify init | Firebase initialized | FCM token obtained | P1 | No |
| CORE-U078 | Service/NotificationService | should handle foreground message | Verify foreground | Message received while app open | Local notification shown | P1 | No |
| CORE-U079 | Service/NotificationService | should navigate on notification tap | Verify tap handling | User taps notification with emailId | Navigation to email detail | P1 | No |
| CORE-U080 | Service/NotificationService | should redirect to login if not authenticated | Verify auth check | Notification tap while logged out | Redirect to login | P1 | Yes |
| CORE-U081 | Service/Breakpoints | should detect mobile for width < 600 | Verify isMobile | width=375 | isMobile=true | P0 | No |
| CORE-U082 | Service/Breakpoints | should detect tablet for width 600-1023 | Verify isTablet | width=768 | isTablet=true | P0 | No |
| CORE-U083 | Service/Breakpoints | should detect desktop for width >= 1024 | Verify isDesktop | width=1440 | isDesktop=true | P0 | No |
| CORE-U084 | Service/Breakpoints | should return correct DeviceType enum | Verify getDeviceType | Various widths | Correct DeviceType for each | P0 | No |
| CORE-U085 | Service/Breakpoints | should detect phone (shortestSide < 600) | Verify isPhone | shortestSide=375 | isPhone=true | P1 | No |
| CORE-U086 | Service/Breakpoints | should detect phone landscape | Verify isPhoneLandscape | width=667, height=375, shortestSide=375 | isPhoneLandscape=true | P1 | No |
| CORE-U087 | Service/Breakpoints | should not show reading pane when height < 500 | Verify height check | width=700, height=400 | canShowReadingPaneFromContext=false | P1 | Yes |
| CORE-U088 | Service/Breakpoints | should detect native tablet portrait as mobile | Verify tablet handling | Native tablet, portrait, shortestSide>=600 | isMobileLayout=true | P1 | No |
| CORE-U089 | Service/Breakpoints | should detect native tablet landscape as tablet | Verify tablet handling | Native tablet, landscape | isTabletLayout=true | P1 | No |
| CORE-U090 | Service/DescopeApiService | should make POST with Bearer token | Verify auth header | Active Descope session | Bearer projectId:refreshJwt | P1 | No |
| CORE-U091 | Service/CountNotifier | should update all counts | Verify counts | inbox=5, draft=2, trash=1, archive=3 | All counts match | P0 | No |
| CORE-U092 | Service/CountNotifier | should handle email sending flow | Verify triggerEmail | Valid compose data | Socket emit called | P1 | No |
| CORE-U093 | Service/CountNotifier | should display add email modal for opt-in | Verify opt-in flow | Email not in contacts | AddEmailModal shown | P1 | No |
| CORE-U094 | Service/GlobalVariableNotifier | should track navigation paths | Verify path tracking | addPath('/inbox') | pathList contains '/inbox' | P2 | No |
| CORE-U095 | Service/GlobalVariableNotifier | should clear path list | Verify clear | Paths added | clearPathList → empty list | P2 | No |
| CORE-U096 | Service/UpdateNotifier | should track update dialog visibility | Verify visibility | setUpdateDialogVisible(true) | isUpdateDialogVisible=true | P2 | No |
| CORE-U097 | Service/UpdateNotifier | should track optional update dismissal | Verify dismissal | dismissOptionalUpdate() | isOptionalUpdateDismissed=true | P2 | No |

### Flutter Test Notes — Core Services
- **Required mocks:** MockHttpClient (for http package), MockDio (if Dio used), MockNetworkService, MockSecureStorage, MockDescopeSessionManager
- **TestWidgetsFlutterBinding.ensureInitialized():** Required for all service tests using platform channels
- **HttpOverrides:** May need `HttpOverrides.global = MockHttpOverrides()` for HTTP tests
- **SharedPreferences:** `SharedPreferences.setMockInitialValues({})` before each test
- **Firebase:** Need `setupFirebaseCoreMocks()` from `firebase_core_platform_interface` for notification tests

---

## 11. Reusable Widgets

### Current Coverage Status
- **Existing tests:** None
- **Gaps:** Complete

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| WID-W001 | Widget/CustomTextFormField | should render with label | Verify rendering | CustomTextFormField | labelText='Email' | None | Label text visible, input field rendered | All | All | Both | P0 | No |
| WID-W002 | Widget/CustomTextFormField | should accept text input | Verify input | CustomTextFormField | Empty | Type 'hello' | Controller.text='hello' | All | All | Both | P0 | No |
| WID-W003 | Widget/CustomTextFormField | should show validation error | Verify validation | CustomTextFormField | validator returns error | Submit form | Error text visible below field | All | All | Both | P0 | No |
| WID-W004 | Widget/CustomTextFormField | should toggle password visibility | Verify password | CustomTextFormField | isPassword=true | Tap visibility icon | Text toggles obscured/visible | All | All | Both | P1 | No |
| WID-W005 | Widget/CustomTextFormField | should strip spaces for username type | Verify space removal | CustomTextFormField | Username field | Type 'user name' | Text becomes 'username' | All | All | Both | P1 | No |
| WID-W006 | Widget/SimpleTextFormField | should render with label | Verify rendering | SimpleTextFormField | labelText='Name' | None | Label visible | All | All | Both | P0 | No |
| WID-W007 | Widget/GrayTextFormField | should render with gray background | Verify styling | GrayTextFormField | Default | None | Gray filled background | All | All | Both | P2 | No |
| WID-W008 | Widget/ClickableText | should render text segments | Verify rendering | ClickableText | text1='Click', text2='here' | None | Both text segments visible | All | All | Both | P1 | No |
| WID-W009 | Widget/ClickableText | should call onTap on segment tap | Verify interaction | ClickableText | onTap provided | Tap second segment | onTap callback fired | All | All | Both | P1 | No |
| WID-W010 | Widget/CustomGradientButton | should render with text | Verify rendering | CustomGradientButton | text='Submit' | None | Button with gradient background and text | All | All | Both | P0 | No |
| WID-W011 | Widget/CustomGradientButton | should call onPressed on tap | Verify interaction | CustomGradientButton | onPressed callback | Tap button | Callback fired | All | All | Both | P0 | No |
| WID-W012 | Widget/CustomGradientButton | should render with leading icon | Verify icon | CustomGradientButton | leadingIcon=Icon(Icons.send) | None | Icon visible before text | All | All | Both | P1 | No |
| WID-W013 | Widget/CommonWebButton | should render icon and label | Verify rendering | CommonWebButton | label='Compose', iconData | None | Icon + label visible | Web | Large | Both | P1 | No |
| WID-W014 | Widget/CommonWebButton | should call hover callbacks | Verify hover | CommonWebButton | onHoverStart/End | Mouse hover | Hover callbacks fired | Web | Large | Both | P2 | No |
| WID-W015 | Widget/FooterButton | should render two buttons | Verify rendering | FooterButton | textButton1='Cancel', textButton2='Save' | None | Both buttons visible | All | All | Both | P1 | No |
| WID-W016 | Widget/FooterButton | should call correct callback per button | Verify callbacks | FooterButton | Both callbacks | Tap each button | Correct callback per button | All | All | Both | P1 | No |
| WID-W017 | Widget/CustomPopupModal | should render dialog with title | Verify rendering | CustomPopupModal | title='Confirm' | None | Title, subtitle, buttons visible | All | All | Both | P1 | No |
| WID-W018 | Widget/CustomPopupModal | should render with optional form field | Verify form | CustomPopupModal | formField1=SimpleTextFormField | None | Form field visible in dialog | All | All | Both | P1 | No |
| WID-W019 | Widget/CustomPopupModal | should call button callbacks | Verify callbacks | CustomPopupModal | Both button callbacks | Tap buttons | Correct callback fired | All | All | Both | P1 | No |
| WID-W020 | Widget/PopUpModalTagList | should render tag list with checkboxes | Verify rendering | PopUpModalTagList | itemList with 3 tags | None | 3 tag items with checkboxes | All | All | Both | P1 | No |
| WID-W021 | Widget/PopUpModalTagList | should pre-select initial tags | Verify pre-selection | PopUpModalTagList | initialSelectedTagIds=[1,2] | None | Tags 1,2 checked | All | All | Both | P1 | No |
| WID-W022 | Widget/PopUpModalTagList | should toggle tag selection | Verify toggle | PopUpModalTagList | Tag unchecked | Tap tag checkbox | Tag becomes checked | All | All | Both | P1 | No |
| WID-W023 | Widget/PopUpModalTagList | should cancel and revert selections | Verify cancel | PopUpModalTagList | Selections changed | Tap Cancel | Reverted to initialTagIds | All | All | Both | P1 | No |
| WID-W024 | Widget/PopUpModalTagList | should add tag via creation form | Verify creation | PopUpModalTagList | Default | Tap "Add Tag" link | Bottom sheet form shown | All | All | Both | P1 | No |
| WID-W025 | Widget/CustomSearchBar | should render search input | Verify rendering | CustomSearchBar | Default | None | Search icon and input visible | All | All | Both | P1 | No |
| WID-W026 | Widget/CustomSearchBar | should call onSearch on input | Verify search | CustomSearchBar | onSearch callback | Type text | onSearch fired with value | All | All | Both | P1 | No |
| WID-W027 | Widget/CustomSearchBar | should clear on icon tap | Verify clear | CustomSearchBar | Text entered | Tap clear icon | Input cleared, onSearch('') | All | All | Both | P1 | No |
| WID-W028 | Widget/DateOfBirthPicker | should render with label | Verify rendering | DateOfBirthPicker | labelText='Date of Birth' | None | Label and calendar icon visible | All | All | Both | P1 | No |
| WID-W029 | Widget/DateOfBirthPicker | should open date picker on icon tap | Verify picker | DateOfBirthPicker | Default | Tap calendar icon | DatePicker dialog shown | All | All | Both | P1 | No |
| WID-W030 | Widget/DateOfBirthPicker | should format selected date | Verify formatting | DateOfBirthPicker | Date selected | Select date | Controller shows MM/dd/yyyy | All | All | Both | P1 | No |
| WID-W031 | Widget/SkeletonLoader | should render with shimmer animation | Verify animation | SkeletonLoader | width=200, height=20 | None | Animated gradient visible | All | All | Both | P1 | No |
| WID-W032 | Widget/SkeletonLoader | should render EmailListItemSkeleton variant | Verify variant | EmailListItemSkeleton | Default | None | Multiple skeleton rows | All | All | Both | P2 | No |
| WID-W033 | Widget/SkeletonLoader | should render DesktopInboxSkeletonLoader | Verify desktop variant | DesktopInboxSkeletonLoader | Desktop viewport | None | Split-pane skeleton | Web | Large | Both | P2 | No |
| WID-W034 | Widget/NoData | should render empty state for inbox | Verify rendering | NoData | page='inbox' | None | Illustration + empty message | All | All | Both | P1 | No |
| WID-W035 | Widget/NoData | should render empty state for contacts | Verify variant | NoData | page='contact' | None | Contact-specific empty message | All | All | Both | P1 | No |
| WID-W036 | Widget/NoData | should render custom title | Verify custom | NoData | title='No results found' | None | Custom text shown | All | All | Both | P2 | No |
| WID-W037 | Widget/CustomToast | should render success toast | Verify success variant | CustomToast | type='success', message='Saved' | None | Green background, check icon, message | All | All | Both | P1 | No |
| WID-W038 | Widget/CustomToast | should render error toast | Verify error variant | CustomToast | type='error', message='Failed' | None | Red background, error icon, message | All | All | Both | P1 | No |
| WID-W039 | Widget/CustomToast | should render undo toast | Verify undo variant | CustomToast | type='Undo', undoMethod callback | None | Blue background, Undo button visible | All | All | Both | P1 | No |
| WID-W040 | Widget/CustomToast | should call undoMethod on undo tap | Verify undo action | CustomToast | undoMethod callback | Tap Undo | Callback fired | All | All | Both | P1 | No |
| WID-W041 | Widget/CustomToast | should call close on X tap | Verify close | CustomToast | closeIcon callback | Tap X | Callback fired | All | All | Both | P1 | No |
| WID-W042 | Widget/GradientAppBar | should render app bar with gradient | Verify rendering | GradientAppBar | title, actions | None | Gradient background, title, actions visible | All | All | Both | P0 | No |
| WID-W043 | Widget/GradientAppBar | should show free trial banner | Verify banner | GradientAppBar | User on trial | None | Free trial countdown visible | All | All | Both | P1 | No |
| WID-W044 | Widget/GradientAppBar | should hide banner when hideUpgradeBanner=true | Verify hide | GradientAppBar | hideUpgradeBanner=true | None | No banner | All | All | Both | P1 | No |
| WID-W045 | Widget/GradientAppBar | should show compact banner on tablet | Verify responsive | GradientAppBar | Tablet viewport | None | Compact trial text | All | Medium | Both | P2 | No |
| WID-W046 | Widget/GradientBackground | should render child with gradient | Verify rendering | GradientBackground | child=Text('Hello') | None | Blue gradient + child | All | All | Both | P2 | No |
| WID-W047 | Widget/AddEmailModal | should render modal with form fields | Verify rendering | AddEmailModal | type='Single' | None | Name, email fields, save/cancel buttons | All | All | Both | P1 | No |
| WID-W048 | Widget/AddEmailModal | should validate email in modal | Verify validation | AddEmailModal | Invalid email entered | Tap Save | Validation error | All | All | Both | P1 | Yes |
| WID-W049 | Widget/AddEmailModal | should call saveFlag on success | Verify callback | AddEmailModal | Valid data entered | Tap Save | saveFlag callback fired | All | All | Both | P1 | No |
| WID-W050 | Widget/AddEmailModal | should show skip button | Verify skip | AddEmailModal | type='Multiple' | None | Skip button visible | All | All | Both | P1 | No |
| WID-W051 | Widget/AddEmailModal | should show add to existing option | Verify existing | AddEmailModal | type='optin' | None | "Add to Existing Contact" visible | All | All | Both | P2 | No |
| WID-W052 | Widget/CreditCardWidget | should render card details | Verify rendering | CreditCardWidget | cardType='Visa', last4='1234' | None | Visa label, masked number, expiry | All | All | Both | P2 | No |
| WID-W053 | Widget/CreditCardWidget | should call onDelete | Verify delete | CreditCardWidget | onDelete callback | Tap delete icon | Callback fired | All | All | Both | P2 | No |
| WID-W054 | Widget/CustomSwitchListTile | should render switch with title | Verify rendering | CustomSwitchListTile | title='Enable', value=false | None | Title text, Cupertino switch (off) | All | All | Both | P1 | No |
| WID-W055 | Widget/CustomSwitchListTile | should toggle on tap | Verify toggle | CustomSwitchListTile | value=false | Tap switch | onChanged(true) called | All | All | Both | P1 | No |
| WID-W056 | Widget/DraggableDivider | should render divider line | Verify rendering | DraggableDivider | isHorizontal=true | None | Divider line visible | Web | Large | Both | P2 | No |
| WID-W057 | Widget/DraggableDivider | should resize on drag | Verify drag | DraggableDivider | currentSize=300 | Drag gesture | onDragUpdate fired with new size | Web | Large | Both | P2 | No |
| WID-W058 | Widget/DraggableDivider | should respect min/max constraints | Verify bounds | DraggableDivider | minSize=200, maxSize=600 | Drag beyond bounds | Size clamped to min/max | Web | Large | Both | P2 | Yes |
| WID-W059 | Widget/LogoWithSlogan | should render logo and text | Verify rendering | LogoWithSlogan | Default | None | Logo image + slogan text | All | All | Both | P2 | No |
| WID-W060 | Widget/DashedBorder | should render dashed line | Verify custom paint | DashedBorder | width=200, height=1 | None | Dashed horizontal line via CustomPaint | All | All | Both | P2 | No |
| WID-W061 | Widget/CountryPicker | should render country code | Verify rendering | CountryPicker | Default | None | Flag + "(+1)" visible | All | All | Both | P2 | No |
| WID-W062 | Widget/UpgradePlanPopup | should render upgrade prompt | Verify rendering | UpgradePlanPopup | Default | None | Upgrade message + button visible | All | All | Both | P1 | No |
| WID-W063 | Widget/UpgradePlanPopup | should navigate to plans on tap | Verify navigation | UpgradePlanPopup | Default | Tap Upgrade | Navigation to /plans | All | All | Both | P1 | No |
| WID-W064 | Widget/LoadContainer | should show loader when loading | Verify loading | LoadContainer | isLoading=true | None | Loading overlay visible | All | All | Both | P0 | No |
| WID-W065 | Widget/LoadContainer | should show child when not loading | Verify normal | LoadContainer | isLoading=false | None | Child widget visible, no overlay | All | All | Both | P0 | No |
| WID-W066 | Widget/BottomNavAction | should render action buttons | Verify rendering | BottomNavAction | ids selected | None | Archive, Tag, Trash buttons | All | Small | Portrait | P1 | No |
| WID-W067 | Widget/BottomNavAction | should open tag modal on tag tap | Verify interaction | BottomNavAction | Tags available | Tap Tag button | Tag selection modal shown | All | Small | Portrait | P1 | No |
| WID-W068 | Widget/Onboarding | should render onboarding screens | Verify rendering | Onboarding | Default | None | Onboarding content visible | All | All | Both | P2 | No |

### Flutter Test Notes — Widgets
- **Required wrappers:** `MaterialApp` for theme/navigation context, `MediaQuery` for responsive tests
- **pumpAndSettle:** Required for SkeletonLoader animation tests (or use `pump(Duration)`)
- **Golden test candidates:** SkeletonLoader, DashedBorder, CreditCardWidget, CustomToast variants, GradientAppBar
- **Window size overrides:** Required for responsive widget variants (GradientAppBar banner)

---

## 12. No Internet Screen

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| NET-W001 | Network/NoInternet | should render offline message | Verify rendering | NoInternetScreen | No connectivity | None | Offline icon + message visible | All | All | Both | P0 | No |
| NET-W002 | Network/NoInternet | should show check connection button | Verify button | NoInternetScreen | Default | None | Button visible | All | All | Both | P0 | No |
| NET-W003 | Network/NoInternet | should dismiss on connection restored | Verify auto-dismiss | NoInternetScreen | Connectivity restored | Stream emits connected | Screen dismissed | All | All | Both | P0 | No |
| NET-W004 | Network/NoInternet | should check manually on button tap | Verify manual check | NoInternetScreen | No connectivity | Tap Check | Connectivity checked | All | All | Both | P1 | No |

---

## 13. Cross-Cutting Integration Test Cases

| ID | Feature/Module | Test Case | Description | Components Involved | Preconditions | Expected Outcome | Platform | Screen Size | Orientation | Priority |
|----|----------------|-----------|-------------|---------------------|---------------|------------------|----------|-------------|-------------|----------|
| INT-I001 | Auth+Inbox | should load inbox after successful login | Login to inbox flow | AuthNotifier + InboxNotifier + BottomNavNotifier | Mock API | Login succeeds → inbox loads with emails | All | All | Both | P0 |
| INT-I002 | Auth+Storage | should restore session from storage | App restart with session | AuthNotifier + SecureStorageService | Previous login stored | App skips login, shows inbox | All | All | Both | P0 |
| INT-I003 | Inbox+Socket | should update inbox count on socket event | Real-time count update | InboxNotifier + SocketService + BottomNavNotifier | Socket connected | unReadCount event → badge updates | All | All | Both | P0 |
| INT-I004 | Inbox+Socket | should add new email on newMessage event | Real-time email arrival | InboxNotifier + SocketService | Socket connected, inbox visible | newMessage event → email appears in list | All | All | Both | P0 |
| INT-I005 | Inbox+Tags | should filter inbox by tag | Tag filtering | InboxNotifier + TagsNotifier | Tags and emails loaded | Select tag filter → filtered list | All | All | Both | P1 |
| INT-I006 | Inbox+Detail | should load email detail on selection | Email viewing | InboxNotifier + EmailDetailNotifier | Email in list | Tap email → detail loaded in reading pane or screen | All | All | Both | P0 |
| INT-I007 | Inbox+Detail+Archive | should archive email and update list | Archive flow | InboxNotifier + EmailDetailNotifier + ArchiveNotifier | Email loaded | Archive → removed from inbox, undo available | All | All | Both | P0 |
| INT-I008 | Inbox+Detail+Trash | should delete email and update list | Delete flow | InboxNotifier + EmailDetailNotifier | Email loaded | Delete → moved to trash, undo toast | All | All | Both | P0 |
| INT-I009 | Contact+Compose | should compose email from contact view | Contact to compose | ViewContactNotifier + Navigation | Contact with email | Tap email → compose screen with recipient | All | All | Both | P1 |
| INT-I010 | Settings+Auth | should logout and clear data | Logout flow | SettingsNotifier + AuthNotifier + SecureStorageService + SocketService | Logged in | Logout → storage cleared, socket disconnected, login screen | All | All | Both | P0 |
| INT-I011 | Settings+Profile | should load and edit profile | Profile edit flow | ProfileNotifier + AccountApi | Logged in | Profile loads → edit → save → updated | All | All | Both | P1 |
| INT-I012 | Settings+Account | should delete account | Account deletion | AccountNotifier + AuthNotifier + AccountApi | Logged in | Confirm delete → API called → logged out | All | All | Both | P0 |
| INT-I013 | Inbox+Compose+Draft | should save draft on compose cancel | Draft save flow | InboxNotifier + DraftNotifier + Navigation | Composing email | Cancel compose → draft saved, appears in drafts | All | All | Both | P1 |
| INT-I014 | Draft+Compose | should resume draft editing | Draft resume flow | DraftNotifier + Navigation | Draft exists | Tap draft → compose with pre-filled data | All | All | Both | P1 |
| INT-I015 | Subscription+Checkout | should complete plan selection and checkout | Purchase flow | SubscriptionScreen + CheckOut + Navigation | Plans loaded | Select plan → checkout → payment success | All | All | Both | P1 |
| INT-I016 | Notification+Navigation | should navigate to email on notification tap | Deep notification | NotificationService + EmailDetailNotifier + Navigation | Notification with emailId | Tap → email detail screen | All | All | Both | P1 |
| INT-I017 | Inbox+ReadingPane | should preserve reading pane on resize | Resize persistence | InboxNotifier + Responsive | Desktop with email selected | Resize window | Reading pane preserves selection | Web | Large | Both | P1 |
| INT-I018 | Tags+Email | should create tag and assign to email | Tag workflow | TagsNotifier + InboxNotifier + TagApi | Logged in | Create tag → select emails → assign tag | All | All | Both | P1 |
| INT-I019 | Auth+Biometric | should authenticate via biometric on resume | Biometric resume | BiometricService + AppLifecycle + AuthNotifier | Biometric enabled | App resume → biometric prompt → authenticated | iOS, Android | All | Both | P1 |
| INT-I020 | Inbox+OptIn | should handle opt-in flow for new sender | Opt-in workflow | InboxNotifier + CountNotifier + AddEmailModal | Email from unknown sender | Opt-in → modal → add contact → send allowed | All | All | Both | P1 |
| INT-I021 | Network+Global | should show no internet overlay | Connectivity monitoring | NoInternetScreen + connectivity_plus | Network lost | Overlay shown, actions disabled | All | All | Both | P0 |
| INT-I022 | Network+Recovery | should resume operations on reconnect | Recovery flow | All notifiers + connectivity_plus | Network restored | Data refreshes, socket reconnects | All | All | Both | P0 |
| INT-I023 | Responsive+Layout | should adapt layout correctly on window resize across breakpoints | Adaptive layout transition | InboxResponsive + SideMenu + ReadingPane + Breakpoints | Desktop viewport | Resize from large → medium → small | Layout transitions correctly at each breakpoint | Web | All | Both | P1 |
| INT-I024 | Responsive+State | should preserve application state during layout transitions | State persistence on resize | InboxNotifier + EmailDetailNotifier + Responsive | Email selected in reading pane | Resize window across breakpoints | Selected email and scroll position preserved after transition | Web | All | Both | P1 |
| INT-I025 | Inbox+OptIn+Send | should complete full opt-in flow during email send with multiple recipients | Multi-recipient opt-in | CountNotifier + AddEmailModal + ComposeNotifier | Compose to 3 recipients (2 non-contacts) | Tap Send | Opt-in modal shown for each non-contact, skip/save options, email sends after | All | All | Both | P1 |
| INT-I026 | Onboarding+Auth | should complete full onboarding flow on first login then skip on subsequent login | Onboarding lifecycle | AuthNotifier + OnboardingScreen + SecureStorageService + Navigation | New account, first login | Login → Complete onboarding → Logout → Login again | First login shows onboarding; second login skips directly to inbox | iOS, Android | Small | Portrait | P1 |
| INT-I027 | Subscription+Account | should reflect account upgrade immediately in UI | Upgrade state propagation | SubscriptionNotifier + AccountNotifier + SettingsNotifier | Free user upgrades to paid | Complete upgrade checkout | Account screen, settings, and compose restrictions update immediately | All | All | Both | P1 |
| INT-I028 | Subscription+Account | should reflect account downgrade at billing cycle end | Downgrade state propagation | SubscriptionNotifier + AccountNotifier | Paid user downgrades | Downgrade confirmed | Current features remain until cycle end; downgrade date shown | All | All | Both | P1 |
| INT-I029 | Inbox+Archive+Undo | should archive email, show undo toast, and restore on undo tap | Archive undo full flow | InboxNotifier + ArchiveNotifier + CountNotifier + CustomToast | Email in inbox | Archive → undo toast → tap Undo | Email removed from inbox → appears in archive → undo restores to inbox; counts correct at each step | All | All | Both | P0 |
| INT-I030 | Inbox+Trash+Undo | should trash email, show undo toast, and restore on undo tap | Trash undo full flow | InboxNotifier + CountNotifier + CustomToast | Email in inbox | Delete → undo toast → tap Undo | Email moved to trash → undo restores to inbox; counts correct at each step | All | All | Both | P0 |
| INT-I031 | Inbox+BulkArchive+Undo | should bulk-archive emails and restore all on undo tap | Bulk archive undo flow | InboxNotifier + ArchiveNotifier + CountNotifier + CustomToast | 5 emails selected in inbox | Bulk archive → undo toast "[5] emails archived" → tap Undo | All 5 emails restored to inbox, archive count reset | All | All | Both | P1 |
| INT-I032 | Inbox+MoveFolder+Undo | should move email to folder and restore to original folder on undo | Move undo flow | InboxNotifier + ArchiveNotifier + CountNotifier + CustomToast | Email in Sent | Move to Archive → undo toast → tap Undo | Email restored to Sent (original folder), not Inbox | All | All | Both | P1 |
| INT-I033 | Inbox+Archive+UndoTimeout | should make archive permanent when undo toast expires without tap | Undo timeout flow | InboxNotifier + ArchiveNotifier + CountNotifier + CustomToast | Email in inbox | Archive → undo toast → wait for timeout | Undo toast dismisses, email remains permanently in archive, undo no longer possible | All | All | Both | P1 |
| INT-I034 | DefaultClient+Compose | should process mailto deep link and open compose with recipient | Mailto-to-compose flow | AppLinks + SecureStorageService + InboxNotifier + Navigation | App launched via mailto:user@example.com, authenticated | mailto URI stored → inbox loads → _handleMailToOnStart reads mailto → compose opens with toEmail=user@example.com | iOS, Android | All | Both | P0 |
| INT-I035 | DefaultClient+Auth | should queue mailto and open compose after login completes | Mailto before auth flow | AppLinks + SecureStorageService + AuthNotifier + InboxNotifier | App launched via mailto: while not authenticated | mailto stored → login screen → user logs in → inbox loads → compose opens with queued recipient | iOS, Android | All | Both | P0 |
| INT-I036 | DefaultClient+AndroidIntent | should handle Android SENDTO intent and open compose | Android intent flow | Android MethodChannel + SecureStorageService + InboxNotifier + Navigation | Android, another app triggers SENDTO with mailto: | Intent received via platform channel → email stored → compose opens with recipient | Android | All | Both | P0 |
| INT-I037 | DefaultClient+IncomingLink | should handle mailto URI received while app is running | Background mailto flow | AppLinks stream + SecureStorageService + InboxNotifier | App running in foreground, new mailto: URI arrives | URI received via stream → stored → processed on next inbox refresh or navigation | iOS, Android | All | Both | P1 |

---

## 14. End-to-End Test Cases

| ID | Feature/Module | Test Case | Description | User Flow | Preconditions | Expected Outcome | Platform | Screen Size | Orientation | Priority |
|----|----------------|-----------|-------------|-----------|---------------|------------------|----------|-------------|-------------|----------|
| E2E-001 | Auth/FullLogin | should complete full login with OTP | Login → OTP → Inbox | Open app → Enter username → Submit → Enter OTP → Submit | Clean app state, mock API | User sees inbox with emails | All | Small | Portrait | P0 |
| E2E-002 | Auth/CreateAccount | should register new user | Signup → OTP → Profile → Inbox | Open app → Tap signup → Fill form → OTP → Setup profile → Inbox | Clean state, mock API | New user account created, inbox shown | All | Small | Portrait | P0 |
| E2E-003 | Auth/ForgotUsername | should recover username | Login → Forgot → OTP → Success | Tap forgot → Enter phone → OTP → Username displayed | Existing account, mock API | Username recovery message shown | All | Small | Portrait | P1 |
| E2E-004 | Email/ReadAndArchive | should read and archive email | Inbox → Email → Archive | Login → Tap email → Read content → Archive | Authenticated, emails exist | Email opened, marked read, archived, undo shown | All | Small | Portrait | P0 |
| E2E-005 | Email/SearchAndFilter | should search and filter inbox | Inbox → Search → Filter by tag | Login → Type search → Select tag filter → View results | Authenticated, emails+tags exist | Filtered results shown | All | Small | Portrait | P1 |
| E2E-006 | Email/MultiSelect | should bulk delete emails | Inbox → Select → Delete | Login → Long press → Select multiple → Delete | Authenticated, emails exist | Selected emails moved to trash | All | Small | Portrait | P1 |
| E2E-007 | Email/ViewDraft | should resume and view draft | Drafts → Draft → Compose | Login → Go to drafts → Tap draft → Edit in compose | Authenticated, drafts exist | Draft opened in compose with data | All | Small | Portrait | P1 |
| E2E-008 | Contact/FullCRUD | should create, view, edit, delete contact | Add → View → Edit → Delete | Login → Contacts → Add → Fill → Save → View → Edit → Save → Delete → Confirm | Authenticated | Contact lifecycle completed | All | Small | Portrait | P0 |
| E2E-009 | Contact/ComposeFromContact | should compose email from contact | Contacts → View → Compose | Login → Contacts → Tap contact → Tap email → Compose | Authenticated, contact exists | Compose screen with pre-filled recipient | All | Small | Portrait | P1 |
| E2E-010 | Settings/ProfileEdit | should update profile | Settings → Profile → Edit → Save | Login → Menu → Settings → Profile → Edit → Change name → Save | Authenticated | Profile updated successfully | All | Small | Portrait | P1 |
| E2E-011 | Settings/Logout | should logout successfully | Settings → Logout | Login → Menu → Settings → Logout → Confirm | Authenticated | Returned to login, session cleared | All | Small | Portrait | P0 |
| E2E-012 | Settings/DeleteAccount | should delete account | Settings → Account → Delete → Confirm | Login → Settings → Account → Delete → Confirm | Authenticated | Account deleted, returned to login | All | Small | Portrait | P0 |
| E2E-013 | Tags/ManageTags | should create and manage tags | Tags → Create → Edit → Delete | Login → Tags → Add tag → Edit name → Delete tag | Authenticated | Tag lifecycle completed | All | Small | Portrait | P1 |
| E2E-014 | Tags/AssignToEmail | should assign tag to email | Inbox → Select → Tag | Login → Inbox → Select email → Tag button → Select tag → Apply | Authenticated, tags exist | Tag applied to email, visible in list | All | Small | Portrait | P1 |
| E2E-015 | Subscription/SelectPlan | should select and initiate plan | Plans → Select → Checkout | Login → Plans → Select plan → Proceed to checkout | Authenticated, free user | Checkout flow initiated | All | All | Both | P1 |
| E2E-016 | Notification/ViewAndAct | should view and act on notification | Notifications → View → Navigate | Login → Tap notification icon → View list → Tap notification | Authenticated, notifications exist | Notification detail or linked email shown | All | Small | Portrait | P1 |
| E2E-017 | Navigation/TabSwitching | should navigate between all tabs | All tabs | Login → Tap each tab in bottom nav | Authenticated | Each tab renders correct screen | All | Small | Portrait | P0 |
| E2E-018 | Navigation/DeepLink | should handle mailto deep link | App launch with mailto URI | Launch app with mailto:user@optmsg.com | Authenticated | Compose screen with recipient pre-filled | All | All | Both | P1 |
| E2E-019 | Navigation/BackNavigation | should handle back navigation correctly | Multi-screen back | Login → Inbox → Email → Back → Contacts → Back | Authenticated | Correct screen shown at each back press | All | Small | Portrait | P1 |
| E2E-020 | Responsive/DesktopInbox | should use desktop layout with sidebar and reading pane | Desktop full flow | Login → Inbox (desktop) → Tap email → See in reading pane | Authenticated, desktop viewport | Sidebar + list + reading pane layout | Web | Large | Both | P0 |
| E2E-021 | Responsive/TabletLandscape | should use tablet layout | Tablet landscape flow | Login → Inbox (tablet landscape) → Tap email → Reading pane | Authenticated, tablet landscape | List + reading pane layout | iOS, Android | Medium | Landscape | P1 |
| E2E-022 | Responsive/TabletPortrait | should fall back to mobile layout | Tablet portrait flow | Login → Inbox (tablet portrait) → Tap email → Full screen | Authenticated, tablet portrait | Mobile-style full screen layout | iOS, Android | Medium | Portrait | P1 |
| E2E-023 | Responsive/PhoneLandscape | should keep mobile layout in phone landscape | Phone landscape | Rotate phone to landscape in inbox | Authenticated, phone landscape | Still mobile layout (no reading pane) | iOS, Android | Small | Landscape | P1 |
| E2E-024 | Offline/ShowOverlay | should show no internet screen on disconnect | Offline detection | Login → Disconnect network | Authenticated, network available then lost | No internet overlay shown | All | All | Both | P0 |
| E2E-025 | Offline/Reconnect | should recover on reconnect | Recovery | Disconnected → Reconnect | No internet overlay shown | Overlay dismissed, data refreshes | All | All | Both | P1 |
| E2E-026 | Auth/BiometricOnResume | should prompt biometric on app resume | App resume | Login → Background app → Resume | Biometric enabled | Biometric prompt shown | iOS, Android | All | Both | P1 |
| E2E-027 | Email/UndoArchive | should undo archive action | Archive undo | Login → Archive email → Tap Undo | Authenticated, email archived | Email restored to inbox | All | Small | Portrait | P1 |
| E2E-028 | Email/TrashRestore | should restore email from trash | Trash restore | Login → Trash → Select email → Restore | Authenticated, email in trash | Email restored to inbox | All | Small | Portrait | P1 |
| E2E-029 | Email/PermanentDelete | should permanently delete from trash | Permanent delete | Login → Trash → Select → Permanent Delete → Confirm | Authenticated, email in trash | Email permanently deleted | All | Small | Portrait | P1 |
| E2E-030 | HelpCenter/Browse | should browse help center FAQs | Help browsing | Login → Menu → Help → Browse categories → Expand FAQ | Authenticated | FAQ answer visible | All | Small | Portrait | P2 |
| E2E-031 | Notification/SwipeActions | should swipe to delete notification | Swipe delete | Login → Notifications → Swipe left → Delete | Authenticated, notifications exist | Notification removed | iOS, Android | Small | Portrait | P2 |
| E2E-032 | Contact/Import | should import contacts from device | Contact import | Login → Contacts → Import → Select contacts | Authenticated, permission granted | Contacts imported | iOS, Android | Small | Portrait | P2 |
| E2E-033 | Onboarding/FirstLogin | should complete onboarding flow on first mobile login | First-time onboarding | Login (first time) → Onboarding carousel → Welcome video → Inbox | New account, mobile | User walks through onboarding steps, watches video, arrives at inbox | iOS, Android | Small | Portrait | P0 |
| E2E-034 | Subscription/Renewal | should complete account renewal flow | Renewal | Login → Account → Renew → Checkout → Confirm | Subscription expiring, payment method on file | Subscription renewed, new expiry date shown | All | All | Both | P1 |
| E2E-035 | Subscription/UpgradeDowngrade | should upgrade and downgrade account plan | Plan change | Login → Plans → Select higher plan → Upgrade → Confirm; then Downgrade | Authenticated, paid user | Upgrade immediate; downgrade scheduled; confirmations shown | All | All | Both | P1 |
| E2E-036 | Onboarding/WelcomeVideo | should play welcome video during onboarding | Video playback | Login (first time) → Onboarding → Welcome video step → Play → Skip or Finish | First login, mobile | Video plays, can be skipped or watched to completion | iOS, Android | Small | Both | P1 |
| E2E-037 | Email/Attachments | should download and open email attachment | Attachment workflow | Login → Inbox → Open email with attachments → Download → Open | Authenticated, email with attachments | File downloaded, opens in viewer/browser | All | All | Both | P1 |
| E2E-038 | Email/OptInOnSend | should handle opt-in on send with multiple recipients | Multi-recipient opt-in | Login → Compose → Add 3 recipients (2 non-contacts) → Send → Opt-in modals → Skip/Save → Send | Authenticated, contacts partially matched | Opt-in prompts for non-contacts, skip all or save, email sends | All | All | Both | P1 |
| E2E-039 | Reader/SignUp | should complete reader account sign-up | Reader registration | Open reader sign-up → Fill form → Submit → Confirmation | Reader sign-up page accessible | Reader account created, alert preferences configurable | All | Small | Portrait | P1 |
| E2E-040 | Email/InternalSendReceive | should send and receive internal OptMsg message | Internal messaging | Login User A → Compose to User B → Send → Login User B → Verify receipt | Both users authenticated | Message appears in User B's inbox in real time | All | All | Both | P0 |
| E2E-041 | Email/ExternalSendReceive | should send and receive external email | External email | Login → Compose to external address → Send → Verify delivery; receive from external | Authenticated, external email configured | External email sent successfully; inbound external email received in inbox | All | All | Both | P0 |
| E2E-042 | Email/UndoTrash | should undo trash action and verify email restored | Trash undo | Login → Inbox → Delete email → Tap Undo on toast | Authenticated, email in inbox | Email removed from inbox, undo toast shown, tap Undo → email back in inbox, sidebar counts correct | All | Small | Portrait | P1 |
| E2E-043 | Email/UndoBulkArchive | should undo bulk archive and verify all emails restored | Bulk undo | Login → Inbox → Select 3 emails → Archive → Tap Undo on toast | Authenticated, 3+ emails in inbox | 3 emails archived, undo toast "[3] emails archived", tap Undo → all 3 restored to inbox | All | Small | Portrait | P1 |
| E2E-044 | Email/UndoMoveFolder | should undo move-to-folder and verify email restored to original folder | Move undo | Login → Inbox → Move email to Archive → Tap Undo on toast | Authenticated, email in inbox | Email moved to Archive, undo toast, tap Undo → email restored to Inbox | All | Small | Portrait | P1 |
| E2E-045 | Email/UndoTimeout | should verify undo becomes unavailable after toast timeout | Undo expiry | Login → Inbox → Archive email → Wait for toast to auto-dismiss | Authenticated, email in inbox | Email archived, undo toast shown, toast auto-dismisses after timeout, email stays permanently in archive | All | Small | Portrait | P1 |
| E2E-046 | DefaultClient/iOSSetDefault | should set OptMsg as default email client on iOS | iOS default client | iOS Settings → Default Mail App → Select OptMsg | OptMsg installed on iOS 14+ | OptMsg listed in iOS Default Mail App settings, can be selected | iOS | All | Both | P0 |
| E2E-047 | DefaultClient/AndroidSetDefault | should set OptMsg as default email client on Android | Android default client | Android Settings → Default Apps → Email App → Select OptMsg | OptMsg installed on Android | OptMsg listed as email app candidate, selectable as default | Android | All | Both | P0 |
| E2E-048 | DefaultClient/MailtoFromBrowser | should open compose when mailto link tapped in browser | Browser mailto | Set OptMsg as default → Open browser → Tap mailto: link on webpage | OptMsg set as default email client, authenticated | OptMsg launches/foregrounds, compose opens with recipient pre-filled from mailto link | iOS, Android | All | Both | P0 |
| E2E-049 | DefaultClient/MailtoFromOtherApp | should open compose when mailto triggered from another app | Cross-app mailto | Set OptMsg as default → Open Contacts/other app → Tap email action | OptMsg set as default email client, authenticated | OptMsg launches/foregrounds, compose opens with correct recipient | iOS, Android | All | Both | P0 |
| E2E-050 | DefaultClient/MailtoNotAuthenticated | should queue mailto and prompt login when not authenticated | Mailto unauthenticated | Tap mailto link in browser → OptMsg opens (not logged in) → Login → Compose | OptMsg set as default, not authenticated | Login screen shown, after login compose opens with queued recipient | iOS, Android | All | Both | P1 |
| E2E-051 | DefaultClient/MailtoWhileRunning | should handle mailto received while app is in foreground | Foreground mailto | OptMsg open in inbox → Switch to browser → Tap mailto link → Return to OptMsg | OptMsg default, authenticated, app in foreground | OptMsg receives mailto URI, compose opens with recipient | iOS, Android | All | Both | P1 |
| E2E-052 | DefaultClient/MailtoWithSubject | should handle mailto URI with subject parameter | Mailto with params | Tap mailto:user@example.com?subject=Hello link | OptMsg set as default, authenticated | Compose opens with recipient AND subject pre-filled | iOS, Android | All | Both | P1 |
| E2E-053 | DefaultClient/VerifyIntentFilters | should appear as email app option in OS app chooser | OS integration | Trigger mailto: action on device without default set | OptMsg installed | OptMsg appears in OS app picker/chooser dialog as email client option | iOS, Android | All | Both | P0 |
| E2E-054 | WelcomeScreen/QRScan | should open App Store when iOS QR code is scanned with iPhone camera | QR scan iOS | Sign up on web, scan iOS QR code with iPhone camera | iPhone with camera | App Store link opens in Safari to OptMsg app page | iOS | All | Both | P1 |
| E2E-055 | WelcomeScreen/QRScan | should open Play Store when Android QR code is scanned with Android camera | QR scan Android | Sign up on web, scan Android QR code with Android device camera | Android device with camera | Google Play Store opens in browser to OptMsg app page | Android | All | Both | P1 |
| E2E-056 | WelcomeScreen/QRScan | should display URL when scanned with unsupported third-party scanner app | QR scan unsupported | Scan QR code with basic third-party scanner that does not support deep linking | Third-party scanner app | QR code scanned but URL text shown instead of opening app store directly | iOS, Android | All | Both | P2 |
| E2E-057 | Auth/PasskeySetup | should complete first-time login and set up a passkey | First login + passkey | Open app → Login with username + OTP → Prompted to set up passkey → Register passkey via device biometric/PIN → Confirm | Clean app state, device supports WebAuthn/passkey | User logs in successfully, passkey registered, passkey stored for future logins, confirmation shown | All | All | Both | P0 |
| E2E-058 | Auth/PasskeyLogin | should login using a previously registered passkey | Passkey login | Open app → Tap "Login with Passkey" → Device biometric/PIN prompt → Authenticate | Passkey previously registered, device supports WebAuthn | User authenticated via passkey without OTP, navigates directly to inbox | All | All | Both | P0 |
| E2E-059 | Email/CreateSaveDraft | should create a new email and save it as a draft | Draft creation | Login → Compose → Add recipient, subject, body → Tap Save Draft (or navigate away) → Go to Drafts folder → Verify draft exists | Authenticated | Compose opens, draft saved with all entered fields (recipient, subject, body), appears in Drafts folder with correct content | All | All | Both | P0 |
| E2E-060 | Account/CancelAccount | should cancel an account and verify cancellation confirmation | Account cancellation | Login → Settings → Account → Cancel Account → Confirm cancellation reason → Submit | Authenticated, active subscription | Account marked as canceled, cancellation confirmation shown, user informed subscription remains active until end of billing period | All | All | Both | P0 |
| E2E-061 | Account/CanceledStillActive | should allow login for canceled account while subscription is still active | Canceled + active sub | Cancel account → Logout → Login again before subscription end date | Account canceled, subscription end date in future | User can still login, access inbox, send/receive emails normally until subscription period ends | All | All | Both | P0 |
| E2E-062 | Subscription/GracePeriod | should allow login during 7-day grace period after subscription lapse to resubscribe | Grace period access | Subscription lapses → Wait 1–7 days → Attempt login → Prompted to resubscribe → Complete renewal | Subscription expired within last 7 days | User can login, shown renewal/resubscribe prompt, can complete payment to renew subscription and regain full access | All | All | Both | P0 |
| E2E-063 | Subscription/LapsedBlocked | should block login for lapsed user (day 8–30) and bounce inbound emails | Lapsed user blocked | Subscription expired 8+ days ago → Attempt login → Blocked with renewal prompt; Send email to user's @optmsg.com address from external sender | Subscription expired 8–30 days ago | Login blocked with message prompting subscription renewal; inbound emails to @optmsg.com address bounce back to sender with delivery failure notice | All | All | Both | P0 |
| E2E-072 | Subscription/CheckoutDecline | should handle generic card decline during checkout | Generic card decline | Login → Plans → Select plan → Checkout → Enter test card 4000000000000002 → Submit | Authenticated, free user, Stripe test mode | Payment fails with "Card declined" error, user remains on checkout, can retry with different card | All | All | Both | P0 |
| E2E-073 | Subscription/CheckoutInsufficientFunds | should handle insufficient funds decline during checkout | Insufficient funds | Login → Plans → Select plan → Checkout → Enter test card 4000000000009995 → Submit | Authenticated, free user, Stripe test mode | Payment fails with "Insufficient funds" error, appropriate message shown, can retry | All | All | Both | P0 |
| E2E-074 | Subscription/CheckoutLostCard | should handle lost card decline during checkout | Lost card decline | Login → Plans → Select plan → Checkout → Enter test card 4000000000009987 → Submit | Authenticated, free user, Stripe test mode | Payment fails with "Lost card" error, appropriate security message shown, can retry with different card | All | All | Both | P0 |
| E2E-075 | Subscription/CheckoutStolenCard | should handle stolen card decline during checkout | Stolen card decline | Login → Plans → Select plan → Checkout → Enter test card 4000000000009979 → Submit | Authenticated, free user, Stripe test mode | Payment fails with "Stolen card" error, appropriate security message shown, cannot retry with same card | All | All | Both | P0 |
| E2E-076 | Subscription/CheckoutExpiredCard | should handle expired card decline during checkout | Expired card | Login → Plans → Select plan → Checkout → Enter test card 4000000000000069 → Submit | Authenticated, free user, Stripe test mode | Payment fails with "Expired card" error, user prompted to enter valid expiration date | All | All | Both | P0 |
| E2E-077 | Subscription/CheckoutIncorrectCVC | should handle incorrect CVC decline during checkout | Incorrect CVC | Login → Plans → Select plan → Checkout → Enter test card 4000000000000127 → Submit | Authenticated, free user, Stripe test mode | Payment fails with "Incorrect CVC" error, user prompted to verify card security code | All | All | Both | P0 |
| E2E-078 | Subscription/CheckoutProcessingError | should handle processing error during checkout | Processing error | Login → Plans → Select plan → Checkout → Enter test card 4000000000000119 → Submit | Authenticated, free user, Stripe test mode | Payment fails with "Processing error" message, user advised to try again or contact support | All | All | Both | P0 |
| E2E-079 | Subscription/CheckoutFraudBlocked | should handle Radar fraud prevention block during checkout | Fraudulent card blocked | Login → Plans → Select plan → Checkout → Enter test card 4100000000000019 → Submit | Authenticated, free user, Stripe test mode with Radar enabled | Payment blocked by fraud prevention, appropriate security message shown, transaction not processed | All | All | Both | P0 |
| E2E-080 | Email/SaveDraftNoAttachments | should save draft with no attachments | Draft save (no attachments) | Login → Compose → Add recipient, subject, body (no attachments) → Save Draft → Navigate to Drafts → Verify draft | Authenticated | Draft saved with recipient, subject, body, no attachments, appears in Drafts folder | All | All | Both | P0 |
| E2E-081 | Email/SaveDraftOneAttachment | should save draft with one attachment | Draft save (1 attachment) | Login → Compose → Add recipient, subject, body → Attach 1 file → Save Draft → Navigate to Drafts → Verify draft → Open draft → Verify attachment present | Authenticated | Draft saved with 1 attachment, attachment visible in draft, file name and size shown | All | All | Both | P0 |
| E2E-082 | Email/SaveDraftMultipleAttachments | should save draft with multiple attachments | Draft save (multiple) | Login → Compose → Add recipient, subject, body → Attach 3 files → Save Draft → Navigate to Drafts → Verify draft → Open draft → Verify all attachments | Authenticated | Draft saved with 3 attachments, all attachments visible with correct file names and sizes | All | All | Both | P0 |
| E2E-083 | Email/SendExternalNoAttachments | should send external email with no attachments | Send external (no attachments) | Login → Compose → Enter external email address → Add subject, body (no attachments) → Send → Verify sent folder | Authenticated, external recipient | Email sent successfully to external address, appears in Sent folder, no attachments | All | All | Both | P0 |
| E2E-084 | Email/SendExternalOneAttachment | should send external email with one attachment | Send external (1 attachment) | Login → Compose → Enter external email address → Add subject, body → Attach 1 file → Send → Verify sent folder → Verify attachment uploaded | Authenticated, external recipient | Email sent with 1 attachment, attachment uploaded to S3, appears in Sent folder with attachment indicator | All | All | Both | P0 |
| E2E-085 | Email/SendExternalMultipleAttachments | should send external email with multiple attachments | Send external (multiple) | Login → Compose → Enter external email address → Add subject, body → Attach 3 files (total < 25MB) → Send → Verify sent folder → Verify all attachments uploaded | Authenticated, external recipient | Email sent with 3 attachments, all attachments uploaded to S3, appears in Sent folder, attachment count shown | All | All | Both | P0 |
| E2E-086 | Email/SendInternalNoAttachments | should send internal OptMsg with no attachments | Send internal (no attachments) | Login User A → Compose → Enter User B @optmsg.com address → Add subject, body (no attachments) → Send → Login User B → Verify inbox | Both users authenticated | Internal message sent successfully, appears in User B inbox via socket, no attachments | All | All | Both | P0 |
| E2E-087 | Email/SendInternalOneAttachment | should send internal OptMsg with one attachment | Send internal (1 attachment) | Login User A → Compose → Enter User B @optmsg.com → Add subject, body → Attach 1 file → Send → Login User B → Verify inbox → Verify attachment | Both users authenticated | Internal message sent with 1 attachment, appears in User B inbox, attachment downloadable | All | All | Both | P0 |
| E2E-088 | Email/SendInternalMultipleAttachments | should send internal OptMsg with multiple attachments | Send internal (multiple) | Login User A → Compose → Enter User B @optmsg.com → Add subject, body → Attach 3 files → Send → Login User B → Verify inbox → Verify all attachments | Both users authenticated | Internal message sent with 3 attachments, all attachments visible and downloadable by recipient | All | All | Both | P0 |

---

## 15. Onboarding Module

### Current Coverage Status
- **Existing tests:** None
- **Files involved:**
  - Onboarding screen/widget files
  - Welcome video player
  - Notification scheduling logic (day 1–10 push messages)
- **Gaps:** Complete — no test coverage exists

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| ONB-U001 | Onboarding/Flow | should show onboarding flow on first mobile login | Verify first-login detection | isFirstLogin=true, platform=mobile | Onboarding carousel/screens displayed before inbox | P0 | No |
| ONB-U002 | Onboarding/Flow | should skip onboarding on subsequent logins | Verify repeat-login bypass | isFirstLogin=false (onboarding previously completed) | Onboarding skipped, navigates directly to inbox | P0 | No |
| ONB-U003 | Onboarding/Flow | should track onboarding completion state in storage | Verify persistence | User completes onboarding | onboardingCompleted=true stored in SecureStorage | P1 | No |
| ONB-U004 | Onboarding/PushNotifications | should schedule day 1–10 onboarding push notifications | Verify notification scheduling | New account created, notifications enabled | 10 push notifications scheduled for days 1–10 | P1 | No |
| ONB-U005 | Onboarding/PushNotifications | should deliver correct notification content per day | Verify per-day content | Day 3 notification fires | Notification body matches day-3 onboarding message | P1 | No |
| ONB-U006 | Onboarding/PushNotifications | should stop onboarding notifications after day 10 | Verify schedule end | Day 10 notification delivered | No further onboarding notifications scheduled | P1 | No |
| ONB-U007 | Onboarding/PushNotifications | should cancel remaining onboarding notifications if user completes early | Verify early cancellation | User manually completes onboarding on day 2 | Remaining day 3–10 notifications cancelled | P1 | Yes |
| ONB-U008 | Onboarding/WelcomeVideo | should load and play welcome video | Verify video playback | Welcome video URL/asset available | Video player initializes and plays | P1 | No |
| ONB-U009 | Onboarding/WelcomeVideo | should track welcome video completion | Verify completion tracking | User watches video to end | videoCompleted=true recorded | P2 | No |
| ONB-U010 | Onboarding/WelcomeVideo | should allow skipping welcome video | Verify skip | User taps Skip during video | Video dismissed, onboarding proceeds to next step | P1 | No |
| ONB-U011 | Onboarding/WelcomeScreen | should display QR code linking to App Store on iOS web | Verify iOS QR | Welcome screen on web, detected iOS user agent | QR code generated with App Store URL for OptMsg app | P1 | No |
| ONB-U012 | Onboarding/WelcomeScreen | should display QR code linking to Play Store on Android web | Verify Android QR | Welcome screen on web, detected Android user agent | QR code generated with Google Play Store URL for OptMsg app | P1 | No |
| ONB-U013 | Onboarding/WelcomeScreen | should display both store QR codes on desktop web | Verify desktop QR | Welcome screen on web, desktop user agent | Both App Store and Play Store QR codes displayed | P1 | No |
| ONB-U014 | Onboarding/WelcomeScreen | should generate valid scannable QR code | Verify QR validity | QR code rendered | QR code encodes correct store URL, scannable by standard QR reader | P1 | No |
| ONB-U015 | Onboarding/WelcomeScreen | should handle offline state on welcome screen gracefully | Verify offline welcome | No internet on welcome screen | QR codes still display (locally generated), store link warning shown | P2 | Yes |
| ONB-U016 | Onboarding/MobileScreens | should display "Sync Mobile Contacts" screen with Sync Now action | Verify sync contacts screen | Onboarding flow active, navigated to contacts step | Screen shows "Sync Mobile Contacts" title and Sync Now button; tapping triggers contacts permission request | P1 | No |
| ONB-U017 | Onboarding/MobileScreens | should display "Forward Other Email Accounts to OptMsg" screen | Verify forward accounts screen | Onboarding flow active, navigated to forwarding step | Screen shows forwarding instructions with setup guidance for external accounts | P1 | No |
| ONB-U018 | Onboarding/MobileScreens | should display "Check Your Notification" screen with Complete button | Verify notification check screen | Onboarding flow active, navigated to notification step | Screen shows "Check Your Notification" title and Complete button; tapping completes onboarding | P1 | No |
| ONB-U019 | Onboarding/WelcomeScreen | should show error for malformed or invalid QR code URL | Verify invalid QR handling | QR code URL is malformed or empty | Error page or "Invalid URL" message shown; does not navigate to app store | P1 | Yes |
| ONB-U020 | Onboarding/WelcomeScreen | should encode correct regional App Store URL based on device locale | Verify regional URL | Device region set to non-US locale (e.g., Japan) | QR code encodes region-appropriate App Store/Play Store URL | P2 | No |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| ONB-W001 | Onboarding/Screens | should render onboarding carousel with step indicators | Verify rendering | OnboardingScreen | First step | None | Carousel visible with page dots, content, Next button | iOS, Android | Small | Portrait | P0 | No |
| ONB-W002 | Onboarding/Screens | should navigate between onboarding steps | Verify step navigation | OnboardingScreen | Step 1 of N | Swipe or tap Next | Step 2 content shown, indicator updates | iOS, Android | Small | Portrait | P0 | No |
| ONB-W003 | Onboarding/Screens | should show skip button to bypass onboarding | Verify skip UI | OnboardingScreen | Any step | Tap Skip | Onboarding dismissed, navigates to inbox | iOS, Android | Small | Portrait | P1 | No |
| ONB-W004 | Onboarding/WelcomeVideo | should render welcome video player with controls | Verify video UI | WelcomeVideoPlayer | Video loaded | None | Video player, play/pause button, skip button visible | iOS, Android | Small | Both | P1 | No |
| ONB-W005 | Onboarding/WelcomeVideo | should pause and resume video on control tap | Verify controls | WelcomeVideoPlayer | Video playing | Tap pause → tap play | Video pauses, resumes | iOS, Android | Small | Both | P1 | No |
| ONB-W006 | Onboarding/WelcomeScreen | should render QR code(s) with store download text | Verify QR rendering | WelcomeScreen | Web platform | None | QR code image(s) visible with "Download on App Store" / "Get it on Google Play" labels | Web | All | Both | P1 | No |
| ONB-W007 | Onboarding/WelcomeScreen | should render App Store and Play Store direct links below QR codes | Verify store links | WelcomeScreen | Web platform | None | Tappable App Store and Play Store buttons/links visible | Web | All | Both | P1 | No |
| ONB-W008 | Onboarding/WelcomeScreen | should not render QR codes on native mobile (iOS/Android) | Verify QR hidden on mobile | WelcomeScreen | Native mobile platform | None | No QR codes shown; mobile users already have the app | iOS, Android | Small | Both | P1 | No |
| ONB-W009 | Onboarding/MobileScreens | should render "Let's Complete Your Setup" as first onboarding screen | Verify setup screen | OnboardingScreen | First step, mobile platform | None | Screen displays "Let's Complete Your Setup" heading with Get Started button | iOS, Android | Small | Portrait | P0 | No |
| ONB-W010 | Onboarding/MobileScreens | should render "Sync Mobile Contacts" screen with active Sync Now button | Verify sync contacts UI | OnboardingScreen | Contacts sync step | None | "Sync Mobile Contacts" title visible, Sync Now button enabled and tappable | iOS, Android | Small | Portrait | P1 | No |
| ONB-W011 | Onboarding/MobileScreens | should render "Forward Other Email Accounts" screen with setup instructions | Verify forwarding screen UI | OnboardingScreen | Email forwarding step | None | "Forward Other Email Accounts to OptMsg" title visible with forwarding instructions | iOS, Android | Small | Portrait | P1 | No |
| ONB-W012 | Onboarding/MobileScreens | should render "Check Your Notification" screen with Complete button | Verify notification screen UI | OnboardingScreen | Final onboarding step | None | "Check Your Notification" title visible, Complete button enabled | iOS, Android | Small | Portrait | P1 | No |
| ONB-W013 | Onboarding/MobileScreens | should verify all onboarding screen buttons are responsive and not disabled | Verify button responsiveness | OnboardingScreen | Each onboarding step | Tap each action button | All buttons respond to tap, no disabled or unresponsive buttons | iOS, Android | Small | Portrait | P1 | No |
| ONB-W014 | Onboarding/WelcomeScreen | should navigate to App Store when iOS QR code is tapped | Verify iOS QR tap | WelcomeScreen | Web platform, iOS QR visible | Tap iOS QR code | URL launcher opens correct App Store page for OptMsg | Web | All | Both | P1 | No |
| ONB-W015 | Onboarding/WelcomeScreen | should navigate to Play Store when Android QR code is tapped | Verify Android QR tap | WelcomeScreen | Web platform, Android QR visible | Tap Android QR code | URL launcher opens correct Google Play Store page for OptMsg | Web | All | Both | P1 | No |

### Integration Test Cases

| ID | Feature/Module | Test Case | Description | Components Involved | Preconditions | Expected Outcome | Platform | Screen Size | Orientation | Priority |
|----|----------------|-----------|-------------|---------------------|---------------|------------------|----------|-------------|-------------|----------|
| ONB-I001 | Onboarding/FullFlow | should complete full onboarding flow on first mobile login | End-to-end onboarding | AuthNotifier + OnboardingScreen + WelcomeVideo + Navigation + SecureStorageService | First login, mobile | Login → Onboarding steps → Welcome video → Inbox; onboardingCompleted stored | iOS, Android | Small | Portrait | P0 |
| ONB-I002 | Onboarding/Notifications | should schedule and deliver onboarding push notifications | Push notification lifecycle | NotificationService + OnboardingScheduler + FCM | New account, notifications enabled | Notifications scheduled, day-1 notification delivered, cancels on completion | iOS, Android | All | Both | P1 |

### Flutter Test Notes — Onboarding Module
- **Required mocks:** MockSecureStorageService (for onboarding state), MockVideoPlayerController, MockNotificationService/MockFCM
- **ProviderScope overrides:** `authNotifier`, `onboardingProvider` (if exists), `notificationServiceProvider`
- **Platform mocks:** Video player platform channel, FCM platform channel
- **pumpAndSettle:** Required after step transitions and video load

---

## 16. Responsive Framework & App Utilities

### Current Coverage Status
- **Existing tests:** None
- **Files involved:**
  - `lib/common/responsive/base_responsive_screen.dart`
  - `lib/common/responsive/breakpoints.dart`
  - `lib/common/responsive/responsive_layout_builder.dart`
  - `lib/common/app_manger/app_cache.dart`
  - `lib/common/app_manger/app_environment.dart`
  - `lib/services/adaptive_service.dart`
  - `lib/services/overlay_manager.dart`
  - `lib/services/reg_exp_service.dart`
  - `lib/services/floating_action_button_location.dart`
  - `lib/services/tags_provider.dart`
- **Gaps:** Complete — no test coverage exists

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| RESP-U001 | Responsive/Breakpoints | should detect mobile for width < 600 | Verify mobile breakpoint | screenWidth=375 | DeviceType.mobile | P0 | No |
| RESP-U002 | Responsive/Breakpoints | should detect tablet for width 600-1023 | Verify tablet breakpoint | screenWidth=768 | DeviceType.tablet | P0 | No |
| RESP-U003 | Responsive/Breakpoints | should detect desktop for width >= 1024 | Verify desktop breakpoint | screenWidth=1440 | DeviceType.desktop | P0 | No |
| RESP-U004 | Responsive/Breakpoints | should handle boundary value 600 as tablet | Verify boundary | screenWidth=600 | DeviceType.tablet | P0 | Yes |
| RESP-U005 | Responsive/Breakpoints | should handle boundary value 1024 as desktop | Verify boundary | screenWidth=1024 | DeviceType.desktop | P0 | Yes |
| RESP-U006 | Responsive/BaseScreen | should return correct isMobile/isTablet/isDesktop getters | Verify computed props | Various widths | Boolean getters match device type | P0 | No |
| RESP-U007 | Responsive/BaseScreen | should show FAB on native mobile only | Verify shouldShowFab | screenWidth < 600, kIsWeb=false | shouldShowFab=true | P1 | No |
| RESP-U008 | Responsive/BaseScreen | should show FAB on web mobile | Verify web mobile FAB | screenWidth < 600, kIsWeb=true | shouldShowFab=true | P1 | No |
| RESP-U009 | Responsive/BaseScreen | should hide FAB on desktop | Verify no desktop FAB | screenWidth=1440 | shouldShowFab=false | P1 | No |
| RESP-U010 | Responsive/BaseScreen | should return canShowReadingPane for width >= 1024 | Verify reading pane logic | screenWidth=1024 | canShowReadingPane=true | P0 | No |
| RESP-U011 | Responsive/BaseScreen | should return canShowReadingPane=false for width < 1024 | Verify reading pane logic | screenWidth=768 | canShowReadingPane=false | P0 | No |
| RESP-U012 | Responsive/BaseScreenController | should safely notifyListeners when not disposed | Verify safe notify | Controller active | No error thrown | P1 | No |
| RESP-U013 | Responsive/BaseScreenController | should skip notifyListeners when disposed | Verify disposed check | Controller disposed | No error, no notification | P1 | Yes |
| RESP-U014 | AppCache/Singleton | should store and retrieve tabName | Verify getter/setter | setTabName('inbox') | tabName='inbox' | P1 | No |
| RESP-U015 | AppCache/Singleton | should store and retrieve navigation names | Verify navigation tracking | setLastNavigationName('/inbox'), setCurrentNavigationName('/contacts') | lastNavigation='/inbox', currentNavigation='/contacts' | P1 | No |
| RESP-U016 | AppCache/Singleton | should store and retrieve subscription cache data | Verify subscription caching | setSubscriptionCacheData({'plan':'pro'}) | subscriptionCacheData={'plan':'pro'} | P1 | No |
| RESP-U017 | AppCache/Singleton | should store and retrieve isAllMailSaved flag | Verify mail save flag | setIsAllMailSaved(true) | isAllMailSaved=true | P1 | No |
| RESP-U018 | AppEnvironment/Singleton | should detect dev environment from app name | Verify dev detection | appName='OptMsg Dev' | AppEnvironmentType.dev | P0 | No |
| RESP-U019 | AppEnvironment/Singleton | should detect stage environment from app name | Verify stage detection | appName='OptMsg-Stg' | AppEnvironmentType.stage | P0 | No |
| RESP-U020 | AppEnvironment/Singleton | should detect production environment from app name | Verify prod detection | appName='OptMsg' | AppEnvironmentType.prod | P0 | No |
| RESP-U021 | AppEnvironment/Singleton | should default to stage for unknown app name | Verify fallback | appName='Unknown' | AppEnvironmentType.stage | P0 | Yes |
| RESP-U022 | AppEnvironment/Singleton | should cache environment after first detection | Verify caching | Called twice | Second call returns cached, no re-detection | P1 | No |
| RESP-U023 | AppEnvironment/getTypeForAppFlavor | should map 'dev' flavor to dev type | Verify flavor mapping | env='dev' | AppEnvironmentType.dev | P1 | No |
| RESP-U024 | AppEnvironment/getTypeForAppFlavor | should map 'prod' flavor to prod type | Verify flavor mapping | env='prod' | AppEnvironmentType.prod | P1 | No |
| RESP-U025 | AppEnvironment/getTypeForAppFlavor | should default to stage for unknown flavor | Verify fallback | env='unknown' | AppEnvironmentType.stage | P1 | Yes |
| RESP-U026 | AdaptiveService | should delegate isMobileLayout to breakpoints | Verify delegation | screenWidth=375 | isMobileLayout=true | P1 | No |
| RESP-U027 | AdaptiveService | should delegate isDesktopLayout to breakpoints | Verify delegation | screenWidth=1440 | isDesktopLayout=true | P1 | No |
| RESP-U028 | AdaptiveService | should delegate canShowReadingPane | Verify delegation | screenWidth=1024 | canShowReadingPane=true | P1 | No |
| RESP-U029 | OverlayManager/ToastManager | should initialize with BuildContext | Verify initialization | Valid BuildContext | overlayState accessible | P1 | No |
| RESP-U030 | OverlayManager/ToastManager | should throw when accessing overlayState before init | Verify guard | Not initialized | Exception thrown | P1 | Yes |
| RESP-U031 | OverlayManager/ToastManager | should return null from overlayStateOrNull before init | Verify safe getter | Not initialized | Returns null, no exception | P1 | No |
| RESP-U032 | RegExpService | should match valid alphanumeric characters | Verify regex | 'hello_world.test-123' | Match=true | P1 | No |
| RESP-U033 | RegExpService | should reject special characters | Verify regex | 'hello@world!' | Match=false | P1 | No |
| RESP-U034 | RegExpService | should match empty string | Verify regex edge | '' | Match=true (pattern uses *) | P1 | Yes |
| RESP-U035 | RegExpService | should reject spaces | Verify regex | 'hello world' | Match=false | P1 | Yes |
| RESP-U036 | FloatingActionButtonLocation | should calculate offset with custom Y | Verify positioning | offsetY=20 | Position offset includes custom Y | P2 | No |
| RESP-U037 | FloatingActionButtonLocation | should account for scaffold insets | Verify inset handling | Various scaffold geometries | Correct offset calculation | P2 | No |
| RESP-U038 | TagsProvider | should set tags list and notify listeners | Verify setter | TagsListModel instance | tagsList updated, listeners notified | P1 | No |
| RESP-U039 | TagsProvider | should reset tags to null | Verify reset | tagsList set then reset() called | tagsList=null | P1 | No |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| RESP-W001 | Responsive/LayoutBuilder | should render mobile builder for small screen | Verify mobile fallback | ResponsiveLayoutBuilder | screenWidth=375, mobile builder provided | None | Mobile builder rendered | All | Small | Portrait | P0 | No |
| RESP-W002 | Responsive/LayoutBuilder | should render tablet builder for medium screen | Verify tablet | ResponsiveLayoutBuilder | screenWidth=768, tablet builder provided | None | Tablet builder rendered | All | Medium | Portrait | P0 | No |
| RESP-W003 | Responsive/LayoutBuilder | should render desktop builder for large screen | Verify desktop | ResponsiveLayoutBuilder | screenWidth=1440, desktop builder provided | None | Desktop builder rendered | All | Large | Both | P0 | No |
| RESP-W004 | Responsive/LayoutBuilder | should fallback to tablet when desktop builder missing | Verify fallback chain | ResponsiveLayoutBuilder | screenWidth=1440, no desktop builder | None | Tablet builder rendered | All | Large | Both | P1 | Yes |
| RESP-W005 | Responsive/LayoutBuilder | should fallback to mobile when tablet and desktop missing | Verify full fallback | ResponsiveLayoutBuilder | screenWidth=1440, only mobile builder | None | Mobile builder rendered | All | Large | Both | P1 | Yes |
| RESP-W006 | Responsive/ResponsiveValue | should return correct value for each device type | Verify generic value | ResponsiveValue<int> | mobile=1, tablet=2, desktop=3 | None | Correct value per screen width | All | All | Both | P1 | No |

### Flutter Test Notes — Responsive Framework
- **Required mocks:** None for pure unit tests; use `tester.binding.window.physicalSizeTestValue` for widget tests
- **MediaQuery override:** Wrap widgets in `MediaQuery` with controlled size for breakpoint tests
- **Static caching:** `AppBreakpoints._isPhysicalTabletCached` is static; may need reset between tests
- **Platform override:** `debugDefaultTargetPlatformOverride` for native tablet tests

---

## 17. Router & Navigation

### Current Coverage Status
- **Existing tests:** None (dashboard/nav module has some tests but not for navigation_helper, route_observer, or route_wrappers)
- **Files involved:**
  - `lib/router/navigation_helper.dart`
  - `lib/router/responsive_route_wrappers.dart`
  - `lib/router/route_observer_service.dart`
  - `lib/router/app_router.dart`
  - `lib/router/app_routes.dart`
- **Gaps:** Complete — no test coverage exists for navigation helper, route wrappers, or route observer

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| NAV-U013 | Router/AppNavigator | should call go() on underlying router | Verify go navigation | path='/inbox' | GoRouter.go('/inbox') called | P0 | No |
| NAV-U014 | Router/AppNavigator | should call push() on underlying router | Verify push navigation | path='/contacts/add' | GoRouter.push('/contacts/add') called | P0 | No |
| NAV-U015 | Router/AppNavigator | should call replace() on underlying router | Verify replace | path='/inbox' | GoRouter.replace('/inbox') called | P1 | No |
| NAV-U016 | Router/AppNavigator | should pop() current route | Verify pop | Navigator has stack | GoRouter.pop() called | P0 | No |
| NAV-U017 | Router/AppNavigator | should return canPop() correctly | Verify stack check | Route stack with 2 routes | canPop()=true | P1 | No |
| NAV-U018 | Router/AppNavigator | should navigate to login via goToLogin() | Verify convenience | None | go('/login') called | P0 | No |
| NAV-U019 | Router/AppNavigator | should navigate to inbox via goToInbox() | Verify convenience | None | go('/inbox') called | P0 | No |
| NAV-U020 | Router/AppNavigator | should pass extras to goToCompose() | Verify extras | composeData map | push('/compose', extra: composeData) called | P1 | No |
| NAV-U021 | Router/AppNavigator | should set authenticated and navigate | Verify auth transition | setAuthenticated(true, userData) | Auth state updated, navigation to inbox | P0 | No |
| NAV-U022 | Router/AppNavigator | should logout and navigate to login | Verify logout | Authenticated user | Auth state cleared, go('/login') called | P0 | No |
| NAV-U023 | Router/RouteObserver | should save route to SharedPreferences on push | Verify persistence | Route pushed '/inbox' | SharedPreferences stores '/inbox' | P1 | No |
| NAV-U024 | Router/RouteObserver | should track current and previous routes | Verify tracking | Push '/inbox' then '/contacts' | currentRootRoute='/contacts', previousRootRoute='/inbox' | P1 | No |
| NAV-U025 | Router/RouteObserver | should handle null route name | Verify null safety | Route with name=null | No crash, route skipped | P1 | Yes |
| NAV-U026 | Router/RouteObserver | should retrieve initial route from SharedPreferences | Verify getInitialRoute | SharedPrefs has '/inbox' stored | Returns '/inbox' | P1 | No |
| NAV-U027 | Router/RouteObserver | should sync route with AppCache | Verify cache sync | Route pushed '/contacts' | AppCache.currentNavigation updated | P1 | No |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| NAV-W036 | Router/RouteWrappers | should render mobile inbox layout on phone | Verify responsive | ResponsiveInboxWrapper | screenWidth=375, native | None | Mobile inbox layout | iOS, Android | Small | Portrait | P0 | No |
| NAV-W037 | Router/RouteWrappers | should render desktop inbox layout on web | Verify responsive | ResponsiveInboxWrapper | screenWidth=1440, kIsWeb=true | None | Desktop inbox layout | Web | Large | Both | P0 | No |
| NAV-W038 | Router/RouteWrappers | should render desktop layout on tablet landscape | Verify tablet landscape | ResponsiveInboxWrapper | screenWidth=1024, tablet, landscape | None | Desktop layout (reading pane) | iOS, Android | Medium | Landscape | P1 | No |
| NAV-W039 | Router/RouteWrappers | should map email type to correct page path | Verify email type mapping | ResponsiveViewInboxWrapper | emailType='sent' | None | Correct sent page path used | All | All | Both | P1 | No |
| NAV-W040 | Router/RouteWrappers | should check auth in Plans wrapper | Verify auth guard | ResponsivePlansWrapper | Not authenticated | None | Redirect to login or error | All | All | Both | P1 | Yes |
| NAV-W041 | Router/RouteWrappers | should render contacts wrapper for desktop | Verify responsive | ResponsiveContactsWrapper | screenWidth=1440, kIsWeb=true | None | Desktop contacts layout | Web | Large | Both | P1 | No |
| NAV-W042 | Router/RouteWrappers | should render settings wrapper for mobile | Verify responsive | ResponsiveSettingsWrapper | screenWidth=375 | None | Mobile settings layout | All | Small | Portrait | P1 | No |
| NAV-W043 | Router/RouteWrappers | should render subscription wrapper for web | Verify responsive | ResponsiveSubscriptionWrapper | kIsWeb=true | None | Desktop subscription layout | Web | Large | Both | P1 | No |

### Flutter Test Notes — Router & Navigation
- **Required mocks:** MockGoRouter, MockSharedPreferences, MockAppCache
- **GoRouter testing:** Use `GoRouterProvider` to inject mock router for navigation assertions
- **Route observer:** Use `NavigatorObserver` subclass to capture route transitions
- **pumpAndSettle:** Required after navigation calls

---

## 18. Web Compose & Email Viewers

### Current Coverage Status
- **Existing tests:** None
- **Files involved:**
  - `lib/screens/compose/web_compose.dart`
  - `lib/screens/inbox/view_inbox.dart`
  - `lib/screens/inbox/custom_file_downloader_manager.dart`
  - `lib/screens/inbox/widget/open_full_screen_image.dart`
  - `lib/screens/inbox/widget/open_full_screen_pdf.dart`
  - `lib/screens/inbox/widget/open_full_screen_webView.dart`
- **Gaps:** Complete — no test coverage exists

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| COMPOSE-U001 | Compose/FileValidation | should reject file exceeding 25MB | Verify file size limit | File size=30MB | Error shown, file not attached | P0 | No |
| COMPOSE-U002 | Compose/FileValidation | should accept file under 25MB | Verify file acceptance | File size=5MB | File added to attachments list | P0 | No |
| COMPOSE-U003 | Compose/FileValidation | should reject when total attachments exceed 25MB | Verify cumulative limit | Existing 20MB + new 10MB | Error shown, second file rejected | P0 | Yes |
| COMPOSE-U004 | Compose/ContentCheck | should detect empty compose (no TO, no subject, no body) | Verify content check | All fields empty | _checkComposeHasContent returns false | P0 | No |
| COMPOSE-U005 | Compose/ContentCheck | should detect compose with TO only | Verify partial content | TO field populated only | Returns true (has content) | P0 | No |
| COMPOSE-U006 | Compose/ContentCheck | should detect compose with attachments only | Verify attachment content | Attachments present, fields empty | Returns true | P1 | No |
| COMPOSE-U007 | Compose/SignedUrl | should get signed URL from API | Verify S3 flow | Valid file name, authenticated | Signed URL returned from API | P0 | No |
| COMPOSE-U008 | Compose/SignedUrl | should upload file to signed URL | Verify S3 upload | Valid signed URL, file data | File uploaded successfully | P0 | No |
| COMPOSE-U009 | Compose/SocketThrottle | should throttle socket events within 1000ms | Verify throttle | Two sends < 1000ms apart | Second send blocked | P1 | Yes |
| COMPOSE-U010 | Compose/SocketThrottle | should allow socket event after 1000ms | Verify throttle release | Two sends > 1000ms apart | Both sends succeed | P1 | No |
| COMPOSE-U011 | Compose/DraftHandling | should save as new draft when type is 'addDraft' | Verify draft save | composeType='addDraft' | Socket emit 'addUpdateDraft' with correct action | P1 | No |
| COMPOSE-U012 | Compose/DraftHandling | should update existing draft when type is 'updateDraft' | Verify draft update | composeType='updateDraft', existing draftId | Socket emit 'addUpdateDraft' with update action | P1 | No |
| COMPOSE-U013 | Compose/EmailValidation | should validate all recipients before sending | Verify recipient check | 3 recipients, 1 not in contacts | Modal shown for unknown recipient | P0 | No |
| COMPOSE-U014 | Compose/EmailValidation | should handle 'Skip All' for unknown recipients | Verify skip all | Multiple unknown recipients | All skipped, email sent without adding contacts | P1 | No |
| COMPOSE-U015 | ViewInbox/Detail | should fetch email detail by ID and type | Verify API fetch | emailId=123, emailType='inbox' | API called, email data populated | P0 | No |
| COMPOSE-U016 | ViewInbox/Detail | should handle different email types | Verify type handling | emailType='sent' vs 'archive' vs 'trash' | Correct API endpoint used per type | P0 | No |
| COMPOSE-U017 | ViewInbox/Detail | should re-fetch on emailId change | Verify didUpdateWidget | emailId changes from 123 to 456 | New API call triggered | P1 | No |
| COMPOSE-U018 | ViewInbox/Detail | should track email state transitions | Verify state tracking | Archive action | movedToArchive flag set, callback fired | P1 | No |
| COMPOSE-U019 | FileDownloader | should download file from URL | Verify download | Valid URL | File downloaded to temp, save dialog shown | P1 | No |
| COMPOSE-U020 | FileDownloader | should handle download error | Verify error | Invalid URL or network failure | Error thrown, rethrown for caller handling | P1 | Yes |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| COMPOSE-W001 | Compose/Web | should render compose form with TO, Subject, Body fields | Verify rendering | WebCompose | Default | None | All compose fields visible | Web | Large | Both | P0 | No |
| COMPOSE-W002 | Compose/Web | should show file picker action sheet | Verify file picker | WebCompose | Default | Tap attachment icon | Action sheet with Gallery/File options | All | All | Both | P1 | No |
| COMPOSE-W003 | Compose/Web | should show upload progress for each attachment | Verify progress | WebCompose | File being uploaded | None | Progress indicator visible per file | All | All | Both | P1 | No |
| COMPOSE-W004 | Compose/Web | should show cancel/save/delete action sheet on back | Verify cancel flow | WebCompose | Content entered | Tap back/cancel | Action sheet with Delete Draft/Save Draft/Cancel options | All | All | Both | P0 | No |
| COMPOSE-W005 | Compose/Web | should show add email modal for unknown recipients | Verify opt-in modal | WebCompose | Unknown recipient | Tap Send | AddEmailModal shown with Add/Skip options | All | All | Both | P0 | No |
| COMPOSE-W006 | Compose/Web | should render responsive layout for mobile | Verify responsive | WebCompose | screenWidth=375 | None | Mobile compose layout | All | Small | Portrait | P1 | No |
| COMPOSE-W007 | ViewInbox | should render email detail with subject and body | Verify rendering | ViewInbox | emailId=123, emailType='inbox' | None | Subject, sender, body visible | All | All | Both | P0 | No |
| COMPOSE-W008 | ViewInbox | should render in reading pane mode (hideAppBar=true) | Verify reading pane | ViewInbox | hideAppBar=true | None | No AppBar, content fits pane | Web | Large | Both | P1 | No |
| COMPOSE-W009 | ViewInbox | should show tag list overlay | Verify tag UI | ViewInbox | Email loaded | Tap tag button | Tag selection overlay visible | All | All | Both | P1 | No |
| COMPOSE-W010 | ViewInbox | should show menu options overlay | Verify menu | ViewInbox | Email loaded | Tap more options | Menu with archive/trash/move options | All | All | Both | P1 | No |
| COMPOSE-W011 | FullScreenImage | should render full-screen image with loading progress | Verify viewer | openFullScreenImage | Valid image URL | None | Image displayed with progress indicator during load | All | All | Both | P1 | No |
| COMPOSE-W012 | FullScreenPDF | should render full-screen PDF viewer | Verify viewer | openFullScreenPDF | Valid PDF URL | None | PDF rendered | All | All | Both | P1 | No |
| COMPOSE-W013 | FullScreenWebView | should render WebView with JavaScript enabled | Verify viewer | openFullScreenWebView | Valid URL | None | WebView loaded with JS and DOM storage | All | All | Both | P1 | No |

### Flutter Test Notes — Web Compose & Email Viewers
- **Required mocks:** MockSocketService, MockApiService (signed URL, email detail), MockInAppWebView
- **File picker:** Mock `FilePicker` and `ImagePicker` for attachment tests
- **S3 upload:** Mock HTTP PUT for signed URL upload
- **Permission handler:** Mock `permission_handler` for camera/storage permissions
- **WebView:** Use `InAppWebView` platform mock for full-screen WebView tests
- **pumpAndSettle:** Required after async file operations and socket events

---

## 19. Subscription Management Screens

### Current Coverage Status
- **Existing tests:** None (Section 8 covers plan selection and checkout, but not change/detail/payment screens)
- **Files involved:**
  - `lib/screens/subscription/change_subscription.dart`
  - `lib/screens/subscription/payment_method.dart`
  - `lib/screens/subscription/subscription_detail.dart`
- **Gaps:** Complete — no test coverage for these screens

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| SUBMGMT-U001 | Subscription/ChangeSubscription | should load current plan and available plans | Verify data load | Authenticated user with active subscription | planList populated, current plan index detected | P1 | No |
| SUBMGMT-U002 | Subscription/ChangeSubscription | should detect current plan from payment list | Verify plan detection | Payment list with plan type 'pro' | _selectedPlanIndex matches 'pro' plan | P1 | No |
| SUBMGMT-U003 | Subscription/ChangeSubscription | should cancel membership via API | Verify cancellation | User confirms cancel | cancelMembershipApi called, success response handled | P1 | No |
| SUBMGMT-U004 | Subscription/ChangeSubscription | should handle plan load failure | Verify error | API returns error | Error toast shown, graceful degradation | P1 | Yes |
| SUBMGMT-U005 | Subscription/PaymentMethod | should fetch saved payment cards | Verify card load | Authenticated | getCards() returns card list | P1 | No |
| SUBMGMT-U006 | Subscription/PaymentMethod | should handle addCardSuccess socket event | Verify socket | Socket emits addCardSuccess | Card list refreshed | P1 | No |
| SUBMGMT-U007 | Subscription/PaymentMethod | should handle card fetch failure | Verify error | API error | Error toast shown | P1 | Yes |
| SUBMGMT-U008 | Subscription/SubscriptionDetail | should calculate remaining days correctly | Verify date math | startDate='2026-01-01', endDate='2026-02-28' | Remaining days calculated correctly | P1 | No |
| SUBMGMT-U009 | Subscription/SubscriptionDetail | should handle expired subscription (negative days) | Verify edge case | endDate in the past | Shows 0 or expired state | P1 | Yes |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| SUBMGMT-W001 | Subscription/ChangePlan | should render plan options | Verify rendering | ChangeSubscription | Plans loaded | None | Available plans displayed with current highlighted | All | All | Both | P1 | No |
| SUBMGMT-W002 | Subscription/ChangePlan | should show cancel confirmation dialog | Verify cancel flow | ChangeSubscription | Active subscription | Tap Cancel | Confirmation dialog shown | All | All | Both | P1 | No |
| SUBMGMT-W003 | Subscription/PaymentMethod | should render saved cards | Verify rendering | PaymentMethod | Cards loaded | None | Card list with last 4 digits visible | All | All | Both | P1 | No |
| SUBMGMT-W004 | Subscription/PaymentMethod | should show loading state | Verify loading | PaymentMethod | Loading | None | Loading indicator visible | All | All | Both | P2 | No |
| SUBMGMT-W005 | Subscription/Detail | should render subscription details | Verify rendering | SubscriptionDetail | Subscription data | None | Plan name, dates, remaining days visible | All | All | Both | P1 | No |
| SUBMGMT-W006 | Subscription/Detail | should render responsive layout | Verify responsive | SubscriptionDetail | Mobile viewport | None | Mobile layout | All | Small | Portrait | P2 | No |

---

## 20. Auth Support Screens

### Current Coverage Status
- **Existing tests:** None
- **Files involved:**
  - `lib/screens/auth/login_post_processor.dart`
  - `lib/screens/auth/enterOtp/enter_otp_profile.dart`
  - `lib/screens/auth/enterOtp/success_otp.dart`
  - `lib/screens/auth/web/paymentSuccess/payment_success.dart`
- **Gaps:** Complete — no test coverage exists
- **Note:** `check_breach_mails.dart` and `breach_notifier.dart` were deleted in v1.0.7. Breach-check test cases (AUTHSUP-U001–U007, AUTHSUP-W001–W003) removed as orphaned.

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| AUTHSUP-U001 | Auth/LoginPostProcessor | should navigate to passkey page when passkey is supported | Verify navigateAfterLogin routes to addPassKey | Descope.passkey.isSupported()=true | GoRouter.go(AppRoutes.addPassKey) called with pageKey='login' | P0 | No |
| AUTHSUP-U002 | Auth/LoginPostProcessor | should navigate to inbox when passkey unsupported and subscription valid | Verify fallthrough navigation | Descope.passkey.isSupported()=false, isSubscriptionValid=true | GoRouter.go(AppRoutes.inbox) called | P0 | No |
| AUTHSUP-U003 | Auth/LoginPostProcessor | should navigate to plans when passkey unsupported and subscription invalid | Verify fallthrough navigation | Descope.passkey.isSupported()=false, isSubscriptionValid=false | GoRouter.go(AppRoutes.plans) called | P0 | No |
| AUTHSUP-U004 | Auth/LoginPostProcessor | should handle DescopeException during passkey check gracefully | Verify exception catch | Descope.passkey.isSupported() throws DescopeException | Falls through to subscription navigation, no crash | P0 | Yes |
| AUTHSUP-U005 | Auth/LoginPostProcessor | should handle generic exception during passkey check gracefully | Verify catch-all | Descope.passkey.isSupported() throws generic error | Falls through to subscription navigation, no crash | P1 | Yes |
| AUTHSUP-U006 | Auth/OtpProfile | should load user data from secure storage | Verify init | Storage has user data | Phone, country code populated | P1 | No |
| AUTHSUP-U007 | Auth/OtpProfile | should resend OTP via API | Verify resend | Valid loginId | API called, fields cleared on success | P1 | No |
| AUTHSUP-U008 | Auth/OtpProfile | should reject OTP shorter than 6 digits | Verify validation | OTP='12345' (5 digits) | Error shown, no API call | P1 | Yes |
| AUTHSUP-U009 | Auth/OtpProfile | should verify OTP via API | Verify verification | Valid 6-digit OTP | API called, success navigation | P1 | No |
| AUTHSUP-U010 | Auth/PaymentSuccess | should fetch profile data on load | Verify init | Authenticated | getProfile API called, auth state synced | P1 | No |
| AUTHSUP-U011 | Auth/PaymentSuccess | should allow navigation even on API failure | Verify degradation | API fails | Button still enabled after timeout, navigation works | P1 | Yes |
| AUTHSUP-U012 | Auth/PaymentSuccess | should disable button until data ready | Verify guard | Data loading | Button disabled (_isDataReady=false) | P1 | No |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| AUTHSUP-W001 | Auth/OtpProfile | should render OTP form with phone display | Verify rendering | EnterOtpProfile | Phone data loaded | None | Phone number, OTP input, submit button visible | All | All | Both | P1 | No |
| AUTHSUP-W002 | Auth/OtpProfile | should render responsive layout (desktop centered) | Verify responsive | EnterOtpProfile | Desktop viewport | None | 600px centered container | Web | Large | Both | P1 | No |
| AUTHSUP-W003 | Auth/SuccessOtp | should render success message and login button | Verify rendering | SuccessOtp | Default | None | Success message, login button visible | All | All | Both | P1 | No |
| AUTHSUP-W004 | Auth/SuccessOtp | should prevent back navigation with PopScope | Verify PopScope | SuccessOtp | Default | System back | Back navigation blocked | All | All | Both | P1 | No |
| AUTHSUP-W005 | Auth/PaymentSuccess | should render success state with continue button | Verify rendering | PaymentSuccess | Data ready | None | Success message, continue button enabled | Web | All | Both | P1 | No |
| AUTHSUP-W006 | Auth/PaymentSuccess | should show app store links | Verify links | PaymentSuccess | Default | None | iOS App Store and Android Play Store links visible | Web | All | Both | P2 | No |

---

## 21. Additional Uncovered Widgets

### Current Coverage Status
- **Existing tests:** None
- **Files involved:** Various widgets in `lib/widgets/` not covered by Section 11
- **Gaps:** Multiple widgets with zero test coverage

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| WIDG-W001 | Widget/CustomDismissible | should render inbox email item with slidable actions | Verify rendering | CustomDismissible | emailType='inbox', items=[email] | None | Email item with slide actions | All | All | Both | P0 | No |
| WIDG-W002 | Widget/CustomDismissible | should show archive action for inbox emails | Verify actions | CustomDismissible | emailType='inbox' | Slide left | Archive action visible | All | All | Both | P0 | No |
| WIDG-W003 | Widget/CustomDismissible | should hide archive action in archive folder | Verify conditional | CustomDismissible | emailType='archive' | Slide left | No archive action (already archived) | All | All | Both | P0 | Yes |
| WIDG-W004 | Widget/CustomDismissible | should show different actions for sent emails | Verify sent actions | CustomDismissible | emailType='sent' | Slide left | Sent-specific actions (no archive) | All | All | Both | P1 | No |
| WIDG-W005 | Widget/CustomDismissible | should toggle selection on tap in long-press mode | Verify selection | CustomDismissible | longPressFlag=true | Tap email | Email toggles selected/unselected | All | All | Both | P0 | No |
| WIDG-W006 | Widget/CustomDismissible | should use receivers[0].emailId for sent emails | Verify ID mapping | CustomDismissible | emailType='sent' | Select email | Correct sent email ID used | All | All | Both | P1 | Yes |
| WIDG-W007 | Widget/CustomDismissible | should mark as read with undo on tap | Verify markAsReadWithUndo | CustomDismissible | Unread email | Tap email | API called, undo toast shown | All | All | Both | P1 | No |
| WIDG-W008 | Widget/CustomDismissible | should show permanent delete confirmation for trash | Verify trash delete | CustomDismissible | emailType='trash' | Tap delete | Confirmation dialog shown | All | All | Both | P1 | No |
| WIDG-W009 | Widget/CustomDismissible | should call moreOptions with type-dependent list | Verify options | CustomDismissible | emailType='inbox' | Long press → More | Options: Move to Archive, Move to Trash, etc. | All | All | Both | P1 | No |
| WIDG-W010 | Widget/CustomDismissible | should navigate to email detail on tap | Verify navigation | CustomDismissible | Default | Tap email | gotoViewDetail called with correct params | All | All | Both | P0 | No |
| WIDG-W011 | Widget/ButtonFormField | should render gradient button with text | Verify rendering | CustomGradientButton | text='Submit' | None | Button with gradient background and text | All | All | Both | P1 | No |
| WIDG-W012 | Widget/ButtonFormField | should render gradient button with leading icon | Verify icon | CustomGradientButton | text='Send', leadingIcon=Icons.send | None | Icon + text in row layout | All | All | Both | P1 | No |
| WIDG-W013 | Widget/DraftEmailList | should render draft email item | Verify rendering | DraftEmailList | Draft email data | None | Draft subject, recipients visible | All | All | Both | P1 | No |
| WIDG-W014 | Widget/DraftEmailList | should use item.id for draft selection | Verify ID | DraftEmailList | Draft email | Select | Correct draft ID used (not receivers[0]) | All | All | Both | P1 | Yes |
| WIDG-W015 | Widget/SentEmailList | should render sent email item | Verify rendering | SentEmailList | Sent email data | None | Sent subject, recipients visible | All | All | Both | P1 | No |
| WIDG-W016 | Widget/SentEmailList | should show moveToInbox action | Verify action | SentEmailList | emailType='trash' | Action menu | Move to Inbox option visible | All | All | Both | P1 | No |
| WIDG-W017 | Widget/DrawerItem | should render with badge for inbox | Verify badge | MyDrawerItem | labelText='5' | None | Badge with count '5' visible | All | All | Both | P1 | No |
| WIDG-W018 | Widget/DrawerItem | should render different badge style for draft | Verify draft badge | MyDrawerItem | draft=true, labelText='3' | None | Draft-styled badge | All | All | Both | P2 | No |
| WIDG-W019 | Widget/NotificationItem | should render with unread indicator | Verify unread | NotificationItem | Unread notification | None | Blue dot indicator visible | All | All | Both | P1 | No |
| WIDG-W020 | Widget/NotificationItem | should expand/collapse content on tap | Verify expandable | NotificationItem | Long notification text | Tap | Content toggles between truncated and full | All | All | Both | P1 | No |
| WIDG-W021 | Widget/ProfileDobPicker | should show date picker on tap | Verify picker | ProfileDobPicker | editable=true | Tap field | Date picker dialog shown | All | All | Both | P1 | No |
| WIDG-W022 | Widget/ProfileDobPicker | should format selected date as MM/dd/yyyy | Verify format | ProfileDobPicker | Date selected | Pick date | Controller text formatted correctly | All | All | Both | P1 | No |
| WIDG-W023 | Widget/PromoCodeTextField | should render with suffix text | Verify suffix | PromoCodeTextField | showRightText=true, rightText='Apply' | None | 'Apply' suffix visible | All | All | Both | P1 | No |
| WIDG-W024 | Widget/PromoCodeTextField | should call onSuffixTap callback | Verify callback | PromoCodeTextField | showRightText=true | Tap suffix | onSuffixTap called | All | All | Both | P1 | No |
| WIDG-W025 | Widget/TagInputField | should validate email format on submit | Verify validation | TagInputField | Invalid email entered | Submit | Email rejected, not added as tag | All | All | Both | P0 | No |
| WIDG-W026 | Widget/TagInputField | should prevent duplicate tags | Verify dedup | TagInputField | 'test@mail.com' already added | Enter same | Duplicate rejected | All | All | Both | P1 | Yes |
| WIDG-W027 | Widget/TagInputField | should split on comma and space separators | Verify separators | TagInputField | 'a@b.com, c@d.com' | Type with comma | Two separate tags created | All | All | Both | P1 | No |
| WIDG-W028 | Widget/GradientWebBar | should render with search bar when enabled | Verify rendering | CustomWebBar | showSearchBar=true | None | Search bar visible in web bar | Web | Large | Both | P1 | No |
| WIDG-W029 | Widget/GradientWebBar | should show notification icon when enabled | Verify notification | CustomWebBar | showNotificationIcon=true | None | Notification bell icon visible | Web | Large | Both | P1 | No |
| WIDG-W030 | Widget/Print | should auto-close after 5 seconds | Verify auto-close | Print | printUrl='https://...' | Wait 5s | Navigator.pop called | All | All | Both | P2 | No |

### Flutter Test Notes — Additional Widgets
- **CustomDismissible:** Requires mock data with different email types (inbox/sent/archive/trash/draft), mock callbacks for all actions
- **TagInputField:** Requires `StringTagController` setup with pre-populated tags for duplicate tests
- **Slidable:** `flutter_slidable` actions need `SlidableController` mocking for slide gesture tests
- **Print:** Uses `Timer` — need `fakeAsync` for timeout testing

---

## 22. Tag Email List & Miscellaneous Screens

### Current Coverage Status
- **Existing tests:** None
- **Files involved:**
  - `lib/screens/tags/tag_email_list.dart`
  - `lib/screens/no_internet_screen.dart` (may have basic tests in Section 12)
  - `lib/services/web_file_picker_service.dart`
  - `lib/services/web_utils.dart`
- **Gaps:** tag_email_list and web services have no test coverage

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| MISC-U001 | Tags/TagEmailList | should fetch emails for specific tag | Verify load | tagId=5 | API called with tag filter, emails populated | P1 | No |
| MISC-U002 | Tags/TagEmailList | should toggle email selection | Verify selection | emailId=123 | Email added to selectedEmailIds, re-tap removes | P1 | No |
| MISC-U003 | Tags/TagEmailList | should toggle select-all flag | Verify select all | Multiple emails | allEmailIdsFlag toggled, all IDs selected | P1 | No |
| MISC-U004 | Tags/TagEmailList | should handle pagination | Verify paging | First page loaded | loadMore triggers next page fetch | P1 | No |
| MISC-U005 | Tags/TagEmailList | should handle empty tag (no emails) | Verify empty | Tag with 0 emails | Empty state displayed | P1 | Yes |
| MISC-U006 | WebFilePicker | should pick file with allowed extensions | Verify picker | File selected | File data (bytes, name) returned | P1 | No |
| MISC-U007 | WebFilePicker | should handle pick cancellation | Verify cancel | User cancels picker | Returns null, no error | P1 | No |
| MISC-U008 | WebFilePicker | should show error toast on picker failure | Verify error | Picker throws exception | Error toast shown | P1 | Yes |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| MISC-W001 | Tags/TagEmailList | should render emails filtered by tag | Verify rendering | TagEmailList | tagId=5, emails loaded | None | Email list displayed with tag indicator | All | All | Both | P1 | No |
| MISC-W002 | Tags/TagEmailList | should enter long-press mode and show checkboxes | Verify long press | TagEmailList | Emails loaded | Long press | Checkboxes appear, action bar shown | All | All | Both | P1 | No |
| MISC-W003 | Tags/TagEmailList | should show empty state for tag with no emails | Verify empty | TagEmailList | tagId with no emails | None | NoData widget displayed | All | All | Both | P1 | Yes |

---

## 23. Session Management & Security Utilities (NEW — v1.0.7)

### Current Coverage Status
- **Existing tests:** None
- **Files involved:**
  - `lib/services/session_expiry_manager.dart`
  - `lib/services/session_refresh_mutex.dart`
  - `lib/services/analytics_service.dart`
  - `lib/services/connectivity_service.dart`
  - `lib/services/storage/platform_secure_storage.dart` (+ web/stub)
  - `lib/common/utilites/secure_url_helper.dart`
  - `lib/common/utilites/stripe_url_validator.dart`
  - `lib/common/utilites/secure_print_helper.dart`
  - `lib/router/route_extras.dart`
  - `lib/widgets/load_container/delayed_loading_overlay.dart`
  - `lib/services/update_provider.dart`
  - `lib/services/global_variable_notifier.dart`
  - `lib/repositories/base/http_client_factory.dart` (+ web/stub)
- **Gaps:** All files new since last audit — zero test coverage

### Unit Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| SESS-U001 | Session/ExpiryManager | should clear session and set unauthenticated on expiry | Verify handleExpiry() calls clearSession, setAuthenticated(false), clearAllData | Active session | Session cleared, auth state false, storage wiped | P0 | No |
| SESS-U002 | Session/ExpiryManager | should show toast when showToast is true | Verify toast display | showToast=true | "Session expired. Please log in again." toast shown | P0 | No |
| SESS-U003 | Session/ExpiryManager | should not show toast when showToast is false | Verify default behavior | showToast=false (default) | No toast displayed | P1 | No |
| SESS-U004 | Session/ExpiryManager | should be idempotent when called concurrently | Verify _isHandling guard | Two concurrent handleExpiry() calls | Second call is no-op | P0 | Yes |
| SESS-U005 | Session/ExpiryManager | should reset _isHandling in finally block | Verify cleanup | First call completes | Subsequent call works correctly | P0 | No |
| SESS-U006 | Session/ExpiryManager | should set SessionRefreshMutex.isLoggedOut to true | Verify mutex flag | handleExpiry() called | isLoggedOut=true before storage clear | P0 | No |
| SESS-U007 | Session/RefreshMutex | should skip refresh when isLoggedOut is true | Verify early return | isLoggedOut=true | guardedRefreshIfNeeded returns immediately, no Descope call | P0 | No |
| SESS-U008 | Session/RefreshMutex | should skip refresh when passkeyFlowInProgress is true | Verify passkey guard | passkeyFlowInProgress=true | guardedRefreshIfNeeded returns immediately | P0 | No |
| SESS-U009 | Session/RefreshMutex | should serialize concurrent refresh calls via Completer | Verify mutex | Two concurrent guardedRefreshIfNeeded calls | Second call awaits first's Completer | P0 | Yes |
| SESS-U010 | Session/RefreshMutex | should clear session if logout happened during refresh | Verify double-check | isLoggedOut set true while refresh is awaiting | clearSession called after refresh completes | P0 | Yes |
| SESS-U011 | Session/RefreshMutex | should rethrow on refresh failure | Verify error propagation | refreshSessionIfNeeded throws | Error rethrown to caller | P0 | Yes |
| SESS-U012 | Session/RefreshMutex | should reset _refreshCompleter in finally block | Verify cleanup | After success or failure | _refreshCompleter set to null | P0 | No |
| ANAL-U001 | Analytics/AnalyticsService | should not log events when firebaseReady is false | Verify guard | firebaseReady=false | logEvent is no-op | P0 | No |
| ANAL-U002 | Analytics/AnalyticsService | should log login flow events with correct parameters | Verify login analytics | Various login events | Correct event names and params passed to Firebase | P0 | No |
| ANAL-U003 | Analytics/AnalyticsService | should log signup flow events with correct parameters | Verify signup analytics | logSignupStart through logSignupComplete | Correct events fired in sequence | P0 | No |
| ANAL-U004 | Analytics/AnalyticsService | should log passkey enrollment events | Verify passkey analytics | logPasskeyEnrollStart/Success/Skip/Fail | Correct event names and error params | P1 | No |
| ANAL-U005 | Analytics/AnalyticsService | should log subscription/checkout events with correct parameters | Verify checkout analytics | logPlanView through logSubscriptionChangeStart | Correct plan_name, plan_type, price params | P0 | No |
| ANAL-U006 | Analytics/AnalyticsService | should set user properties correctly | Verify setUserProperty calls | logLoginPasskeySuccess, logSignupStart | login_method, has_passkey, signup_source set correctly | P1 | No |
| ANAL-U007 | Analytics/AnalyticsService | should truncate error strings to 100 characters | Verify _truncate utility | 200-char error string | Truncated to 100 chars | P1 | Yes |
| ANAL-U008 | Analytics/AnalyticsService | should swallow exceptions from Firebase calls | Verify no exception propagation | Firebase throws internally | No error propagated to caller | P1 | Yes |
| ANAL-U009 | Analytics/AnalyticsService | should distinguish web vs mobile in signup_source | Verify kIsWeb conditional | kIsWeb=true vs kIsWeb=false | signup_source='web' vs 'mobile' | P1 | No |
| SEC-U001 | Security/SecureUrlHelper | should strip token parameter from URL | Verify stripTokenFromUrl | URL with ?token=abc&tokentype=descope | Token and tokentype params removed | P0 | No |
| SEC-U002 | Security/SecureUrlHelper | should preserve non-token query parameters | Verify param preservation | URL with ?token=abc&page=2 | Only token removed, page=2 preserved | P0 | No |
| SEC-U003 | Security/SecureUrlHelper | should return URL unchanged when no token param present | Verify passthrough | URL without token param | URL returned unchanged | P1 | No |
| SEC-U004 | Security/SecureUrlHelper | should handle empty query string | Verify edge case | URL with no query params | URL returned unchanged | P1 | Yes |
| SEC-U005 | Security/SecureUrlHelper | should return session JWT from Descope or fallback | Verify getSessionToken | Active session vs no session | JWT returned or fallback string | P0 | No |
| SEC-U006 | Security/StripeUrlValidator | should accept valid stripe.com HTTPS URL | Verify isValidStripeUrl | https://checkout.stripe.com/pay/cs_test_123 | Returns true | P0 | No |
| SEC-U007 | Security/StripeUrlValidator | should accept valid API domain URL | Verify backend redirect acceptance | https://api.optmsg.com/checkout/redirect | Returns true (matches baseUrl host) | P0 | No |
| SEC-U008 | Security/StripeUrlValidator | should reject non-HTTPS URL | Verify scheme check | http://stripe.com/pay | Returns false | P0 | Yes |
| SEC-U009 | Security/StripeUrlValidator | should reject null or empty URL | Verify null/empty handling | null, '' | Returns false | P0 | Yes |
| SEC-U010 | Security/StripeUrlValidator | should reject URLs from unknown domains | Verify domain check | https://evil.com/fake-stripe | Returns false | P0 | Yes |
| SEC-U011 | Security/SecurePrintHelper | should use web print dialog on kIsWeb | Verify web path | kIsWeb=true | showDialog called with InAppWebView | P1 | No |
| SEC-U012 | Security/SecurePrintHelper | should use mobile print screen on native | Verify mobile path | kIsWeb=false | Navigator.push called with _MobilePrintScreen | P1 | No |
| SEC-U013 | Security/SecurePrintHelper | should pass auth headers in WebView request | Verify headers | token='jwt_token' | URLRequest headers contain authorization and tokentype | P0 | No |
| NAV-U028 | Router/RouteExtras | should return empty map from safeExtras when extra is null | Verify null safety | extra=null | Returns empty Map<String,dynamic> | P0 | No |
| NAV-U029 | Router/RouteExtras | should return map from safeExtras when extra is valid Map | Verify passthrough | extra={'key':'val'} | Returns the same map | P0 | No |
| NAV-U030 | Router/RouteExtras | should return fallback from extraString when key missing | Verify default value | extras={}, key='missing' | Returns '' (default) | P1 | No |
| NAV-U031 | Router/RouteExtras | should return correct string from extraString when present | Verify extraction | extras={'name':'John'}, key='name' | Returns 'John' | P1 | No |
| NAV-U032 | Router/RouteExtras | should return typed value from extraTyped or null on mismatch | Verify type-safe extraction | extras={'count': 5}, key='count', T=int | Returns 5; with T=String returns null | P1 | Yes |
| STOR-U001 | Storage/PlatformSecureStorage | should create platform-appropriate storage instance | Verify factory | Call createPlatformSecureStorage() | Returns non-null PlatformSecureStorage | P0 | No |
| STOR-U002 | Storage/PlatformSecureStorage | should write and read values correctly | Verify roundtrip | write(key:'k', value:'v') then read(key:'k') | Returns 'v' | P0 | No |
| STOR-U003 | Storage/PlatformSecureStorage | should delete specific key | Verify delete | write then delete(key:'k') then read | Returns null | P0 | No |
| STOR-U004 | Storage/PlatformSecureStorage | should delete all stored values | Verify deleteAll | write multiple then deleteAll() | All reads return null | P0 | No |
| STOR-U005 | Storage/PlatformSecureStorage | should return null for non-existent key | Verify read miss | read(key:'nonexistent') | Returns null | P1 | Yes |
| CONN-U001 | Service/Connectivity | should detect online status | Verify connectivity | Device online | Returns true / connected status | P0 | No |
| CONN-U002 | Service/Connectivity | should detect offline status | Verify no connectivity | Device offline | Returns false / disconnected status | P0 | No |
| CONN-U003 | Service/Connectivity | should notify listeners on connectivity change | Verify stream | Connectivity changes | Stream emits new status | P1 | No |
| MISC-U009 | Service/UpdateProvider | should track loading paths via addPath/clearPathList | Verify path management | addPath('/inbox'), clearPathList() | Paths tracked then cleared | P1 | No |
| MISC-U010 | Service/UpdateProvider | should expose current loading state | Verify state | Various operations | State reflects current loading status | P1 | No |
| MISC-U011 | Service/GlobalVariableNotifier | should manage global state variables | Verify state management | Set various globals | State accessible via provider | P1 | No |
| MISC-U012 | Service/GlobalVariableNotifier | should notify listeners on state change | Verify notification | Update state | Listeners notified | P1 | No |
| MISC-U013 | Repository/HttpClientFactory | should create appropriate HTTP client for platform | Verify factory | Web vs mobile | Correct HttpClient returned per platform | P2 | No |

### Widget Test Cases

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| WIDG-W031 | Loading/DelayedOverlay | should not show spinner before delay elapses | Verify delayed appearance | DelayedLoadingOverlay | isLoading=true, delay=600ms | pump(300ms) | No spinner visible | All | All | Both | P0 | No |
| WIDG-W032 | Loading/DelayedOverlay | should show spinner after delay when isLoading is true | Verify spinner appears | DelayedLoadingOverlay | isLoading=true | pump(700ms) | LoaderIndicator and ModalBarrier visible | All | All | Both | P0 | No |
| WIDG-W033 | Loading/DelayedOverlay | should hide spinner when isLoading becomes false before delay | Verify cancellation | DelayedLoadingOverlay | isLoading=true then false before delay | pump(300ms), set isLoading=false | No spinner ever shown | All | All | Both | P0 | Yes |
| WIDG-W034 | Loading/DelayedOverlay | should show ModalBarrier when spinner is visible | Verify barrier | DelayedLoadingOverlay | isLoading=true | pump(700ms) | ModalBarrier(dismissible:false) present | All | All | Both | P1 | No |
| WIDG-W035 | Loading/DelayedOverlay | should cancel timer on dispose | Verify cleanup | DelayedLoadingOverlay | isLoading=true | Dispose widget before delay | No setState error | All | All | Both | P1 | Yes |
| WIDG-W036 | Loading/DelayedOverlay | should restart delay timer when isLoading toggles | Verify timer reset | DelayedLoadingOverlay | isLoading true→false→true | Toggle loading | New delay starts from scratch | All | All | Both | P1 | No |
| SEC-W001 | Security/SecurePrint | should auto-close mobile print after 5 seconds | Verify auto-pop | _MobilePrintScreen | printUrl, token | pump(5100ms) | Screen auto-popped | iOS, Android | All | Both | P1 | No |
| SEC-W002 | Security/SecurePrint | should show close button in web print dialog | Verify UI | Web print dialog | printUrl, token | None | Close IconButton visible | Web | All | Both | P1 | No |
| WIDG-W037 | Loading/LoaderIndicator | should render loading indicator | Verify rendering | LoaderIndicator | Default | None | Loading indicator visible | All | All | Both | P2 | No |

### Flutter Test Notes — Session & Security
- **SessionExpiryManager:** Test `_isHandling` static flag by calling handleExpiry() concurrently. Reset between tests.
- **SessionRefreshMutex:** Test `_refreshCompleter` static field. Reset `isLoggedOut` and `passkeyFlowInProgress` between tests.
- **AnalyticsService:** Mock `FirebaseAnalytics.instance` and `firebaseReady` global. Verify event names and params.
- **SecureUrlHelper:** Pure functions — no mocks needed.
- **StripeUrlValidator:** Mock `app_config.baseUrl` for domain comparison tests.
- **SecurePrintHelper:** Mock `InAppWebView` and `Navigator` for platform-specific tests. Use `debugDefaultTargetPlatformOverride` for platform switching.
- **PlatformSecureStorage:** Test the stub implementation directly; web implementation requires JS interop mocks.
- **DelayedLoadingOverlay:** Use `tester.pump(Duration)` (NOT pumpAndSettle) to test timer-based behavior.
- **RouteExtras:** Pure functions — no mocks needed.

---

## 24. Infrastructure & DevOps

### Current Coverage Status
- **Existing tests:** None
- **Gaps:** Complete — no test coverage exists for environment configuration, CI/CD, or performance benchmarks

### Test Cases

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| INFRA-001 | Env/Flavors | should configure dev environment with correct base URL | Verify dev flavor | Build flavor=dev | API baseUrl points to dev server, debug flags enabled | P0 | No |
| INFRA-002 | Env/Flavors | should configure staging environment with correct base URL | Verify staging flavor | Build flavor=staging | API baseUrl points to staging server | P0 | No |
| INFRA-003 | Env/Flavors | should configure production environment with correct base URL | Verify prod flavor | Build flavor=production | API baseUrl points to production server, debug flags disabled | P0 | No |
| INFRA-004 | Env/Flavors | should use correct API base URL per flavor at runtime | Verify runtime config | App started with each flavor | All API calls use the flavor-specific base URL | P0 | No |
| INFRA-005 | Env/Flavors | should use correct Firebase config per flavor | Verify Firebase flavor | Each build flavor | Correct GoogleService-Info.plist / google-services.json used | P1 | No |
| INFRA-006 | CI/CD | should run unit tests in CI pipeline | Verify CI unit test stage | Pipeline triggered | All unit tests execute and pass | P0 | No |
| INFRA-007 | CI/CD | should run widget tests in CI pipeline | Verify CI widget test stage | Pipeline triggered | All widget tests execute and pass | P0 | No |
| INFRA-008 | CI/CD | should run integration tests in CI pipeline | Verify CI integration test stage | Pipeline triggered | Integration tests execute and report results | P1 | No |
| INFRA-009 | CI/CD | should build APK and IPA artifacts successfully | Verify mobile builds | Pipeline triggered | APK (Android) and IPA (iOS) built without errors | P0 | No |
| INFRA-010 | CI/CD | should build web app successfully | Verify web build | Pipeline triggered | Web build completes without errors, assets generated | P0 | No |
| INFRA-011 | Perf/JMeter | should verify API response times under load | Verify response time SLA | JMeter load test with N concurrent users | 95th percentile response time < threshold (e.g., 2s) | P1 | No |
| INFRA-012 | Perf/JMeter | should verify concurrent user capacity | Verify scalability | JMeter ramp-up to max concurrent users | System handles target concurrent users without errors | P1 | No |
| INFRA-013 | Perf/JMeter | should verify throughput under sustained load | Verify throughput | JMeter sustained load for T minutes | Throughput (requests/sec) meets or exceeds target | P1 | No |
| INFRA-014 | DefaultClient/Android | should declare mailto intent-filter with VIEW action in AndroidManifest.xml | Verify Android manifest | AndroidManifest.xml | intent-filter with action.VIEW + scheme=mailto + BROWSABLE category present | P0 | No |
| INFRA-015 | DefaultClient/Android | should declare mailto intent-filter with SENDTO action in AndroidManifest.xml | Verify Android SENDTO | AndroidManifest.xml | intent-filter with action.SENDTO + scheme=mailto + DEFAULT category present | P0 | No |
| INFRA-016 | DefaultClient/iOS | should declare mailto in CFBundleURLSchemes in Info.plist | Verify iOS URL scheme | ios/Runner/Info.plist | CFBundleURLTypes contains dict with CFBundleURLSchemes including 'mailto' | P0 | No |
| INFRA-017 | DefaultClient/iOS | should declare mailto in LSApplicationQueriesSchemes in Info.plist | Verify iOS queries | ios/Runner/Info.plist | LSApplicationQueriesSchemes array includes 'mailto' | P0 | No |
| INFRA-018 | DefaultClient/Deps | should include app_links dependency for deep link handling | Verify app_links dep | pubspec.yaml | app_links package listed in dependencies | P1 | No |

### Notes — Infrastructure & DevOps
- **Environment flavors:** Verified via build configuration files and runtime assertions (not traditional Flutter tests)
- **CI/CD:** Validated by pipeline definitions (e.g., GitHub Actions, Codemagic, Bitrise YAML configs)
- **JMeter:** Performance tests are external to Flutter; require JMeter test plans (.jmx) targeting the backend API
- **Recommended tools:** Codemagic or GitHub Actions for CI/CD; Apache JMeter or k6 for performance testing

---

## Appendix A: Model Serialization Test Matrix

All models requiring fromJson/toJson tests:

| Model | File | Has fromJson | Has toJson | Priority |
|-------|------|-------------|-----------|----------|
| LoginModel | login_model.dart | Yes | Yes | P0 |
| CreateAccount | create_account_model.dart | Yes | Yes | P0 |
| OtpVerify | otp_verify_model.dart | Yes | Yes | P0 |
| InboxListModel | inbox_list_model.dart | Yes | Yes | P0 |
| ViewEmailModel | view_email_model.dart | Yes | Yes | P0 |
| ViewDraftModel | view_draft_model.dart | Yes | Yes | P0 |
| DraftListModel | draft_list_modal.dart | Yes | Yes | P0 |
| SentListModel | sent_list_model.dart | Yes | Yes | P0 |
| ContactListModel | contact_list_model.dart | Yes | Yes | P0 |
| ContactEmailDetailsModel | contact_email_details.dart | Yes | Yes | P1 |
| SearchEmailModel | search_email_model.dart | Yes | Yes | P1 |
| RequestAddContact | request_add_contact_modal.dart | Yes | Yes | P1 |
| NotificationListModel | notification_list_model.dart | Yes | Yes | P1 |
| TagsListModel | tags_list_model.dart | Yes | Yes | P1 |
| PaymentListModel | payment_list_model.dart | Yes | Yes | P1 |
| PlanListModel | plan_list_model.dart | Yes | Yes | P1 |
| MyProfile | profile_model.dart | Yes | Yes | P1 |
| SetupProfile | setup_profile_model.dart | Yes | Yes | P1 |
| RequestLogin | request_login_model.dart | Yes | Yes | P1 |
| UserName (ForgotUsername) | forgot_user_name_model.dart | Yes | Yes | P1 |
| StaticPage | static_page_model.dart | Yes | Yes | P2 |
| FaqStaticPage | static_faq_page_model.dart | Yes | Yes | P2 |
| SignedUrlModel | signed_url_model.dart | Yes | Yes | P2 |
| RequestError | request_error.dart | Yes (generated) | No | P0 |
| AuthState | auth_state.dart | Freezed | Freezed | P0 |
| EnterOtpState | enter_otp_state.dart | Freezed | Freezed | P0 |
| PasskeyState | passkey_state.dart | Freezed | Freezed | P1 |
| BottomNavState | bottom_nav_state.dart | Freezed | Freezed | P1 |
| HelpCenterState | help_center_state.dart | Freezed | Freezed | P2 |

---

## Appendix B: Responsive Breakpoint Test Matrix

Window sizes required for responsive tests:

| Device Type | Orientation | Width | Height | Use For |
|-------------|------------|-------|--------|---------|
| Phone (Small) | Portrait | 375 | 667 | Mobile layouts |
| Phone (Small) | Landscape | 667 | 375 | Phone landscape (should stay mobile) |
| Tablet (Medium) | Portrait | 768 | 1024 | Tablet portrait (mobile fallback for native) |
| Tablet (Medium) | Landscape | 1024 | 768 | Tablet landscape (reading pane) |
| Desktop (Large) | N/A | 1440 | 900 | Desktop layouts (sidebar + reading pane) |
| Large Desktop | N/A | 1920 | 1080 | Extra-large desktop |
| Phone landscape edge | Landscape | 700 | 350 | Height < 500 → no reading pane |

Platform override for native tablet tests:
```dart
debugDefaultTargetPlatformOverride = TargetPlatform.iOS; // or .android
```

---

## Appendix C: Socket Event Test Matrix

Events to mock for socket integration tests:

| Event | Payload | Used By | Priority |
|-------|---------|---------|----------|
| unReadCount | {inbox, draft, trash, archive} | BottomNavNotifier, SideMenu, Drawer, InboxNotifier | P0 |
| notificationExists | bool | InboxNotifier, DraftNotifier, ArchiveNotifier | P1 |
| newMessage | email data | InboxNotifier (refresh) | P0 |
| trashMessage | email data | InboxNotifier (remove) | P1 |
| inboxMessage | email data | InboxNotifier (refresh) | P1 |
| draftMessage | email data | DraftNotifier (refresh) | P1 |
| tagList | tags data | TagsNotifier, InboxNotifier | P1 |
| msgOptInApp | opt-in data | InboxNotifier | P2 |
| paymentStatus | payment data | Navigation | P2 |
| addCardSuccess | card data | Navigation | P2 |

---

## Appendix D: Snackbar / Toast Message Validation Matrix

All snackbar and toast messages that should be validated in widget and integration tests. Each entry represents a user-facing feedback message triggered by a specific action or error condition. Tests should verify: correct message text, correct type (success/error/info/undo), auto-dismiss behavior, and undo callback where applicable.

### Error Messages

| ID | Trigger Context | Message Text | Type | Module | Priority |
|----|----------------|-------------|------|--------|----------|
| SNACK-E001 | Login with invalid username | "Invalid username" | Error | Auth | P0 |
| SNACK-E002 | Login with empty fields | "Please enter your username" | Error | Auth | P0 |
| SNACK-E003 | OTP verification fails | "Invalid OTP code" | Error | Auth | P0 |
| SNACK-E004 | OTP expired | "OTP has expired. Please request a new one" | Error | Auth | P0 |
| SNACK-E005 | Create account with existing email | "An account with this email already exists" | Error | Auth | P1 |
| SNACK-E006 | Create account validation fails | "Please fill in all required fields" | Error | Auth | P0 |
| SNACK-E007 | Password/username format invalid | "Username must be 3-30 characters" | Error | Auth | P1 |
| SNACK-E008 | Passkey setup fails | "Passkey setup failed. Please try again" | Error | Auth | P1 |
| SNACK-E009 | Network request fails | "No internet connection" | Error | Core | P0 |
| SNACK-E010 | API timeout | "Request timed out. Please try again" | Error | Core | P0 |
| SNACK-E011 | Session expired (401/405) | "Session expired. Please log in again" | Error | Core | P0 |
| SNACK-E012 | Compose with empty recipient | "Please add at least one recipient" | Error | Email | P0 |
| SNACK-E013 | Compose with invalid email recipient | "Invalid email address" | Error | Email | P0 |
| SNACK-E014 | Compose with empty subject | "Please enter a subject" | Error | Email | P1 |
| SNACK-E015 | Attachment upload fails | "Failed to upload attachment" | Error | Email | P1 |
| SNACK-E016 | Attachment exceeds size limit | "File size exceeds the maximum limit" | Error | Email | P1 |
| SNACK-E017 | Email send fails | "Failed to send email. Please try again" | Error | Email | P0 |
| SNACK-E018 | Draft save fails | "Failed to save draft" | Error | Email | P1 |
| SNACK-E019 | Email bounce — lapsed user | "Message could not be delivered. Recipient account has lapsed." | Error | Email | P1 |
| SNACK-E020 | Email bounce — inactive user | "Message could not be delivered. Recipient account is inactive." | Error | Email | P1 |
| SNACK-E021 | Email bounce — suspended user | "Message could not be delivered. Recipient account is suspended." | Error | Email | P1 |
| SNACK-E022 | Email bounce — deleted user | "Message could not be delivered. Recipient account no longer exists." | Error | Email | P1 |
| SNACK-E023 | Contact save validation fails | "Please enter a valid email address" | Error | Contacts | P0 |
| SNACK-E024 | Contact save API fails | "Failed to save contact" | Error | Contacts | P1 |
| SNACK-E025 | Contact delete fails | "Failed to delete contact" | Error | Contacts | P1 |
| SNACK-E026 | Device contact sync fails | "Failed to sync device contacts" | Error | Contacts | P1 |
| SNACK-E027 | Tag name exceeds 20 chars | "Tag name must be 20 characters or less" | Error | Tags | P1 |
| SNACK-E028 | Tag creation fails | "Failed to create tag" | Error | Tags | P1 |
| SNACK-E029 | Tag delete fails | "Failed to delete tag" | Error | Tags | P1 |
| SNACK-E030 | Profile save validation fails | "Please fill in all required fields" | Error | Settings | P0 |
| SNACK-E031 | Profile save API fails | "Failed to update profile" | Error | Settings | P1 |
| SNACK-E032 | Account delete fails | "Failed to delete account. Please try again" | Error | Settings | P1 |
| SNACK-E033 | Promo code invalid | "Invalid promo code" | Error | Subscription | P1 |
| SNACK-E034 | Promo code expired | "This promo code has expired" | Error | Subscription | P1 |
| SNACK-E035 | Promo code usage cap reached | "This promo code has reached its usage limit" | Error | Subscription | P1 |
| SNACK-E036 | Payment method declined | "Card was declined. Please try a different card" | Error | Subscription | P1 |
| SNACK-E037 | Subscription renewal fails | "Renewal failed. Please update your payment method" | Error | Subscription | P0 |
| SNACK-E038 | Payment method delete fails | "Cannot remove last payment method with active subscription" | Error | Subscription | P1 |
| SNACK-E039 | Checkout process fails | "Payment processing failed. Please try again" | Error | Subscription | P0 |
| SNACK-E040 | Notification delete fails | "Failed to delete notification" | Error | Notifications | P2 |
| SNACK-E041 | Move message fails | "Failed to move message" | Error | Email | P1 |
| SNACK-E042 | Print email fails | "Unable to print. Please check your printer connection" | Error | Email | P2 |
| SNACK-E043 | Search returns error | "Search failed. Please try again" | Error | Email | P1 |
| SNACK-E044 | Biometric auth fails | "Biometric authentication failed" | Error | Settings | P1 |
| SNACK-E045 | Forgot username — phone not found | "No account found with this phone number" | Error | Auth | P1 |
| SNACK-E046 | Login attempt — suspended account | "Your account has been suspended. Please contact support." | Error | Auth | P0 |
| SNACK-E047 | Login attempt — inactive account | "Your account is no longer active." | Error | Auth | P0 |
| SNACK-E048 | Login attempt — deleted account | "This account no longer exists." | Error | Auth | P0 |
| SNACK-E049 | Payment failed — subscription expiring | "Payment failed. Please update your payment method to avoid service interruption." | Error | Subscription | P0 |
| SNACK-E050 | Email bounce — grace period expired (lapsed) | "Message could not be delivered. Recipient's subscription has expired." | Error | Email | P1 |

### Success Messages

| ID | Trigger Context | Message Text | Type | Module | Priority |
|----|----------------|-------------|------|--------|----------|
| SNACK-S001 | Email sent successfully | "Email sent" | Success | Email | P0 |
| SNACK-S002 | Draft saved | "Draft saved" | Success | Email | P1 |
| SNACK-S003 | Email archived | "Email archived" | Undo | Email | P0 |
| SNACK-S004 | Email moved to trash | "Email moved to trash" | Undo | Email | P0 |
| SNACK-S005 | Email restored from trash | "Email restored to inbox" | Success | Email | P1 |
| SNACK-S006 | Email permanently deleted | "Email permanently deleted" | Success | Email | P1 |
| SNACK-S007 | Email moved to folder | "Email moved to [folder]" | Undo | Email | P1 |
| SNACK-S008 | Bulk emails archived | "[N] emails archived" | Undo | Email | P1 |
| SNACK-S009 | Bulk emails trashed | "[N] emails moved to trash" | Undo | Email | P1 |
| SNACK-S010 | Tag applied to email(s) | "Tag applied" | Success | Tags | P1 |
| SNACK-S011 | Tag removed from email(s) | "Tag removed" | Success | Tags | P1 |
| SNACK-S012 | Tag created | "Tag created" | Success | Tags | P1 |
| SNACK-S013 | Tag deleted | "Tag deleted" | Success | Tags | P1 |
| SNACK-S014 | Tag edited | "Tag updated" | Success | Tags | P1 |
| SNACK-S015 | Contact created | "Contact saved" | Success | Contacts | P0 |
| SNACK-S016 | Contact updated | "Contact updated" | Success | Contacts | P1 |
| SNACK-S017 | Contact deleted | "Contact deleted" | Success | Contacts | P1 |
| SNACK-S018 | Device contacts synced | "Contacts synced successfully" | Success | Contacts | P1 |
| SNACK-S019 | Profile updated | "Profile updated" | Success | Settings | P1 |
| SNACK-S020 | Notification toggle changed | "Notifications [enabled/disabled]" | Success | Settings | P1 |
| SNACK-S021 | Biometric toggle changed | "[Face ID/Touch ID] [enabled/disabled]" | Success | Settings | P1 |
| SNACK-S022 | Logout successful | "Logged out successfully" | Success | Settings | P1 |
| SNACK-S023 | Account deleted | "Account deleted" | Success | Settings | P0 |
| SNACK-S024 | Promo code applied | "Promo code applied — [X]% off" | Success | Subscription | P1 |
| SNACK-S025 | Payment method added | "Payment method added" | Success | Subscription | P1 |
| SNACK-S026 | Payment method removed | "Payment method removed" | Success | Subscription | P1 |
| SNACK-S027 | Subscription renewed | "Subscription renewed" | Success | Subscription | P1 |
| SNACK-S028 | Plan upgraded | "Plan upgraded to [Plan Name]" | Success | Subscription | P1 |
| SNACK-S029 | Plan downgraded | "Plan will downgrade to [Plan Name] at end of billing cycle" | Success | Subscription | P1 |
| SNACK-S030 | Notification deleted | "Notification deleted" | Success | Notifications | P2 |
| SNACK-S031 | Notification marked as read | "Marked as read" | Success | Notifications | P2 |
| SNACK-S032 | Opt-in contact saved | "Contact added" | Success | Email | P1 |
| SNACK-S033 | Opt-in contact skipped | "Skipped" | Info | Email | P2 |
| SNACK-S034 | All opt-in contacts skipped | "All skipped" | Info | Email | P2 |
| SNACK-S035 | Email printed | "Print job sent" | Success | Email | P2 |
| SNACK-S036 | Attachment downloaded | "Attachment downloaded" | Success | Email | P1 |
| SNACK-S037 | Email marked as read | "Marked as read" | Success | Email | P2 |
| SNACK-S038 | Email marked as unread | "Marked as unread" | Success | Email | P2 |
| SNACK-S039 | Password/passkey set up | "Passkey set up successfully" | Success | Auth | P1 |
| SNACK-S040 | Username recovered | "Username sent to your phone" | Success | Auth | P1 |
| SNACK-S041 | Email copied to clipboard | "Copied to clipboard" | Success | Core | P2 |
| SNACK-S044 | Default payment method updated | "Default payment method updated" | Success | Subscription | P1 |
| SNACK-S045 | Email forwarded | "Email forwarded" | Success | Email | P1 |
| SNACK-S046 | Subscription cancelled by user | "Your subscription has been cancelled. You will have access until [date]." | Info | Subscription | P0 |
| SNACK-S047 | Subscription expired — entering grace period | "Your subscription has expired. You have 7 days to renew." | Warning | Subscription | P0 |
| SNACK-S048 | Grace period daily reminder | "Your Subscription has expired. You have [X] days to purchase a new subscription before your account will be locked." | Warning | Subscription | P0 |
| SNACK-S049 | Account deleted confirmation | "Your account has been deleted." | Info | Settings | P0 |
| SNACK-S050 | Subscription renewal warning (cancelled user) | "Your subscription expires in [X] days. Renew now to maintain access." | Warning | Subscription | P1 |

### Widget Test Validation Notes
- **CustomToast widget:** All snackbar messages in this app use the `CustomToast` widget with type variants: `success`, `error`, `Undo`
- **Undo action verification (critical):** For every Undo-type toast (SNACK-S003, S004, S007, S008, S009), tests must verify:
  1. Undo button is rendered and tappable
  2. Tapping Undo calls the undo callback and **actually reverses the action** (e.g., email restored to original folder)
  3. Sidebar/drawer counts update correctly after undo (inbox/archive/trash counts revert)
  4. After undo, the restored item re-appears in the correct list with correct position/state
  5. Undo is only allowed once per action (second tap has no effect)
  6. After timeout expires, undo becomes unavailable and the action is permanent
- **Auto-dismiss:** All toasts should auto-dismiss after a set duration (typically 3-5 seconds)
- **Stacking:** When multiple actions trigger toasts in rapid succession, verify that toasts queue correctly (not overlapping)
- **Accessibility:** All messages should be announced by screen readers (semantics label)

---

## 25. User State Lifecycle Module

### Overview

This section covers all user states as defined in the OptMsg User States specification document. The system recognizes 7 distinct user states: **Active**, **Cancelled**, **Suspended**, **Grace Period (Day 1-7)**, **Lapsed (Day 8-30)**, **Inactive**, and **Deleted**. Each state has specific behaviors for login access, messaging, Descope authentication state, Stripe subscription state, and in-app/push notifications. Tests in this section verify correct state transitions, notification delivery, and cross-system consistency (OptMsg, Descope, Stripe).

### Current Coverage Status
- **Existing tests:** Partial — bounced message tests (EMAIL-U102-U108), subscription renewal (SUB-U007-U009), E2E account cancel/grace/lapsed (E2E-060-063)
- **Gaps:** Major — no dedicated state lifecycle tests, no notification type tests, no Descope/Stripe state sync tests, no admin action tests

### 25.1 User State Definition Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U001 | UserState/Active | should identify Active user state correctly | Verify Active state attributes | User with status=Active, subscription=Active, renewal=Auto-renew | isActive=true, canLogin=true, canSendMessages=true, canReceiveMessages=true | P0 | No |
| UST-U002 | UserState/Cancelled | should identify Cancelled user state correctly | Verify Cancelled state attributes | User with status=Active, subscription=Active, renewal=None (cancelled) | isCancelled=true, canLogin=true, canSendMessages=true until subscription end | P0 | No |
| UST-U003 | UserState/Suspended | should identify Suspended user state correctly | Verify Suspended state attributes | User with status=Suspended | isSuspended=true, canLogin=false, canSendMessages=false, canReceiveMessages=false | P0 | No |
| UST-U004 | UserState/GracePeriod | should identify Grace Period user state correctly | Verify Grace Period state attributes | User with status=GracePeriod, subscription=None | isGracePeriod=true, canLogin=true, canSendMessages=true, canReceiveMessages=true | P0 | No |
| UST-U005 | UserState/Lapsed | should identify Lapsed user state correctly | Verify Lapsed state attributes | User with status=Lapsed, subscription=None, day 8-30 | isLapsed=true, canLogin=false (app), canLoginWeb=true (plan page only), canSendMessages=false | P0 | No |
| UST-U006 | UserState/Inactive | should identify Inactive user state correctly | Verify Inactive state attributes | User with status=Inactive, soft-deleted | isInactive=true, canLogin=false, canSendMessages=false, isRecoverable=false | P0 | No |
| UST-U007 | UserState/Deleted | should identify Deleted user state correctly | Verify Deleted state attributes | User with status=Deleted, soft-deleted | isDeleted=true, canLogin=false, canSendMessages=false, isRecoverable=false | P0 | No |

### 25.2 State Transition Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U008 | UserState/Transition | should transition from new customer to Active on subscription success | Verify new→Active | New customer completes Stripe checkout | User status=Active, Descope status=Active, Stripe subscription=Active with auto-renew | P0 | No |
| UST-U009 | UserState/Transition | should transition from Active to Cancelled when user cancels subscription | Verify Active→Cancelled | Active user cancels via Settings→Account→Billing→Cancel Subscription (web only) | User status remains Active until subscription end, Stripe renewal=None | P0 | No |
| UST-U010 | UserState/Transition | should transition from Cancelled to Grace Period when subscription expires | Verify Cancelled→Grace | Cancelled user's subscription period ends | User status=GracePeriod, 7-day countdown begins, Stripe subscription=None | P0 | No |
| UST-U011 | UserState/Transition | should transition from Active to Grace Period on payment failure | Verify Active→Grace (payment fail) | Active user's auto-renewal payment fails | User status=GracePeriod, Stripe subscription=None | P0 | No |
| UST-U012 | UserState/Transition | should transition from Grace Period to Lapsed after 7 days without renewal | Verify Grace→Lapsed | Grace Period day 7 expires, no payment update | User status=Lapsed, messages bounce, app login blocked | P0 | No |
| UST-U013 | UserState/Transition | should transition from Lapsed to Inactive after day 30 without renewal | Verify Lapsed→Inactive | Lapsed Period day 30 expires, no payment update | User status=Inactive, soft delete, contacts deleted, Descope deactivated, sessions force-closed | P0 | No |
| UST-U014 | UserState/Transition | should transition from Grace Period to Active on payment update | Verify Grace→Active | Grace Period user updates Stripe payment | User status=Active, subscription renewed | P0 | No |
| UST-U015 | UserState/Transition | should transition from Lapsed to Active on payment update | Verify Lapsed→Active | Lapsed user updates Stripe payment via web | User status=Active, subscription renewed | P0 | No |
| UST-U016 | UserState/Transition | should transition from Cancelled to Active on payment update | Verify Cancelled→Active | Cancelled user resubscribes before subscription end | User status=Active, Stripe renewal=Auto-renew restored | P0 | No |
| UST-U017 | UserState/Transition | should transition from Active to Suspended via admin panel | Verify Active→Suspended | Admin toggles user to Suspended in Admin Panel→Manage Users→User List | User status=Suspended, Descope deactivated, sessions force-closed, Stripe unchanged | P0 | No |
| UST-U018 | UserState/Transition | should transition from Suspended to Active via admin panel | Verify Suspended→Active | Admin toggles user back to Active in Admin Panel | User status=Active, Descope reactivated, Stripe unchanged | P0 | No |
| UST-U019 | UserState/Transition | should transition to Deleted on user-initiated delete | Verify Any→Deleted (user) | User deletes account via Settings→Account→Delete Account (web or app) | User status=Deleted, immediate logout, Descope deactivated, sessions force-closed, Stripe subscription cancelled | P0 | No |
| UST-U020 | UserState/Transition | should transition to Deleted on admin-initiated delete | Verify Any→Deleted (admin) | Admin deletes user via Admin Panel→Manage User→User List | User status=Deleted, same effects as user-initiated delete | P0 | No |
| UST-U021 | UserState/Transition | should transition Active to Active on auto-renewal success | Verify Active→Active (renewal) | Active user's subscription auto-renews successfully | User status remains Active, new expiration date set | P0 | No |
| UST-U022 | UserState/Transition | should transition Cancelled users to Cancelled when admin cancels all subscribers to a plan | Verify bulk cancel | Admin retires plan via Admin Panel→Plan Subscription→List→Cancel all Users Subscription | All subscribers to that plan move to Cancelled state, Stripe renewal=None | P1 | No |

### 25.3 Notification Tests per State Transition (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U023 | UserState/Notification | should send SUBSCRIPTION SUCCESS notification on new customer signup | Verify new customer notification | New customer completes subscription checkout | In-app notification type=SUBSCRIPTION SUCCESS sent to user | P0 | No |
| UST-U024 | UserState/Notification | should send SUBSCRIPTION SUCCESS push notification on new customer signup | Verify new customer push | New customer completes subscription checkout | Push notification delivered to user's device | P0 | No |
| UST-U025 | UserState/Notification | should send SUBSCRIPTION RENEWED notification on Grace→Active transition | Verify renewal notification (Grace) | Grace Period user updates payment | In-app notification type=SUBSCRIPTION RENEWED sent | P0 | No |
| UST-U026 | UserState/Notification | should send SUBSCRIPTION RENEWED push notification on Grace→Active | Verify renewal push (Grace) | Grace Period user updates payment | Push notification delivered | P0 | No |
| UST-U027 | UserState/Notification | should send SUBSCRIPTION RENEWED notification on Lapsed→Active transition | Verify renewal notification (Lapsed) | Lapsed user updates payment | In-app notification type=SUBSCRIPTION RENEWED sent | P0 | No |
| UST-U028 | UserState/Notification | should send SUBSCRIPTION RENEWED push notification on Lapsed→Active | Verify renewal push (Lapsed) | Lapsed user updates payment | Push notification delivered | P0 | No |
| UST-U029 | UserState/Notification | should send SUBSCRIPTION RENEWED notification on Cancelled→Active transition | Verify renewal notification (Cancelled) | Cancelled user resubscribes | In-app notification type=SUBSCRIPTION RENEWED sent | P0 | No |
| UST-U030 | UserState/Notification | should send SUBSCRIPTION RENEWED push notification on Cancelled→Active | Verify renewal push (Cancelled) | Cancelled user resubscribes | Push notification delivered | P0 | No |
| UST-U031 | UserState/Notification | should send SUBSCRIPTION RENEWED notification on auto-renewal | Verify auto-renewal notification | Active user's subscription auto-renews | In-app notification type=SUBSCRIPTION RENEWED sent | P1 | No |
| UST-U032 | UserState/Notification | should send SUBSCRIPTION RENEWED push notification on auto-renewal | Verify auto-renewal push | Active user's subscription auto-renews | Push notification delivered | P1 | No |
| UST-U033 | UserState/Notification | should send SUBSCRIPTION CANCEL notification when user cancels | Verify cancel notification (user) | User cancels via Settings→Account→Billing→Cancel Subscription | In-app notification type=SUBSCRIPTION CANCEL sent | P0 | No |
| UST-U034 | UserState/Notification | should send SUBSCRIPTION CANCEL push notification when user cancels | Verify cancel push (user) | User cancels subscription | Push notification delivered | P0 | No |
| UST-U035 | UserState/Notification | should send SUBSCRIPTION CANCEL notification when admin cancels all plan subscribers | Verify cancel notification (admin bulk) | Admin retires plan, cancels all subscribers | In-app notification type=SUBSCRIPTION CANCEL sent to each affected user | P1 | No |
| UST-U036 | UserState/Notification | should send SUBSCRIPTION CANCEL push notification when admin cancels all plan subscribers | Verify cancel push (admin bulk) | Admin cancels all subscribers to a plan | Push notification delivered to each affected user | P1 | No |
| UST-U037 | UserState/Notification | should send SUBSCRIPTION RENEWAL WARNING notifications on approach to subscription end for Cancelled user | Verify renewal warning (Cancelled) | Cancelled user approaching subscription end (5th, 4th, 3rd, 2nd, and day of expiration) | In-app notification type=SUBSCRIPTION RENEWAL WARNING sent on each countdown day | P0 | No |
| UST-U038 | UserState/Notification | should send SUBSCRIPTION RENEWAL WARNING push notifications on countdown days | Verify renewal warning push | Cancelled user approaching subscription end | Push notification delivered on 5th, 4th, 3rd, 2nd, and day of expiration | P0 | No |
| UST-U039 | UserState/Notification | should send PAYMENT FAILED notification when payment fails triggering Grace Period | Verify payment failed notification | Active user's payment fails | In-app notification type=PAYMENT FAILED sent | P0 | No |
| UST-U040 | UserState/Notification | should send PAYMENT FAILED push notification | Verify payment failed push | Active user's payment fails | Push notification delivered | P0 | No |
| UST-U041 | UserState/Notification | should send SUBSCRIPTION EXPIRED notification when subscription ends triggering Grace Period | Verify expired notification | Subscription period ends (either via payment fail or cancelled user's period ending) | In-app notification type=SUBSCRIPTION EXPIRED sent | P0 | No |
| UST-U042 | UserState/Notification | should send SUBSCRIPTION EXPIRED push notification | Verify expired push | Subscription period ends | Push notification delivered | P0 | No |
| UST-U043 | UserState/Notification | should send daily GRACE PERIOD notification during Grace Period | Verify daily grace notification | User in Grace Period (Day 1-7) | Daily in-app notification type=GRACE PERIOD sent with message: "Your Subscription has expired. You have XX days to purchase a new subscription before your account will be locked and you can no longer send, receive, or access your messages." | P0 | No |
| UST-U044 | UserState/Notification | should send daily GRACE PERIOD push notification during Grace Period | Verify daily grace push | User in Grace Period | Daily push notification with countdown message delivered | P0 | No |
| UST-U045 | UserState/Notification | should NOT send notification when admin suspends user | Verify no suspend notification | Admin suspends user | No in-app notification sent, no push notification | P1 | No |
| UST-U046 | UserState/Notification | should NOT send notification when admin moves Suspended to Active | Verify no unsuspend notification | Admin reactivates suspended user | No in-app notification sent | P1 | No |
| UST-U047 | UserState/Notification | should NOT send notification when Lapsed transitions to Inactive | Verify no inactive notification | Lapsed period expires | No notification sent to user | P1 | No |
| UST-U048 | UserState/Notification | should NOT send notification on user or admin delete | Verify no delete notification | User or admin deletes account | No notification sent | P1 | No |

### 25.4 Descope Integration Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U049 | UserState/Descope | should set Descope user status to Active for Active user | Verify Descope Active sync | User status=Active | Descope User Exists=True, User Status=Active | P0 | No |
| UST-U050 | UserState/Descope | should keep Descope user status Active for Cancelled user | Verify Descope Cancelled sync | User status=Cancelled (still has active subscription) | Descope User Exists=True, User Status=Active | P0 | No |
| UST-U051 | UserState/Descope | should set Descope user status to Deactivated for Suspended user | Verify Descope Suspended sync | User status=Suspended | Descope User Exists=True, User Status=Deactivated | P0 | No |
| UST-U052 | UserState/Descope | should force close all Descope sessions on Suspend | Verify session force-close (Suspend) | User transitions to Suspended | All active Descope sessions terminated | P0 | No |
| UST-U053 | UserState/Descope | should keep Descope user status Active for Grace Period user | Verify Descope Grace sync | User status=Grace Period | Descope User Exists=True, User Status=Active | P0 | No |
| UST-U054 | UserState/Descope | should keep Descope user status Active for Lapsed user | Verify Descope Lapsed sync | User status=Lapsed | Descope User Exists=True, User Status=Active | P1 | No |
| UST-U055 | UserState/Descope | should set Descope user status to Deactivated for Inactive user | Verify Descope Inactive sync | User status=Inactive | Descope User Exists=True, User Status=Deactivated | P0 | No |
| UST-U056 | UserState/Descope | should force close all Descope sessions on Inactive transition | Verify session force-close (Inactive) | User transitions to Inactive | All active Descope sessions terminated | P0 | No |
| UST-U057 | UserState/Descope | should set Descope user status to Deactivated for Deleted user | Verify Descope Deleted sync | User status=Deleted | Descope User Exists=True, User Status=Deactivated | P0 | No |
| UST-U058 | UserState/Descope | should force close all Descope sessions on Delete | Verify session force-close (Delete) | User transitions to Deleted | All active Descope sessions terminated | P0 | No |

### 25.5 Stripe State Sync Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U059 | UserState/Stripe | should have active subscription with auto-renew for Active user | Verify Stripe Active state | User status=Active | Stripe: Customer Record Exists, Subscription=Active, Renewal=Auto-renew | P0 | No |
| UST-U060 | UserState/Stripe | should have active subscription with no renewal for Cancelled user | Verify Stripe Cancelled state | User status=Cancelled | Stripe: Customer Record Exists, Subscription=Active, Renewal=None | P0 | No |
| UST-U061 | UserState/Stripe | should not change Stripe subscription on Suspend | Verify Stripe unchanged on Suspend | User transitions to Suspended | Stripe: subscription and renewal unchanged from prior state | P0 | No |
| UST-U062 | UserState/Stripe | should have no subscription for Grace Period user | Verify Stripe Grace state | User status=Grace Period | Stripe: Customer Record Exists, Subscription=None, Renewal=None | P0 | No |
| UST-U063 | UserState/Stripe | should have no subscription for Lapsed user | Verify Stripe Lapsed state | User status=Lapsed | Stripe: Customer Record Exists, Subscription=None, Renewal=None | P0 | No |
| UST-U064 | UserState/Stripe | should have no subscription for Inactive user | Verify Stripe Inactive state | User status=Inactive | Stripe: Customer Record Exists, Subscription=None, Renewal=None | P1 | No |
| UST-U065 | UserState/Stripe | should have no subscription for Deleted user | Verify Stripe Deleted state | User status=Deleted | Stripe: Customer Record Exists, Subscription=None, Renewal=None | P1 | No |
| UST-U066 | UserState/Stripe | should set user to Deleted on Stripe/CC-initiated fraud refund | Verify fraud refund → Deleted | Stripe initiates refund due to fraud/bank contest | User status=Deleted | P0 | Yes |
| UST-U067 | UserState/Stripe | should not change user status on OptMsg-issued refund | Verify OptMsg refund → no change | Admin issues refund via admin panel | User status unchanged | P1 | No |
| UST-U068 | UserState/Stripe | should set user to Inactive on Stripe immediate subscription cancel | Verify Stripe immediate cancel → Inactive | Stripe console: Cancel Subscription (immediate) | User status=Inactive | P0 | Yes |
| UST-U069 | UserState/Stripe | should set user to Cancelled on Stripe end-of-term subscription cancel | Verify Stripe end-of-term cancel → Cancelled | Stripe console: Cancel Subscription (end of term) | User status=Cancelled | P0 | Yes |

### 25.6 Login Behavior Tests per State (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U070 | UserState/Login | should allow web login for Active user | Verify Active web login | User status=Active | Login succeeds, navigates to inbox | P0 | No |
| UST-U071 | UserState/Login | should allow app login for Active user | Verify Active app login | User status=Active | Login succeeds, navigates to inbox | P0 | No |
| UST-U072 | UserState/Login | should allow web login for Cancelled user during subscription period | Verify Cancelled web login | User status=Cancelled, subscription still active | Login succeeds, normal access | P0 | No |
| UST-U073 | UserState/Login | should allow app login for Cancelled user during subscription period | Verify Cancelled app login | User status=Cancelled, subscription still active | Login succeeds, normal access | P0 | No |
| UST-U074 | UserState/Login | should block web login for Suspended user | Verify Suspended web login blocked | User status=Suspended | Login rejected, access denied | P0 | No |
| UST-U075 | UserState/Login | should block app login for Suspended user | Verify Suspended app login blocked | User status=Suspended | Login rejected, access denied | P0 | No |
| UST-U076 | UserState/Login | should allow web login for Grace Period user | Verify Grace web login | User status=Grace Period | Login succeeds, renewal prompt shown | P0 | No |
| UST-U077 | UserState/Login | should allow app login for Grace Period user | Verify Grace app login | User status=Grace Period | Login succeeds, renewal prompt shown | P0 | No |
| UST-U078 | UserState/Login | should show choose-a-plan page on web login for Lapsed user | Verify Lapsed web login | User status=Lapsed | Login succeeds but user shown plan selection page, cannot proceed to inbox | P0 | No |
| UST-U079 | UserState/Login | should show web-redirect page on app login for Lapsed user | Verify Lapsed app login | User status=Lapsed | App presents page notifying user to login via web to update subscription, with link that opens browser | P0 | No |
| UST-U080 | UserState/Login | should block web login for Inactive user | Verify Inactive web login blocked | User status=Inactive | Login rejected, user immediately logged out | P0 | No |
| UST-U081 | UserState/Login | should block app login for Inactive user | Verify Inactive app login blocked | User status=Inactive | Login rejected, user immediately logged out | P0 | No |
| UST-U082 | UserState/Login | should block web login for Deleted user | Verify Deleted web login blocked | User status=Deleted | Login rejected, user immediately logged out | P0 | No |
| UST-U083 | UserState/Login | should block app login for Deleted user | Verify Deleted app login blocked | User status=Deleted | Login rejected, user immediately logged out | P0 | No |

### 25.7 Message Bounce Tests per State (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U084 | UserState/Bounce | should NOT bounce messages for Active user | Verify Active no bounce | Message sent to Active user | Message delivered successfully | P0 | No |
| UST-U085 | UserState/Bounce | should NOT bounce messages for Cancelled user during subscription period | Verify Cancelled no bounce | Message sent to Cancelled user with active subscription | Message delivered successfully | P0 | No |
| UST-U086 | UserState/Bounce | should bounce messages for Suspended user with account-inactive error | Verify Suspended bounce | Message sent to Suspended user | Bounce message returned indicating account is no longer active | P0 | No |
| UST-U087 | UserState/Bounce | should NOT bounce messages for Grace Period user | Verify Grace no bounce | Message sent to Grace Period user | Message delivered successfully | P0 | No |
| UST-U088 | UserState/Bounce | should bounce messages for Lapsed user with account-invalid error | Verify Lapsed bounce | Message sent to Lapsed user | Bounce message returned indicating user is not valid | P0 | No |
| UST-U089 | UserState/Bounce | should bounce messages for Inactive user | Verify Inactive bounce | Message sent to Inactive user | Bounce message returned indicating account is no longer active | P0 | No |
| UST-U090 | UserState/Bounce | should bounce messages for Deleted user | Verify Deleted bounce | Message sent to Deleted user | Bounce message returned indicating account no longer exists | P0 | No |

### 25.8 Suspended User Specific Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U091 | UserState/Suspended | should NOT auto-delete Suspended user after 30 days | Verify no auto-delete | User status=Suspended for 30+ days | User remains Suspended, NOT transitioned to Deleted or Inactive | P0 | Yes |
| UST-U092 | UserState/Suspended | should preserve Stripe subscription state during suspension | Verify Stripe unchanged | Active subscription user gets suspended | Stripe subscription and renewal state unchanged | P0 | No |
| UST-U093 | UserState/Suspended | should allow admin to toggle Suspended back to Active | Verify admin unsuspend | Suspended user, admin toggles Active | User status=Active, Descope reactivated, can login again | P0 | No |

### 25.9 Inactive User Specific Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U094 | UserState/Inactive | should perform soft delete retaining messages and attachments | Verify soft delete scope | User transitions to Inactive | User contacts deleted from database, messages/attachments in DB and S3 NOT removed | P0 | No |
| UST-U095 | UserState/Inactive | should NOT allow user recovery of Inactive account | Verify no user recovery | Inactive user attempts to login or resubscribe | Account cannot be recovered, login blocked | P0 | No |
| UST-U096 | UserState/Inactive | should NOT allow admin recovery of Inactive account | Verify no admin recovery | Admin attempts to reactivate Inactive user | Account cannot be recovered by administrator | P0 | No |

### 25.10 Deleted User Specific Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U097 | UserState/Deleted | should perform soft delete retaining messages and attachments | Verify soft delete scope | User transitions to Deleted | User contacts deleted from database, messages/attachments in DB and S3 NOT removed | P0 | No |
| UST-U098 | UserState/Deleted | should require confirmation popup before user-initiated delete | Verify delete confirmation | User taps Delete Account | Confirmation popup appears requiring acknowledgment | P0 | No |
| UST-U099 | UserState/Deleted | should display acknowledgment that user data becomes inaccessible | Verify data loss warning | Delete confirmation popup shown | Popup states user will be unable to access all information (emails, contacts, etc.) | P0 | No |
| UST-U100 | UserState/Deleted | should display acknowledgment that unused subscription payment is forfeited | Verify payment forfeiture warning | Delete confirmation popup shown | Popup states unused subscription payment is forfeited | P0 | No |
| UST-U101 | UserState/Deleted | should cancel Stripe subscription immediately on delete | Verify Stripe cancel on delete | User or admin deletes account | Stripe subscription cancelled, renewal removed | P0 | No |

### 25.11 Admin Panel Action Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U102 | UserState/Admin | should allow admin to suspend an Active user | Verify admin suspend | Admin Panel→Manage Users→User List, select Active user | User status=Suspended, Descope deactivated, sessions force-closed | P0 | No |
| UST-U103 | UserState/Admin | should allow admin to reactivate a Suspended user | Verify admin reactivate | Admin Panel→Manage Users→User List, select Suspended user | User status=Active, Descope reactivated | P0 | No |
| UST-U104 | UserState/Admin | should allow admin to delete a user | Verify admin delete | Admin Panel→Manage User→User List, select user for deletion | User status=Deleted, soft delete performed | P0 | No |
| UST-U105 | UserState/Admin | should allow admin to cancel all subscribers to a plan | Verify admin bulk cancel | Admin Panel→Plan Subscription→List→Cancel all Users Subscription | All subscribers to that plan status=Cancelled, each receives SUBSCRIPTION CANCEL notification | P1 | No |
| UST-U106 | UserState/Admin | should allow admin to cancel individual user subscription | Verify admin single cancel | Admin cancels specific user's subscription | User status=Cancelled, notification sent | P1 | No |
| UST-U107 | UserState/Admin | should allow admin to issue refund (partial or full) | Verify admin refund | Admin Panel→User Detail→Refund→Select partial/full | Refund initiated via Stripe, user subscription cancelled, user treated as unsubscribed | P1 | No |
| UST-U108 | UserState/Admin | should remove action buttons for Deleted/Inactive users in admin panel | Verify admin UI cleanup | Admin views Deleted or Inactive user in User List | No action buttons shown for these users | P1 | No |
| UST-U109 | UserState/Admin | should allow admin to toggle user role to Admin | Verify admin role toggle | Admin Panel→User List→Mark as Admin | User role updated in OptMsg and Descope, subscription check bypassed for admin users | P1 | No |

### 25.12 Cancelled User Subscription Renewal Warning Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U110 | UserState/RenewalWarning | should send SUBSCRIPTION RENEWAL WARNING on 5th day before subscription end | Verify 5-day warning | Cancelled user, 5 days until subscription expires | SUBSCRIPTION RENEWAL WARNING notification + push sent | P0 | No |
| UST-U111 | UserState/RenewalWarning | should send SUBSCRIPTION RENEWAL WARNING on 4th day before subscription end | Verify 4-day warning | Cancelled user, 4 days until subscription expires | SUBSCRIPTION RENEWAL WARNING notification + push sent | P1 | No |
| UST-U112 | UserState/RenewalWarning | should send SUBSCRIPTION RENEWAL WARNING on 3rd day before subscription end | Verify 3-day warning | Cancelled user, 3 days until subscription expires | SUBSCRIPTION RENEWAL WARNING notification + push sent | P1 | No |
| UST-U113 | UserState/RenewalWarning | should send SUBSCRIPTION RENEWAL WARNING on 2nd day before subscription end | Verify 2-day warning | Cancelled user, 2 days until subscription expires | SUBSCRIPTION RENEWAL WARNING notification + push sent | P1 | No |
| UST-U114 | UserState/RenewalWarning | should send SUBSCRIPTION RENEWAL WARNING on day of subscription expiration | Verify expiration day warning | Cancelled user, subscription expires today | SUBSCRIPTION RENEWAL WARNING notification + push sent | P0 | No |

### 25.13 Grace Period Daily Notification Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| UST-U115 | UserState/GraceNotification | should send GRACE PERIOD notification on day 1 of grace period | Verify day 1 grace notification | User in Grace Period, day 1 | GRACE PERIOD notification sent with "You have 7 days to purchase a new subscription" | P0 | No |
| UST-U116 | UserState/GraceNotification | should send GRACE PERIOD notification on day 7 (final day) of grace period | Verify day 7 grace notification | User in Grace Period, day 7 | GRACE PERIOD notification sent with "You have 1 day to purchase a new subscription" | P0 | Yes |
| UST-U117 | UserState/GraceNotification | should include correct countdown in GRACE PERIOD notification message | Verify countdown accuracy | User in Grace Period, day 3 | Message includes "You have 5 days to purchase a new subscription before your account will be locked and you can no longer send, receive, or access your messages." | P0 | No |
| UST-U118 | UserState/GraceNotification | should send GRACE PERIOD push notification daily | Verify daily push | Each day of Grace Period | Push notification delivered daily with countdown | P0 | No |
| UST-U119 | UserState/GraceNotification | should stop GRACE PERIOD notifications after user renews subscription | Verify notification stop on renewal | Grace Period user renews on day 3 | No more GRACE PERIOD notifications sent after renewal | P1 | No |

### 25.14 User State Lifecycle E2E Tests

| ID | Feature/Module | Test Case | Description | Steps | Preconditions | Expected Outcome | Platform | Screen Size | Orientation | Priority |
|----|----------------|-----------|-------------|-------|---------------|------------------|----------|-------------|-------------|----------|
| E2E-064 | UserState/SuspendReactivate | should suspend and reactivate a user via admin panel | Admin suspend/reactivate | Admin suspends user → User attempts login (fails) → Admin reactivates → User logs in successfully | Admin account, target Active user | Suspend blocks login; reactivate restores access; Stripe unchanged throughout | All | All | Both | P0 |
| E2E-065 | UserState/GraceRenewal | should complete renewal during grace period and restore active status | Grace period renewal | Subscription expires → Login during grace period → Navigate to subscription → Complete payment → Verify Active status | User with expired subscription within 7 days | User can login, renewal prompt shown, payment completes, status=Active, SUBSCRIPTION RENEWED notification received | All | All | Both | P0 |
| E2E-066 | UserState/LapsedWebLogin | should show plan selection page for Lapsed user on web login | Lapsed web login | Login as Lapsed user on web → Verify plan page shown → Cannot access inbox | User expired 8+ days ago | Web login succeeds but redirects to plan selection, inbox inaccessible until plan purchased | Web | All | Both | P0 |
| E2E-067 | UserState/LapsedAppLogin | should show web-redirect page for Lapsed user on app login | Lapsed app login | Login as Lapsed user on app → Verify redirect message shown → Tap link opens browser | User expired 8+ days ago | App shows message to login via web and update subscription, link opens browser to web app | iOS, Android | All | Both | P0 |
| E2E-068 | UserState/DeleteWithConfirm | should delete account with confirmation popup acknowledgments | Account deletion | Login → Settings → Account → Delete Account → Read confirmation → Acknowledge data loss → Acknowledge payment forfeiture → Confirm | Authenticated, active subscription | Confirmation popup shown with two acknowledgments, account deleted, logged out immediately, subscription cancelled | All | All | Both | P0 |
| E2E-069 | UserState/InactiveNoRecovery | should prevent login and recovery for Inactive user | Inactive user blocked | Attempt login as Inactive user on web → Verify blocked; Attempt login on app → Verify blocked | User status=Inactive (30+ days past lapsed) | Login blocked on both platforms, no recovery option presented, account permanently inaccessible | All | All | Both | P0 |
| E2E-070 | UserState/CancelledNotifications | should receive SUBSCRIPTION CANCEL and RENEWAL WARNING notifications for cancelled user | Cancelled user notifications | Cancel subscription → Verify SUBSCRIPTION CANCEL notification → Wait until 5 days before expiry → Verify RENEWAL WARNING notifications on countdown days | Authenticated, active subscription | SUBSCRIPTION CANCEL notification received immediately; RENEWAL WARNING notifications received on 5th, 4th, 3rd, 2nd, and day of expiration | All | All | Both | P1 |
| E2E-071 | UserState/PaymentFailGrace | should transition to Grace Period on payment failure with proper notifications | Payment failure flow | Active user's payment fails → Verify PAYMENT FAILED notification → Verify SUBSCRIPTION EXPIRED notification → Verify daily GRACE PERIOD notifications | Authenticated, subscription with failing payment method | PAYMENT FAILED and SUBSCRIPTION EXPIRED notifications received, daily GRACE PERIOD notifications with countdown during 7-day period | All | All | Both | P0 |

### 25.15 Widget Tests for User State UI

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| UST-W001 | UserState/GraceBanner | should display grace period renewal banner on login | Verify grace banner | DashboardScreen/InboxScreen | User status=Grace Period | None | Banner shown prompting subscription renewal with days remaining | All | All | Both | P0 | No |
| UST-W002 | UserState/GraceBanner | should navigate to subscription page from grace banner | Verify grace banner tap | DashboardScreen/InboxScreen | Grace period banner visible | Tap banner/renew button | Navigation to Settings→Account→Subscription on web | All | All | Both | P0 | No |
| UST-W003 | UserState/LapsedPlanPage | should render plan selection page for Lapsed user on web | Verify lapsed plan page | PlanSelectionScreen | User status=Lapsed, web login | None | Plan cards visible, no inbox access, subscription required to proceed | Web | All | Both | P0 | No |
| UST-W004 | UserState/LapsedAppRedirect | should render web-redirect message for Lapsed user on app | Verify lapsed app redirect | LapsedRedirectScreen | User status=Lapsed, app login | None | Message displayed: "Please login via web to update your subscription", link/button to open browser | iOS, Android | All | Both | P0 | No |
| UST-W005 | UserState/LapsedAppRedirect | should open browser when web link tapped on Lapsed app redirect | Verify browser open | LapsedRedirectScreen | Lapsed redirect shown | Tap web link | Browser opens to OptMsg web app | iOS, Android | All | Both | P0 | No |
| UST-W006 | UserState/DeleteConfirmPopup | should render delete confirmation popup with two acknowledgments | Verify delete popup | DeleteAccountConfirmation | User taps Delete Account | None | Popup with checkboxes/acknowledgments: (a) data inaccessibility, (b) payment forfeiture | All | All | Both | P0 | No |
| UST-W007 | UserState/DeleteConfirmPopup | should disable confirm button until both acknowledgments checked | Verify confirm guard | DeleteAccountConfirmation | Popup shown, neither checkbox checked | None | Confirm/Delete button disabled | All | All | Both | P0 | No |
| UST-W008 | UserState/DeleteConfirmPopup | should enable confirm button when both acknowledgments checked | Verify confirm enabled | DeleteAccountConfirmation | Popup shown | Check both acknowledgment checkboxes | Confirm/Delete button becomes enabled | All | All | Both | P0 | No |
| UST-W009 | UserState/CancelledBanner | should display subscription expiration warning banner for Cancelled user | Verify cancel banner | AccountScreen/SettingsScreen | User status=Cancelled, subscription ending soon | None | Banner shows subscription end date and option to resubscribe | All | All | Both | P1 | No |
| UST-W010 | UserState/SuspendedMessage | should display account suspended message on login attempt | Verify suspended message | LoginScreen/ErrorScreen | User status=Suspended, login attempted | None | Error message indicating account is suspended, contact admin | All | All | Both | P0 | No |

---

## Appendix E: User State Reference Matrix

This appendix provides a quick-reference matrix of all user states cross-referenced with system states (OptMsg, Descope, Stripe) and behavioral attributes (login, messaging, notifications).

### State-System Matrix

| User State | OptMsg Status | Descope Exists | Descope Status | Stripe Customer | Stripe Subscription | Stripe Renewal | Can Login Web | Can Login App | Can Send | Can Receive | Messages Bounce | Recoverable |
|------------|-------------|----------------|----------------|-----------------|---------------------|----------------|--------------|---------------|----------|-------------|-----------------|-------------|
| Active | Active | True | Active | Exists | Active | Auto-renew | Yes | Yes | Yes | Yes | No | N/A |
| Cancelled | Active | True | Active | Exists | Active | None | Yes | Yes | Yes | Yes | No | Yes (resubscribe) |
| Suspended | Suspended | True | Deactivated | Exists | No Change | No Change | No | No | No | No | Yes | Yes (admin only) |
| Grace Period (Day 1-7) | Grace Period | True | Active | Exists | None | None | Yes | Yes | Yes | Yes | No | Yes (payment) |
| Lapsed (Day 8-30) | Lapsed | True | Active | Exists | None | None | Plan page only | Redirect to web | No | No | Yes | Yes (payment) |
| Inactive | Inactive | True | Deactivated | Exists | None | None | No | No | No | No | Yes | No |
| Deleted | Deleted | True | Deactivated | Exists | None | None | No | No | No | No | N/A | No |

### Notification Matrix

| Trigger | Notification Type | Push Notification | Target State |
|---------|-------------------|-------------------|--------------|
| New customer signup | SUBSCRIPTION SUCCESS | Yes | Active |
| Grace→Active payment | SUBSCRIPTION RENEWED | Yes | Active |
| Lapsed→Active payment | SUBSCRIPTION RENEWED | Yes | Active |
| Cancelled→Active resubscribe | SUBSCRIPTION RENEWED | Yes | Active |
| Auto-renewal success | SUBSCRIPTION RENEWED | Yes | Active |
| User cancels subscription | SUBSCRIPTION CANCEL | Yes | Cancelled |
| Admin cancels all plan subscribers | SUBSCRIPTION CANCEL | Yes | Cancelled |
| Cancelled user 5 days before expiry | SUBSCRIPTION RENEWAL WARNING | Yes | Cancelled |
| Cancelled user 4 days before expiry | SUBSCRIPTION RENEWAL WARNING | Yes | Cancelled |
| Cancelled user 3 days before expiry | SUBSCRIPTION RENEWAL WARNING | Yes | Cancelled |
| Cancelled user 2 days before expiry | SUBSCRIPTION RENEWAL WARNING | Yes | Cancelled |
| Cancelled user day of expiry | SUBSCRIPTION RENEWAL WARNING | Yes | Cancelled |
| Payment failure | PAYMENT FAILED | Yes | Grace Period |
| Subscription period ends | SUBSCRIPTION EXPIRED | Yes | Grace Period |
| Each day of Grace Period | GRACE PERIOD | Yes | Grace Period |
| Admin suspends user | NONE | No | Suspended |
| Admin unsuspends user | NONE | No | Active |
| Lapsed→Inactive (day 30) | NONE | No | Inactive |
| User or admin deletes | NONE | No | Deleted |

### Known Issues / Bugs per User States Document

| Issue | Description | Current Behavior | Expected Behavior | Status |
|-------|-------------|------------------|-------------------|--------|
| Suspended auto-delete | Suspended users should NOT be auto-deleted after 30 days | Suspended users may be auto-deleted after 30 days | Suspended users remain in Suspended state indefinitely until admin action | Needs Fix |
| Admin delete button missing | Admin Panel→Manage User→User List lacks Delete button | No delete option for admin | Admin should have ability to delete users from User List | Needs Implementation |
| Descope session force-close | Suspended/Inactive/Deleted users need sessions force-closed | Gap in Descope integration | All sessions terminated on state change to Suspended/Inactive/Deleted | Needs Implementation |

---

## 26. Notification Module

This section covers comprehensive test cases for the OptMsg notification system, including onboarding notifications, profile change notifications, message notifications, subscription notifications (covered in Section 23 User State Lifecycle), authentication notifications, push notifications (FCM), and in-app notification display and actions.

### 26.1 Notification Model Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| NOTIF-U001 | Notification/Model | should deserialize NotificationListModel from JSON | Verify model fromJson | Valid JSON with notifications array | Model created with success=true, data populated, message set | P0 | No |
| NOTIF-U002 | Notification/Model | should serialize NotificationListModel to JSON | Verify model toJson | NotificationListModel instance | JSON map with success, data, message keys | P0 | No |
| NOTIF-U003 | Notification/Model | should deserialize Notifications from JSON | Verify notification fromJson | Valid JSON with id, type, title, body, userId, info, isRead, isDeleted, created, updated | Notification instance with all fields correctly mapped | P0 | No |
| NOTIF-U004 | Notification/Model | should serialize Notifications to JSON | Verify notification toJson | Notifications instance | JSON map with all notification fields | P0 | No |
| NOTIF-U005 | Notification/Model | should handle notification with emailId in info | Verify emailId parsing | Notification JSON with info.emailId populated | info.emailId correctly set and accessible | P0 | No |
| NOTIF-U006 | Notification/Model | should handle notification without emailId | Verify null emailId handling | Notification JSON with info.emailId = null | info.emailId = null, no error thrown | P0 | Yes |
| NOTIF-U007 | Notification/Model | should update isRead status | Verify isRead mutation | Notification with isRead=false → set to true | isRead changes from false to true | P0 | No |
| NOTIF-U008 | Notification/Model | should parse multiple notifications in list | Verify list parsing | NotificationListModel JSON with 5 notifications | All 5 notifications correctly parsed into list | P0 | No |

### 26.2 Notification API Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| NOTIF-U009 | Notification/API | should send notification request | Verify send notification | POST user/send-notification with type parameter | API called with correct endpoint and payload | P0 | No |
| NOTIF-U010 | Notification/API | should fetch notification list | Verify get notifications | POST /notification/list | API returns NotificationListModel with notifications array | P0 | No |
| NOTIF-U011 | Notification/API | should delete notification by ID | Verify delete notification | POST /notification/delete with notification ID | Notification marked as deleted, API returns success | P0 | No |
| NOTIF-U012 | Notification/API | should mark notification as read | Verify mark read | POST /notification/read with notification ID | Notification isRead=true, API returns success | P0 | No |
| NOTIF-U013 | Notification/API | should handle empty notification list | Verify empty list | API returns empty notifications array | NotificationListModel with empty data.notifications list, no error | P0 | Yes |
| NOTIF-U014 | Notification/API | should handle API error on send notification | Verify error handling | API returns 500 error | Error caught and handled gracefully, user notified | P1 | Yes |

### 26.3 Onboarding Notification Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| NOTIF-U015 | Notification/Onboarding | should send WELCOME notification on account creation | Verify welcome notification | User completes onboarding screen 0 | POST user/send-notification with type="welcome" | P0 | No |
| NOTIF-U016 | Notification/Onboarding | should send SYNCH notification on contact sync | Verify sync notification | User completes contact sync onboarding | POST user/send-notification with type="synch" | P0 | No |
| NOTIF-U017 | Notification/Onboarding | should send FORWARD notification on email forward setup | Verify forward notification | User completes forward email onboarding | POST user/send-notification with type="forward" | P0 | No |
| NOTIF-U018 | Notification/Onboarding | should send NOTIFICATION notification on final onboarding | Verify final onboarding notification | User completes final onboarding screen | POST user/send-notification with type="notification" | P0 | No |
| NOTIF-U019 | Notification/Onboarding | should trigger UPDATE ACCOUNTS notification on day 3 | Verify scheduled notification | 3 days after account creation, cron job runs | Notification sent prompting user to update online accounts to @optmsg.com | P1 | No |
| NOTIF-U020 | Notification/Onboarding | should trigger NEW ADDRESS notification on day 7 | Verify scheduled notification | 7 days after account creation, cron job runs | Notification sent with pre-composed draft to share new email address | P1 | No |
| NOTIF-U021 | Notification/Onboarding | should trigger COMMUNITY RECOMMENDATIONS notification on day 10 | Verify scheduled notification | 10 days after account creation, cron job runs | Notification sent about Community Recommendation feature | P1 | No |

### 26.4 Profile Change Notification Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| NOTIF-U022 | Notification/Profile | should send NAME CHANGE notification on name update | Verify name change notification | User updates firstName or lastName in profile | Notification sent with "Your name is updated" title and new name in body | P0 | No |
| NOTIF-U023 | Notification/Profile | should send MOBILE CHANGE notification on phone update | Verify mobile change notification | User updates mobile phone number in profile | Notification sent with "Phone Number was Updated" title and new number in body | P0 | No |
| NOTIF-U024 | Notification/Profile | should send DOB CHANGE notification on DOB update | Verify DOB change notification | User updates date of birth in profile | Notification sent with "Your date of birth is updated" title and new DOB in body | P0 | No |
| NOTIF-U025 | Notification/Profile | should include push notification for NAME CHANGE | Verify push sent | User updates name | Both in-app notification AND push notification sent | P0 | No |
| NOTIF-U026 | Notification/Profile | should include push notification for MOBILE CHANGE | Verify push sent | User updates mobile | Both in-app notification AND push notification sent | P0 | No |
| NOTIF-U027 | Notification/Profile | should include push notification for DOB CHANGE | Verify push sent | User updates DOB | Both in-app notification AND push notification sent | P0 | No |

### 26.5 Message Notification Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| NOTIF-U028 | Notification/Message | should send NEW MESSAGE notification on inbox email | Verify new message notification | New email arrives in user's inbox | Notification sent with sender name as title, subject + preview as body | P0 | No |
| NOTIF-U029 | Notification/Message | should send CR notification for community recommended email | Verify CR notification | Email from non-contact sender trusted by community arrives in trash | Notification sent with "Community Recommendation ([FROM])" title | P0 | No |
| NOTIF-U030 | Notification/Message | should include emailId in notification info for NEW MESSAGE | Verify emailId mapping | New message notification sent | notification.info.emailId contains correct email ID | P0 | No |
| NOTIF-U031 | Notification/Message | should include emailId in notification info for CR | Verify emailId mapping | CR notification sent | notification.info.emailId contains email in trash with CR flag | P0 | No |
| NOTIF-U032 | Notification/Message | should send push notification for NEW MESSAGE | Verify push sent | New email arrives | Both in-app notification AND push notification sent, badge count updated | P0 | No |
| NOTIF-U033 | Notification/Message | should send push notification for CR | Verify push sent | CR email arrives | Both in-app notification AND push notification sent | P0 | No |

### 26.6 Authentication Notification Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| NOTIF-U034 | Notification/Auth | should send PASSKEY ADDED notification | Verify passkey add notification | User successfully adds passkey | POST user/send-notification with type="passKeyAdd" sent | P0 | No |
| NOTIF-U035 | Notification/Auth | should send PASSKEY REMOVED notification | Verify passkey remove notification | User removes passkey from account | Notification sent with "Passkey was Removed" title | P0 | No |
| NOTIF-U036 | Notification/Auth | should send OTP CODE via SMS | Verify OTP SMS | User requests OTP for login or profile verification | SMS sent via Descope with 6-digit OTP code | P0 | No |
| NOTIF-U037 | Notification/Auth | should send FORGOT USERNAME notification | Verify forgot username | User initiates forgot username flow | API call to auth/forgot-username with type="FORGOT_USERNAME" | P0 | No |
| NOTIF-U038 | Notification/Auth | should include push notification for PASSKEY ADDED | Verify push sent | Passkey added | Both in-app notification AND push notification sent | P0 | No |
| NOTIF-U039 | Notification/Auth | should include push notification for PASSKEY REMOVED | Verify push sent | Passkey removed | Both in-app notification AND push notification sent | P0 | No |

### 26.7 Push Notification Service Tests (Unit)

| ID | Feature/Module | Test Case | Description | Input/Preconditions | Expected Outcome | Priority | Edge Case? |
|----|----------------|-----------|-------------|---------------------|------------------|----------|------------|
| NOTIF-U040 | Notification/Push | should initialize FCM and save device token | Verify FCM init | App starts, FCM available | FCM token retrieved and saved to secure storage as 'deviceToken' | P0 | No |
| NOTIF-U041 | Notification/Push | should handle Safari FCM unsupported | Verify Safari handling | App runs on Safari browser | Device token saved as 'NOT SUPPORTED', no FCM error | P0 | Yes |
| NOTIF-U042 | Notification/Push | should parse notification payload PATH | Verify payload parsing | FCM message with data.PATH JSON | Path parsed into type and emailId fields | P0 | No |
| NOTIF-U043 | Notification/Push | should update badge count from notification | Verify badge update | FCM message with data.badge = "5" | App badge updated to 5 (iOS/Android) | P0 | No |
| NOTIF-U044 | Notification/Push | should show local notification when app in foreground | Verify foreground notification | FCM message received while app open | Local notification displayed with title and body | P0 | No |
| NOTIF-U045 | Notification/Push | should handle notification tap and navigate | Verify navigation | User taps push notification | App opens, navigates based on notification type (newEmailInbox, newEmailCommunity, or notifications) | P0 | No |
| NOTIF-U046 | Notification/Push | should navigate to email detail for newEmailInbox | Verify email navigation | Notification type="newEmailInbox", emailId=123 | Navigates to AppRoutes.viewInboxEmailPath("123") | P0 | No |
| NOTIF-U047 | Notification/Push | should navigate to inbox for newEmailCommunity | Verify community navigation | Notification type="newEmailCommunity", emailId=456 | Saves emailId to storage, navigates to AppRoutes.inbox | P0 | No |
| NOTIF-U048 | Notification/Push | should navigate to notifications for other types | Verify default navigation | Notification with unrecognized type | Navigates to AppRoutes.notifications | P0 | Yes |
| NOTIF-U049 | Notification/Push | should redirect to login if not authenticated | Verify auth check | Notification tapped, user not logged in | Navigates to AppRoutes.login instead of notification target | P0 | Yes |
| NOTIF-U050 | Notification/Push | should request notification permissions on Android | Verify Android permissions | Android device, permissions not granted | Permission.notification.request() called | P0 | No |
| NOTIF-U051 | Notification/Push | should request notification permissions on iOS | Verify iOS permissions | iOS device, permissions not granted | firebaseMessaging.requestPermission() called for alert, badge, sound | P0 | No |
| NOTIF-U052 | Notification/Push | should create Android notification channel | Verify channel creation | Android device | 'high_importance_channel' created with high importance | P0 | No |
| NOTIF-U053 | Notification/Push | should handle invalid notification payload | Verify error handling | FCM message with malformed PATH JSON | Error caught, toast shown "Invalid notification data" | P1 | Yes |
| NOTIF-U054 | Notification/Push | should handle notification when app killed (iOS) | Verify background handling | App killed, notification arrives, user taps | getInitialMessage() retrieves notification, handleNotification() called | P0 | No |

### 26.8 Notification Display Widget Tests (Widget)

| ID | Feature/Module | Test Case | Description | Widget Under Test | Initial State/Props | Interaction | Expected Outcome | Platform | Screen Size | Orientation | Priority | Edge Case? |
|----|----------------|-----------|-------------|-------------------|---------------------|-------------|------------------|----------|-------------|-------------|----------|------------|
| NOTIF-W001 | Notification/Display | should render notification item with title and body | Verify basic rendering | NotificationItem | Notification with title="Test", body="Body text", isRead=false | None | Unread indicator shown, title and body displayed | All | All | Both | P0 | No |
| NOTIF-W002 | Notification/Display | should show unread indicator for unread notification | Verify unread indicator | NotificationItem | isRead=false | None | Unread dot/indicator visible | All | All | Both | P0 | No |
| NOTIF-W003 | Notification/Display | should hide unread indicator for read notification | Verify read state | NotificationItem | isRead=true | None | No unread indicator, normal display | All | All | Both | P0 | No |
| NOTIF-W004 | Notification/Display | should capitalize notification title | Verify title formatting | NotificationItem | title="test notification" | None | Title displayed as "Test notification" | All | All | Both | P0 | No |
| NOTIF-W005 | Notification/Display | should display formatted created date | Verify date formatting | NotificationItem | created="2024-01-15T10:30:00Z" | None | Formatted date/time displayed | All | All | Both | P0 | No |
| NOTIF-W006 | Notification/Display | should expand notification body on tap | Verify expandable content | NotificationItem | Long body text (>100 chars) | Tap notification | Body expands to show full text | All | All | Both | P1 | No |
| NOTIF-W007 | Notification/Display | should show swipe actions (Android) | Verify swipe actions | NotificationItem | Any notification | Swipe left | Mark read/unread and Trash actions visible | Android | All | Both | P0 | No |
| NOTIF-W008 | Notification/Display | should mark notification as read on tap | Verify mark read | NotificationItem | isRead=false | Tap "Mark as Read" action | Notification isRead changes to true, UI updates | All | All | Both | P0 | No |
| NOTIF-W009 | Notification/Display | should mark notification as unread | Verify mark unread | NotificationItem | isRead=true | Tap "Mark as Unread" action | Notification isRead changes to false, unread indicator appears | All | All | Both | P0 | No |
| NOTIF-W010 | Notification/Display | should delete notification on trash action | Verify delete | NotificationItem | Any notification | Tap "Trash" action | Notification removed from list, delete API called | All | All | Both | P0 | No |
| NOTIF-W011 | Notification/Display | should render empty notification list state | Verify empty state | NotificationList | Empty notifications array | None | "No notifications" message or empty state illustration shown | All | All | Both | P1 | No |
| NOTIF-W012 | Notification/Display | should show notification badge count on bell icon | Verify badge count | NavigationBar | 5 unread notifications | None | Bell icon shows "5" badge | All | All | Both | P0 | No |

### 26.9 Notification Navigation Integration Tests (Integration)

| ID | Feature/Module | Test Case | Description | Components | Scenario | Expected Outcome | Platform | Priority |
|----|----------------|-----------|-------------|------------|----------|------------------|----------|----------|
| NOTIF-I001 | Notification/Navigation | should navigate to email detail from newEmailInbox notification | Email notification navigation | NotificationService + ViewInbox + Router | FCM notification type="newEmailInbox", emailId=789 → user taps → navigate | App navigates to email detail view with emailId=789 | All | P0 |
| NOTIF-I002 | Notification/Navigation | should navigate to inbox for newEmailCommunity notification | Community email navigation | NotificationService + Inbox + Router | FCM notification type="newEmailCommunity" → user taps → navigate | App navigates to inbox, community email ID stored in secure storage | All | P0 |
| NOTIF-I003 | Notification/Navigation | should navigate to notification list for generic notification | Generic navigation | NotificationService + NotificationList + Router | FCM notification with type="welcome" → user taps → navigate | App navigates to notifications screen | All | P0 |
| NOTIF-I004 | Notification/Navigation | should update notification list after marking as read | Notification state sync | NotificationItem + NotificationAPI + NotificationList | User marks notification as read → API call → list refresh | Notification isRead=true in list, unread count decremented | All | P0 |
| NOTIF-I005 | Notification/Navigation | should remove notification from list after delete | Notification delete sync | NotificationItem + NotificationAPI + NotificationList | User deletes notification → API call → list refresh | Notification removed from UI list | All | P0 |
| NOTIF-I006 | Notification/Navigation | should update badge count after reading notification | Badge sync | NotificationItem + AppBadge + NotificationAPI | User marks notification as read → badge update | App badge count decremented by 1 | iOS, Android | P0 |

### 26.10 End-to-End Notification Tests

| ID | Feature/Module | Test Case | Description | Steps | Preconditions | Expected Outcome | Platform | Screen Size | Orientation | Priority |
|----|----------------|-----------|-------------|-------|---------------|------------------|----------|-------------|-------------|----------|
| E2E-089 | Notification/Onboarding | should receive WELCOME notification on account creation | Complete onboarding and receive welcome | Sign up → Complete onboarding screen 0 → Navigate to notifications | New account, onboarding in progress | WELCOME notification appears in notification list with welcome message | All | All | Both | P0 |
| E2E-090 | Notification/Onboarding | should receive SYNCH notification after contact sync | Contact sync triggers notification | Complete onboarding → Sync contacts → Navigate to notifications | Onboarding step 1, contacts permission granted | SYNCH notification appears with contact sync message | iOS, Android | All | Both | P0 |
| E2E-091 | Notification/Profile | should receive NAME CHANGE notification on profile update | Profile change triggers notification | Login → Settings → Profile → Change name → Save → Navigate to notifications | Authenticated, profile editable | NAME CHANGE notification with new name in body | All | All | Both | P0 |
| E2E-092 | Notification/Profile | should receive MOBILE CHANGE notification on phone update | Phone change triggers notification | Login → Settings → Profile → Change phone → Verify OTP → Navigate to notifications | Authenticated, OTP verified | MOBILE CHANGE notification with new phone number | All | All | Both | P0 |
| E2E-093 | Notification/Message | should receive NEW MESSAGE notification on incoming email | New email triggers notification | Login → Wait for new email to arrive → Check notifications | Authenticated, email incoming | NEW MESSAGE notification with sender and subject, tap opens email detail | All | All | Both | P0 |
| E2E-094 | Notification/Message | should receive push notification for NEW MESSAGE | Push notification received | App backgrounded → New email arrives → Push notification appears | Authenticated, FCM enabled, app in background | Push notification shown on device, tap opens app to email detail | iOS, Android | All | Both | P0 |
| E2E-095 | Notification/CR | should receive Community Recommendation notification | CR email triggers notification | Login → Wait for non-contact email trusted by community → Check notifications | Authenticated, CR feature enabled | CR notification visible, tap navigates to email in trash | All | All | Both | P1 |
| E2E-096 | Notification/Auth | should receive PASSKEY ADDED notification | Passkey addition triggers notification | Login → Settings → Security → Add Passkey → Complete passkey setup → Check notifications | Authenticated, device supports passkeys | PASSKEY ADDED notification appears | All | All | Both | P0 |
| E2E-097 | Notification/MarkRead | should mark notification as read and update badge | Mark read flow | Login → Notifications → Tap unread notification → Mark as read | Authenticated, unread notifications exist | Notification marked as read, unread indicator removed, badge count decremented | All | All | Both | P0 |
| E2E-098 | Notification/Delete | should delete notification and remove from list | Delete flow | Login → Notifications → Swipe notification left → Tap Trash → Confirm | Authenticated, notifications exist | Notification removed from list, no longer appears on refresh | All | All | Both | P0 |
| E2E-099 | Notification/Navigation | should navigate to email from notification tap | Notification navigation | Login → Notifications → Tap NEW MESSAGE notification | Authenticated, notification with emailId | Email detail screen opens with correct email content | All | All | Both | P0 |
| E2E-100 | Notification/BadgeUpdate | should update app badge count with notification count | Badge count sync | Receive 3 notifications → Check badge → Mark 1 as read → Check badge | Authenticated, FCM enabled | Badge shows "3", then "2" after marking one read | iOS, Android | All | Both | P0 |
| E2E-101 | Notification/Subscription | should receive SUBSCRIPTION SUCCESS notification | Subscription purchase triggers notification | Login → Plans → Select plan → Complete payment → Check notifications | Authenticated, Stripe checkout completed | SUBSCRIPTION SUCCESS notification with plan title | All | All | Both | P0 |
| E2E-102 | Notification/Subscription | should receive SUBSCRIPTION CANCEL notification | Subscription cancellation triggers notification | Login → Settings → Account → Cancel Subscription → Confirm → Check notifications | Authenticated, active subscription | SUBSCRIPTION CANCEL notification confirming cancellation | All | All | Both | P0 |

