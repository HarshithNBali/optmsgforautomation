import 'package:flutter/material.dart';

/// A contact list widget that combines [ListView.builder] with a vertical
/// alphabet sidebar for jump-to-letter navigation.
///
/// Uses the native [ListView.builder] `itemExtent` parameter for O(1) scroll
/// offset calculations, improving performance over the alphabet_scroll_view
/// package which wraps items in ConstrainedBox instead.
class AlphabetContactList extends StatefulWidget {
  const AlphabetContactList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.letterIndexMap,
    required this.itemExtent,
    this.selectedTextStyle,
    this.unselectedTextStyle,
  });

  /// Total number of items in the list.
  final int itemCount;

  /// Builder for each list item.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Map of uppercase letter → first occurrence index in the sorted list.
  final Map<String, int> letterIndexMap;

  /// Fixed height for each item. Enables O(1) scroll offset calculation.
  final double itemExtent;

  /// Style for the currently active letter in the sidebar.
  final TextStyle? selectedTextStyle;

  /// Style for inactive letters in the sidebar.
  final TextStyle? unselectedTextStyle;

  @override
  State<AlphabetContactList> createState() => _AlphabetContactListState();
}

class _AlphabetContactListState extends State<AlphabetContactList> {
  late ScrollController _scrollController;
  String? _activeLetter;
  List<String> _letters = const [];

  /// Key for the sidebar Column, used to compute letter height during drag.
  final GlobalKey _sidebarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _rebuildLetters();
  }

  @override
  void didUpdateWidget(AlphabetContactList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.letterIndexMap != widget.letterIndexMap) {
      _rebuildLetters();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Sort letters alphabetically, with non-alpha characters grouped at the end.
  void _rebuildLetters() {
    final alphaLetters = <String>[];
    final nonAlpha = <String>[];
    for (final key in widget.letterIndexMap.keys) {
      if (RegExp(r'^[A-Z]$').hasMatch(key)) {
        alphaLetters.add(key);
      } else {
        nonAlpha.add(key);
      }
    }
    alphaLetters.sort();
    nonAlpha.sort();
    _letters = [...alphaLetters, ...nonAlpha];
  }

  void _scrollToLetter(String letter) {
    if (!_scrollController.hasClients) return;
    final itemIndex = widget.letterIndexMap[letter];
    if (itemIndex == null) return;
    final offset = itemIndex * widget.itemExtent;
    final maxScroll = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      offset.clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    setState(() => _activeLetter = letter);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_letters.isEmpty) return;
    final sidebarBox =
        _sidebarKey.currentContext?.findRenderObject() as RenderBox?;
    if (sidebarBox == null) return;
    final sidebarHeight = sidebarBox.size.height;
    final letterHeight = sidebarHeight / _letters.length;
    final localY = sidebarBox.globalToLocal(details.globalPosition).dy;
    final index = (localY / letterHeight).floor().clamp(0, _letters.length - 1);
    _scrollToLetter(_letters[index]);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() => _activeLetter = null);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Main list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            itemExtent: widget.itemExtent,
            itemCount: widget.itemCount,
            itemBuilder: widget.itemBuilder,
          ),
        ),
        // Alphabet sidebar
        if (_letters.isNotEmpty)
          GestureDetector(
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            child: Container(
              key: _sidebarKey,
              width: 28,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: _letters.map((letter) {
                  final isActive = letter == _activeLetter;
                  return GestureDetector(
                    key: Key('alphabet_sidebar_letter_$letter'),
                    onTap: () => _scrollToLetter(letter),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      child: Text(
                        letter,
                        style: isActive
                            ? widget.selectedTextStyle
                            : widget.unselectedTextStyle,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
