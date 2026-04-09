
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/img_path.dart';
import '../archive_list_notifier.dart';
import '../archive_state.dart';

Widget archiveFilterIcons(ArchiveState s, ArchiveNotifier notifier, BuildContext context) {
  // -------- CLEAR UNREAD / COMMUNITY FILTER ----------
  if (s.emailType == 'unread' || s.emailType == 'community') {
    return IconButton(
      icon: SvgPicture.asset(
        svgUnread,
        height: 20,
        width: 20,
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
      ),
      onPressed: () {
        notifier.clearUnreadFilter();
      },
      tooltip: 'Clear Unread Filter',
    );
  }

  // -------- CLEAR TAG FILTER ----------
  if (s.tagFilter) {
    return IconButton(
      icon: SvgPicture.asset(
        svgTags,
        height: 20,
        width: 20,
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
      ),
      onPressed: () {
        notifier.clearTagFilter();
      },
      tooltip: 'Clear Tag Filter',
    );
  }

  // -------- SHOW FILTER OVERLAY ----------
  return IconButton(
    icon: SvgPicture.asset(
      svgFilter,
      height: 20,
      width: 20,
      colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
    ),
    onPressed: () {
      notifier.toggleFilter();
    },
    tooltip: 'Filter',
  );
}
