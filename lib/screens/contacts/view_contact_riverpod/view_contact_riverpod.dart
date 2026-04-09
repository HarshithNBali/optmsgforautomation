import 'dart:async';
import 'package:descope/descope.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';

import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/screens/contacts/view_contact_riverpod/view_contact_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constant/img_path.dart';
import '../../../constant/string_constant.dart';
import '../../../constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import '../../../constant/app_config.dart';
import '../../../model/contact_list_model.dart';
import '../../../services/adaptive_service.dart';
import '../../../services/common_service.dart';
import '../../../services/form_validation.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import '../../../widgets/pop_up_modal.dart';
import '../../../widgets/text_form_field.dart';
import 'layouts/view_contact_desktop_layout.dart';
import 'layouts/view_contact_mobile_layout.dart';
import 'layouts/view_contact_tablet_layout.dart';

class ViewContactriverpod extends ConsumerStatefulWidget {
  final Contacts contact;
  final String? page;
  final bool hideAppBar;
  final Future<void> Function(Map<String, dynamic>)? onContactUpdated;

  const ViewContactriverpod({
    super.key,
    required this.contact,
    this.page,
    this.hideAppBar = false,
    this.onContactUpdated,
  });

  @override
  ConsumerState<ViewContactriverpod> createState() =>
      _ViewContactriverpodState();
}

class _ViewContactriverpodState extends ConsumerState<ViewContactriverpod> {
  final _emailController = TextEditingController();
  final _formValidationService = FormValidationService();

  void _pushAppBarConfig() {
    if (!mounted) return;
    final state = ref.read(viewContactProvider);
    final currentContact = state.contact ?? widget.contact;
    final contactName = '${currentContact.firstName} ${currentContact.lastName}'
        .trim();
    final isMobileView = AdaptiveService.isMobileLayout(context);
    final isTablet = AppBreakpoints.isTabletLayout(context);
    final isNativeTabletLandscape =
        !kIsWeb &&
        isTablet &&
        MediaQuery.of(context).orientation == Orientation.landscape;
    final showActions = !((kIsWeb || isNativeTabletLandscape) && !isMobileView);

    ShellLayout.of(context)?.setAppBarConfig(
      AppBarConfig(
        title: contactName.isNotEmpty ? contactName : 'Contact',
        customActions: showActions
            ? [
                IconButton(
                  icon: SvgPicture.asset(svgEditForm, height: 20, width: 20),
                  onPressed: state.loadingContactDetails
                      ? null
                      : () async {
                          final emails = ref.read(viewContactProvider).emails;
                          final notifier = ref.read(
                            viewContactProvider.notifier,
                          );
                          context
                              .push(
                                AppRoutes.editContactriverpodPath(
                                  widget.contact.id,
                                ),
                                extra: {
                                  'contact': currentContact,
                                  'contactData': emails,
                                },
                              )
                              .then((value) async {
                                if (value != null &&
                                    value is Map &&
                                    value['contact'] != null) {
                                  notifier.updateContact(value['contact']);
                                }
                                await notifier.loadContactDetails(
                                  widget.contact.id,
                                );
                              });
                        },
                ),
                IconButton(
                  icon: SvgPicture.asset(svgDelete, height: 20, width: 20),
                  onPressed: _handleDeleteContact,
                ),
              ]
            : [],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    printLog("contactClick", widget.contact.toJson());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(viewContactProvider.notifier).initialize(widget.contact);
      if (!widget.hideAppBar) {
        _pushAppBarConfig();
      }
    });
  }

  @override
  void didUpdateWidget(ViewContactriverpod oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool isNativeTabletLandscape =
        !kIsWeb &&
        MediaQuery.of(context).orientation == Orientation.landscape &&
        AppBreakpoints.screenWidth(context) >= AppBreakpoints.tablet;
    printLog(
      "didUpdateWidget",
      ref.read(viewContactProvider.notifier).readingPaneEnabled,
    );
    if ((kIsWeb || isNativeTabletLandscape) &&
        ref.read(viewContactProvider.notifier).readingPaneEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(viewContactProvider.notifier).initialize(widget.contact);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleAddEmail() {
    _emailController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => CustomPopupModal(
        title: 'Add Email',
        textButton1: 'Cancel',
        textButton2: 'Submit',
        onPressedButton1: () {
          Navigator.of(dialogContext).pop();
        },
        onPressedButton2: () async {
          final email = _emailController.text;
          if (_formValidationService.isValidEmail(email)) {
            await ref
                .read(viewContactProvider.notifier)
                .addOrDeleteEmail(
                  type: 'add',
                  email: email,
                  contactId: widget.contact.id,
                );
            Navigator.of(dialogContext).pop();
            // Notify parent about email update if in reading pane mode
            if (widget.hideAppBar && widget.onContactUpdated != null) {
              await widget.onContactUpdated!({
                'type': 'update',
                'contact': widget.contact as dynamic,
              });
            }
          } else {
            CommonService.animatedToast('Invalid email', 'error');
          }
        },
        formField1: SimpleTextFormField(
          controller: _emailController,
          labelText: 'Email',
        ),
      ),
    );
  }

  void _handleDeleteEmail(String email) async {
    await ref
        .read(viewContactProvider.notifier)
        .addOrDeleteEmail(
          type: 'delete',
          email: email,
          contactId: widget.contact.id,
        );
    // Notify parent about email update if in reading pane mode
    if (widget.hideAppBar && widget.onContactUpdated != null) {
      await widget.onContactUpdated!({
        'type': 'update',
        'contact': widget.contact as dynamic,
      });
    }
  }

  Future<void> _handleEmailTap(String email, BuildContext tapContext) async {
    final isSmallDevice = AdaptiveService.isMobileLayout(context);

    if (!isSmallDevice) {
      final RenderBox? renderBox = tapContext.findRenderObject() as RenderBox?;
      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox?;

      if (renderBox != null && overlay != null) {
        final position = renderBox.localToGlobal(
          Offset.zero,
          ancestor: overlay,
        );
        final size = renderBox.size;

        final menuRect = Rect.fromLTWH(
          position.dx,
          position.dy + size.height + 1,
          200,
          0,
        );

        final relativePosition = RelativeRect.fromRect(
          menuRect,
          Offset.zero & overlay.size,
        );

        await showMenu(
          context: context,
          position: relativePosition,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
          ),
          elevation: 8,
          color: Theme.of(context).colorScheme.surface,
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 200),
          items: [
            PopupMenuItem<String>(
              padding: EdgeInsets.zero,
              value: 'copy',
              child: InkWell(
                onTap: () async {
                  // Only pop if this is a separate route (not in reading pane)
                  if (!widget.hideAppBar) {
                    context.pop();
                  }
                  await Clipboard.setData(ClipboardData(text: email));
                  CommonService.animatedToast('Successfully copied', 'success');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        color: context.colors.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        copy,
                        style: AppTypography.labelLarge(
                          context,
                        ).copyWith(color: context.colors.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuItem<String>(
              padding: EdgeInsets.zero,
              value: 'compose',
              child: Column(
                children: [
                  const Divider(),
                  InkWell(
                    onTap: () async {
                      // Only pop if this is a separate route (not in reading pane)
                      if (!widget.hideAppBar) {
                        context.pop();
                      }
                      await _openCompose(email);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            svgCompose,
                            height: 20,
                            width: 20,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            compose,
                            style: AppTypography.labelLarge(
                              context,
                            ).copyWith(color: context.colors.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    } else {
      await showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(
                copy,
                style: AppTypography.actionSheetCancel(context),
              ),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: email));
                context.pop();
                CommonService.animatedToast('Successfully copied', 'success');
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                compose,
                style: AppTypography.actionSheetCancel(context),
              ),
              onPressed: () async {
                context.pop();
                await _openCompose(email);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              context.pop();
            },
            child: Text(
              cancel,
              style: AppTypography.actionSheetCancel(context),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _openCompose(String email) async {
    final data = ref.read(authProvider).userData;
    final token =
        Descope.sessionManager.session?.sessionJwt ??
        (data?['token'] as String?) ??
        '';
    final int pageId = DateTime.now().microsecondsSinceEpoch;
    final int offsetInMinutes = DateTime.now().timeZoneOffset.inMinutes;
    final composeUrl =
        '${defaultBaseUrl}email/compose?pageId=$pageId&toEmail=$email&timeZone=$offsetInMinutes';
    printLog("composeUrl", composeUrl);
    await context.push(
      AppRoutes.compose,
      extra: {
        'type': 'contact',
        'url': composeUrl,
        'token': token,
        'pageId': pageId,
        'email': email,
        'sourcePage': AppRoutes.contacts,
      },
    );
  }

  Future<void> _handleDeleteContact() async {
    showDialog(
      context: context,
      builder: (_) => CustomPopupModal(
        icon: svgTrash,
        title: delete,
        subtitle: deleteContact,
        textButton1: cancel,
        textButton2: delete,
        onPressedButton1: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
        onPressedButton2: () async {
          Navigator.of(context, rootNavigator: true).pop();
          await _performDeleteContact();
        },
      ),
    );
  }

  Future<void> _performDeleteContact() async {
    final success = await ref
        .read(viewContactProvider.notifier)
        .deleteContact(widget.contact.id);

    if (!mounted) return;
    if (success) {
      // Always navigate back to contact list when contact is deleted
      final deleteResult = {'type': 'delete', 'contact': widget.contact};

      // Notify parent about deletion if callback is available
      if (widget.onContactUpdated != null) {
        await widget.onContactUpdated!(deleteResult);
      }

      // Navigate back (unless in reading pane mode where parent handles navigation)
      if (!widget.hideAppBar) {
        // If came from edit screen, pop twice to go back to contact list
        // For 'addContact', pushReplacement was used so stack is: List -> View Contact (pop once)
        // Otherwise, pop once to go back to contact list
        if (widget.page == 'edit' || widget.page == 'add') {
          // Pop twice: once for current screen, once for edit/add screen
          if (context.canPop()) context.pop();
          if (context.canPop()) context.pop(deleteResult);
        } else if (widget.page == 'addContact') {
          context.push(AppRoutes.contacts);
        } else {
          // For 'addContact', 'list', and other cases, pop once to go back to contact list
          if (context.canPop()) {
            context.pop(deleteResult);
          } else {
            // Fallback: if stack is empty (e.g. reload or direct link), force navigate to contacts
            context.go(AppRoutes.contacts);
          }
        }
      }
    }
  }

  Future<void> backPressed() async {
    if (widget.page!.isNotEmpty && widget.page == 'edit') {
      if (context.canPop()) context.pop();
      redirection('edit');
      return;
    }
    if (widget.page!.isNotEmpty && widget.page == 'add') {
      if (context.canPop()) context.pop();
      redirection('add');
    }
    if (widget.page!.isNotEmpty && widget.page == 'list') {
      redirection('list');
    }
    if (widget.page!.isNotEmpty && widget.page == 'addContact') {
      // Only pop once since pushReplacement was used (stack is: List -> View Contact)
      // redirection('add');
      //  if (widget.page!.isNotEmpty && widget.page == 'addContact') {
      // print("backPressed - addContact");
      context.push(AppRoutes.contacts);
      // }
    }
  }

  Future<void> redirection(String type) async {
    final state = ref.read(viewContactProvider);
    final currentContact = state.contact ?? widget.contact;

    // If we have a local update, ensure we return 'edit' type so the list updates
    String returnType = type;
    if (state.contact != null && (type == 'list' || type == 'view')) {
      returnType = 'edit';
    }

    Map<String, dynamic> result = {
      'type': returnType,
      'contact': currentContact,
    };
    if (widget.hideAppBar && widget.onContactUpdated != null) {
      await widget.onContactUpdated!(result);
    } else {
      context.pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(viewContactProvider);
    final notifier = ref.read(viewContactProvider.notifier);
    final emails = state.emails;
    final currentContact = state.contact ?? widget.contact;
    // Re-push AppBarConfig after build so actions stay in sync with state
    if (!widget.hideAppBar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pushAppBarConfig();
      });
    }
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: ResponsiveLayoutBuilder(
          mobile: (ctx, deviceType, width) =>
              MediaQuery.of(context).orientation == Orientation.landscape
              ? ViewContactDesktopLayoutRiverpod(
                  firstName: currentContact.firstName,
                  lastName: currentContact.lastName,
                  companyName: currentContact.company,
                  emails: emails,
                  loadingContactDetails: state.loadingContactDetails,
                  onEmailTap: (email, tapCtx) => _handleEmailTap(email, tapCtx),
                  onDeleteEmail: _handleDeleteEmail,
                  onAddEmail: _handleAddEmail,
                  // Always show Edit/Delete buttons in desktop layout for web
                  hideAppBar: widget.hideAppBar,
                  onEdit: () async {
                    if (state.loadingContactDetails || state.emails.isEmpty) {
                      return;
                    }
                    await context
                        .push(
                          AppRoutes.editContactriverpodPath(currentContact.id),
                          extra: {
                            'contact': currentContact,
                            'contactData': state.emails,
                            'isReadingPaneMode': true,
                          },
                        )
                        .then((result) async {
                          /*  if (result != null && result is Map<String, dynamic>) {
                if (result != null && result['contact'] != null) {
                  printLog("result", result);
                  notifier.updateContact(result['contact']); // instant UI update
                }
                if (widget.onContactUpdated != null) {
                  await widget.onContactUpdated!(result);
                }
              }*/
                          await notifier.loadContactDetails(widget.contact.id);
                          notifier.loadContactDetails(widget.contact.id);
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            if (result['contact'] != null) {
                              notifier.updateContact(result['contact']);
                            }
                            if (widget.onContactUpdated != null) {
                              widget.onContactUpdated!(result);
                            }
                          }
                        });
                  },
                  onDelete: _handleDeleteContact,
                )
              : ViewContactMobileLayoutRiverpod(
                  firstName: currentContact.firstName,
                  lastName: currentContact.lastName,
                  companyName: currentContact.company,
                  emails: emails,
                  loadingContactDetails: state.loadingContactDetails,
                  onEmailTap: (email, tapCtx) => _handleEmailTap(email, tapCtx),
                  onDeleteEmail: _handleDeleteEmail,
                ),
          tablet: (ctx, deviceType, width) =>
              MediaQuery.of(context).orientation == Orientation.landscape
              ? ViewContactDesktopLayoutRiverpod(
                  firstName: currentContact.firstName,
                  lastName: currentContact.lastName,
                  companyName: currentContact.company,
                  emails: emails,
                  loadingContactDetails: state.loadingContactDetails,
                  onEmailTap: (email, tapCtx) => _handleEmailTap(email, tapCtx),
                  onDeleteEmail: _handleDeleteEmail,
                  onAddEmail: _handleAddEmail,
                  // Always show Edit/Delete buttons in desktop layout for web
                  hideAppBar: widget.hideAppBar,
                  onEdit: () async {
                    if (state.loadingContactDetails || state.emails.isEmpty) {
                      return;
                    }
                    await context
                        .push(
                          AppRoutes.editContactriverpodPath(currentContact.id),
                          extra: {
                            'contact': currentContact,
                            'contactData': state.emails,
                            'isReadingPaneMode': true,
                          },
                        )
                        .then((result) async {
                          /*  if (result != null && result is Map<String, dynamic>) {
                if (result != null && result['contact'] != null) {
                  printLog("result", result);
                  notifier.updateContact(result['contact']); // instant UI update
                }
                if (widget.onContactUpdated != null) {
                  await widget.onContactUpdated!(result);
                }
              }*/
                          await notifier.loadContactDetails(widget.contact.id);
                          notifier.loadContactDetails(widget.contact.id);
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            if (result['contact'] != null) {
                              notifier.updateContact(result['contact']);
                            }
                            if (widget.onContactUpdated != null) {
                              widget.onContactUpdated!(result);
                            }
                          }
                        });
                  },
                  onDelete: _handleDeleteContact,
                )
              : ViewContactTabletLayoutRiverpod(
                  firstName: currentContact.firstName,
                  lastName: currentContact.lastName,
                  companyName: currentContact.company,
                  emails: emails,
                  loadingContactDetails: state.loadingContactDetails,
                  onEmailTap: (email, tapCtx) => _handleEmailTap(email, tapCtx),
                  onDeleteEmail: _handleDeleteEmail,
                  onAddEmail: _handleAddEmail,
                  // Show Add Contact button in tablet layout when reading pane is OFF
                  onAddContact: () async {
                    final result = await context.push<Map<String, dynamic>?>(
                      AppRoutes.addContactriverpod,
                    );
                    if (result != null) {
                      if (result['type'] == 'add') {
                        final Contacts newContact = result['contact'];
                        // Notify parent to update the contact list
                        if (widget.onContactUpdated != null) {
                          await widget.onContactUpdated!(result);
                        }
                        // Navigate to the newly added contact's view page
                        if (mounted) {
                          context.pushReplacement(
                            AppRoutes.viewContactriverpodPath(newContact.id),
                            extra: {
                              'contact': newContact,
                              'page': 'addContact',
                              'onContactUpdated': widget.onContactUpdated,
                            },
                          );
                        }
                      } else if (result['type'] == 'refresh' &&
                          widget.onContactUpdated != null) {
                        await widget.onContactUpdated!(result);
                      }
                    }
                  },
                  // Show Edit/Delete buttons in tablet layout for web
                  onEdit: () async {
                    if (state.loadingContactDetails || state.emails.isEmpty) {
                      return;
                    }
                    final result = await context.push(
                      AppRoutes.editContactriverpodPath(widget.contact.id),
                      extra: {
                        'contact': widget.contact,
                        'contactData': state.emails,
                        'isReadingPaneMode': true,
                      },
                    );
                    notifier.loadContactDetails(widget.contact.id);
                    if (result != null && result is Map<String, dynamic>) {
                      if (result['contact'] != null) {
                        notifier.updateContact(result['contact']);
                      }
                      if (widget.onContactUpdated != null) {
                        widget.onContactUpdated!(result);
                      }
                    }
                  },
                  onDelete: _handleDeleteContact,
                  hideAppBar: widget.hideAppBar,
                ),
          desktop: (ctx, deviceType, width) => ViewContactDesktopLayoutRiverpod(
            firstName: currentContact.firstName,
            lastName: currentContact.lastName,
            companyName: currentContact.company,
            emails: emails,
            loadingContactDetails: state.loadingContactDetails,
            onEmailTap: (email, tapCtx) => _handleEmailTap(email, tapCtx),
            onDeleteEmail: _handleDeleteEmail,
            onAddEmail: _handleAddEmail,
            // Always show Edit/Delete buttons in desktop layout for web
            hideAppBar: widget.hideAppBar,
            onEdit: () async {
              if (state.loadingContactDetails || state.emails.isEmpty) return;
              await context
                  .push(
                    AppRoutes.editContactriverpodPath(currentContact.id),
                    extra: {
                      'contact': currentContact,
                      'contactData': state.emails,
                      'isReadingPaneMode': true,
                    },
                  )
                  .then((result) async {
                    await notifier.loadContactDetails(widget.contact.id);
                    notifier.loadContactDetails(widget.contact.id);
                    if (result != null && result is Map<String, dynamic>) {
                      if (result['contact'] != null) {
                        notifier.updateContact(result['contact']);
                      }
                      if (widget.onContactUpdated != null) {
                        widget.onContactUpdated!(result);
                      }
                    }
                  });
            },
            onDelete: _handleDeleteContact,
          ),
        ),
      ),
    );
  }
}
