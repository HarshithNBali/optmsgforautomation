import 'package:descope/descope.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/services/session_refresh_mutex.dart';

// SHA-1 fingerprints of the pinned TLS leaf certificates for api.descope.com.
// Update this list whenever the certificate rotates.
// Obtain with:
//   openssl s_client -connect api.descope.com:443 2>/dev/null \
//     | openssl x509 -fingerprint -sha1 -noout
//
// ⚠️  SCOPE OF PINNING — READ BEFORE POPULATING THIS LIST:
// Certificate pinning below applies ONLY to this class's Dio client, which
// is used exclusively for direct REST calls (e.g. GET v1/auth/me).
// The Descope Flutter SDK (Descope.otp, Descope.passkey, Descope.sessionManager)
// uses its own internal HTTP client that CANNOT be configured from outside the SDK.
// Therefore, populating this list will NOT pin the SDK's authentication traffic.
// TODO: Request Descope to expose an HTTP-client injection API so the pinned
//       client can cover all SDK traffic, not just the supplemental REST calls.
const List<String> _descopePinnedSha1 = <String>[
  // 'XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX',
];

class DescopeApiService {
  final String baseUrl;
  final Dio _dio;

  DescopeApiService({this.baseUrl = descopeApiBaseUrl})
      : _dio = _buildDio(baseUrl);

  static Dio _buildDio(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));
    if (!kIsWeb) {
      final adapter = IOHttpClientAdapter();
      // validateCertificate is called for every certificate (including ones that
      // pass normal CA validation), making it suitable for certificate pinning.
      adapter.validateCertificate = (cert, host, port) {
        if (_descopePinnedSha1.isEmpty) {
          // No pins configured yet — allow all valid certs.
          // Populate _descopePinnedSha1 to activate pinning.
          return true;
        }
        if (cert == null) return false;
        final sha1 = cert.sha1
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(':')
            .toUpperCase();
        return _descopePinnedSha1.contains(sha1);
      };
      dio.httpClientAdapter = adapter;
    }
    return dio;
  }

  Future<Map<String, String>> _buildHeaders({Map<String, String>? additionalHeaders}) async {
    // Refresh the session JWT if it is about to expire, serialised through
    // SessionRefreshMutex so concurrent refreshes (from ApiService, etc.) are
    // coalesced, and isLoggedOut / passkeyFlowInProgress guards are respected.
    try {
      // L-03: Timeout prevents a hung refresh from blocking every API call.
      await SessionRefreshMutex.guardedRefreshIfNeeded()
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // If refresh fails, proceed with whatever JWT we have (or empty).
      // The caller will handle the 401 response.
    }
    final jwt = Descope.sessionManager.session?.sessionJwt ?? '';
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $projectId:$jwt',
    };
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data, {
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(
          headers: await _buildHeaders(additionalHeaders: additionalHeaders),
        ),
      );
      return response.data ?? {};
    } on DioException {
      throw Exception('Failed to load user data');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: data,
        options: Options(
          headers: await _buildHeaders(additionalHeaders: additionalHeaders),
        ),
      );
      return response.data ?? {};
    } on DioException {
      throw Exception('Failed to load user data');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
