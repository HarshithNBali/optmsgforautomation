import 'package:optmsg/common/utilites/logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constant/img_path.dart';

void openFullScreenWebView(
  BuildContext context,
  String url,
) {
  printLog("url", url);
  showDialog(
    context: context,
    barrierDismissible: false,
    useSafeArea: false,
    builder: (_) {
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
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              useWideViewPort: true,
              loadWithOverviewMode: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              useShouldOverrideUrlLoading: true,
            ),
            onReceivedError: (controller, request, error) {
              debugPrint('WebView load error: ${error.description}');
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              debugPrint('HTTP error: ${errorResponse.statusCode} ${errorResponse.reasonPhrase}');
            },
          ),
        ),
      );
    },
  );
}
