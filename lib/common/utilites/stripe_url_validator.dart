import 'package:optmsg/constant/app_config.dart' as app_config;

/// Validates that a URL is a legitimate payment HTTPS URL.
///
/// Returns `true` if the URL is valid and points to stripe.com or
/// the current environment's API domain (the backend returns its own
/// redirect URL for Stripe checkout, not a direct stripe.com link).
bool isValidStripeUrl(String? url) {
  final uri = Uri.tryParse(url ?? '');
  if (uri == null) return false;
  if (uri.scheme != 'https') return false;
  final host = uri.host;
  final apiHost = Uri.parse(app_config.baseUrl).host;
  return host.endsWith('.stripe.com') ||
      host == 'stripe.com' ||
      host == apiHost;
}
