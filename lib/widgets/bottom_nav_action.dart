// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables

import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/widgets/pop_up_modal_tag_list.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomNavAction extends StatefulWidget {
  final List<int> ids;
  final List<dynamic>? tagList;
  final String? gotoPage;
  final String? emailType;
  final String? page;
  final VoidCallback? getAllEmails;

  const BottomNavAction(
      {super.key,
      required this.ids,
      this.tagList,
      this.gotoPage,
      this.emailType,
      this.page,
      this.getAllEmails,
      this.testId});
  final String? testId;
  @override
  State<BottomNavAction> createState() => _BottomNavActionState();
}

class _BottomNavActionState extends State<BottomNavAction> {
  final int _currentIndex = 0;
  bool _isLoading = false;
  late List<int> selectedTagIds;

  List<BottomNavigationBarItem> _buildNavItems(BuildContext context) {
    final items = [
      BottomNavigationBarItem(
          icon: SvgPicture.asset(svgArchive,
              key: widget.testId != null ? Key('${widget.testId}_archive') : null),
          label: 'Archive'),
      BottomNavigationBarItem(
          icon: SvgPicture.asset(svgTags,
              key: widget.testId != null ? Key('${widget.testId}_tags') : null),
          label: 'Tag'),
      BottomNavigationBarItem(
          icon: SvgPicture.asset(
            svgDelete,
            key: widget.testId != null ? Key('${widget.testId}_trash') : null,
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
          ),
          label: 'Trash'),
    ];
    if (widget.page == "archive") {
      items.removeAt(0);
    } else if (widget.page == "trash") {
      items.removeAt(2);
    }
    return items;
  }

  @override

  /// Returns a BottomNavigationBar with the following items:
  ///
  /// - Archive (svgArchive)
  /// - Tags (svgTags)
  /// - Trash (svgDelete)
  ///
  /// The order of the items is determined by the value of widget.page.
  /// If widget.page is "archive", the Archive item is first.
  /// If widget.page is "trash", the Trash item is first.
  /// If widget.page is neither "archive" nor "trash", the Tag item is first.
  ///
  /// The user can select one of the items by tapping on it.
  /// If the user selects an item, the onTap callback is called with the index of the selected item.
  /// If the user selects an item and the item is not the Trash item, the updateEmailStatus function is called with the appropriate status and the list of selected email ids.
  /// If the user selects the Trash item, the updateEmailStatus function is called with the appropriate status and the list of selected email ids.
  /// If the user selects the Tags item, the showTagsPopup function is called.
  /// If the user does not select any item, a toast is shown with the message "Please Select Email".
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: context.colors.outlineVariant,
      type: BottomNavigationBarType.fixed,
      items: _buildNavItems(context),
      currentIndex: _currentIndex,
      onTap: (value) {
        if (widget.ids.isNotEmpty) {
          switch (value) {
            case 0:
              if (widget.page == "archive") {
                showTagsPopup();
              } else {
                updateEmailStatus("isArchive", widget.ids);
              }
              break;
            case 1:
              if (widget.page == "archive") {
                updateEmailStatus("isTrash", widget.ids);
              } else {
                showTagsPopup();
              }
              break;
            case 2:
              updateEmailStatus("isTrash", widget.ids);
              break;
            default:
          }
        } else {
          CommonService.animatedToast("Please Select Email", 'warning');
        }
      },
      selectedFontSize: 13,
      unselectedFontSize: 13,
      selectedLabelStyle: TextStyle(
        color: context.colors.onSurface,
        overflow: TextOverflow.ellipsis,
      ),
      unselectedLabelStyle:
          TextStyle(color: context.colors.onSurface, overflow: TextOverflow.ellipsis),
      fixedColor: context.colors.onSurface,
      unselectedItemColor: context.colors.onSurface,
    );
  }

  void onPressedYes() {
    addEmailTags();
  }

  /// Add email tags
  void showTagsPopup() {
    if (widget.tagList != null && widget.tagList!.isNotEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return PopUpModalTagList(
                title: 'Tags',
                loading: _isLoading,
                onPressedButton2: onPressedYes,
                textButton1: 'Cancel',
                textButton2: 'Add',
                itemList: widget.tagList,
                callback: (value) {
                  setState(() {
                    selectedTagIds = value;
                  });
                });
          });
    } else {
      CommonService.animatedToast("No tags found", 'warning');
    }
  }

  /// Update email status
  ///
  /// This function is used to update the email status.
  ///
  /// [type] String, the type of status to update. For example, 'isRead' or 'isDeleted'.
  /// [ids] List, the list of email ids to update.
  ///
  /// The function call the ApiService.post() to update the email status. If the response is success, the function navigate to the page specified in the [widget.gotoPage]. If the response is not success, the function show the error toast message.
  ///
  /// If the function catch an error, the function set the [_isLoading] to false.
  ///
  Future<void> updateEmailStatus(String type, List ids) async {
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> resp = await ApiService().post(
        'email/update-email-status',
        {
          "key": type,
          "emailIds": ids,
          "value": true,
        },
      );
      if (resp['success'] == true) {
        setState(() {
          _isLoading = false;
        });
        if (widget.gotoPage != null) {
          if (!mounted) return;
          context.push(widget.gotoPage!);
        }
        widget.getAllEmails?.call();
      } else {
        CommonService.animatedToast(resp['message'], 'error');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Add the selected tags to the selected emails.
  ///
  /// If the response is success, the function navigate to the page specified in the [widget.gotoPage].
  /// After that, the function call the [widget.getAllEmails] to refresh the email list.
  ///
  /// If the response is not success, the function show the error toast message.
  ///
  /// If the function catch an error, the function set the [_isLoading] to false.
  Future<void> addEmailTags() async {
    selectedTagIds.removeWhere((item) => item == 0);
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> resp = await ApiService().post(
        'email/emails-tags',
        {
          "emailIds": widget.ids,
          "tagsId": selectedTagIds,
          "type": "add",
        },
      );
      if (resp['success']) {
        setState(() {
          _isLoading = false;
        });
        if (widget.gotoPage != null) {
          if (!mounted) return;
          context.push(widget.gotoPage!);
        }
        if (!mounted) return;
        context.pop();
      } else {
        CommonService.animatedToast(resp['message'], 'error');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      if (!mounted) return;
      context.pop();
      setState(() {
        _isLoading = false;
      });
    }
    widget.getAllEmails?.call();
  }
}
