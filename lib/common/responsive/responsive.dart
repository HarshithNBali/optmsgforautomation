/// Common responsive utilities for the application.
///
/// This library exports all responsive-related classes and utilities.
/// Import this file to access breakpoints, layout builders, and extensions.
///
/// Usage:
/// ```dart
/// import 'package:optmsg/common/responsive/responsive.dart';
///
/// // Use breakpoints
/// if (AppBreakpoints.isMobile(width)) { ... }
///
/// // Use context extensions
/// if (context.isMobile) { ... }
///
/// // Use layout builder
/// ResponsiveLayoutBuilder(
///   mobile: (ctx, type, w) => MobileWidget(),
///   desktop: (ctx, type, w) => DesktopWidget(),
/// )
///
/// // Use responsive screen mixin
/// class _MyScreenState extends State<MyScreen> with ResponsiveScreenMixin {
///   @override
///   Widget build(BuildContext context) {
///     if (isMobile) return MobileLayout();
///     return DesktopLayout();
///   }
/// }
/// ```
library;

export 'breakpoints.dart';
export 'responsive_layout_builder.dart';
export 'base_responsive_screen.dart';
