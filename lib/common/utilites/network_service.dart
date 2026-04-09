import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class NetworkService {
  // PH-03: Cache the probe result with a 30-second TTL.
  // Eliminates 50–200ms overhead on every API call while still
  // catching captive portals / dead zones within the TTL window.
  static bool _lastProbeResult = true;
  static DateTime? _lastProbeTime;
  static const _probeTtl = Duration(seconds: 30);

  static Future<bool> hasInternet() async {
    // connectivity_plus 6.0.0+ returns a List<ConnectivityResult>
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();

    // If 'none' is in the list, there is no physical connection —
    // invalidate cache immediately so reconnection triggers a fresh probe.
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _lastProbeResult = false;
      _lastProbeTime = null;
      return false;
    }

    // If we have a recent successful probe, skip the actual check.
    if (_lastProbeTime != null &&
        _lastProbeResult &&
        DateTime.now().difference(_lastProbeTime!) < _probeTtl) {
      return true;
    }

    // Bug 27: Use platform-appropriate reachability check.
    // InternetAddress.lookup is not available in web browsers — it throws,
    // causing hasInternet() to always return false and freezing the web UI.
    if (kIsWeb) {
      _lastProbeResult = await _checkWebReachability();
    } else {
      _lastProbeResult = await _checkNativeReachability();
    }
    _lastProbeTime = DateTime.now();
    return _lastProbeResult;
  }

  /// Web: Use HTTP HEAD to verify reachability (DNS lookup unavailable).
  static Future<bool> _checkWebReachability() async {
    try {
      final response = await http
          .head(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  /// Native (iOS/Android): Use DNS lookup for fast reachability check.
  static Future<bool> _checkNativeReachability() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
