import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:optmsg/services/action_biometric_guard.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:optmsg/model/view_email_model.dart';

import '../../constant/app_config.dart';
import '../../constant/string_constant.dart';
import '../../constant/styles.dart';
import '../../services/common_service.dart';
import '../../webPackerHandler/mobile_check_out.dart';

/// Full-screen attachment previewer supporting images and PDFs (top-level).
class AttachmentPreviewScreen extends ConsumerStatefulWidget {
  final List<Attachments> attachments;
  final List<String>? previewUrls;
  final int initialIndex;
  const AttachmentPreviewScreen({
    super.key,
    required this.attachments,
    this.previewUrls,
    required this.initialIndex,
  });

  @override
  ConsumerState<AttachmentPreviewScreen> createState() =>
      _AttachmentPreviewScreenState();
}

class _AttachmentPreviewScreenState
    extends ConsumerState<AttachmentPreviewScreen> {
  late PageController _pageController;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ADD THIS METHOD HERE
  Future<String> _generateExcelHtml(String url) async {
    try {
      // Fetch the Excel file
      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      // Convert to base64
      final base64Data = base64Encode(response.data);

      // Generate HTML with SheetJS
      return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
  <style>
    body {
      margin: 0;
      padding: 16px;
      font-family: Arial, sans-serif;
      background: #f5f5f5;
    }
    .sheet-selector {
      margin-bottom: 16px;
      padding: 8px;
      background: white;
      border-radius: 4px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    select {
      padding: 8px 12px;
      font-size: 14px;
      border: 1px solid #ddd;
      border-radius: 4px;
      min-width: 200px;
    }
    .table-container {
      overflow: auto;
      background: white;
      border-radius: 4px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    table {
      border-collapse: collapse;
      width: 100%;
      font-size: 14px;
    }
    th, td {
      border: 1px solid #ddd;
      padding: 8px 12px;
      text-align: left;
      white-space: nowrap;
    }
    th {
      background-color: #f8f9fa;
      font-weight: 600;
      position: sticky;
      top: 0;
      z-index: 1;
    }
    tr:nth-child(even) {
      background-color: #f9f9f9;
    }
    tr:hover {
      background-color: #f0f0f0;
    }
    .loading {
      text-align: center;
      padding: 40px;
      color: #666;
    }
  </style>
</head>
<body>
  <div class="loading">Loading Excel file...</div>
  <div class="sheet-selector" style="display:none;">
    <label for="sheetSelect">Sheet: </label>
    <select id="sheetSelect" onchange="renderSheet()"></select>
  </div>
  <div class="table-container" id="tableContainer"></div>

  <script>
    let workbook = null;

    async function loadExcel() {
      try {
        const base64Data = '$base64Data';
        const binaryString = atob(base64Data);
        const bytes = new Uint8Array(binaryString.length);
        for (let i = 0; i < binaryString.length; i++) {
          bytes[i] = binaryString.charCodeAt(i);
        }
        
        workbook = XLSX.read(bytes, { type: 'array' });
        
        const sheetSelect = document.getElementById('sheetSelect');
        workbook.SheetNames.forEach((name, index) => {
          const option = document.createElement('option');
          option.value = index;
          option.textContent = name;
          sheetSelect.appendChild(option);
        });
        
        document.querySelector('.sheet-selector').style.display = 'block';
        document.querySelector('.loading').style.display = 'none';
        
        renderSheet();
      } catch (error) {
        document.querySelector('.loading').textContent = 'Error loading Excel file: ' + error.message;
      }
    }

    function renderSheet() {
      const sheetIndex = parseInt(document.getElementById('sheetSelect').value);
      const sheetName = workbook.SheetNames[sheetIndex];
      const worksheet = workbook.Sheets[sheetName];
      
      const html = XLSX.utils.sheet_to_html(worksheet, { editable: false });
      document.getElementById('tableContainer').innerHTML = html;
    }

    loadExcel();
  </script>
</body>
</html>
      ''';
    } catch (e) {
      throw Exception('Failed to generate Excel preview: $e');
    }
  }

  // late PageController _pageController;
  // int _current = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   _current = widget.initialIndex;
  //   _pageController = PageController(initialPage: _current);
  // }

  // @override
  // void dispose() {
  //   _pageController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppBreakpoints.isTabletLayout(context);
    final isNativeTabletLandscape =
        !kIsWeb &&
        isTablet &&
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (!kIsWeb && !isNativeTabletLandscape) {
      // Mobile full-screen viewer — AppBar handled by ShellLayout via config
      final current = widget.attachments[_current];
      final fileName = CommonService().getFileName(current.path ?? '');

      // Push AppBarConfig with filename title — push route, must include title
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ShellLayout.of(context)?.setAppBarConfig(AppBarConfig(
            title: fileName,
          ));
        }
      });

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _current = i),
              itemCount: widget.attachments.length,
              itemBuilder: (context, index) {
                final att = widget.attachments[index];
                final url =
                    (widget.previewUrls != null &&
                        widget.previewUrls!.length == widget.attachments.length)
                    ? widget.previewUrls![index]
                    : s3BaseUrl + (att.path ?? '');
                return _buildPreviewContent(att, url);
              },
            ),
            if (widget.attachments.length > 1)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FloatingActionButton.small(
                    heroTag: 'prev_att',
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
                    onPressed: _current > 0
                        ? () {
                            final to = _current - 1;
                            _pageController.animateToPage(
                              to,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          }
                        : null,
                    // child: const Icon(Icons.chevron_left, color: Colors.black87),
                    child: Opacity(
                      opacity: _current > 0 ? 1.0 : 0.4,
                      child: Icon(
                        Icons.chevron_left,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.attachments.length > 1)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FloatingActionButton.small(
                    heroTag: 'next_att',
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
                    onPressed: _current < widget.attachments.length - 1
                        ? () {
                            final to = _current + 1;
                            _pageController.animateToPage(
                              to,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          }
                        : null,
                    // child: const Icon(Icons.chevron_right, color: Colors.black87),
                    child: Opacity(
                      opacity: _current < widget.attachments.length - 1
                          ? 1.0
                          : 0.4,
                      child: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Web overlay viewer (Outlook-like)
    final media = MediaQuery.of(context);
    final maxWidth = media.size.width >= AppBreakpoints.largeDesktop
        ? 900.0
        : media.size.width - 320.0;
    final current = widget.attachments[_current];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.8),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: media.size.height - 60,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      height: 48,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () => context.pop(),
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              CommonService().getFileName(current.path ?? ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Download',
                            onPressed: () async {
                              try {
                                final String path = current.path ?? '';
                                String signedUrl = s3BaseUrl + path;
                                final Map<String, dynamic> resp =
                                    await ApiService().post(attachmentUrlApi, {
                                      "file": path,
                                    });
                                if (resp['success'] == true &&
                                    resp['data'] != null) {
                                  signedUrl =
                                      resp['data']['signedUrl'] ?? signedUrl;
                                }
                                // Open in new tab on web
                                if (kIsWeb) {
                                  CheckOutImp().webWindowOpenPrint(
                                    signedUrl,
                                    'new tab',
                                  );
                                } else {
                                  // Fallback for non-web platforms
                                  final uri = Uri.parse(signedUrl);
                                  if (await canLaunchUrl(uri)) {
                                    ActionBiometricGuard.markDeparture();
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                }
                              } catch (e) {
                                CommonService.animatedToast(
                                  catchError,
                                  'error',
                                );
                              }
                            },
                            icon: Icon(
                              Icons.download_rounded,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Print',
                            onPressed: () async {
                              try {
                                final String path = current.path ?? '';
                                String signedUrl = s3BaseUrl + path;
                                final Map<String, dynamic> resp =
                                    await ApiService().post(attachmentUrlApi, {
                                      "file": path,
                                    });
                                if (resp['success'] == true &&
                                    resp['data'] != null) {
                                  signedUrl =
                                      resp['data']['signedUrl'] ?? signedUrl;
                                }
                                if (kIsWeb) {
                                  CheckOutImp().webWindowOpenPrint(
                                    signedUrl,
                                    'new tab',
                                  );
                                } else {
                                  final uri = Uri.parse(signedUrl);
                                  if (await canLaunchUrl(uri)) {
                                    ActionBiometricGuard.markDeparture();
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                }
                              } catch (e) {
                                CommonService.animatedToast(
                                  catchError,
                                  'error',
                                );
                              }
                            },
                            icon: Icon(
                              Icons.print_rounded,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _current = i),
                        itemCount: widget.attachments.length,
                        itemBuilder: (context, index) {
                          final att = widget.attachments[index];
                          final url =
                              (widget.previewUrls != null &&
                                  widget.previewUrls!.length ==
                                      widget.attachments.length)
                              ? widget.previewUrls![index]
                              : s3BaseUrl + (att.path ?? '');
                          return _buildPreviewContent(att, url);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.attachments.length > 1)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: _current > 0
                        ? () {
                            final to = _current - 1;
                            _pageController.animateToPage(
                              to,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          }
                        : null,
                    child: Opacity(
                      opacity: _current > 0 ? 1 : 0.4,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.attachments.length > 1)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: _current < widget.attachments.length - 1
                        ? () {
                            final to = _current + 1;
                            _pageController.animateToPage(
                              to,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                            );
                          }
                        : null,
                    child: Opacity(
                      opacity: _current < widget.attachments.length - 1
                          ? 1
                          : 0.4,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent(Attachments att, String resolvedUrl) {
    final ext = (att.type ?? '').toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
    final isPdf = ext == 'pdf';
    final isExcel = ['xls', 'xlsx'].contains(ext);
    final isOffice = [
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
    ].contains(ext);
    final url = resolvedUrl;

    if (isImage) {
      // Show loader until the image is rendered
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 5,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            progressIndicatorBuilder: (context, url, downloadProgress) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            errorWidget: (context, url, error) =>
                const Center(child: Text('Failed to load preview')),
          ),
        ),
      );
    }

    if (isExcel) {
      return FutureBuilder<String>(
        future: _generateExcelHtml(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load Excel preview: ${snapshot.error}'),
            );
          }

          return InAppWebView(
            initialData: InAppWebViewInitialData(data: snapshot.data!),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              supportZoom: true,
              useWideViewPort: true,
            ),
          );
        },
      );
    }

    if (isOffice) {
      if (kIsWeb) {
        // final officeViewer = 'https://view.officeapps.live.com/op/view.aspx?src=' + Uri.encodeComponent(url);
        final officeViewer =
            'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(url)}';
        return InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(officeViewer)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            supportZoom: true,
            useWideViewPort: true,
          ),
        );
      } else {
        // Add a cache-busting timestamp to avoid blank first render on mobile
        final mobileViewerUrl =
            'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(url)}&ts=${DateTime.now().millisecondsSinceEpoch}';
        bool localLoading = true;
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return Stack(
              children: [
                InAppWebView(
                  key: ValueKey(mobileViewerUrl),
                  initialUrlRequest: URLRequest(url: WebUri(mobileViewerUrl)),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    supportZoom: true,
                    useWideViewPort: true,
                  ),
                  onLoadStart: (_, _) {
                    localLoading = true;
                  },
                  onLoadStop: (_, _) => setStateSB(() => localLoading = false),
                ),
                if (localLoading)
                  Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      }
    }

    if (isPdf) {
      if (kIsWeb) {
        // final viewerUrl = 'https://mozilla.github.io/pdf.js/web/viewer.html?file=' + Uri.encodeComponent(url);
        final viewerUrl =
            'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(url)}';
        return InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(viewerUrl)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            supportZoom: true,
            useWideViewPort: true,
          ),
        );
      } else {
        // Add a cache-busting timestamp to avoid blank first render on mobile
        final mobileViewerUrl =
            'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(url)}&ts=${DateTime.now().millisecondsSinceEpoch}';
        bool localLoading = true;
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return Stack(
              children: [
                InAppWebView(
                  key: ValueKey(mobileViewerUrl),
                  initialUrlRequest: URLRequest(url: WebUri(mobileViewerUrl)),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    supportZoom: true,
                    useWideViewPort: true,
                  ),
                  onLoadStart: (_, _) {
                    localLoading = true;
                  },
                  onLoadStop: (_, _) => setStateSB(() => localLoading = false),
                ),
                if (localLoading)
                  Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      }
    }

    // Web view types (pdf or others) with per-page loader
    // return StatefulBuilder(builder: (context, setStateSB) {
    //   bool localLoading = true;
    //   return Stack(
    //     children: [
    //       InAppWebView(
    //         initialUrlRequest: URLRequest(url: WebUri(url)),
    //         initialSettings: InAppWebViewSettings(
    //           javaScriptEnabled: true,
    //           supportZoom: true,
    //           useWideViewPort: true,
    //           allowsBackForwardNavigationGestures: true,
    //         ),
    //         onLoadStart: (_, __) => setStateSB(() => localLoading = true),
    //         onLoadStop: (_, __) => setStateSB(() => localLoading = false),
    //       ),
    //       if (localLoading)
    //         const Positioned.fill(
    //           child: Center(child: CircularProgressIndicator(color: AppStyles.blueBackground)),
    //         ),
    //     ],
    //   );
    // });
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        supportZoom: true,
        useWideViewPort: true,
        allowsBackForwardNavigationGestures: true,
      ),
    );
  }
}
