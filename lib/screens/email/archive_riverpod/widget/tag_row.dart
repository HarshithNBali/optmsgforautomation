import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/app_typography.dart';
import '../../../../constant/img_path.dart';

Widget tagRow(String label, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        SvgPicture.asset(
          svgTags,
          height: 20,
          width: 20,
          colorFilter:
          ColorFilter.mode(Theme.of(context).colorScheme.onSurfaceVariant, BlendMode.srcIn),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.titleSmall(context).copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    ),
  );
}
