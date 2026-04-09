import 'package:optmsg/webPackerHandler/mobile_check_out.dart'
    if (dart.library.js_interop) 'package:optmsg/webPackerHandler/web_check_out.dart';

class CheckPlatform {
  final CheckOutImp _checkOutImp;

  CheckPlatform() : _checkOutImp = CheckOutImp();

  /// Opens a new browser window with the given [url].
  ///
  /// On web, uses the [CheckOutImp] class to open the window.
  ///
  /// Optional [features] parameter is not used on web.
  ///
  void check(String url, [String? features]) {
    _checkOutImp.webWindowOpen(url);
  }

  /// Downloads a file from the given [url].
  ///
  /// On web, uses the [CheckOutImp] class to perform the download.

  Future<void> download(String url, {String? suggestedName}) async {
    await _checkOutImp.downloadWebFile(url, suggestedName: suggestedName);
  }

  /// Checks if the current web browser's user agent contains specific substrings.
  ///
  /// This function delegates the check to the [CheckOutImp] implementation.
  /// It typically checks for browser-specific identifiers, such as 'Safari'
  /// or 'Chrome', to determine the browser being used.
  ///
  /// Returns a boolean indicating whether the user agent contains the desired substrings.

  bool webWindowNavigatorUserAgentContains() {
    return _checkOutImp.webWindowNavigatorUserAgentContains();
  }
}
