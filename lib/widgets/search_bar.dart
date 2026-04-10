import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';

class CustomSearchBar extends StatefulWidget {
  final ValueChanged<String>? onSearch;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isLightBackground;
  final String? testId;

  const CustomSearchBar({
    super.key,
    this.onSearch,
    this.controller,
    this.focusNode,
    this.isLightBackground = false,
    this.testId,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override

  /// Builds a custom search bar widget with a search icon on the left and a close icon on the right.
  ///
  /// The search bar is a [Container] with a [BorderRadius.circular] decoration.
  /// The background color of the search bar is white with an opacity of 0.1.
  /// The search bar is padded with a horizontal padding of 10.0.
  ///
  /// The search bar contains a [Row] with two children:
  ///   - An [Expanded] [TextField] with a white text color, a scroll padding of 0.0, and a decoration with a border of [InputBorder.none].
  ///     The [TextField] is styled with a hint text of 'Search' and a hint style with a white color.
  ///     The [TextField] is also styled with a content padding of a horizontal padding of 4.0 and a vertical padding of 8.0.
  ///     The [TextField] is focused when the widget is constructed.
  ///     The [TextField] is cleared when the close icon is tapped.
  ///   - A [SizedBox] with a width of 0.008 of the screen width.
  ///   - An [InkWell] with a child of a [SvgPicture] of either the search icon or the close icon.
  ///     The [InkWell] is tapped when the search icon is changed.
  ///     The [InkWell] is styled with a padding of 0.0.
  ///     The [InkWell] is also styled with a tap callback that clears the text field, unfocuses the text field, and unfocuses the focus scope.
  ///
  /// The [onSearch] callback is called when the text field is changed.
  /// The [controller] is the text field controller.
  /// The [focusNode] is the focus node of the text field.
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final appBarFg = Theme.of(context).appBarTheme.foregroundColor ?? cs.onSurface;
    final textColor = widget.isLightBackground ? cs.onSurface : appBarFg;
    final hintColor =
        widget.isLightBackground ? cs.onSurfaceVariant : appBarFg.withValues(alpha: 0.7);
    final backgroundColor = widget.isLightBackground
        ? cs.surfaceContainerHighest
        : appBarFg.withValues(alpha: 0.1);
    final borderColor = widget.isLightBackground
        ? cs.outlineVariant
        : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        color: backgroundColor,
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: widget.testId != null ? Key(widget.testId!) : null,
              focusNode: widget.focusNode,
              controller: widget.controller,
              cursorColor: textColor,
              style: TextStyle(color: textColor),
              scrollPadding: const EdgeInsets.all(0.0),
              onChanged: (value) {
                // Bug 31: setState triggers rebuild; icon is derived from
                // controller text below — no separate flag needed.
                setState(() {});
                widget.onSearch?.call(value);
              },
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search',
                hintStyle: TextStyle(color: hintColor),
                // Override inputDecorationTheme — search bar has its own
                // Container with rounded corners; no inner borders or fill.
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
              ),
            ),
          ),
          SizedBox(width: AppBreakpoints.screenWidth(context) * 0.008),
          // Search/Close icon on the right
          InkWell(
              key: widget.testId != null ? Key('${widget.testId}_action') : null,
              onTap: () {
                widget.controller?.clear();
                widget.onSearch?.call('');
                widget.focusNode?.unfocus();
                FocusScope.of(context).unfocus();
                setState(() {});
              },
              // Bug 31: Derive icon from controller text instead of a
              // stateful flag — prevents stale state on web refresh.
              child: (widget.controller?.text.isEmpty ?? true)
                  ? SvgPicture.asset(svgSearch)
                  : SvgPicture.asset(svgClose)),
        ],
      ),
    );
  }
}
