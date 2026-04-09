import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:optmsg/common/responsive/responsive.dart';
import '../../../../constant/string_constant.dart';
import '../../../../constant/styles.dart';
import '../../../../constant/app_typography.dart';
import '../../../../services/form_validation.dart';
import '../../../../services/reg_exp_service.dart';
import '../../../../widgets/footer_button.dart';
import '../../../../widgets/text_form_field.dart';
import '../tags_notifier.dart';

void showActionSheet(BuildContext context, String actionType, WidgetRef ref,
    TextEditingController parentController) {
  final notifier = ref.read(tagsProvider.notifier);
  final s = ref.read(tagsProvider);
  final isMobile = AppBreakpoints.isMobileLayout(context);
  final isTablet = AppBreakpoints.isTabletLayout(context);
  final isNativeTabletLandscape = !kIsWeb &&
      isTablet &&
      MediaQuery.of(context).orientation == Orientation.landscape;

  // For mobile view (native + web mobile): show bottom sheet
  // For web desktop/tablet: show dialog
  if ((!kIsWeb || isMobile) && !isNativeTabletLandscape) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
        ),
        child: _TagActionBottomSheet(
          actionType: actionType,
          initialText: parentController.text,
          notifier: notifier,
          isEditMode: s.editFlag,
          tagId: s.id,
          onComplete: () {
            parentController.clear();
          },
        ),
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (dialogContext) => _TagActionDialog(
        actionType: actionType,
        initialText: parentController.text,
        notifier: notifier,
        isEditMode: s.editFlag,
        tagId: s.id,
        onComplete: () {
          parentController.clear();
        },
      ),
    );
  }
}

class _TagActionDialog extends ConsumerStatefulWidget {
  final String actionType;
  final String initialText;
  final TagsNotifier notifier;
  final bool isEditMode;
  final int? tagId;
  final VoidCallback onComplete;

  const _TagActionDialog({
    required this.actionType,
    required this.initialText,
    required this.notifier,
    required this.isEditMode,
    this.tagId,
    required this.onComplete,
  });

  @override
  ConsumerState<_TagActionDialog> createState() => _TagActionDialogState();
}

class _TagActionDialogState extends ConsumerState<_TagActionDialog> {
  late final TextEditingController _localController;
  final _tagFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _localController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppBreakpoints.actionSheetMaxWidth),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.26),
              offset: const Offset(0, 10),
              blurRadius: 10,
            ),
          ],
        ),
        child: Form(
          key: _tagFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.actionType == 'add' ? 'Add Tag' : 'Edit Tag',
                style: AppTypography.popUpTitle(context),
              ),
              const SizedBox(height: 16),
              SimpleTextFormField(
                controller: _localController,
                inputFormatter: FilteringTextInputFormatter.allow(
                  validCharactersRegex,
                ),
                labelText: 'Tag',
                keyboardType: TextInputType.text,
                validator: FormValidationService().validateTagName,
              ),
              const SizedBox(height: 24),
              FooterButton(
                button1Color: context.colors.surface,
                button1TextColor: context.colors.onSurface,
                button1BorderColor: context.colors.outlineVariant,
                button2Color: context.appColors.accent,
                button2TextColor: context.colors.onPrimary,
                button2BorderColor: Colors.transparent,
                onPressedButton1: () {
                  context.pop();
                  widget.notifier.setEditFlag(false);
                  widget.onComplete();
                },
                onPressedButton2: () {
                  if (_tagFormKey.currentState!.validate()) {
                    if (_localController.text.isNotEmpty) {
                      if (widget.isEditMode) {
                        widget.notifier.editTag(
                            widget.tagId ?? 0, _localController.text);
                      } else {
                        widget.notifier.addTag(_localController.text);
                      }
                      context.pop();
                      widget.notifier.setEditFlag(false);
                      widget.onComplete();
                    }
                  }
                },
                textButton1: cancel,
                textButton2: widget.isEditMode ? 'Save' : 'Add',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet widget for native mobile
class _TagActionBottomSheet extends ConsumerStatefulWidget {
  final String actionType;
  final String initialText;
  final TagsNotifier notifier;
  final bool isEditMode;
  final int? tagId;
  final VoidCallback onComplete;

  const _TagActionBottomSheet({
    required this.actionType,
    required this.initialText,
    required this.notifier,
    required this.isEditMode,
    this.tagId,
    required this.onComplete,
  });

  @override
  ConsumerState<_TagActionBottomSheet> createState() =>
      _TagActionBottomSheetState();
}

class _TagActionBottomSheetState extends ConsumerState<_TagActionBottomSheet> {
  late final TextEditingController _localController;
  final _tagFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _localController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.surface,
      child: Form(
        key: _tagFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: context.colors.outlineVariant,
                  borderRadius: BorderRadius.circular(AppStyles.radiusXS),
                ),
              ),
            ),
            // Title
            Text(
              widget.actionType == 'add' ? 'Add Tag' : 'Edit Tag',
              style: AppStyles.popUpTitle,
            ),
            const SizedBox(height: 20),
            // Text field
            SimpleTextFormField(
              controller: _localController,
              inputFormatter: FilteringTextInputFormatter.allow(
                validCharactersRegex,
              ),
              labelText: 'Tag',
              keyboardType: TextInputType.text,
              validator: FormValidationService().validateTagName,
            ),
            const SizedBox(height: 24),
            // Buttons
            FooterButton(
              button1Color: Theme.of(context).colorScheme.surface,
              button1TextColor: Theme.of(context).colorScheme.onSurface,
              button1BorderColor: context.colors.outlineVariant,
              button2Color: context.appColors.accent,
              button2TextColor: context.colors.onPrimary,
              button2BorderColor: Colors.transparent,
              onPressedButton1: () {
                context.pop();
                widget.notifier.setEditFlag(false);
                widget.onComplete();
              },
              onPressedButton2: () {
                if (_tagFormKey.currentState!.validate()) {
                  if (_localController.text.isNotEmpty) {
                    if (widget.isEditMode) {
                      widget.notifier.editTag(
                          widget.tagId ?? 0, _localController.text);
                    } else {
                      widget.notifier.addTag(_localController.text);
                    }
                    context.pop();
                    widget.notifier.setEditFlag(false);
                    widget.onComplete();
                  }
                }
              },
              textButton1: cancel,
              textButton2: widget.isEditMode ? 'Save' : 'Add',
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
