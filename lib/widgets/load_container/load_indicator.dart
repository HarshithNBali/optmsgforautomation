import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class LoaderIndicator extends StatelessWidget {
  const LoaderIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return !kIsWeb && Platform.isIOS
        ? const CupertinoActivityIndicator(radius: 15)
        : const CircularProgressIndicator();
  }
}
