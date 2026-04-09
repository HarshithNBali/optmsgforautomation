import 'package:flutter/foundation.dart';

void printLog(String title, dynamic message) {
  if (!kDebugMode) return;
  debugPrint("-----------APPLOG::$title-----------");
  printWrapped(message.toString());
  debugPrint("----------------------------");
}

void printWrapped(String text) {
  const int chunkSize = 800;

  for (int i = 0; i < text.length; i += chunkSize) {
    final int end =
    (i + chunkSize < text.length) ? i + chunkSize : text.length;

    debugPrint(text.substring(i, end));
  }
}

