import 'package:flutter/material.dart';

/// Stub for non-web platforms. Should never be called at runtime because
/// `openSecurePrint` guards with `kIsWeb` before reaching this.
Future<void> openWebPrint({
  required String printUrl,
  required String token,
  required BuildContext context,
  String? subject,
}) async {
  throw UnsupportedError('openWebPrint is only available on web');
}
