import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/widgets/add_email_modal.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/screens/compose/compose_riverpod/compose_notifier.dart';
import 'package:optmsg/screens/compose/compose_riverpod/compose_state.dart';
import 'package:optmsg/screens/compose/widgets/attachment_row.dart';
import 'package:optmsg/screens/compose/widgets/cc_bcc_toggle.dart';
import 'package:optmsg/screens/compose/widgets/compose_editor.dart';
import 'package:optmsg/screens/compose/widgets/compose_toolbar.dart';
import 'package:optmsg/screens/compose/widgets/from_field.dart';
import 'package:optmsg/screens/compose/widgets/recipient_field.dart';
import 'package:optmsg/screens/compose/widgets/subject_field.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/widgets/load_container/load_indicator.dart'
    show LoaderIndicator;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Native Flutter compose screen — replaces the legacy WebView compose.
///
/// Uses a single [SingleChildScrollView] so header fields and the Quill.js
/// editor scroll as one unit (matching the ViewEmail paradigm).
class ComposeScreen extends ConsumerStatefulWidget {
  final ComposeParams params;
  final bool hideAppBar;

  const ComposeScreen({
    super.key,
    required this.params,
    this.hideAppBar = false,
  });

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen>
    with WidgetsBindingObserver {
  final TextEditingController _subjectController = TextEditingController();
  final GlobalKey<ComposeEditorState> _editorKey = GlobalKey();
  final FocusNode _toFieldFocusNode = FocusNode();
  final ValueNotifier<double> _editorHeight = ValueNotifier<double>(250);
  Map<String, dynamic> _activeFormats = {};
  bool _headerCollapsed = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pushAppBarConfig();
    _setComposeFlag(true);
  }

  @override
  void dispose() {
    _autoSaveOnExit();
    WidgetsBinding.instance.removeObserver(this);
    _setComposeFlag(false);
    _toFieldFocusNode.dispose();
    _subjectController.dispose();
    _editorHeight.dispose();
    super.dispose();
  }

  /// Fire-and-forget server save on dispose (desktop/tablet navigate-away).
  /// Uses a state snapshot + ApiService directly — doesn't depend on the
  /// notifier staying alive after the widget disposes.
  void _autoSaveOnExit() {
    final notifier = ref.read(composeProvider(widget.params).notifier);
    if (notifier.isDiscarded) return;

    // Flush any cached editor content into state before reading
    notifier.syncCachedContent();
    final state = ref.read(composeProvider(widget.params));

    if (state.sendStatus == SendStatus.sent ||
        state.sendStatus == SendStatus.partialFailure) {
      return;
    }
    if (!state.hasContent || (!state.isDirty && state.draftId != null)) {
      return;
    }

    _saveDraftInBackground(state);
  }

  /// Static fire-and-forget save — no dependency on notifier lifecycle.
  static Future<void> _saveDraftInBackground(ComposeState state) async {
    try {
      final payload = {
        'to': state.toRecipients,
        'cc': state.ccRecipients,
        'bcc': state.bccRecipients,
        'subject': state.subject,
        'body': state.bodyHtml,
        'attachments': state.attachments.map((a) => a.toServerJson()).toList(),
        if (state.emailId != null) 'replyToEmailId': state.emailId,
      };

      if (state.draftId != null) {
        await ApiService().put('email/draft/${state.draftId}', payload);
      } else {
        await ApiService().post('email/draft', payload);
      }
    } catch (_) {
      // Best effort — local autosave is the safety net
    }
  }

  Future<void> _setComposeFlag(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('inCompose', value);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Autosave when app is backgrounded
      ref.read(composeProvider(widget.params).notifier).autosaveToLocal();
    }
  }

  void _pushAppBarConfig() {
    if (widget.hideAppBar) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isMobile = AppBreakpoints.isMobileLayout(context);
      ShellLayout.of(context)?.setAppBarConfig(
        AppBarConfig(
          title: _titleForMode(widget.params.mode),
          // Only show attach/send in AppBar on mobile — desktop has its own header bar
          customActions: isMobile
              ? [
                  IconButton(
                    key: const Key('compose_mobile_discard_button'),
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _handleDiscard,
                  ),
                  IconButton(
                    key: const Key('compose_mobile_attach_button'),
                    icon: const Icon(Icons.attach_file),
                    onPressed: _handleAttach,
                  ),
                  IconButton(
                    key: const Key('compose_mobile_send_button'),
                    icon: const Icon(Icons.send),
                    onPressed: _handleSend,
                  ),
                ]
              : null,
          onBackPressed: _handleBack,
        ),
      );
    });
  }

  String _titleForMode(ComposeMode mode) {
    switch (mode) {
      case ComposeMode.reply:
        return 'Reply';
      case ComposeMode.replyAll:
        return 'Reply All';
      case ComposeMode.forward:
        return 'Forward';
      case ComposeMode.updateDraft:
        return 'Edit Draft';
      default:
        return 'New Message';
    }
  }

  // ── Actions ──

  Future<void> _handleSend() async {
    await _syncEditorContent();
    if (!mounted) return;
    ref.read(composeProvider(widget.params).notifier).send();
  }

  void _handleAttach() {
    _showAttachmentPicker();
  }

  Future<void> _showAttachmentPicker() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      // Native: show action sheet with Gallery + File options
      final result = await showCupertinoModalPopup<String>(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: const Text('Gallery'),
              onPressed: () => Navigator.pop(ctx, 'gallery'),
            ),
            CupertinoActionSheetAction(
              child: const Text('File'),
              onPressed: () => Navigator.pop(ctx, 'file'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ),
      );
      if (!mounted || result == null) return;
      // Delay to let action sheet dismiss before presenting picker
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      final notifier = ref.read(composeProvider(widget.params).notifier);
      if (result == 'gallery') {
        await notifier.pickAndUploadImage();
      } else {
        await notifier.pickAndUploadFile();
      }
    } else {
      // Web: file picker only
      await ref
          .read(composeProvider(widget.params).notifier)
          .pickAndUploadFile();
    }
  }

  Future<void> _handleBack() async {
    final notifier = ref.read(composeProvider(widget.params).notifier);
    final state = ref.read(composeProvider(widget.params));

    if (!state.hasContent) {
      context.pop();
      return;
    }

    final isMobile = AppBreakpoints.isMobileLayout(context);
    if (isMobile) {
      await showCupertinoModalPopup(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          actions: [
            PointerInterceptor(
              intercepting: kIsWeb,
              child: CupertinoActionSheetAction(
                child: const Text('Save Draft'),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _syncEditorContent();
                  final saved = await notifier.saveDraftToServer(quiet: true);
                  if (mounted) {
                    if (saved) {
                      CommonService.animatedToast('Draft saved', 'success');
                    }
                    // Explicitly invalidate to clear state for next session
                    ref.invalidate(composeProvider(widget.params));
                    context.pop('draftSaved');
                  }
                },
              ),
            ),
            PointerInterceptor(
              intercepting: kIsWeb,
              child: CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _handleDiscard();
                  // Invalidate after discard
                  ref.invalidate(composeProvider(widget.params));
                  if (mounted) context.pop('draftDiscarded');
                },
                child: const Text('Discard'),
              ),
            ),
          ],
          cancelButton: PointerInterceptor(
            intercepting: kIsWeb,
            child: CupertinoActionSheetAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
        ),
      );
      return;
    }

    // Default desktop-like behavior (currently it auto-saves and pops)
    // Sync latest editor content and save to server before leaving
    if (state.isDirty || state.draftId == null) {
      await _syncEditorContent();
      if (!mounted) return;
      final saved = await notifier.saveDraftToServer(quiet: true);
      if (!mounted) return;
      if (saved) {
        CommonService.animatedToast('Draft saved', 'success');
      }
    }

    // Explicitly invalidate before popping
    ref.invalidate(composeProvider(widget.params));
    context.pop('draftSaved');
  }

  Future<void> _handleDiscard() async {
    final success = await ref
        .read(composeProvider(widget.params).notifier)
        .discard();
    if (success && mounted) {
      ref.invalidate(composeProvider(widget.params));
      context.pop('draftDiscarded');
    }
  }

  Future<void> _syncEditorContent() async {
    final html = await _editorKey.currentState?.getContent() ?? '';
    ref.read(composeProvider(widget.params).notifier).updateBodyHtml(html);
  }

  /// Handle unknownContacts response from server — show AddEmailModal for
  /// each unknown contact, then re-send with skipContactCheck: true.
  Future<void> _handleUnknownContacts(String errorPayload) async {
    final jsonStr = errorPayload.replaceFirst('unknownContacts:', '');
    final List<String> emails;
    try {
      emails = List<String>.from(jsonDecode(jsonStr) as List);
    } catch (_) {
      return;
    }
    if (emails.isEmpty) return;

    for (int i = 0; i < emails.length; i++) {
      if (!mounted) return;
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AddEmailModal(
          title: emails[i],
          subtitle: emails[i],
          type: 'compose',
          currentIndex: i,
          totalEmails: emails.length,
        ),
      );
      if (result == 'cancel-email') return;
      if (result == 'skip_all') break;
    }

    if (!mounted) return;
    // Re-send with contact check skipped
    await _syncEditorContent();
    ref
        .read(composeProvider(widget.params).notifier)
        .send(skipContactCheck: true);
  }

  // ── Initialization sync (one-time: populate subject controller from state) ──

  void _syncFromState(ComposeState state) {
    if (!_initialized && !state.isLoading) {
      _initialized = true;
      _subjectController.text = state.subject;
      // Editor content is set via ComposeEditor.initialHtml or setContent
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(composeProvider(widget.params));
    _syncFromState(state);

    // Listen for send lifecycle changes
    ref.listen(composeProvider(widget.params), (prev, next) {
      if (!mounted) return;

      // Success — navigate away
      if (next.sendStatus == SendStatus.sent) {
        ref.invalidate(composeProvider(widget.params));
        context.pop('sent');
        return;
      }

      // Partial failure (internal delivered, SES failed) — navigate to Sent
      if (next.sendStatus == SendStatus.partialFailure) {
        ref.invalidate(composeProvider(widget.params));
        context.pop('sent');
        return;
      }

      // Unknown contacts — show AddEmailModal for each, then re-send
      if (next.error != null &&
          next.error!.startsWith('unknownContacts:') &&
          prev?.error != next.error) {
        _handleUnknownContacts(next.error!);
      }
    });

    if (state.isLoading) {
      return const Scaffold(body: Center(child: LoaderIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = AppBreakpoints.isMobileLayout(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        key: const Key('compose_screen'),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              // Desktop/tablet header bar (shows in reading pane too)
              if (!isMobile) _buildDesktopHeaderBar(context, state),
              // Platform-aware layout:
              // - Native (iOS/Android): CustomScrollView with slivers —
              //   header scrolls away, toolbar pins, editor in SliverFillRemaining
              // - Web: Column with Flexible header + pinned toolbar + Expanded editor
              //   (iframe can't participate in Flutter sliver scroll)
              if (kIsWeb)
                ..._buildWebLayout(context, state, isDark)
              else
                ..._buildNativeLayout(context, state, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared widgets used by both layouts ──

  Widget _buildHeaderFields(ComposeState state) {
    final totalRecipients =
        state.toRecipients.length +
        state.ccRecipients.length +
        state.bccRecipients.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FromField(
          testId: 'compose_from_field',
          fromName: state.fromName,
          fromEmail: state.fromEmail,
        ),
        Row(
          children: [
            Expanded(
              child: RecipientField(
                testId: 'compose_to_field',
                label: 'To',
                recipients: state.toRecipients,
                onChanged: ref
                    .read(composeProvider(widget.params).notifier)
                    .updateToRecipients,
                focusNode: _toFieldFocusNode,
                totalRecipientCount: totalRecipients,
              ),
            ),
            CcBccToggle(
              isExpanded: state.showCcBcc,
              onToggle: ref
                  .read(composeProvider(widget.params).notifier)
                  .toggleCcBcc,
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: state.showCcBcc
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RecipientField(
                      testId: 'compose_cc_field',
                      label: 'Cc',
                      recipients: state.ccRecipients,
                      onChanged: ref
                          .read(composeProvider(widget.params).notifier)
                          .updateCcRecipients,
                      totalRecipientCount: totalRecipients,
                    ),
                    RecipientField(
                      testId: 'compose_bcc_field',
                      label: 'Bcc',
                      recipients: state.bccRecipients,
                      onChanged: ref
                          .read(composeProvider(widget.params).notifier)
                          .updateBccRecipients,
                      totalRecipientCount: totalRecipients,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        SubjectField(
          testId: 'compose_subject_field',
          controller: _subjectController,
          onChanged: ref
              .read(composeProvider(widget.params).notifier)
              .updateSubject,
        ),
        AttachmentRow(
          attachments: state.attachments,
          onRemove: ref
              .read(composeProvider(widget.params).notifier)
              .removeAttachment,
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return ComposeToolbar(
      activeFormats: _activeFormats,
      onFormat: (cmd) {
        _editorKey.currentState?.applyFormat(cmd.format, cmd.value);
      },
      onUndo: () => _editorKey.currentState?.undo(),
      onRedo: () => _editorKey.currentState?.redo(),
    );
  }

  Widget _buildEditor(ComposeState state, bool isDark) {
    return ComposeEditor(
      key: _editorKey,
      initialHtml: state.bodyHtml.isNotEmpty ? state.bodyHtml : null,
      isDarkMode: isDark,
      onContentChanged: (html) {
        final notifier = ref.read(composeProvider(widget.params).notifier);
        notifier.cacheBodyHtml(html);
        notifier.markDirty();
      },
      onActiveFormatsChanged: (formats) {
        setState(() => _activeFormats = formats);
      },
      onScrollAtTop: (atTop) {
        if (_headerCollapsed == atTop) {
          setState(() => _headerCollapsed = !atTop);
        }
      },
      onHeightChanged: (h) {
        // Only update if the height changed significantly (>10px) to
        // avoid rapid re-layouts that trigger disposed-view errors on web.
        if ((h - _editorHeight.value).abs() > 10) {
          if (kDebugMode) {
            debugPrint(
              '[COMPOSE] editorHeight changed: $h (was ${_editorHeight.value})',
            );
          }
          _editorHeight.value = h;
        }
      },
      onEditorReady: () {
        // Compose/Forward: focus To field to add recipients
        // Reply/ReplyAll: focus editor body to start typing
        final mode = widget.params.mode;
        if (mode == ComposeMode.reply || mode == ComposeMode.replyAll) {
          _editorKey.currentState?.focusEditor();
        } else {
          // newMessage, forward, updateDraft — focus To field
          _toFieldFocusNode.requestFocus();
        }
      },
    );
  }

  // ── Native layout (iOS/Android): Column with header + toolbar + editor ──
  // Header fields stay visible (scrollable internally when overflow),
  // toolbar is always pinned, editor InAppWebView fills remaining space
  // and scrolls internally for long content.
  // Note: CustomScrollView + SliverFillRemaining causes scroll freezes
  // because Flutter's sliver scroll and InAppWebView's platform scroll
  // fight each other. The Column approach is stable on both platforms.
  List<Widget> _buildNativeLayout(
    BuildContext context,
    ComposeState state,
    bool isDark,
  ) {
    // Column layout: header collapses when editor scrolls down,
    // expands when editor scrolls back to top. The InAppWebView's
    // WKWebView handles all editor content scrolling natively —
    // no Flutter scroll widgets compete for gestures.
    return [
      // Header fields — collapse/expand based on editor scroll position
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: _headerCollapsed
            ? const SizedBox.shrink()
            : _buildHeaderFields(state),
      ),
      _buildToolbar(),
      Expanded(child: _buildEditor(state, isDark)),
    ];
  }

  // ── Web layout: same collapse pattern as native ──
  // Header collapses when editor scrolls down, expands when editor
  // scrolls back to top. Iframe handles its own internal scroll.
  List<Widget> _buildWebLayout(
    BuildContext context,
    ComposeState state,
    bool isDark,
  ) {
    return [
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: _headerCollapsed
            ? const SizedBox.shrink()
            : _buildHeaderFields(state),
      ),
      _buildToolbar(),
      Expanded(child: _buildEditor(state, isDark)),
    ];
  }

  Widget _buildDesktopHeaderBar(BuildContext context, ComposeState state) {
    final dividerColor = context.colors.outlineVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(width: 0.5, color: dividerColor)),
      ),
      child: Row(
        children: [
          // Send button (matches existing CommonWebButton style)
          ElevatedButton.icon(
            key: const Key('compose_desktop_send_button'),
            onPressed: state.canSend && !state.isSending ? _handleSend : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isSending
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : context.appColors.accentButton,
              foregroundColor: context.colors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: state.isSending
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.onPrimary,
                    ),
                  )
                : const Icon(Icons.send, size: 18),
            label: Text(
              'Send',
              style: AppTypography.labelLarge(
                context,
              ).copyWith(color: context.colors.onPrimary),
            ),
          ),
          const SizedBox(width: 16),
          // Discard
          TextButton.icon(
            key: const Key('compose_desktop_discard_button'),
            onPressed: _handleDiscard,
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: Text(
              'Discard',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Attachment
          TextButton.icon(
            key: const Key('compose_desktop_attach_button'),
            onPressed: _handleAttach,
            icon: Icon(
              Icons.attach_file_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: Text(
              'Attach',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
