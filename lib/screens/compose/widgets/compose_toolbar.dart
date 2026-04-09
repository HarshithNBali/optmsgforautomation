import 'package:flutter/material.dart';
import 'package:optmsg/common/responsive/responsive.dart';

/// Format command sent to the Quill.js editor.
class FormatCommand {
  final String format;
  final dynamic value;
  const FormatCommand(this.format, [this.value]);
}

/// Native Flutter toolbar for the compose editor.
///
/// Renders formatting buttons as Flutter widgets so dropdowns use Flutter's
/// overlay (never clipped by iframe bounds). Active formats are passed in
/// from the editor via [activeFormats].
class ComposeToolbar extends StatelessWidget {
  final ValueChanged<FormatCommand> onFormat;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final Map<String, dynamic> activeFormats;

  const ComposeToolbar({
    super.key,
    required this.onFormat,
    this.onUndo,
    this.onRedo,
    this.activeFormats = const {},
  });

  bool _isActive(String key, [dynamic matchValue]) {
    final v = activeFormats[key];
    if (matchValue != null) return v == matchValue;
    return v == true;
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = context.colors.onSurfaceVariant;
    final activeColor = Theme.of(context).colorScheme.primary;
    final dividerColor = context.colors.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(width: 0.5, color: dividerColor),
        ),
      ),
      height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
          children: [
            const SizedBox(width: 4),
            // Undo / Redo
            _IconBtn(Icons.undo, iconColor, onUndo, tooltip: 'Undo'),
            _IconBtn(Icons.redo, iconColor, onRedo, tooltip: 'Redo'),
            _Divider(dividerColor),
            // Text style toggles
            _ToggleBtn(Icons.format_bold, _isActive('bold'), iconColor,
                activeColor, () => onFormat(FormatCommand('bold', !_isActive('bold'))),
                tooltip: 'Bold'),
            _ToggleBtn(Icons.format_italic, _isActive('italic'), iconColor,
                activeColor, () => onFormat(FormatCommand('italic', !_isActive('italic'))),
                tooltip: 'Italic'),
            _ToggleBtn(Icons.format_underline, _isActive('underline'), iconColor,
                activeColor, () => onFormat(FormatCommand('underline', !_isActive('underline'))),
                tooltip: 'Underline'),
            _ToggleBtn(Icons.format_strikethrough, _isActive('strike'), iconColor,
                activeColor, () => onFormat(FormatCommand('strike', !_isActive('strike'))),
                tooltip: 'Strikethrough'),
            _Divider(dividerColor),
            // Font size
            _PopupBtn<dynamic>(
              icon: Icons.format_size,
              iconColor: iconColor,
              tooltip: 'Font Size',
              items: const [
                PopupMenuItem(value: 'small', child: Text('Small')),
                PopupMenuItem(value: false, child: Text('Normal')),
                PopupMenuItem(value: 'large', child: Text('Large')),
                PopupMenuItem(value: 'huge', child: Text('Huge')),
              ],
              onSelected: (v) => onFormat(FormatCommand('size', v)),
            ),
            _Divider(dividerColor),
            // Text color
            _PopupBtn<Color?>(
              icon: Icons.format_color_text,
              iconColor: iconColor,
              tooltip: 'Text Color',
              items: [
                _colorItem(null, 'Default', context),
                _colorItem(Colors.black, 'Black', context),
                _colorItem(Colors.red, 'Red', context),
                _colorItem(Colors.blue, 'Blue', context),
                _colorItem(Colors.green, 'Green', context),
                _colorItem(Colors.orange, 'Orange', context),
                _colorItem(Colors.purple, 'Purple', context),
                _colorItem(Colors.grey, 'Grey', context),
              ],
              onSelected: (v) => onFormat(FormatCommand(
                  'color', v == null ? false : '#${v.toARGB32().toRadixString(16).substring(2)}')),
            ),
            _Divider(dividerColor),
            // Alignment
            _PopupBtn<dynamic>(
              icon: Icons.format_align_left,
              iconColor: iconColor,
              tooltip: 'Alignment',
              items: const [
                PopupMenuItem(value: false, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.format_align_left, size: 18), SizedBox(width: 8), Text('Left')])),
                PopupMenuItem(value: 'center', child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.format_align_center, size: 18), SizedBox(width: 8), Text('Center')])),
                PopupMenuItem(value: 'right', child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.format_align_right, size: 18), SizedBox(width: 8), Text('Right')])),
                PopupMenuItem(value: 'justify', child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.format_align_justify, size: 18), SizedBox(width: 8), Text('Justify')])),
              ],
              onSelected: (v) => onFormat(FormatCommand('align', v)),
            ),
            _Divider(dividerColor),
            // Lists
            _ToggleBtn(Icons.format_list_numbered,
                _isActive('list', 'ordered'), iconColor, activeColor,
                () => onFormat(FormatCommand('list', _isActive('list', 'ordered') ? false : 'ordered')),
                tooltip: 'Numbered List'),
            _ToggleBtn(Icons.format_list_bulleted,
                _isActive('list', 'bullet'), iconColor, activeColor,
                () => onFormat(FormatCommand('list', _isActive('list', 'bullet') ? false : 'bullet')),
                tooltip: 'Bullet List'),
            // Indent
            _IconBtn(Icons.format_indent_decrease, iconColor,
                () => onFormat(const FormatCommand('indent', '-1')),
                tooltip: 'Decrease Indent'),
            _IconBtn(Icons.format_indent_increase, iconColor,
                () => onFormat(const FormatCommand('indent', '+1')),
                tooltip: 'Increase Indent'),
            _Divider(dividerColor),
            // Link
            _IconBtn(Icons.link, iconColor,
                () => onFormat(const FormatCommand('link')),
                tooltip: 'Link'),
            // Clear formatting
            _IconBtn(Icons.format_clear, iconColor,
                () => onFormat(const FormatCommand('clean')),
                tooltip: 'Clear Formatting'),
            const SizedBox(width: 4),
          ],
        ),
      ),
      ),
    );
  }

  PopupMenuItem<Color?> _colorItem(Color? color, String label, BuildContext context) {
    return PopupMenuItem<Color?>(
      value: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16, height: 16,
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).colorScheme.onSurface,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

// ── Private helper widgets ──

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _IconBtn(this.icon, this.color, this.onPressed, {this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        hoverColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color defaultColor;
  final Color activeColor;
  final VoidCallback onPressed;
  final String? tooltip;

  const _ToggleBtn(
      this.icon, this.isActive, this.defaultColor, this.activeColor, this.onPressed,
      {this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        hoverColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: isActive
              ? BoxDecoration(
                  color: activeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: Icon(icon, size: 20,
              color: isActive ? activeColor : defaultColor),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: color,
    );
  }
}

class _PopupBtn<T> extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String tooltip;
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T> onSelected;

  const _PopupBtn({
    required this.icon,
    required this.iconColor,
    required this.tooltip,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: tooltip,
      onSelected: onSelected,
      offset: const Offset(0, 36),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(icon, size: 20, color: iconColor),
      itemBuilder: (_) => items,
    );
  }
}
