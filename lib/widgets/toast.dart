import 'dart:io';

import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class CustomToast extends StatelessWidget {
  final String message;
  final String type;
  final VoidCallback closeIcon;
  final VoidCallback undoMethod;

  const CustomToast({
    super.key,
    required this.message,
    required this.type,
    required this.closeIcon,
    required this.undoMethod,
  });

  @override

  /// Builds a widget that displays a message in a toast with a close icon and an undo icon.
  ///
  /// The background color and text color of the toast are determined by the [type].
  /// The toast is displayed with a shadow.
  /// The toast is displayed with a maximum width of 500.
  /// The toast is displayed with a margin of 20 horizontally and 10 vertically.
  /// The toast is displayed with a padding of 10 horizontally and 0 vertically.
  /// The toast is displayed with a border radius of 8.
  /// The toast is displayed with an icon and a text.
  /// The icon is displayed with a color of [iconColor].
  /// The text is displayed with a color of [textColor] and a font size of 12.
  /// The text is displayed with an overflow of [TextOverflow.ellipsis].
  /// The text is displayed with a maximum number of lines of 1.
  /// The toast is displayed with an undo icon if the [type] is 'Undo'.
  /// The undo icon is displayed with a color of [textColor].
  /// The undo icon is displayed with a font weight of bold.
  /// The undo icon is displayed with a tap callback of [undoMethod].
  /// The close icon is displayed with a color of [textColor].
  /// The close icon is displayed with a tap callback of [closeIcon].
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color iconColor;
    IconData icon;

    switch (type) {
      case 'success':
        backgroundColor = context.appColors.statusSuccessBg;
        textColor = context.appColors.statusSuccessText;
        iconColor = textColor;
        icon = Icons.check_circle;
        break;
      case 'error':
        backgroundColor = context.appColors.statusErrorBg;
        textColor = context.appColors.statusErrorText;
        iconColor = textColor;
        icon = Icons.error;
        break;
      case 'Undo':
        backgroundColor = context.appColors.statusInfoBg;
        textColor = context.appColors.statusInfoText;
        iconColor = textColor;
        icon = Icons.error;
        break;
      case 'warning':
      default:
        backgroundColor = context.appColors.statusWarnBg;
        textColor = context.appColors.statusWarnText;
        iconColor = textColor;
        icon = Icons.warning;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppBreakpoints.popupMaxWidth),
        width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.only(right: 10, left: 10, top: 0, bottom: 0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppStyles.radiusS),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.26),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: AppTypography.caption(context).copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (type == 'Undo')
              PointerInterceptor(
                intercepting: kIsWeb || Platform.isAndroid ? true : false,
                child: InkWell(
                    onTap: undoMethod,
                    child: Text(
                      'Undo',
                      style: TextStyle(color: textColor)
                          .copyWith(fontWeight: FontWeight.bold),
                    )),
              ),
            PointerInterceptor(
              intercepting: kIsWeb || Platform.isAndroid ? true : false,
              child: IconButton(
                icon: Icon(Icons.close, color: textColor),
                onPressed: closeIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
