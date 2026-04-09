// Responsive typography system for OptMsg.
//
// Provides breakpoint-aware TextStyles that scale across mobile (<600px),
// tablet (600–1023px), and desktop (≥1024px). Uses the same type scale from
// the Typography Specification (docs/UXUI_MODERNIZATION_PLAN.md) with
// conservative offsets per breakpoint.
//
// Usage:
//   Text('Hello', style: AppTypography.titleLarge(context))
//   Text('Hello', style: AppTypography.titleLarge(context).copyWith(color: Colors.white))
//
// Base responsive methods (displayLarge, titleMedium, etc.) are color-free.
// Legacy compatibility methods use theme-aware `context.colors.*` tokens.

import 'package:flutter/material.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/constant/string_constant.dart'
    show headingFontFamily, bodyFontFamily;
import 'package:optmsg/constant/styles.dart';

// ---------------------------------------------------------------------------
// Private data class holding per-breakpoint font sizes + shared properties
// ---------------------------------------------------------------------------

class _ResponsiveStyle {
  final double mobile;
  final double tablet;
  final double desktop;
  final FontWeight weight;
  final double height;
  final String fontFamily;
  final double letterSpacing;

  const _ResponsiveStyle({
    required this.mobile,
    required this.tablet,
    required this.desktop,
    required this.weight,
    required this.height,
    required this.fontFamily,
    this.letterSpacing = 0,
  });
}

// ---------------------------------------------------------------------------
// AppTypography — responsive text styles
// ---------------------------------------------------------------------------

class AppTypography {
  AppTypography._();

  // ═════════════════════════════════════════════════════════════════════════
  // PUBLIC RESPONSIVE METHODS — Figtree (UI chrome: headings, nav, labels)
  // ═════════════════════════════════════════════════════════════════════════

  /// Hero numbers, plan prices, large display text
  static TextStyle displayLarge(BuildContext context) =>
      _resolve(context, _displayLarge);

  /// Screen titles, section headings
  static TextStyle headlineLarge(BuildContext context) =>
      _resolve(context, _headlineLarge);

  /// Card headings, dialog titles
  static TextStyle headlineMedium(BuildContext context) =>
      _resolve(context, _headlineMedium);

  /// App bar titles, panel headings
  static TextStyle titleLarge(BuildContext context) =>
      _resolve(context, _titleLarge);

  /// List row titles, form labels, nav items
  static TextStyle titleMedium(BuildContext context) =>
      _resolve(context, _titleMedium);

  /// Secondary labels, compact headings
  static TextStyle titleSmall(BuildContext context) =>
      _resolve(context, _titleSmall);

  /// Buttons, primary action text
  static TextStyle labelLarge(BuildContext context) =>
      _resolve(context, _labelLarge);

  /// Secondary buttons, tab labels
  static TextStyle labelMedium(BuildContext context) =>
      _resolve(context, _labelMedium);

  /// Chips, badges, tags
  static TextStyle labelSmall(BuildContext context) =>
      _resolve(context, _labelSmall);

  // ═════════════════════════════════════════════════════════════════════════
  // PUBLIC RESPONSIVE METHODS — NotoSans (reading content: email, previews)
  // ═════════════════════════════════════════════════════════════════════════

  /// Email previews, long-form UI text
  static TextStyle bodyLarge(BuildContext context) =>
      _resolve(context, _bodyLarge);

  /// Standard body text, notification content
  static TextStyle bodyMedium(BuildContext context) =>
      _resolve(context, _bodyMedium);

  /// Secondary body, compact reading text
  static TextStyle bodySmall(BuildContext context) =>
      _resolve(context, _bodySmall);

  /// Timestamps, file sizes, metadata
  static TextStyle caption(BuildContext context) => _resolve(context, _caption);

  /// Full email reading pane body
  static TextStyle emailBody(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _resolve(context, _emailBody).copyWith(
      color: isDark ? AppStyles.readingBodyDark : AppStyles.readingBodyLight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.55,
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // LEGACY COMPATIBILITY METHODS
  //
  // Drop-in responsive replacements for the most-used AppStyles.* constants.
  // Colors use theme-aware `context.colors.*` tokens from the app's
  // ColorScheme. Brand-specific colors (links, CTAs, errors) remain hardcoded.
  //
  // Migration: AppStyles.appBarTitleText → AppTypography.appBarTitle(context)
  // ═════════════════════════════════════════════════════════════════════════

  // ── App Bar / Navigation ──

  /// Replaces AppStyles.appBarTitleText (white, 20, w700)
  static TextStyle appBarTitle(BuildContext context) => titleLarge(
    context,
  ).copyWith(color: context.colors.onPrimary, fontWeight: FontWeight.w700);

  /// Replaces AppStyles.appBarTitleText1 (white, 17, w500)
  static TextStyle appBarTitle1(BuildContext context) => titleMedium(
    context,
  ).copyWith(color: context.colors.onPrimary, fontWeight: FontWeight.w500);

  /// Replaces AppStyles.drawerTitle (dark, 17, w500)
  static TextStyle drawerTitle(BuildContext context) => titleLarge(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w500);

  /// Replaces AppStyles.drawerTitle2 (dark, 17, w800)
  static TextStyle drawerTitle2(BuildContext context) => titleLarge(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w800);

  // ── Auth / Marketing ──

  /// Replaces AppStyles.titleText (white, 27, w500)
  static TextStyle heroTitle(BuildContext context) => headlineLarge(
    context,
  ).copyWith(color: context.colors.onPrimary, fontWeight: FontWeight.w500);

  /// Replaces AppStyles.subTitleText (light blue, 17, w400)
  static TextStyle subTitle(BuildContext context) => labelLarge(
    context,
  ).copyWith(color: context.colors.secondary, fontWeight: FontWeight.w400);

  /// Replaces AppStyles.hintText (light blue, 15, w400)
  static TextStyle hintText(BuildContext context) => labelMedium(
    context,
  ).copyWith(color: context.colors.secondary, fontWeight: FontWeight.w400);

  /// Brand tagline ("Your Inbox. Your Rules.") — theme-aware primary color.
  /// colorScheme.primary: light #243A8F (navy), dark #B3CCFF (light blue).
  static TextStyle slogan(BuildContext context) =>
      bodyMedium(context).copyWith(color: context.colors.primary);

  /// Replaces AppStyles.loginStaticContent (white, 20, w600)
  static TextStyle loginContent(BuildContext context) => titleLarge(
    context,
  ).copyWith(color: context.colors.onPrimary, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.copyrightText (white, 14, w400)
  static TextStyle copyright(BuildContext context) =>
      bodySmall(context).copyWith(color: context.colors.onPrimary);

  // ── Inbox / Email ──

  /// Replaces AppStyles.inboxTitleText (dark, 18, w600)
  static TextStyle inboxTitle(BuildContext context) => titleMedium(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.inboxSubTitleText (dark, 17, w500)
  static TextStyle inboxSubTitle(BuildContext context) => titleMedium(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w500);

  /// Replaces AppStyles.inboxSubTitleText2 (dark, 15, w600)
  static TextStyle inboxSubTitle2(BuildContext context) => titleSmall(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.inboxTitleText1 (black, 16, w700)
  static TextStyle inboxTitle1(BuildContext context) => titleMedium(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w700);

  /// Replaces AppStyles.inboxSubTitleText1 (black, 14, w600)
  static TextStyle inboxSubTitle1(BuildContext context) => titleSmall(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.inboxCount2 (white, 15, w500)
  static TextStyle inboxCount(BuildContext context) => labelMedium(
    context,
  ).copyWith(color: context.colors.onPrimary, fontWeight: FontWeight.w500);

  /// Replaces AppStyles.subject (dark, 25, w700)
  static TextStyle subject(BuildContext context) => headlineLarge(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w700);

  /// Replaces AppStyles.viewEmailSubject (tuned for reading comfort)
  static TextStyle viewEmailSubject(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return headlineMedium(context).copyWith(
      color: isDark
          ? AppStyles.readingSubjectDark
          : AppStyles.readingSubjectLight,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      height: 1.2,
    );
  }

  /// Replaces AppStyles.email (primary, 17, w500)
  static TextStyle emailAddress(BuildContext context) => titleMedium(
    context,
  ).copyWith(color: context.colors.primary, fontWeight: FontWeight.w500);

  /// Replaces AppStyles.emailText (blue, 15, w500)
  static TextStyle emailText(BuildContext context) => labelMedium(
    context,
  ).copyWith(color: Theme.of(context).extension<AppColorsExtension>()?.linkBlue ?? const Color(0xFF1C5AD6), fontWeight: FontWeight.w500);

  /// Replaces AppStyles.emailPreText (blue, 17, w500)
  static TextStyle emailPreText(BuildContext context) => labelLarge(
    context,
  ).copyWith(color: Theme.of(context).extension<AppColorsExtension>()?.linkBlue ?? const Color(0xFF1C5AD6), fontWeight: FontWeight.w500);

  /// Replaces AppStyles.emailLabel (grey, 17, w500)
  static TextStyle emailLabel(BuildContext context) =>
      titleMedium(context).copyWith(
        color: context.colors.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      );

  /// Replaces AppStyles.draftText (primary, 18, w600)
  static TextStyle draftText(BuildContext context) => titleMedium(
    context,
  ).copyWith(color: context.colors.primary, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.draftCount2 (dark, 15, w500)
  static TextStyle draftCount(BuildContext context) => labelMedium(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w500);

  // ── Timestamps ──

  /// Replaces AppStyles.timeText (grey, 13, w400)
  static TextStyle timeStamp(BuildContext context) =>
      caption(context).copyWith(color: context.colors.onSurfaceVariant);

  /// Replaces AppStyles.timeText1 (dark grey, 14, w400)
  static TextStyle timeStamp1(BuildContext context) =>
      caption(context).copyWith(color: context.colors.onSurfaceVariant);

  // ── Buttons / Actions ──

  /// Replaces AppStyles.buttonText (white, 17, w600)
  static TextStyle button(BuildContext context) => labelLarge(
    context,
  ).copyWith(color: context.colors.onPrimary, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.actionSheetCancel (blue, 17, w600)
  static TextStyle actionSheetCancel(BuildContext context) => labelLarge(
    context,
  ).copyWith(color: AppStyles.primary2Color, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.actionSheetItem (blue, 17, w400)
  static TextStyle actionSheetItem(BuildContext context) => labelLarge(
    context,
  ).copyWith(color: AppStyles.primary2Color, fontWeight: FontWeight.w400);

  /// Replaces AppStyles.actionSheetDelete (red, 17, w400)
  static TextStyle actionSheetDelete(BuildContext context) => labelLarge(
    context,
  ).copyWith(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w400);

  // ── Popups / Dialogs ──

  /// Replaces AppStyles.popUpTitle (dark, 22, w600)
  static TextStyle popUpTitle(BuildContext context) => headlineMedium(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.tagPopUpTitle (dark, 17, w600)
  static TextStyle tagPopUpTitle(BuildContext context) => titleMedium(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w600);

  // ── Profile / Settings ──

  /// Replaces AppStyles.editProfileTitleText (dark, 27, w500)
  static TextStyle profileTitle(BuildContext context) => headlineLarge(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w500);

  /// Replaces AppStyles.editProfileSubTitleText (grey, 17, w400)
  static TextStyle profileSubTitle(BuildContext context) =>
      titleMedium(context).copyWith(
        color: context.colors.onSurfaceVariant,
        fontWeight: FontWeight.w400,
      );

  /// Replaces AppStyles.logOutText (red, 17, w500)
  /// Color is theme-aware: colorScheme.error (light: #B04249, dark: #FFB4AB)
  static TextStyle logOut(BuildContext context) =>
      titleMedium(context).copyWith(
        color: Theme.of(context).colorScheme.error,
        fontWeight: FontWeight.w500,
      );

  /// Replaces AppStyles.noteText (red, 15, w500)
  static TextStyle noteText(BuildContext context) =>
      labelMedium(context).copyWith(
        color: const Color.fromARGB(255, 253, 26, 26),
        fontWeight: FontWeight.w500,
      );

  // ── Plans / Checkout ──

  /// Replaces AppStyles.planSubTitle (white, 20, w400)
  static TextStyle planSubTitle(BuildContext context) => titleLarge(
    context,
  ).copyWith(color: context.colors.onPrimary, fontWeight: FontWeight.w400);

  /// Replaces AppStyles.planName (white, 25, w600)
  static TextStyle planName(BuildContext context) => headlineLarge(
    context,
  ).copyWith(color: context.colors.onPrimary, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.checkOutPlanTitle (white, 35, w600)
  static TextStyle checkOutTitle(BuildContext context) => displayLarge(
    context,
  ).copyWith(color: context.colors.onPrimary, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.checkOutOrderSummaryText (white, 16, w400)
  static TextStyle checkOutSummary(BuildContext context) =>
      bodyMedium(context).copyWith(color: context.colors.onPrimary);

  // ── Misc ──

  /// Replaces AppStyles.flagText (orange, 12, w400)
  static TextStyle flag(BuildContext context) => labelSmall(
    context,
  ).copyWith(color: AppStyles.orange, fontWeight: FontWeight.w400);

  /// Replaces AppStyles.cantEdit (red, 8 → 11 for accessibility)
  static TextStyle cantEdit(BuildContext context) => labelSmall(
    context,
  ).copyWith(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500);

  /// Replaces AppStyles.attachmentsSize (grey, 11, w600)
  static TextStyle attachmentSize(BuildContext context) =>
      labelSmall(context).copyWith(
        color: context.colors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      );

  /// Replaces AppStyles.alfaListText (blue, 12, w500)
  static TextStyle alfaListText(BuildContext context) => labelSmall(
    context,
  ).copyWith(color: Theme.of(context).extension<AppColorsExtension>()?.linkBlue ?? const Color(0xFF1C5AD6), fontWeight: FontWeight.w500);

  /// Replaces AppStyles.alfaSelectedListText (blue, 15, w700)
  static TextStyle alfaSelectedListText(BuildContext context) => labelMedium(
    context,
  ).copyWith(color: Theme.of(context).extension<AppColorsExtension>()?.linkBlue ?? const Color(0xFF1C5AD6), fontWeight: FontWeight.w700);

  /// Replaces AppStyles.passKeyDescription (light blue, 13, w400)
  static TextStyle passKeyDescription(BuildContext context) =>
      bodySmall(context).copyWith(color: context.colors.secondary);

  /// Replaces AppStyles.noPassKey (orange, 17, w600)
  static TextStyle noPassKey(BuildContext context) => titleMedium(
    context,
  ).copyWith(color: AppStyles.clickableTextColor, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.webRouteText (dark, 32, w700)
  static TextStyle webRoute(BuildContext context) => displayLarge(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w700);

  /// Replaces AppStyles.userNameTitle (white, 40, w700)
  static TextStyle userNameTitle(BuildContext context) => displayLarge(
    context,
  ).copyWith(color: context.colors.onPrimary, fontWeight: FontWeight.w700);

  /// Replaces AppStyles.titleTxt (grey, 15, w400)
  static TextStyle titleTxt(BuildContext context) =>
      bodyMedium(context).copyWith(color: context.colors.onSurfaceVariant);

  /// Replaces AppStyles.titleTxt2 (grey, 14, w400)
  static TextStyle titleTxt2(BuildContext context) =>
      bodySmall(context).copyWith(color: context.colors.onSurfaceVariant);

  /// Replaces AppStyles.gray16Text (grey, 16, w400)
  static TextStyle gray16(BuildContext context) =>
      bodyMedium(context).copyWith(color: context.colors.onSurfaceVariant);

  /// Replaces AppStyles.black20Text (dark, 20, w400)
  static TextStyle black20(BuildContext context) => titleLarge(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w400);

  /// Replaces AppStyles.black22Text (dark, 22, w400)
  static TextStyle black22(BuildContext context) => headlineMedium(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w400);

  /// Replaces AppStyles.blackBold20Text (dark, 20, w700)
  static TextStyle blackBold20(BuildContext context) => titleLarge(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w700);

  /// Replaces AppStyles.redMedium15Text (red, 15, w700)
  static TextStyle redMedium15(BuildContext context) => labelMedium(
    context,
  ).copyWith(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700);

  /// Replaces AppStyles.minMed14BoldBlack (dark, 14, w600)
  static TextStyle minMed14Black(BuildContext context) => titleSmall(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.minMed14BoldWhite (white, 14, w600)
  static TextStyle minMed14White(BuildContext context) => titleSmall(
    context,
  ).copyWith(color: context.colors.onPrimary, fontWeight: FontWeight.w600);

  /// Replaces AppStyles.transactionDetails (dark, 16, w600)
  static TextStyle transactionDetails(BuildContext context) => titleMedium(
    context,
  ).copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w600);

  // ── Message List / Reading Pane Refinements ──

  static TextStyle messageListSender(
    BuildContext context, {
    bool unread = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Figtree titleLarge (17px mobile) — prominent sender anchors each row.
    return titleLarge(context).copyWith(
      color: isDark
          ? AppStyles.messageListSenderDark
          : unread
          ? AppStyles.messageListSenderUnreadLight
          : AppStyles.messageListSenderReadLight,
      fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
      letterSpacing: 0.05,
      height: 1.2,
    );
  }

  static TextStyle messageListSubject(
    BuildContext context, {
    bool unread = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Figtree titleMedium (14.5px mobile) — clear step down from sender.
    return titleMedium(context).copyWith(
      color: isDark
          ? AppStyles.messageListSubjectDark
          : unread
          ? AppStyles.messageListSubjectUnreadLight
          : AppStyles.messageListSubjectReadLight,
      fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
      letterSpacing: 0,
      height: 1.2,
    );
  }

  static TextStyle messageListPreview(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Figtree titleSmall (13.5px mobile) — readable preview text.
    return titleSmall(context).copyWith(
      color: isDark
          ? AppStyles.messageListPreviewDark
          : AppStyles.messageListPreviewLight,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.25,
    );
  }

  static TextStyle messageListTimestamp(
    BuildContext context, {
    bool unread = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Figtree labelMedium (12.5px mobile) — compact timestamp.
    return labelMedium(context).copyWith(
      color: isDark
          ? AppStyles.messageListTimeDark
          : AppStyles.messageListTimeLight,
      fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
      letterSpacing: 0,
      height: 1.2,
    );
  }

  static TextStyle messageHeaderLabel(BuildContext context) =>
      bodyMedium(context).copyWith(
        color: context.colors.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.2,
      );

  static TextStyle messageHeaderValue(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return bodyMedium(context).copyWith(
      color: isDark
          ? AppStyles.readingHeaderValueDark
          : AppStyles.readingHeaderValueLight,
      fontWeight: FontWeight.w400,
      height: 1.25,
    );
  }

  static TextStyle messageHeaderMeta(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return bodySmall(context).copyWith(
      color: isDark ? AppStyles.readingMetaDark : AppStyles.readingMetaLight,
      fontWeight: FontWeight.w400,
      height: 1.25,
    );
  }

  static TextStyle attachmentTitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return bodySmall(context).copyWith(
      color: isDark
          ? AppStyles.messageListSubjectDark
          : Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
      height: 1.2,
    );
  }

  static TextStyle attachmentMeta(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return caption(context).copyWith(
      color: isDark ? AppStyles.readingMetaDark : AppStyles.readingMetaLight,
      fontWeight: FontWeight.w400,
      height: 1.15,
    );
  }

  static TextStyle messageTag(BuildContext context) =>
      labelSmall(context).copyWith(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppStyles.onSurfaceDark
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
        height: 1.15,
      );

  // ═════════════════════════════════════════════════════════════════════════
  // PRIVATE STYLE DEFINITIONS — per-breakpoint sizes
  //
  // Scaling: mobile < tablet < desktop (ascending with screen size).
  // Mobile is compact (held close); desktop is largest (viewed at distance).
  // Matches Outlook, Gmail, Apple Mail rendering behaviour.
  // ═════════════════════════════════════════════════════════════════════════

  // Figtree — UI chrome
  //
  // Scaling: mobile ≈ tablet < desktop (ascending).
  // Mobile and tablet are nearly identical (both handheld, ~0.5px gap).
  // Desktop gets a larger bump (viewed at arm's length).
  // Matches Outlook, Gmail, Apple Mail behaviour.
  static const _displayLarge = _ResponsiveStyle(
    mobile: 30,
    tablet: 36,
    desktop: 40,
    weight: FontWeight.w800,
    height: 1.15,
    fontFamily: headingFontFamily,
    letterSpacing: -0.25,
  );

  static const _headlineLarge = _ResponsiveStyle(
    mobile: 21,
    tablet: 24,
    desktop: 27,
    weight: FontWeight.w700,
    height: 1.15,
    fontFamily: headingFontFamily,
    letterSpacing: -0.25,
  );

  static const _headlineMedium = _ResponsiveStyle(
    mobile: 17,
    tablet: 18,
    desktop: 19,
    weight: FontWeight.w700,
    height: 1.2,
    fontFamily: headingFontFamily,
    letterSpacing: -0.25,
  );

  static const _titleLarge = _ResponsiveStyle(
    mobile: 16,
    tablet: 16,
    desktop: 16.5,
    weight: FontWeight.w600,
    height: 1.2,
    fontFamily: headingFontFamily,
  );

  static const _titleMedium = _ResponsiveStyle(
    mobile: 14.5,
    tablet: 14.5,
    desktop: 15,
    weight: FontWeight.w600,
    height: 1.25,
    fontFamily: headingFontFamily,
  );

  static const _titleSmall = _ResponsiveStyle(
    mobile: 13.5,
    tablet: 13.5,
    desktop: 14,
    weight: FontWeight.w600,
    height: 1.2,
    fontFamily: headingFontFamily,
  );

  static const _labelLarge = _ResponsiveStyle(
    mobile: 14,
    tablet: 14,
    desktop: 14.5,
    weight: FontWeight.w500,
    height: 1.2,
    fontFamily: headingFontFamily,
    letterSpacing: 0.1,
  );

  static const _labelMedium = _ResponsiveStyle(
    mobile: 12.5,
    tablet: 12.5,
    desktop: 13,
    weight: FontWeight.w500,
    height: 1.2,
    fontFamily: headingFontFamily,
    letterSpacing: 0.1,
  );

  static const _labelSmall = _ResponsiveStyle(
    mobile: 11.5,
    tablet: 11.5,
    desktop: 12,
    weight: FontWeight.w500,
    height: 1.2,
    fontFamily: headingFontFamily,
    letterSpacing: 0.1,
  );

  // NotoSans — reading content
  static const _bodyLarge = _ResponsiveStyle(
    mobile: 15,
    tablet: 15.5,
    desktop: 15.5,
    weight: FontWeight.w400,
    height: 1.4,
    fontFamily: bodyFontFamily,
  );

  static const _bodyMedium = _ResponsiveStyle(
    mobile: 14.5,
    tablet: 14.5,
    desktop: 15,
    weight: FontWeight.w400,
    height: 1.35,
    fontFamily: bodyFontFamily,
  );

  static const _bodySmall = _ResponsiveStyle(
    mobile: 13,
    tablet: 13.5,
    desktop: 14,
    weight: FontWeight.w400,
    height: 1.3,
    fontFamily: bodyFontFamily,
  );

  static const _caption = _ResponsiveStyle(
    mobile: 12.5,
    tablet: 12.5,
    desktop: 13,
    weight: FontWeight.w400,
    height: 1.25,
    fontFamily: bodyFontFamily,
    letterSpacing: 0.1,
  );

  static const _emailBody = _ResponsiveStyle(
    mobile: 15.5,
    tablet: 16,
    desktop: 16,
    weight: FontWeight.w400,
    height: 1.55,
    fontFamily: bodyFontFamily,
  );

  // ═════════════════════════════════════════════════════════════════════════
  // SCALING ENGINE
  // ═════════════════════════════════════════════════════════════════════════

  static TextStyle _resolve(BuildContext context, _ResponsiveStyle def) {
    final type = AppBreakpoints.deviceType(context);
    final size = switch (type) {
      DeviceType.mobile => def.mobile,
      DeviceType.tablet => def.tablet,
      DeviceType.desktop => def.desktop,
    };
    return TextStyle(
      fontFamily: def.fontFamily,
      fontFamilyFallback: const ['NotoColorEmoji'],
      fontSize: size,
      fontWeight: def.weight,
      height: def.height,
      letterSpacing: def.letterSpacing,
    );
  }
}
