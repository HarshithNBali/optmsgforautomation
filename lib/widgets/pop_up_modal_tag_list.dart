import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/services/reg_exp_service.dart';
import 'package:optmsg/services/tags_provider.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/widgets/text_form_field.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/widgets/footer_button.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';

class PopUpModalTagList extends ConsumerStatefulWidget {
  final bool? loading;
  final String? icon;
  final String title;
  final String? title2;
  final String subtitle;
  final VoidCallback onPressedButton2;
  final Function? getTagsApi;
  final String textButton1;
  final String textButton2;
  final SimpleTextFormField? formField1;
  final List<dynamic>? itemList;
  final Function(dynamic)? callback;
  final Function(int, int)? showList;
  final List<int>? initialSelectedTagIds;
  final Function(int)? onTagDeleted;
  final int?
      emailId; // Store original emailId to pass back after creating new tag
  final int?
      itemIndex; // Store original itemIndex to pass back after creating new tag

  const PopUpModalTagList({
    super.key,
    this.loading,
    this.icon,
    this.title = "",
    this.title2 = '',
    this.subtitle = "",
    required this.onPressedButton2,
    required this.textButton1,
    required this.textButton2,
    this.getTagsApi,
    this.formField1,
    this.itemList,
    this.callback,
    this.showList,
    this.initialSelectedTagIds,
    this.onTagDeleted,
    this.emailId,
    this.itemIndex,
  });

  @override
  ConsumerState<PopUpModalTagList> createState() => _PopUpModalTagListState();
}

class _PopUpModalTagListState extends ConsumerState<PopUpModalTagList> {
  final TextEditingController _tagController = TextEditingController();
  final GlobalKey<FormState> _tagFormKey = GlobalKey<FormState>();
  List<int> selectedTagIds = [];
  List<int> initialTagIds = []; // Track initial state for cancel

  @override
  initState() {
    super.initState();
    selectedTagIds = widget.initialSelectedTagIds != null
        ? List.from(widget.initialSelectedTagIds!)
        : [];
    initialTagIds = List.from(selectedTagIds); // Store initial state

    if (widget.callback != null && selectedTagIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.callback!(selectedTagIds);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  @override
  void dispose() {
    // H-09: Dispose controller to prevent gesture arena / listener leak.
    _tagController.dispose();
    super.dispose();
  }

  Widget contentBox(BuildContext context) {
    // Watch tagsProvider so the list updates reactively when tags are added/deleted
    final liveTagList = ref.watch(
      tagsProvider.select((s) => s.tagsList?.data.tags ?? []),
    );
    final double screenWidth = AppBreakpoints.screenWidth(context);
    final double dialogWidth =
        AppBreakpoints.isMobile(screenWidth) ? screenWidth * 0.8 : 500;

    return DelayedLoadingOverlay(
      isLoading: widget.loading != false,
      child: Center(
        child: Container(
          width: dialogWidth,
                  padding: const EdgeInsets.only(
                      top: 30, bottom: 16, left: 16, right: 16),
                  margin: const EdgeInsets.only(top: 30),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (widget.icon != null)
                        SvgPicture.asset(
                          widget.icon!,
                          width: widget.icon != null
                              ? AppBreakpoints.screenWidth(context) * 0.120
                              : 0,
                          height: widget.icon != null
                              ? AppBreakpoints.screenHeight(context) * 0.120
                              : 0,
                        ),
                      if (widget.title.isNotEmpty)
                        Row(
                          mainAxisAlignment: widget.title2 == ''
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.title,
                              style: AppTypography.tagPopUpTitle(context),
                              textAlign: TextAlign.center,
                            ),
                            if (widget.title2 != '')
                              InkWell(
                                onTap: () {
                                  showAddTag(context, 'add');
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.add,
                                        color: context.colors.onSurface, size: 24),
                                    Text(
                                      widget.title2.toString(),
                                      style: AppTypography.tagPopUpTitle(context),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      if (widget.subtitle.isNotEmpty)
                        SizedBox(
                            height:
                                AppBreakpoints.screenHeight(context) * 0.020),
                      if (widget.subtitle.isNotEmpty)
                        Text(
                          widget.subtitle,
                          style: AppTypography.slogan(context),
                          textAlign: TextAlign.center,
                        ),
                      if (widget.formField1 != null) ...[
                        SizedBox(
                            height:
                                AppBreakpoints.screenHeight(context) * 0.020),
                        widget.formField1!,
                      ],
                      ...[
                        SizedBox(
                            height:
                                AppBreakpoints.screenHeight(context) * 0.020),
                        Container(
                          constraints: BoxConstraints(
                            maxHeight:
                                AppBreakpoints.screenHeight(context) * 0.3,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                for (int index = 0;
                                    index < liveTagList.length;
                                    index++)
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            child: (selectedTagIds.isNotEmpty &&
                                                    selectedTagIds.contains(
                                                        liveTagList[index].id))
                                                ? Icon(
                                                    Icons.check_box,
                                                    color:
                                                        context.colors.primary,
                                                  )
                                                : Icon(
                                                    Icons
                                                        .check_box_outline_blank,
                                                    color:
                                                        context.colors.primary),
                                            onTap: () async {
                                              final tagId =
                                                  liveTagList[index].id;
                                              final wasSelected = selectedTagIds
                                                  .contains(tagId);

                                              setState(() {
                                                if (wasSelected) {
                                                  selectedTagIds.remove(tagId);
                                                } else {
                                                  selectedTagIds.add(tagId);
                                                }
                                              });

                                              // Only update local state - don't delete tags immediately
                                              // Tags will be added/removed when user clicks "Add" button
                                              widget.callback!(selectedTagIds);
                                            },
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            liveTagList[index].tag,
                                            style: AppTypography.drawerTitle(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      color: context.colors.outlineVariant,
                                      thickness: 1,
                                    ),
                                  ])
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (liveTagList.isEmpty) const Text('No tags found'),
                      SizedBox(
                          height:
                              AppBreakpoints.screenHeight(context) * 0.030),
                      FooterButton(
                          button1Color: context.colors.surface,
                          button1TextColor: context.colors.onSurface,
                          button1BorderColor: context.colors.outlineVariant,
                          button2Color: context.appColors.accent,
                          button2TextColor: context.colors.onPrimary,
                          button2BorderColor: Colors.transparent,
                          onPressedButton1: () {
                            // Restore original state when Cancel is clicked
                            widget.callback!(initialTagIds);
                            if (!mounted) return;
                            context.pop();
                          },
                          onPressedButton2: () {
                            if (!mounted) return;
                            context.pop();
                            widget.onPressedButton2();
                          },
                          textButton1: widget.textButton1,
                          textButton2: widget.textButton2)
                    ],
                  ),
                ),
      ),
    );
  }

  void showAddTag(BuildContext context, String actionType) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: _tagFormKey,
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Add Tag",
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: AppStyles.space8),
                  SimpleTextFormField(
                    controller: _tagController,
                    inputFormatter:
                        FilteringTextInputFormatter.allow(validCharactersRegex),
                    labelText: 'Tags',
                    keyboardType: TextInputType.text,
                    validator: FormValidationService().validateTagName,
                    onChanged: (value) {},
                  ),
                  const SizedBox(
                    height: AppStyles.space8,
                  ),
                  CustomGradientButton(
                    text: 'Add',
                    onPressed: () {
                      if (_tagFormKey.currentState!.validate()) {
                        addTagsApi(_tagController.text);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    ).then((value) {
      if (mounted) setState(() {});
    });
  }

  Future<void> addTagsApi(String value) async {
    try {
      Map<String, dynamic> searchResults = await ApiService().post(
        'email/add-tags',
        {"tag": value},
      );
      if (searchResults['success']) {
        await widget.getTagsApi!();
        // Pop bottom sheet first
        if (!mounted) return;
        context.pop();
        // Pop the original tag dialog before opening a new one
        if (!mounted) return;
        context.pop();
        // Pass back the original emailId and itemIndex to preserve email selection
        await widget.showList!(
            widget.emailId ?? 0, widget.itemIndex ?? 0);
      } else {
        CommonService.animatedToast(searchResults['message'], 'error');
      }
    } catch (error) {
      if (!mounted) return;
      context.pop();
    }
  }
}
