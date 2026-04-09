import 'package:web/web.dart' as web;

String getWebUserAgent() {
  return web.window.navigator.userAgent;
}

bool isTouchDevice() {
  return web.window.navigator.maxTouchPoints > 0;
}
