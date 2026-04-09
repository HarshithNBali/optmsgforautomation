import 'package:http/http.dart' as http;

http.Client createPlatformHttpClient() {
  throw UnsupportedError('Cannot create HTTP client without dart:io or dart:html');
}
