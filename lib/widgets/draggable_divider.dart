import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:optmsg/common/responsive/responsive.dart';

class DraggableDivider extends StatefulWidget {
  /// Whether to resize horizontally (column divider) or vertically (row divider)
  final bool isHorizontal;

  /// The current width/height of the pane being resized
  final double currentSize;

  /// Minimum allowed size
  final double minSize;

  /// Maximum allowed size
  final double maxSize;

  /// Called during drag with the new size (for live preview)
  final ValueChanged<double>? onDragUpdate;

  /// Called when drag ends with the final size (for persisting to state)
  final ValueChanged<double> onDragEnd;

  const DraggableDivider({
    super.key,
    required this.isHorizontal,
    required this.currentSize,
    required this.minSize,
    required this.maxSize,
    this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  State<DraggableDivider> createState() => _DraggableDividerState();
}

class _DraggableDividerState extends State<DraggableDivider> {
  double? _dragSize;
  bool _isDragging = false;
  bool _isHovering = false;

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragSize = widget.currentSize;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = widget.isHorizontal ? details.delta.dx : -details.delta.dy;
    final newSize = (_dragSize ?? widget.currentSize) + delta;
    final clampedSize = newSize.clamp(widget.minSize, widget.maxSize);

    setState(() {
      _dragSize = clampedSize;
    });

    // Optional callback for live preview (parent can use this to update layout)
    widget.onDragUpdate?.call(clampedSize);
  }

  void _handleDragEnd(DragEndDetails details) {
    final finalSize = _dragSize ?? widget.currentSize;

    setState(() {
      _isDragging = false;
      _dragSize = null;
    });

    // Persist the final size to state
    widget.onDragEnd(finalSize);
  }

  void _setHover(bool value) {
    if (!kIsWeb) return; // touch platforms have no pointer hover
    if (!mounted) return;
    setState(() => _isHovering = value);
  }

  Color _dotColor(BuildContext context) {
    if (_isDragging) return context.colors.primary;
    if (_isHovering) return context.colors.onSurfaceVariant;
    return context.colors.outline;
  }

  Color _lineColor(BuildContext context) {
    if (_isDragging) return context.colors.primary;
    return context.colors.outlineVariant;
  }

  /// Builds the 2×3 (horizontal) or 3×2 (vertical) dot grip grid.
  Widget _buildGripDots(BuildContext context) {
    const double dotSize = 3.0;
    const double dotGap = 3.0;

    final int cols = widget.isHorizontal ? 2 : 3;
    final int rows = widget.isHorizontal ? 3 : 2;

    final dotDecoration = BoxDecoration(
      shape: BoxShape.circle,
      color: _dotColor(context),
    );

    final List<Widget> rowWidgets = List.generate(rows, (r) {
      final List<Widget> colWidgets = List.generate(cols, (c) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          width: dotSize,
          height: dotSize,
          decoration: dotDecoration,
        );
      });

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int c = 0; c < cols; c++) ...[
            if (c > 0) const SizedBox(width: dotGap),
            colWidgets[c],
          ],
        ],
      );
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int r = 0; r < rows; r++) ...[
          if (r > 0) const SizedBox(height: dotGap),
          rowWidgets[r],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isHorizontal
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.resizeRow,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onHorizontalDragStart: widget.isHorizontal ? _handleDragStart : null,
        onHorizontalDragUpdate: widget.isHorizontal ? _handleDragUpdate : null,
        onHorizontalDragEnd: widget.isHorizontal ? _handleDragEnd : null,
        onVerticalDragStart: !widget.isHorizontal ? _handleDragStart : null,
        onVerticalDragUpdate: !widget.isHorizontal ? _handleDragUpdate : null,
        onVerticalDragEnd: !widget.isHorizontal ? _handleDragEnd : null,
        child: Container(
          width: widget.isHorizontal ? 10 : null,
          height: !widget.isHorizontal ? 10 : null,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Full-length separator line — spans entire divider via Positioned.fill
              Positioned.fill(
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    width: widget.isHorizontal ? 1.0 : null,
                    height: !widget.isHorizontal ? 1.0 : null,
                    color: _lineColor(context),
                  ),
                ),
              ),
              // Dot grid floats at natural size, centered on the line.
              // OverflowBox decouples visual bounds from the 10px hit-area constraint.
              OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: _buildGripDots(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A complete resizable split pane widget that handles all the state management internally.
/// This provides the smoothest drag experience by keeping all state local.
class ResizableSplitPane extends StatefulWidget {
  /// First child (left or top pane)
  final Widget firstChild;

  /// Second child (right or bottom pane)
  final Widget secondChild;

  /// Whether to split horizontally (side-by-side) or vertically (stacked)
  final bool isHorizontal;

  /// Initial size of the first pane (width if horizontal, height if vertical)
  final double initialFirstPaneSize;

  /// Minimum size of the first pane
  final double minFirstPaneSize;

  /// Maximum size of the first pane
  final double maxFirstPaneSize;

  /// Called when the pane size changes (on drag end)
  final ValueChanged<double>? onSizeChanged;

  const ResizableSplitPane({
    super.key,
    required this.firstChild,
    required this.secondChild,
    this.isHorizontal = true,
    required this.initialFirstPaneSize,
    required this.minFirstPaneSize,
    required this.maxFirstPaneSize,
    this.onSizeChanged,
  });

  @override
  State<ResizableSplitPane> createState() => _ResizableSplitPaneState();
}

class _ResizableSplitPaneState extends State<ResizableSplitPane> {
  late double _firstPaneSize;

  @override
  void initState() {
    super.initState();
    _firstPaneSize = widget.initialFirstPaneSize;
  }

  @override
  void didUpdateWidget(ResizableSplitPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update size if it changed externally (e.g., from stored preferences)
    if (oldWidget.initialFirstPaneSize != widget.initialFirstPaneSize &&
        _firstPaneSize == oldWidget.initialFirstPaneSize) {
      _firstPaneSize = widget.initialFirstPaneSize;
    }
  }

  void _handleDragUpdate(double newSize) {
    setState(() {
      _firstPaneSize = newSize;
    });
  }

  void _handleDragEnd(double finalSize) {
    setState(() {
      _firstPaneSize = finalSize;
    });
    widget.onSizeChanged?.call(finalSize);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHorizontal) {
      return Row(
        children: [
          SizedBox(width: _firstPaneSize, child: widget.firstChild),
          DraggableDivider(
            isHorizontal: true,
            currentSize: _firstPaneSize,
            minSize: widget.minFirstPaneSize,
            maxSize: widget.maxFirstPaneSize,
            onDragUpdate: _handleDragUpdate,
            onDragEnd: _handleDragEnd,
          ),
          Expanded(child: widget.secondChild),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(child: widget.firstChild),
          DraggableDivider(
            isHorizontal: false,
            currentSize: _firstPaneSize,
            minSize: widget.minFirstPaneSize,
            maxSize: widget.maxFirstPaneSize,
            onDragUpdate: _handleDragUpdate,
            onDragEnd: _handleDragEnd,
          ),
          SizedBox(height: _firstPaneSize, child: widget.secondChild),
        ],
      );
    }
  }
}
