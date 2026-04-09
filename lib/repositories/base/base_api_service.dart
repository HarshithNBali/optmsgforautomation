import 'dart:convert';
import 'dart:io';
import 'package:descope/descope.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../../common/utilites/logger.dart';
import '../../common/utilites/network_service.dart';
import '../../main.dart' show firebaseReady;
import '../../model/base_response/request_error.dart';
import '../../model/base_response/request_response.dart';
import '../../services/common_service.dart';
import '../../services/session_expiry_manager.dart';
import '../../services/session_refresh_mutex.dart';
import '../../services/api_service.dart' show CancelToken;

enum RequestType { get, post, delete, patch, put }

abstract class ContentType {
  static const String json = 'application/json';
  static const String multipart = 'multipart/form-data';
  static const String formUrlEncoded = 'application/x-www-form-urlencoded';
}

abstract class BaseAPIService {
  // PH-02: Singleton HTTP client shared across all BaseAPIService subclasses.
  // Reuses TCP+TLS connections instead of creating a fresh handshake per call.
  // N-8: Explicitly reject invalid TLS certificates.
  static final http.Client _sharedClient = kIsWeb
      ? http.Client()
      : IOClient(HttpClient()
          ..badCertificateCallback = (cert, host, port) => false);

  http.Client get client => _sharedClient;

  Future<RequestResponse<dynamic>> make(
    RequestType type,
    dynamic endpoint, {
    // Replace dynamic with your EndPoint type
    dynamic body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
    String contentType = ContentType.json,
    bool isRetry = false,
    CancelToken? cancelToken,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (cancelToken?.isCancelled ?? false) {
      return RequestResponse(
        error: RequestError(
            statusCode: 0,
            data: {'message': 'Cancelled', "success": false}),
      );
    }
    // Check Internet using the updated NetworkService
    if (!kIsWeb) {
      final hasInternet = await NetworkService.hasInternet();
      if (!hasInternet) {
        return RequestResponse(
          error: RequestError(
              statusCode: 0,
              data: {'message': 'No internet connection', "success": false}),
        );
      }
    }

    // Pre-request token refresh — Descope best practice: call
    // refreshSessionIfNeeded() before every API request. It's a no-op when
    // the JWT has >60s remaining, so it's safe to call unconditionally.
    try {
      await SessionRefreshMutex.guardedRefreshIfNeeded();
    } catch (e) {
      var session = Descope.sessionManager.session;
      if (session == null) {
        try {
          await Descope.sessionManager.loadSession();
          session = Descope.sessionManager.session;
        } catch (_) {}
        if (session != null && !session.refreshToken.isExpired) {
          // Session recovered from storage — continue with the request
        }
      }
      if (session == null || session.refreshToken.isExpired || e is DescopeException) {
        // RC-7: Delegate to the centralized SessionExpiryManager so the user
        // sees the "Session expired" toast and is redirected to /login. Without
        // this, the caller just gets an error response but stays on the current
        // screen for up to 30s until the periodic timer catches the terminal state.
        await SessionExpiryManager.handleExpiry();
        return RequestResponse(
          error: RequestError(statusCode: 401, data: {
            'message': '',  // handleExpiry() already showed the toast
            'success': false,
          }),
        );
      }
    }

    // ST-race: guardedRefreshIfNeeded() is a no-op when the in-memory session
    // is null (race between _refreshSessionOnResume().loadSession() and this
    // API call on app resume, or Android memory pressure clearing the session).
    // If the session is still null after the refresh attempt, try loading from
    // storage once and refreshing again so we don't send an unauthenticated
    // request (which causes the backend to return success:false "Invalid Token"
    // in an HTTP 200 — undetectable without this guard).
    if (Descope.sessionManager.session == null) {
      try {
        await Descope.sessionManager.loadSession();
        if (Descope.sessionManager.session != null) {
          await SessionRefreshMutex.guardedRefreshIfNeeded();
        }
      } catch (_) {}
    }

    String version = await CommonService().getAppVersion();
    dynamic jsonBody = (body != null && contentType == ContentType.json)
        ? json.encode(body)
        : body;

    if (kDebugMode) {
      printLog('Request Path', endpoint.path);
      printLog('Request Body', jsonBody);
    }

    // Build URI
    String path = endpoint.path;
    if (!path.startsWith('/api') && !path.startsWith('api')) {
      path = '/api/$path';
    }

    Uri uri;
    if (params != null && params.isNotEmpty) {
      params.removeWhere((key, value) => value == "null" || value == null);
      uri = Uri.https(endpoint.base, path, Map.from(params));
    } else {
      uri = Uri.https(endpoint.base, path);
    }

    if (kDebugMode) printLog('Request FULL URI', uri.toString());

    Map<String, String> allHeaders = {
      "accept": ContentType.json,
      "x-opt-platform": CommonService().getPlatform(),
      "accept-language": "en",
      "x-opt-version": version,
      "Content-Type": contentType,
    };

    // Inject fresh JWT into headers (matches ApiService._buildPerRequestHeaders)
    final jwt = Descope.sessionManager.session?.sessionJwt;
    if (jwt != null && jwt.isNotEmpty) {
      allHeaders['authorization'] = jwt;
      allHeaders['tokentype'] = 'descope';
    }

    if (headers != null) {
      allHeaders.addAll(headers.cast<String, String>());
    }

    HttpMetric? metric;
    if (firebaseReady && kReleaseMode && !kIsWeb) {
      const methodMap = {
        RequestType.get: HttpMethod.Get,
        RequestType.post: HttpMethod.Post,
        RequestType.delete: HttpMethod.Delete,
        RequestType.patch: HttpMethod.Patch,
        RequestType.put: HttpMethod.Put,
      };
      metric = FirebasePerformance.instance
          .newHttpMetric(uri.toString(), methodMap[type]!);
      await metric.start();
    }

    try {
      http.Response response;
      switch (type) {
        case RequestType.get:
          response = await client
              .get(uri, headers: allHeaders)
              .timeout(timeout);
          break;
        case RequestType.post:
          response = await client
              .post(uri, headers: allHeaders, body: jsonBody)
              .timeout(timeout);
          break;
        case RequestType.delete:
          response = await client
              .delete(uri, headers: allHeaders)
              .timeout(timeout);
          break;
        case RequestType.patch:
          response = await client
              .patch(uri, headers: allHeaders, body: jsonBody)
              .timeout(timeout);
          break;
        case RequestType.put:
          response = await client
              .put(uri, headers: allHeaders, body: jsonBody)
              .timeout(timeout);
          break;
      }

      if (cancelToken?.isCancelled ?? false) {
        return RequestResponse(
          error: RequestError(
              statusCode: 0,
              data: {'message': 'Cancelled', "success": false}),
        );
      }

      if (metric != null) {
        metric.httpResponseCode = response.statusCode;
        metric.responseContentType = response.headers['content-type'];
        metric.responsePayloadSize = response.contentLength;
        await metric.stop();
      }

      final decoded = await compute(_parseJson, response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map && decoded['code'] == 401 ||
            decoded is Map && decoded['code'] == 405) {
          if (!isRetry) {
            final recovered = await _handleSessionExpiry();
            if (recovered) {
              return make(type, endpoint, body: body, headers: headers,
                  params: params, contentType: contentType, isRetry: true);
            }
          }
          return RequestResponse(
              error: RequestError(statusCode: 401, data: decoded));
        }
        // ST-race: Some backends return HTTP 200 with success:false and an
        // auth-related message (e.g. "Invalid Token") instead of HTTP 401 when
        // a stale JWT is used. Treat these as 401s so the recovery path fires.
        if (decoded is Map && decoded['success'] == false) {
          final msg = (decoded['message'] ?? '').toString().toLowerCase();
          if (msg.contains('invalid token') || msg.contains('unauthorized') ||
              msg.contains('authentication failed') || msg.contains('token expired')) {
            if (!isRetry) {
              final recovered = await _handleSessionExpiry();
              if (recovered) {
                return make(type, endpoint, body: body, headers: headers,
                    params: params, contentType: contentType, isRetry: true);
              }
            }
            return RequestResponse(
                error: RequestError(statusCode: 401, data: decoded));
          }
        }
        return RequestResponse(data: decoded);
      } else if (response.statusCode == 401 || response.statusCode == 405) {
        if (!isRetry) {
          final recovered = await _handleSessionExpiry();
          if (recovered) {
            return make(type, endpoint, body: body, headers: headers,
                params: params, contentType: contentType, isRetry: true);
          }
        }
        return RequestResponse(
            error: RequestError(statusCode: 401, data: decoded));
      } else {
        return RequestResponse(
            error:
                RequestError(statusCode: response.statusCode, data: decoded));
      }
    } catch (e) {
      await metric?.stop();
      return RequestResponse(
          error: RequestError(statusCode: 500, data: e.toString()));
    }
  }

  Future<void> showSessionExpireAlert() => _handleSessionExpiry().then((_) {});

  // Returns `true` if the session was recovered, `false` if terminal.
  // Delegates to the shared SessionExpiryManager so that only one expiry flow
  // runs at a time across both ApiService and BaseAPIService.
  Future<bool> _handleSessionExpiry() {
    if (firebaseReady && !kIsWeb) {
      FirebaseCrashlytics.instance.log('session: BaseAPI returned 401/405, attempting recovery');
    }
    return SessionExpiryManager.handleExpiry();
  }

  static dynamic _parseJson(String text) {
    return json.decode(text);
  }
}

