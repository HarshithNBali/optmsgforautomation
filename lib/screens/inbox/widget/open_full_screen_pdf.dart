import 'package:optmsg/common/utilites/logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constant/img_path.dart';

void openFullScreenPDF(
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
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back',
              icon: SvgPicture.asset(svgArrowBack, height: 24, width: 24),
              onPressed: () => context.pop(),
            ),
          ),
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            /*child: SfPdfViewer.network(url,
                canShowScrollHead: true,
                canShowScrollStatus: true, onDocumentLoadFailed: (details) {
              debugPrint("PDF load failed: ${details.error}");
              debugPrint("Description: ${details.description}");
            }),*/
          ),
        ),
      );
    },
  );
}
