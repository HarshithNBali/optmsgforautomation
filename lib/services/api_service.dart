import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/main.dart';
import 'package:optmsg/repositories/end_point/end_point.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/global_variable_notifier.dart';
import 'package:descope/descope.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/constant/app_config.dart';

import 'session_expiry_manager.dart';
import 'session_refresh_mutex.dart';

class NoInternetException implements Exception {
  final String message;
  NoInternetException(this.message);
}

class CancelToken {
  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;
  void cancel() => _isCancelled = true;
}

class ApiService {
  final String baseUrl;
  final SecureStorageService secureStorageService = SecureStorageService();
  final http.Client _client = _createSecureClient();

  static String? _cachedAppVersion;
  late final Map<String, String> _defaultHeaders;

  static ApiService? _instance;

  factory ApiService({String? baseUrl}) {
    _instance ??= ApiService._internal(baseUrl: baseUrl);
    return _instance!;
  }

  ApiService._internal({String? baseUrl}) : baseUrl = baseUrl ?? EndPoints.baseUrl {
    debugPrint("ApiService singleton initialized with baseUrl: ${this.baseUrl}");
    _defaultHeaders = {
      "accept": "application/json",
      "x-opt-platform": CommonService().getPlatform(),
      "accept-language": "en",
      "Content-Type": "application/json",
      "Cache-Control": "no-cache, no-store, must-revalidate",
      "Pragma": "no-cache",
      "Expires": "0",
    };
    assert(() { debugPrint("ApiService initialized with baseUrl: ${this.baseUrl}"); return true; }());
    _initAppVersion();
  }

  Future<void> _initAppVersion() async {
    _cachedAppVersion ??= await CommonService().getAppVersion();
  }

  void dispose() => _client.close();

  // Returns an http.Client backed by a native HttpClient with an explicit
  // badCertificateCallback that always rejects invalid certificates.
  // NOTE: badCertificateCallback is only invoked for certificates that fail
  // standard CA validation; it does not provide full certificate pinning.
  // To pin against a known fingerprint for this endpoint, migrate to Dio with
  // IOHttpClientAdapter.validateCertificate (see descope_api_service.dart).
  static http.Client _createSecureClient() {
    if (kIsWeb) return http.Client();
    final nativeClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => false;
    return IOClient(nativeClient);
  }

  // ---------------------------------------------------------------------------
  // 🔹 Common helpers
  // ---------------------------------------------------------------------------

  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? additionalHeaders,
  ) async {
    final headers = Map<String, String>.from(_defaultHeaders);
    headers.addAll(await _buildPerRequestHeaders());
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  void _handleUpdateHeader(http.Response response) {
    if (kIsWeb) return;

    final isForceUpdate =
        response.headers['forceupdate']?.toLowerCase() == 'true';
    final hasUpdate = response.headers['hasupdate']?.toLowerCase() == 'true';

    if (isForceUpdate) {
      CommonService.showUpdateDialog(
        updateType: 'hard',
        updateMessage: forceUpdate,
      );
    } else if (hasUpdate) {
      CommonService.showUpdateDialog(
        updateType: 'soft',
        updateMessage: softUpdate,
      );
    }
  }

  Future<Map<String, dynamic>> _handleResponse(
      http.Response response, Uri uri) async {
    _handleUpdateHeader(response);

    if (kDebugMode) {
      debugPrint("Response: [${response.request?.method}] ${response.request?.url} -> Status: ${response.statusCode}");
      if (response.statusCode == 404) {
        debugPrint("❌ [404 NOT FOUND] The endpoint does not exist on the server.");
      }
    }

    if (response.statusCode == 200) {
      try {
        final decoded = await compute(_parseJson, response.body);
        if (decoded is! Map<String, dynamic>) {
           return {'success': false, 'message': 'Invalid server response format'};
        }
        // ST-race: Some backends return HTTP 200 with success:false and an
        // auth message (e.g. "Invalid Token") instead of HTTP 401 when a
        // stale JWT is used. Surface these as statusCode:401 so _withAuthRetry
        // triggers the recovery path rather than propagating the raw message.
        if (decoded['success'] == false) {
          final msg = (decoded['message'] ?? '').toString().toLowerCase();
          if (msg.contains('invalid token') || msg.contains('unauthorized') ||
              msg.contains('authentication failed') || msg.contains('token expired')) {
            return {...decoded, 'statusCode': 401};
          }
        }
        return decoded;
      } on FormatException {
        return {'success': false, 'message': 'Invalid server response'};
      }
    }

    if (response.statusCode == 304) {
      assert(() { debugPrint("Warning: 304 Not Modified received for expected JSON response."); return true; }());
    }

    return {
      'statusCode': response.statusCode,
      'message': response.body,
      'success': false
    };
  }

  static dynamic _parseJson(String text) {
    return json.decode(text);
  }

  Never _handleNetworkError(Object error) {
    if (error is SocketException || error is TimeoutException) {
      throw NoInternetException(noInternet);
    }
    // Non-network errors (e.g. FormatException, StateError) bubble up as-is
    // so callers can distinguish them from connectivity failures.
    // ignore: only_throw_errors
    throw error;
  }

  Future<T> _safeRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } catch (e) {
      _handleNetworkError(e);
    }
  }

  /// Delegates to the shared [SessionRefreshMutex] so that only one Descope
  /// refresh runs at a time across both ApiService and RefreshableService.
  Future<void> _guardedRefreshIfNeeded() async {
    try {
      await SessionRefreshMutex.guardedRefreshIfNeeded();
    } catch (e) {
      var session = Descope.sessionManager.session;
      // ST-6: If in-memory session is null (Android memory pressure, file
      // picker, camera), try reloading from persistent storage before
      // treating as terminal.
      if (session == null) {
        try {
          await Descope.sessionManager.loadSession();
          session = Descope.sessionManager.session;
        } catch (_) {}
        if (session != null && !session.refreshToken.isExpired) {
          return; // Session recovered — next API call will use fresh JWT
        }
      }
      // Only force logout if the refresh token is expired or Descope
      // explicitly rejected it (server-side revocation, e.g. E064001).
      if (session == null || session.refreshToken.isExpired || e is DescopeException) {
        unawaited(_handleExpiredSession());
      }
    }
    // ST-race: guardedRefreshIfNeeded() is a no-op when the in-memory session
    // is null (race between _refreshSessionOnResume().loadSession() and this
    // API call on app resume, or Android clearing the session under memory
    // pressure). If the session is still null after the refresh attempt, try
    // loading from storage once so the JWT header is populated for the request.
    if (Descope.sessionManager.session == null) {
      try {
        await Descope.sessionManager.loadSession();
        if (Descope.sessionManager.session != null) {
          await SessionRefreshMutex.guardedRefreshIfNeeded();
        }
      } catch (_) {}
    }
  }

  Future<Map<String, String>> _buildPerRequestHeaders() async {
    await _guardedRefreshIfNeeded();
    final version =
        _cachedAppVersion ?? await CommonService().getAppVersion();
    final jwt = Descope.sessionManager.session?.sessionJwt;
    return {
      'x-opt-version': version,
      if (jwt != null && jwt.isNotEmpty) 'authorization': jwt,
      if (jwt != null && jwt.isNotEmpty) 'tokentype': 'descope',
    };
  }

  // Delegates to the shared SessionExpiryManager so that only one expiry flow
  // runs at a time across both ApiService and BaseAPIService.
  // Returns `true` if the session was recovered, `false` if terminal.
  Future<bool> _handleExpiredSession() {
    if (firebaseReady && !kIsWeb) {
      FirebaseCrashlytics.instance.log('session: API returned 401, attempting recovery');
    }
    return SessionExpiryManager.handleExpiry();
  }

  /// Executes [request] and, if it returns a 401, attempts silent session
  /// recovery via [SessionExpiryManager]. If recovery succeeds, re-executes
  /// the request once with a fresh JWT. This makes token refresh completely
  /// invisible to callers.
  Future<Map<String, dynamic>> _withAuthRetry(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    final result = await request();
    if (result['statusCode'] == 401 || result['statusCode'] == 405) {
      final recovered = await _handleExpiredSession();
      if (recovered) {
        // Retry once — _buildPerRequestHeaders() will pick up the fresh JWT.
        return await request();
      }
    }
    return result;
  }

  /// Executes [request] and records an [HttpMetric] for Firebase Performance.
  Future<http.Response> _tracedHttp(
    Uri uri,
    HttpMethod method,
    Future<http.Response> Function() request,
  ) async {
    HttpMetric? metric;
    if (firebaseReady && kReleaseMode && !kIsWeb) {
      metric = FirebasePerformance.instance
          .newHttpMetric(uri.toString(), method);
      await metric.start();
    }
    try {
      final response = await request();
      if (metric != null) {
        metric.httpResponseCode = response.statusCode;
        metric.responseContentType = response.headers['content-type'];
        metric.responsePayloadSize = response.contentLength;
      }
      return response;
    } finally {
      await metric?.stop();
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 Public APIs
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? additionalHeaders,
    CancelToken? cancelToken,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return _withAuthRetry(() => _safeRequest(() async {
      if (cancelToken?.isCancelled ?? false) {
        return {'success': false, 'message': 'Cancelled', 'isCancelled': true};
      }
      final headers = await _buildHeaders(additionalHeaders);

      final uri = data != null
          ? Uri.parse('$baseUrl$path').replace(queryParameters: data)
          : Uri.parse('$baseUrl$path');

      assert(() { debugPrint("GET Request: $uri"); return true; }());
      final response = await _tracedHttp(
        uri,
        HttpMethod.Get,
        () => _client.get(uri, headers: headers).timeout(timeout),
      );

      if (cancelToken?.isCancelled ?? false) {
        return {'success': false, 'message': 'Cancelled', 'isCancelled': true};
      }
      return _handleResponse(response, uri);
    }));
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data, {
    Map<String, String>? additionalHeaders,
    CancelToken? cancelToken,
    Duration timeout = const Duration(seconds: 30),
  }) {
    GlobalVariableNotifier? updateNotifier;
    try {
      updateNotifier = providerContainer.read(globalVariableProvider.notifier);
    } catch (_) {
      // Container disposed or unavailable — proceed without loading indicator
    }

    final requestUrl =
        path.contains('contact/upload') ? contactBaseUrl : baseUrl;

    return _withAuthRetry(() => _safeRequest(() async {
      if (cancelToken?.isCancelled ?? false) {
        return {'success': false, 'message': 'Cancelled', 'isCancelled': true};
      }
      final headers = await _buildHeaders(additionalHeaders);

      updateNotifier?.addPath(path);

      try {
        final uri = Uri.parse('$requestUrl$path');
        assert(() { debugPrint("POST Request: $uri"); return true; }());
        final response = await _tracedHttp(
          uri,
          HttpMethod.Post,
          () => _client.post(uri, headers: headers, body: jsonEncode(data)).timeout(timeout),
        );

        updateNotifier?.clearPathList();
        if (cancelToken?.isCancelled ?? false) {
          return {'success': false, 'message': 'Cancelled', 'isCancelled': true};
        }
        return _handleResponse(response, uri);
      } catch (e) {
        updateNotifier?.clearPathList();
        rethrow;
      }
    }));
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> data, {
    Map<String, String>? additionalHeaders,
    CancelToken? cancelToken,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return _withAuthRetry(() => _safeRequest(() async {
      if (cancelToken?.isCancelled ?? false) {
        return {'success': false, 'message': 'Cancelled', 'isCancelled': true};
      }
      final headers = await _buildHeaders(additionalHeaders);

      final uri = Uri.parse('$baseUrl$path');
      final response = await _tracedHttp(
        uri,
        HttpMethod.Put,
        () => _client.put(uri, headers: headers, body: jsonEncode(data)).timeout(timeout),
      );

      if (cancelToken?.isCancelled ?? false) {
        return {'success': false, 'message': 'Cancelled', 'isCancelled': true};
      }
      return _handleResponse(response, uri);
    }));
  }

  Future<Map<String, dynamic>> authenticatedGet(
    String path,
    String token, {
    CancelToken? cancelToken,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return _safeRequest(() async {
      if (cancelToken?.isCancelled ?? false) {
        return {'success': false, 'message': 'Cancelled', 'isCancelled': true};
      }
      final uri = Uri.parse('$baseUrl$path');
      final response = await _client
          .get(uri, headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          })
          .timeout(timeout);

      if (cancelToken?.isCancelled ?? false) {
        return {'success': false, 'message': 'Cancelled', 'isCancelled': true};
      }
      return _handleResponse(response, uri);
    });
  }

  Future<Map<String, dynamic>> fetchJsonDataUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw ArgumentError('Invalid URL: $url');
    }
    if (uri.scheme != 'https' ||
        !(uri.host.endsWith('.optmsg.com') ||
            uri.host.endsWith('.amazonaws.com') ||
            uri.host.endsWith('.descope.com'))) {
      throw ArgumentError('Untrusted URL: $url');
    }
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to fetch URL ($url): HTTP ${response.statusCode}');
    } catch (e) {
      if (e is ArgumentError) rethrow;
      assert(() { debugPrint('[ApiService] fetchJsonDataUrl failed for $url: $e'); return true; }());
      rethrow;
    }
  }
}
