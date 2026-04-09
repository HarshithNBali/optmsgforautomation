import 'package:optmsg/common/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/img_path.dart';
import '../inbox_notifier.dart';


Widget filterIconWidget(WidgetRef ref, BuildContext context) {
  final (:emailType, :tagFilter, :searchKey) = ref.watch(
    inboxProvider.select((s) => (
      emailType: s.emailType,
      tagFilter: s.tagFilter,
      searchKey: s.searchKey,
    )),
  );
  final notifier = ref.read(inboxProvider.notifier);

  // Unread active
  if (emailType == 'unread') {
    return IconButton(
      tooltip: 'Clear Unread Filter',
      icon: SvgPicture.asset(
        svgUnread,
        height: 20,
        width: 20,
        colorFilter:
        ColorFilter.mode(context.colors.onSurface, BlendMode.srcIn),
      ),
      onPressed: () {
        notifier.clearUnreadFilterForDesktop(searchKey);
      },
    );
  }

  // Tag filter active
  else if (tagFilter == true) {
    return IconButton(
      tooltip: 'Clear Tag Filter',
      icon: SvgPicture.asset(
        svgTags,
        height: 20,
        width: 20,
        colorFilter:
        ColorFilter.mode(context.colors.onSurface, BlendMode.srcIn),
      ),
      onPressed: () {
        notifier.clearTagFilterForDesktop(searchKey);
      },
    );
  }

  // Default filter icon
  else {
    return IconButton(
      tooltip: 'Filter',
      icon: SvgPicture.asset(
        svgFilter,
        height: 20,
        width: 20,
        colorFilter:
        ColorFilter.mode(context.colors.onSurface, BlendMode.srcIn),
      ),
      onPressed: () {
        notifier.toggleFilter();
      },
    );
  }
}
