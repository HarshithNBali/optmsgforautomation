import 'dart:async';

import 'package:optmsg/constant/app_config.dart'
    show emailExtension, maxRecipientsPerEmail;
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A recipient input field for compose (To, Cc, Bcc).
///
/// Supports two modes:
/// - **Collapsed**: Shows chips in a single row with "+N" overflow indicator.
///   Tapping expands to full mode.
/// - **Expanded**: Shows all chips in a `Wrap` layout with an autocomplete
///   text input for adding recipients.
class RecipientField extends StatefulWidget {
  final String label;
  final List<String> recipients;
  final ValueChanged<List<String>> onChanged;
  final bool startExpanded;
  final FocusNode? focusNode;

  /// Total recipients across all fields (To + Cc + Bcc) for limit checking.
  final int totalRecipientCount;
  final String? testId;

  const RecipientField({
    super.key,
    required this.label,
    required this.recipients,
    required this.onChanged,
    this.startExpanded = false,
    this.focusNode,
    this.totalRecipientCount = 0,
    this.testId,
  });

  @override
  State<RecipientField> createState() => _RecipientFieldState();
}

class _RecipientFieldState extends State<RecipientField> {
  late bool _isExpanded;
  final TextEditingController _textController = TextEditingController();
  late final FocusNode _focusNode;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;
  bool _ownsNode = false;
  int _highlightedIndex = -1;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsNode = true;
    }
    _isExpanded = widget.startExpanded;
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsNode) _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_isExpanded) {
      setState(() => _isExpanded = true);
    }
    if (!_focusNode.hasFocus) {
      _commitCurrentText();
      // Delay so tap on suggestion can fire before we collapse/remove overlay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
          // Auto-collapse when field has recipients and user moved away
          if (_isExpanded && widget.recipients.isNotEmpty) {
            setState(() => _isExpanded = false);
          }
        }
      });
    }
  }

  void _commitCurrentText() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && _isValidEmail(text)) {
      _addRecipient(text);
      _textController.clear();
    }
  }

  void _addRecipient(String email) {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty || widget.recipients.contains(trimmed)) return;
    if (widget.totalRecipientCount >= maxRecipientsPerEmail) {
      CommonService.animatedToast(
        'Maximum $maxRecipientsPerEmail recipients per email',
        'error',
      );
      return;
    }
    widget.onChanged([...widget.recipients, trimmed]);
  }

  void _removeRecipient(int index) {
    final updated = List<String>.from(widget.recipients)..removeAt(index);
    widget.onChanged(updated);
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  // ── Autocomplete ──

  void _onTextChanged(String query) {
    _debounce?.cancel();
    if (query.length < 2) {
      _removeOverlay();
      return;
    }
    if (kDebugMode) {
      debugPrint(
        '[RecipientField] onTextChanged: "$query" (len=${query.length})',
      );
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchContacts(query);
    });
  }

  /// Search using the backend's smart search endpoint with relevance scoring.
  /// POST /api/email/search-email — searches by name AND email, excludes
  /// already-added recipients, returns results ranked by relevance.
  Future<void> _searchContacts(String query) async {
    if (kDebugMode) {
      debugPrint('[RecipientField] searchContacts: "$query"');
    }
    try {
      final resp = await ApiService().post('email/search-email', {
        'email': query,
        'addedEmails': widget.recipients,
      });
      if (!mounted) return;

      if (resp['success'] == true) {
        final rawData = resp['data'];
        if (kDebugMode) {
          debugPrint(
            '[RecipientField] search-email resp data type: ${rawData.runtimeType}',
          );
          debugPrint('[RecipientField] search-email resp data: $rawData');
        }
        // The API may return data as a List directly or as a Map with a nested list
        List<dynamic> items;
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map) {
          // Try common keys: 'results', 'emails', 'contacts', or the map values
          items =
              rawData['results'] as List<dynamic>? ??
              rawData['emails'] as List<dynamic>? ??
              rawData['contacts'] as List<dynamic>? ??
              rawData.values.whereType<List>().firstOrNull ??
              [];
        } else {
          items = [];
        }
        if (kDebugMode) {
          debugPrint('[RecipientField] search-email ${items.length} items');
          if (items.isNotEmpty) {
            debugPrint('[RecipientField] first item: ${items[0]}');
          }
        }
        final results = <Map<String, dynamic>>[];
        for (final item in items) {
          if (item is! Map) continue;
          final email = (item['email'] as String? ?? '').trim();
          final firstName = item['firstName'] as String? ?? '';
          final lastName = item['lastName'] as String? ?? '';
          final name = '$firstName $lastName'.trim();
          if (email.isNotEmpty) {
            results.add({'email': email, 'name': name});
          }
        }
        setState(() {
          _suggestions = results;
          _highlightedIndex = -1;
        });
        if (results.isNotEmpty) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            '[RecipientField] search-email failed: ${resp['message']}',
          );
        }
        _removeOverlay();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RecipientField] search error: $e');
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox?;
    final fieldWidth = renderBox?.size.width ?? 300;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 40),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: fieldWidth - 60, // Account for label width
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surface,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final s = _suggestions[index];
                      final email = s['email'] as String;
                      final name = s['name'] as String;
                      final isHighlighted = index == _highlightedIndex;

                      return ListTile(
                        dense: true,
                        selected: isHighlighted,
                        selectedTileColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        title: Text(
                          name.isNotEmpty ? name : email,
                          style: AppTypography.emailAddress(context),
                        ),
                        subtitle: name.isNotEmpty
                            ? Text(
                                email,
                                style: Theme.of(context).textTheme.bodySmall,
                              )
                            : null,
                        onTap: () {
                          _addRecipient(email);
                          _textController.clear();
                          _removeOverlay();
                          setState(() => _highlightedIndex = -1);
                          _focusNode.requestFocus();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;
    if (_suggestions.isEmpty || _overlayEntry == null) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _highlightedIndex = (_highlightedIndex + 1).clamp(
          0,
          _suggestions.length - 1,
        );
      });
      _overlayEntry?.markNeedsBuild();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _highlightedIndex = (_highlightedIndex - 1).clamp(
          0,
          _suggestions.length - 1,
        );
      });
      _overlayEntry?.markNeedsBuild();
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (_highlightedIndex >= 0 && _highlightedIndex < _suggestions.length) {
        _selectHighlightedSuggestion();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      _removeOverlay();
      setState(() => _highlightedIndex = -1);
    }
  }

  void _selectHighlightedSuggestion() {
    if (_highlightedIndex < 0 || _highlightedIndex >= _suggestions.length)
      return;
    final email = _suggestions[_highlightedIndex]['email'] as String;
    _addRecipient(email);
    _textController.clear();
    _removeOverlay();
    setState(() => _highlightedIndex = -1);
    _focusNode.requestFocus();
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    // Collapsed: has recipients and not being edited
    // Expanded: empty (needs input) or user tapped to edit
    if (!_isExpanded && widget.recipients.isNotEmpty) {
      return _buildCollapsed(context);
    }
    return _buildExpanded(context);
  }

  Widget _buildCollapsed(BuildContext context) {
    return GestureDetector(
      key: widget.testId != null ? Key('${widget.testId}_collapsed') : null,
      onTap: () => setState(() => _isExpanded = true),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.colors.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Text('${widget.label}: ', style: AppTypography.emailLabel(context)),
            const SizedBox(width: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _buildCollapsedChips(context, constraints.maxWidth);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedChips(BuildContext context, double maxWidth) {
    final chips = <Widget>[];
    double usedWidth = 0;
    const chipPadding = 8.0;
    const plusChipWidth = 40.0;
    int remaining = 0;

    for (int i = 0; i < widget.recipients.length; i++) {
      final estimatedWidth = (widget.recipients[i].length * 7.5 + 40).clamp(
        60.0,
        200.0,
      );

      if (usedWidth + estimatedWidth + plusChipWidth > maxWidth &&
          i < widget.recipients.length - 1) {
        remaining = widget.recipients.length - i;
        break;
      }
      usedWidth += estimatedWidth + chipPadding;
      chips.add(_buildChip(context, widget.recipients[i], i, compact: true));
    }

    if (remaining > 0) {
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.appColors.tintSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '+$remaining',
            style: AppTypography.emailAddress(context),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: chips.expand((w) => [w, const SizedBox(width: 4)]).toList()
          ..removeLast(),
      ),
    );
  }

  static const _noBorder = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.zero,
  );

  Widget _buildExpanded(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('${widget.label}: ', style: AppTypography.emailLabel(context)),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _focusNode.requestFocus(),
              child: CompositedTransformTarget(
                link: _layerLink,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.recipients.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: widget.recipients
                              .asMap()
                              .entries
                              .map((e) => _buildChip(context, e.value, e.key))
                              .toList(),
                        ),
                      ),
                    KeyboardListener(
                      focusNode: FocusNode(skipTraversal: true),
                      onKeyEvent: _handleKeyEvent,
                      child: TextField(
                        key: widget.testId != null ? Key('${widget.testId}_input') : null,
                        controller: _textController,
                        focusNode: _focusNode,
                        style: AppTypography.emailAddress(context),
                        decoration: const InputDecoration(
                          border: _noBorder,
                          enabledBorder: _noBorder,
                          focusedBorder: _noBorder,
                          errorBorder: _noBorder,
                          disabledBorder: _noBorder,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          hintText: '',
                        ),
                        onChanged: (value) {
                          if (kDebugMode) {
                            debugPrint(
                              '[RecipientField] TextField onChanged: "$value"',
                            );
                          }
                          if (value.contains(',') || value.contains(';')) {
                            _handlePaste(value);
                            return;
                          }
                          _onTextChanged(value);
                        },
                        onSubmitted: (value) {
                          // If a suggestion is highlighted, select it instead
                          if (_highlightedIndex >= 0 &&
                              _highlightedIndex < _suggestions.length) {
                            _selectHighlightedSuggestion();
                            return;
                          }
                          final trimmed = value.trim();
                          if (trimmed.isNotEmpty && _isValidEmail(trimmed)) {
                            _addRecipient(trimmed);
                            _textController.clear();
                            _focusNode.requestFocus();
                          }
                        },
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePaste(String text) {
    final emails = text
        .split(RegExp(r'[,;\s]+'))
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty && _isValidEmail(e))
        .toList();
    if (emails.isNotEmpty) {
      final updated = {...widget.recipients, ...emails}.toList();
      final remaining =
          maxRecipientsPerEmail -
          widget.totalRecipientCount +
          widget.recipients.length;
      if (updated.length > remaining) {
        CommonService.animatedToast(
          'Maximum $maxRecipientsPerEmail recipients per email',
          'error',
        );
        widget.onChanged(updated.take(remaining).toList());
      } else {
        widget.onChanged(updated);
      }
      _textController.clear();
    }
  }

  Widget _buildChip(
    BuildContext context,
    String email,
    int index, {
    bool compact = false,
  }) {
    // Internal (OptMsg) addresses get a subtle blue tint — enough to
    // notice at a glance (like iMessage blue) but not distracting.
    // External addresses get a neutral warm grey.
    final isInternal = email.endsWith(emailExtension);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color chipBg;
    final Color chipFg;
    final Color iconColor;

    if (isInternal) {
      // OptMsg addresses — subtle blue
      chipBg = isDark
          ? const Color(0xFF1A2A4A) // dark: muted navy
          : const Color(0xFFDDE8FC); // light: soft periwinkle
      chipFg = isDark
          ? const Color(0xFFB3CCFF) // dark: light blue text
          : const Color(0xFF2C5299); // light: medium blue text
      iconColor = chipFg.withValues(alpha: 0.6);
    } else {
      // External addresses — warm neutral grey
      chipBg = isDark
          ? const Color(0xFF2A2A2A) // dark: charcoal
          : const Color(0xFFF0EFED); // light: warm light grey
      chipFg = isDark
          ? const Color(0xFFB0B0B0) // dark: muted grey text
          : const Color(0xFF5C5C5C); // light: medium grey text
      iconColor = chipFg.withValues(alpha: 0.5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              email,
              style: AppTypography.emailAddress(
                context,
              ).copyWith(color: chipFg, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            InkWell(
              key: widget.testId != null ? Key('${widget.testId}_remove_$index') : null,
              onTap: () => _removeRecipient(index),
              child: Icon(Icons.cancel, size: 14, color: iconColor),
            ),
          ],
        ],
      ),
    );
  }
}
