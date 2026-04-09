import 'package:descope/descope.dart';

/// Strips `token` and `tokentype` query parameters from a URL to prevent
/// JWT exposure in browser history, server logs, and HTTP Referer headers.
Uri stripTokenFromUri(Uri uri) {
  if (!uri.queryParameters.containsKey('token')) return uri;
  final params = Map<String, String>.from(uri.queryParameters)
    ..remove('token')
    ..remove('tokentype');
  if (params.isEmpty) {
    // Rebuild without query to avoid trailing '?' from Uri.replace(query: '')
    return Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.port,
      path: uri.path,
      fragment: uri.fragment.isEmpty ? null : uri.fragment,
    );
  }
  return uri.replace(queryParameters: params);
}

/// Convenience wrapper that accepts and returns a [String].
String stripTokenFromUrl(String url) {
  return stripTokenFromUri(Uri.parse(url)).toString();
}

/// Returns the current Descope session JWT, falling back to [fallback].
String getSessionToken([String fallback = '']) {
  return Descope.sessionManager.session?.sessionJwt ?? fallback;
}
