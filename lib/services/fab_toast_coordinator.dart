import 'package:flutter/foundation.dart';

/// Coordinates FAB positioning with toast visibility.
///
/// When a toast is showing, the FAB animates upward to avoid being covered.
class FabToastCoordinator {
  FabToastCoordinator._();

  static final ValueNotifier<bool> isToastVisible = ValueNotifier<bool>(false);
}
