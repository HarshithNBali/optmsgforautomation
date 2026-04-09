
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_responsive.dart';

class NotificationList extends ConsumerWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const NotificationResponsive();
  }
}
