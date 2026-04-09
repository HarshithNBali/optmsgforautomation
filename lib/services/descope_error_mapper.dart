import 'package:descope/descope.dart';

/// Maps raw Descope error codes to consumer-friendly messages.
///
/// Descope exceptions contain internal codes like "E064001" that should never
/// be shown in a consumer product. Call this from every `on DescopeException`
/// catch block that surfaces a message to the user.
String mapDescopeError(DescopeException e) {
  return switch (e.code) {
    'E061001' => 'That code is incorrect. Please try again.',
    'E061002' => 'That code has expired. Tap Resend for a new one.',
    'E062001' => 'No account found with that username.',
    'E064001' => 'Incorrect username.',
    _ => 'Something went wrong. Please try again.',
  };
}
