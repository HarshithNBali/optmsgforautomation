
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _LoaderNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final loaderProvider = NotifierProvider<_LoaderNotifier, bool>(_LoaderNotifier.new);
