// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:descope/descope.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/widgets/empty_state.dart';
import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../router/app_routes.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/staticPages/static_pages_notifier.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';

class StaticPages extends ConsumerStatefulWidget {
  final String pageKey;
  final bool showOwnAppBar;
  const StaticPages({
    super.key,
    required this.pageKey,
    this.showOwnAppBar = false,
  });

  @override
  ConsumerState<StaticPages> createState() => _StaticPagesState();
}

class _StaticPagesState extends ConsumerState<StaticPages> {
  final SecureStorageService secureStorageService = SecureStorageService();
  String token = "";
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    getUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(staticPagesProvider.notifier).fetchData(widget.pageKey);
      _pushTitleToShell();
    });
  }

  @override
  void didUpdateWidget(covariant StaticPages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageKey != widget.pageKey) {
      _pushTitleToShell();
    }
  }

  /// Push the resolved page title to the shell's AppBar (only for non-signup flow).
  void _pushTitleToShell() {
    if (!widget.showOwnAppBar && mounted) {
      ShellLayout.of(context)?.setAppBarConfig(AppBarConfig(
        title: _resolveTitle(),
      ));
    }
  }

  Future<void> _handleMailtoTap(String email) async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) return;
    int pageId = DateTime.now().microsecondsSinceEpoch;
    final int offsetInMinutes = DateTime.now().timeZoneOffset.inMinutes;
    if (!mounted) return;
    await context.push(
      AppRoutes.compose,
      extra: {
        'url':
            '${defaultBaseUrl}email/compose?pageId=$pageId&toEmail=$email&timeZone=$offsetInMinutes',
        'token': Descope.sessionManager.session?.sessionJwt ?? token,
        'type': 'contact',
        'email': email,
        'pageId': pageId,
      },
    );
  }

  String _resolveTitle() {
    switch (widget.pageKey) {
      case 'terms_conditions':
        return 'Terms and Conditions';
      case 'privacy_policy':
        return 'Privacy Policy';
      case 'contact_us':
        return 'Contact Us';
      case 'faq':
        return faq;
      default:
        return widget.pageKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Signup flow: render own AppBar (not inside ShellLayout)
    if (widget.showOwnAppBar) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(_resolveTitle()),
        ),
        body: _buildBody(),
      );
    }

    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    final state = ref.watch(staticPagesProvider);
    final notifier = ref.read(staticPagesProvider.notifier);

    if (widget.pageKey == faq || widget.pageKey == 'faq') {
      return DelayedLoadingOverlay(
        isLoading: state.isLoading,
        child: _buildAccordion(state, notifier),
      );
    } else {
      final mediaPadding = MediaQuery.of(context).padding;
      final leftPad = kIsWeb ? 16.0 : mediaPadding.left.clamp(16.0, double.infinity);
      final rightPad = kIsWeb ? 16.0 : mediaPadding.right.clamp(16.0, double.infinity);
      return DelayedLoadingOverlay(
        isLoading: state.isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: leftPad, right: rightPad, top: 16, bottom: 16),
            child: !state.didDataLoad
                ? (state.fetchAttempted && !state.isLoading
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: const Center(
                            child: EmptyState(
                          variant: EmptyStateVariant.generic,
                        )))
                    : const SizedBox.shrink())
                : HtmlWidget(
                    textStyle: AppTypography.profileSubTitle(context),
                    state.htmlData,
                    buildAsync: false,
                    onLoadingBuilder: (_, _, _) =>
                        const SizedBox.shrink(),
                    customWidgetBuilder: (element) {
                      final href = element.attributes['href'] ?? '';
                      if (href.startsWith('mailto:')) {
                        final email = href.substring(7);
                        return InlineCustomWidget(
                          child: GestureDetector(
                            onTap: () => _handleMailtoTap(email),
                            child: Text(
                              element.text,
                              style: AppTypography.profileSubTitle(context).copyWith(
                                color: context.appColors.accent,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                    onTapUrl: (url) async {
                      if (url.startsWith('mailto:')) {
                        final email = url.substring(7);
                        await _handleMailtoTap(email);
                        return true;
                      }
                      const pattern =
                          r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
                      final regExp = RegExp(pattern);
                      if (regExp.hasMatch(url)) {
                        final openUrl = Uri.parse(url);
                        if (await canLaunchUrl(openUrl)) {
                          await launchUrl(openUrl,
                              mode: LaunchMode.externalApplication);
                        }
                      }
                      return true;
                    },
                  ),
          ),
        ),
      );
    }
  }

  Widget _buildAccordion(StaticPagesState state, StaticPagesNotifier notifier) {
    return Card(
      child: ListView(
        children: state.faq.asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          final item = entry.value;
          return ExpansionPanelList(
            elevation: 1,
            expandedHeaderPadding: const EdgeInsets.all(8.0),
            expansionCallback: (int _, bool isExpanded) {
              notifier.toggleFaqExpansion(index);
            },
            children: [
              ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(item['question'],
                        style: AppTypography.titleLarge(context)),
                  );
                },
                body: ListTile(
                  title: Text(item['answer']),
                ),
                isExpanded: item['isExpanded'] == true,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> getUserData() async {
    userData = ref.read(authProvider).userData;
    if (mounted) {
      setState(() {
        token = userData?['token'] ?? '';
      });
    }
  }
}
