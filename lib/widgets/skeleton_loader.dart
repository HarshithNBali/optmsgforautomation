import 'package:flutter/material.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:optmsg/constant/styles.dart';

/// A shimmer effect skeleton loader for loading states
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // L-05: derive shimmer colours from the active theme so the skeleton
    // works correctly in both light and dark mode.
    final scheme = Theme.of(context).colorScheme;
    final baseColor = scheme.surfaceContainerHighest;
    final highlightColor = scheme.surfaceContainerLow;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppStyles.radiusXS),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Small reusable skeleton widgets
//////////////////////////////////////////////////////////////////////////////

class SearchBarSkeleton extends StatelessWidget {
  final EdgeInsets padding;

  const SearchBarSkeleton({
    super.key,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SkeletonLoader(
        width: double.infinity,
        height: 40,
        borderRadius: BorderRadius.circular(AppStyles.radiusS),
      ),
    );
  }
}

class ReadingPaneSkeleton extends StatelessWidget {
  final int lineCount;
  final EdgeInsets padding;

  const ReadingPaneSkeleton({
    super.key,
    required this.lineCount,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: AppBreakpoints.skeletonWidthSm,
            height: 24,
            borderRadius: BorderRadius.circular(AppStyles.radiusXS),
          ),
          const SizedBox(height: 12),
          SkeletonLoader(
            width: AppBreakpoints.skeletonWidthLg,
            height: 14,
            borderRadius: BorderRadius.circular(AppStyles.radiusXS),
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: AppBreakpoints.skeletonWidthMd,
            height: 14,
            borderRadius: BorderRadius.circular(AppStyles.radiusXS),
          ),
          const SizedBox(height: 20),

          /// Content lines
          ...List.generate(
            lineCount,
                (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SkeletonLoader(
                width: double.infinity,
                height: 14,
                borderRadius: BorderRadius.circular(AppStyles.radiusXS),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Email list skeleton widgets
//////////////////////////////////////////////////////////////////////////////

class EmailListItemSkeleton extends StatelessWidget {
  const EmailListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          /// Avatar
          const SkeletonLoader(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          const SizedBox(width: 12),

          /// Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Name + Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoader(
                      width: 120,
                      height: 14,
                      borderRadius: BorderRadius.circular(AppStyles.radiusXS),
                    ),
                    SkeletonLoader(
                      width: 50,
                      height: 12,
                      borderRadius: BorderRadius.circular(AppStyles.radiusXS),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                /// Subject
                SkeletonLoader(
                  width: double.infinity,
                  height: 14,
                  borderRadius: BorderRadius.circular(AppStyles.radiusXS),
                ),
                const SizedBox(height: 6),

                /// Preview
                SkeletonLoader(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 12,
                  borderRadius: BorderRadius.circular(AppStyles.radiusXS),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InboxSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const InboxSkeletonLoader({
    super.key,
    this.itemCount = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, _) => const EmailListItemSkeleton(),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Shared layout skeleton (desktop + tablet)
//////////////////////////////////////////////////////////////////////////////

class InboxLayoutSkeleton extends StatelessWidget {
  final int listCount;
  final int contentLines;
  final EdgeInsets readingPadding;
  final int rightFlex;

  const InboxLayoutSkeleton({
    super.key,
    required this.listCount,
    required this.contentLines,
    required this.readingPadding,
    this.rightFlex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Email list section
        Expanded(
          flex: 1,
          child: Column(
            children: [
              const SearchBarSkeleton(),
              Expanded(
                child: InboxSkeletonLoader(itemCount: listCount),
              ),
            ],
          ),
        ),

        /// Divider
        Container(width: 1, color: Theme.of(context).colorScheme.outlineVariant),

        /// Reading pane
        Expanded(
          flex: rightFlex,
          child: ReadingPaneSkeleton(
            lineCount: contentLines,
            padding: readingPadding,
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Public widgets
//////////////////////////////////////////////////////////////////////////////

class DesktopInboxSkeletonLoader extends StatelessWidget {
  const DesktopInboxSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const InboxLayoutSkeleton(
      listCount: 8,
      contentLines: 6,
      rightFlex: 2,
      readingPadding: EdgeInsets.all(20),
    );
  }
}

class TabletInboxSkeletonLoader extends StatelessWidget {
  const TabletInboxSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const InboxLayoutSkeleton(
      listCount: 6,
      contentLines: 4,
      readingPadding: EdgeInsets.all(16),
    );
  }
}

