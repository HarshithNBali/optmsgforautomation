import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/storage_service.dart';

class AppCache {
  // Private constructor
  AppCache._internal();

  // Single instance
  static final AppCache _instance = AppCache._internal();

  // Factory constructor
  factory AppCache() => _instance;

  final SecureStorageService _secure = SecureStorageService();

  String _tabName = "";
  String _lastNavigation = "";
  String _currentNavigation = "";
  bool _isAllMailSaved = false;

  // GR-2: In-memory cache for redirect-critical storage values.
  // Populated once at app init via loadRedirectCache(), updated inline
  // whenever the corresponding storage write occurs.
  String? _isCheckout;
  String _subscriptionPage = '';
  String _signupInProgress = '';
  bool _hasPasskeyEnrolled = false;
  bool _hasCompletedOnboarding = false;
  bool _isPasskeyPageOpen = false;
  String? _mailto;
  String _themeModePref = 'system';

  // Transient in-memory signal for socket-based payment completion.
  // NOT persisted to storage — cleared on every app restart so stale
  // data can never cause spurious redirects to /payment-processing.
  Map<String, dynamic>? _queryParms;

  // PH-06: LRU cache for email detail responses. Keyed by emailId.
  // Avoids re-fetching the same email body on every navigation.
  // LinkedHashMap preserves insertion order for LRU eviction.
  static const int _emailCacheMaxSize = 10;
  final LinkedHashMap<int, Map<String, dynamic>> _emailDetailCache =
      LinkedHashMap<int, Map<String, dynamic>>();

  // Getters
  String? get isCheckout => _isCheckout;
  String get subscriptionPage => _subscriptionPage;
  String get signupInProgress => _signupInProgress;
  bool get hasPasskeyEnrolled => _hasPasskeyEnrolled;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isPasskeyPageOpen => _isPasskeyPageOpen;
  String? get mailto => _mailto;
  String get themeModePref => _themeModePref;

  // Setters (call these alongside the corresponding storage.writeData)
  void setIsCheckout(String? v) => _isCheckout = v;
  void setSubscriptionPage(String v) => _subscriptionPage = v;
  void setSignupInProgress(String v) => _signupInProgress = v;
  void setHasPasskeyEnrolled(bool v) => _hasPasskeyEnrolled = v;
  void setHasCompletedOnboarding(bool v) => _hasCompletedOnboarding = v;
  void setIsPasskeyPageOpen(bool v) => _isPasskeyPageOpen = v;
  void setMailto(String? v) => _mailto = v;
  void setThemeModePref(String v) => _themeModePref = v;

  /// Load all redirect-critical values from secure storage into memory.
  /// Call once during app initialization (before GoRouter is created).
  /// CS-4: Parallelized — was 6 sequential reads (50-100ms each on iOS
  /// Keychain), now runs all at once via Future.wait.
  Future<void> loadRedirectCache() async {
    final results = await Future.wait([
      _secure.readData('isCheckout'),           // [0]
      _secure.readData('subscriptionPage'),     // [1]
      _secure.readData('signupInProgress'),     // [2]
      _secure.readData('hasPasskeyEnrolled'),   // [3]
      _secure.readData('hasCompletedOnboarding'), // [4]
      _secure.readData('mailto'),               // [5]
      _secure.getString('themeModePref'),       // [6] SharedPrefs (plain localStorage on web)
    ]);
    _isCheckout = results[0];
    _subscriptionPage = results[1] ?? '';
    _signupInProgress = results[2] ?? '';
    _hasPasskeyEnrolled = results[3] == 'true';
    _hasCompletedOnboarding = results[4] == 'true';
    _mailto = results[5];
    _themeModePref = results[6] ?? 'system';
    if (kDebugMode) debugPrint('[THEME] loadRedirectCache: storageValue=${results[6]}, cached=$_themeModePref');

    // Bug 20: On web, SecureStorage uses sessionStorage which is cleared after
    // cross-origin navigation to Stripe. Fall back to SharedPreferences
    // (localStorage) which persists across origins. Mirrors the fallback in
    // ProcessingPaymentScreen._processPaymentRedirect().
    if (kIsWeb && (_isCheckout == null || _subscriptionPage.isEmpty)) {
      final prefs = await SharedPreferences.getInstance();
      _isCheckout ??= prefs.getString('isCheckout');
      if (_subscriptionPage.isEmpty) {
        _subscriptionPage = prefs.getString('subscriptionPage') ?? '';
      }
    }
  }
  void setTabName(String value) {
    _tabName = value;
  }
  Future<void> setSubscriptionCacheData(Map<String,dynamic> value) async {
    await _secure.writeObjectData('payment_data', value);
  }
  Future<void> setQueryParms(Map<String,dynamic> value) async {
    _queryParms = value.isEmpty ? null : Map<String, dynamic>.from(value);
  }
  void setLastNavigationName(String value) {
    _lastNavigation = value;
  }
  void setCurrentNavigationName(String value) {
    _currentNavigation = value;
  }
  void setIsAllMailSaved(bool value) {
    _isAllMailSaved = value;
  }
  bool get isAllMailSaved => _isAllMailSaved;
  Future<Map<String, dynamic>?> getSubscriptionCacheData() async {
    return await _secure.readObjectData('payment_data');
  }

  Future<Map<String, dynamic>?> getQueryParms() async {
    return _queryParms;
  }

  // PH-06: Email detail cache accessors
  /// Returns cached email detail response, or null if not cached.
  /// Moves the entry to the end (most-recently-used).
  Map<String, dynamic>? getEmailDetail(int emailId) {
    final cached = _emailDetailCache.remove(emailId);
    if (cached != null) {
      _emailDetailCache[emailId] = cached; // move to end (MRU)
    }
    return cached;
  }

  /// Caches an email detail response. Evicts the oldest entry if at capacity.
  void putEmailDetail(int emailId, Map<String, dynamic> data) {
    _emailDetailCache.remove(emailId); // remove first to refresh position
    if (_emailDetailCache.length >= _emailCacheMaxSize) {
      _emailDetailCache.remove(_emailDetailCache.keys.first); // evict LRU
    }
    _emailDetailCache[emailId] = data;
  }

  /// Invalidates a single cached email detail (e.g. after tag change).
  void invalidateEmailDetail(int emailId) {
    _emailDetailCache.remove(emailId);
  }

  /// Resets all in-memory state. Call on logout to prevent stale data
  /// from bleeding into the next session (M-12).
  void clear() {
    _tabName = "";
    _lastNavigation = "";
    _currentNavigation = "";
    _isAllMailSaved = false;
    _isCheckout = null;
    _subscriptionPage = '';
    _signupInProgress = '';
    _hasPasskeyEnrolled = false;
    _hasCompletedOnboarding = false;
    _isPasskeyPageOpen = false;
    _mailto = null;
    _queryParms = null;
    _emailDetailCache.clear();
  }

  // Getter
  String get tabName => _tabName;
  String get lastNavigation => _lastNavigation;
  String get currentNavigation => _currentNavigation;
}
