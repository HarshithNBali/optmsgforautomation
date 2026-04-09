import 'package:optmsg/common/utilites/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constant/img_path.dart';

void openFullScreenImage(
  BuildContext context,
  String url,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    useSafeArea: false,
    builder: (_) {
      printLog("signed", url);
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back',
              icon: SvgPicture.asset(svgArrowBack, height: 24, width: 24),
              onPressed: () => context.pop(),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final dpr = MediaQuery.of(context).devicePixelRatio;
              final cacheWidth = (constraints.maxWidth * dpr).round();
              final cacheHeight = (constraints.maxHeight * dpr).round();
              return CachedNetworkImage(
                imageUrl: url,
                memCacheWidth: cacheWidth,
                memCacheHeight: cacheHeight,
                httpHeaders: const {
                  'Accept': 'image/*',
                },
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, downloadProgress) {
                  return Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  printLog("error", error.toString());
                  return Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  );
                },
              );
            },
          ),
        ),
      );
    },
  );
}
