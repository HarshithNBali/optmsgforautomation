import 'package:flutter/material.dart';

class ToastManager {
  static OverlayState? _overlayState;

  // Initialize the overlay state - can be called safely multiple times
  static void initialize(BuildContext context) {
    try {
      _overlayState = Overlay.of(context);
    } catch (e) {
      // Overlay not available yet, will be initialized later
    }
  }

  static set overlayState(OverlayState? state) {
    _overlayState = state;
  }

  // Getter to ensure overlay state is available
  static OverlayState get overlayState {
    if (_overlayState == null) {
      throw Exception(
          'ToastManager not initialized. Call ToastManager.initialize() in your app\'s root widget.');
    }
    return _overlayState!;
  }

  // Safe getter that returns null if not initialized
  static OverlayState? get overlayStateOrNull => _overlayState;
}
