import 'package:flutter/material.dart';

class WebBackground extends StatelessWidget {
  final Widget child;

  const WebBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/img/webBackground.png'),
            fit: BoxFit.cover,
          ),
          color: Theme.of(context).colorScheme.primary),
      child: SafeArea(
        child: child,
      ),
    );
  }
}
