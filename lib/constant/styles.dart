import 'package:flutter/material.dart';
import 'package:optmsg/common/responsive/responsive.dart';

class AppStyles {
  // ═══════════════════════════════════════════════════════════════════════════
  // FONT WEIGHTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Legacy aliases — kept for backward compatibility
  static const FontWeight lightFontWeight = light;
  static const FontWeight regularFontWeight = regular;
  static const FontWeight miniMediumFontWeight = semiBold;
  static const FontWeight mediumFontWeight = bold;
  static const FontWeight boldFontWeight = bold;

  // ═══════════════════════════════════════════════════════════════════════════
  // SPACING
  // ═══════════════════════════════════════════════════════════════════════════

  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Message / reading density tokens
  static const double messageRowHeightCompact = 42.0;
  static const double messageRowHeightComfortable = 48.0;
  static const double messageRowHorizontalPadding = 10.0;
  static const double messageRowVerticalPadding = 5.0;
  static const double messageRowGap = 1.0;
  static const double messageHeaderRowGap = 4.0;
  static const double messageHeaderSectionGap = 8.0;
  static const double messageHeaderPadding = 10.0;
  static const double messageHeaderRowHeight = 20.0;
  static const double attachmentTileMinHeight = 40.0;
  static const double attachmentTileHeight = 44.0;
  static const double tagChipHeight = 20.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // CHECKBOX — responsive tap-target & icon sizing
  // ═══════════════════════════════════════════════════════════════════════════

  /// Responsive SizedBox dimension (width & height) for multi-select checkboxes.
  static double checkboxSize(BuildContext context) {
    final type = AppBreakpoints.deviceType(context);
    return switch (type) {
      DeviceType.mobile => 40.0,
      DeviceType.tablet => 36.0,
      DeviceType.desktop => 36.0,
    };
  }

  /// Responsive icon size for multi-select checkbox icons.
  static double checkboxIconSize(BuildContext context) {
    final type = AppBreakpoints.deviceType(context);
    return switch (type) {
      DeviceType.mobile => 22.0,
      DeviceType.tablet => 20.0,
      DeviceType.desktop => 20.0,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ═══════════════════════════════════════════════════════════════════════════

  static const double radiusXS = 3.0;
  static const double radiusS = 4.0;
  static const double radiusM = 6.0;
  static const double radiusL = 8.0;
  static const double radiusXL = 8.0;
  static const double radiusXXL = 12.0;
  static const double radiusFull = 100.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // FLOATING ACTION BUTTON
  // ═══════════════════════════════════════════════════════════════════════════

  static const double fabSize = 40.0;
  static const double fabIconSize = 22.0;
  static const double fabRadius = 10.0;
  static const double fabInset = 16.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // FONT SIZES — legacy, prefer type scale below
  // ═══════════════════════════════════════════════════════════════════════════

  static const double smallFontSize = 12.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 20.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORS — Brand
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color primaryColor = Color(0xFF243A8F);
  static const Color primaryDark = Color(0xFF1B2A6B);

  /// Darker interactive variant of primaryColor — use for hover/active states
  static const Color primaryVariant = Color(0xFF2F4CC8);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Light-mode AppBar gradient — matches original v1.0.6 appearance.
  /// Deep navy at top, brighter blue at bottom.
  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xFF2748C3), // brighter blue (bottom)
      Color(0xFF121E57), // deep navy (top)
    ],
    stops: [0.01, 0.58],
  );

  /// Orange accent gradient — use for primary CTA buttons
  static const LinearGradient accentButtonGradient = LinearGradient(
    begin: Alignment(0.00, -1.00),
    end: Alignment(0, 1),
    colors: [Color(0xFFFC976D), Color(0xFFFD5D1A)],
  );

  /// Disabled / inactive button gradient
  static const LinearGradient disabledButtonGradient = LinearGradient(
    begin: Alignment(1, 0),
    end: Alignment(-1.00, 0.00),
    colors: [Color(0xFFE3E7E9), Color(0xFFE3E7E9)],
  );

  static const Color secondaryColor = Color(0xFFB3CCFF);
  @Deprecated('Use context.appColors.tintSecondary')
  static const Color lightSecondaryColor = Color(0xFFEEF4FF);

  // Neutral reading surfaces / content hierarchy
  static const Color readingSurfaceLight = Color(0xFFFFFFFF);
  static const Color readingSurfaceAltLight = Color(0xFFF8FAFC);
  static const Color readingDividerLight = Color(0xFFE5E7EB);
  static const Color messageSelectedRowLight = Color(0xFFEFF4FF);
  static const Color messageHoverRowLight = Color(0xFFF8FAFC);

  static const Color messageListSenderReadLight = Color(0xFF1F2937);
  static const Color messageListSenderUnreadLight = Color(0xFF111827);
  static const Color messageListSubjectReadLight = Color(0xFF374151);
  static const Color messageListSubjectUnreadLight = Color(0xFF1F2937);
  static const Color messageListPreviewLight = Color(0xFF6B7280);
  static const Color messageListTimeLight = Color(0xFF6B7280);

  static const Color readingSubjectLight = Color(0xFF111827);
  static const Color readingBodyLight = Color(0xFF1F2937);
  static const Color readingMetaLight = Color(0xFF6B7280);
  static const Color readingHeaderValueLight = Color(0xFF374151);
  static const Color readingHeaderLabel = Color(0xFF2563EB);

  static const Color readingSurfaceDark = Color(0xFF1E1E1E);
  static const Color readingSurfaceAltDark = Color(0xFF2C2C2C);
  static const Color readingDividerDark = Color(0xFF3A3A3A);
  static const Color messageSelectedRowDark = Color(0xFF2A2A2A);
  static const Color messageHoverRowDark = Color(0xFF252525);

  static const Color messageListSenderDark = Color(0xFFE5E7EB);
  static const Color messageListSubjectDark = Color(0xFFD1D5DB);
  static const Color messageListPreviewDark = Color(0xFF9CA3AF);
  static const Color messageListTimeDark = Color(0xFF9CA3AF);
  static const Color readingSubjectDark = Color(0xFFF3F4F6);
  static const Color readingBodyDark = Color(0xFFD1D5DB);
  static const Color readingMetaDark = Color(0xFF9CA3AF);
  static const Color readingHeaderValueDark = Color(0xFFE5E7EB);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORS — Semantic
  // ═══════════════════════════════════════════════════════════════════════════

  /// @deprecated Use `context.colors.surface` or `context.colors.onPrimary`.
  static const Color white = Color(0xFFFFFFFF);

  /// @deprecated Use `context.colors.outlineVariant`.
  static const Color stroke = Color(0xFFf1f1f1);

  /// @deprecated Use `context.colors.onSurfaceVariant`.
  static const Color grey = Color(0xFF747474);

  /// Brand orange accent — canonical constant, also available via `context.appColors.accent`.
  static const Color clickableTextColor = Color(0xFFFF6B35);
  @Deprecated('Use context.appColors.accentBg')
  static const Color clickableBgColor = Color.fromARGB(53, 255, 107, 53);

  @Deprecated('Use context.appColors.toggleGreen')
  static const Color toggleBackground = Color(0xFF00BF30);

  static const Color orange = Color(0xFFFFA800);

  @Deprecated('Use context.appColors.tintOrange')
  static const Color lightOrange = Color(0xFFFFF5E1);

  /// Semi-transparent dark overlay — use for modal backdrops
  static const Color overlayDark = Color.fromRGBO(0, 0, 0, 0.5);

  /// Light scrim — use for subtle overlays and dimming
  static const Color overlayLight = Color.fromRGBO(0, 0, 0, 0.1);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORS — Status / Feedback (source values for AppColorsExtension)
  // Prefer context.appColors.statusXxxBg / .statusXxxText in widgets.
  // ═══════════════════════════════════════════════════════════════════════════

  // Light mode
  static const Color bgError = Color(0xFFEBC8C4);
  static const Color textError = Color(0xFFB04249);
  static const Color bgWarn = Color(0xFFF8F3D6);
  static const Color textWarn = Color(0xFF967942);
  static const Color bgInfo = Color(0xFFCCE8F4);
  static const Color textInfo = Color(0xFF5F8DAA);
  static const Color bgSuccess = Color(0xFFDEF2D5);
  static const Color textSuccess = Color(0xFF5C7054);

  // Dark mode
  static const Color bgErrorDark = Color(0xFF3D1519);
  static const Color textErrorDark = Color(0xFFFFB4AB);
  static const Color bgWarnDark = Color(0xFF3D3012);
  static const Color textWarnDark = Color(0xFFE8D48B);
  static const Color bgInfoDark = Color(0xFF0E2D3D);
  static const Color textInfoDark = Color(0xFF90CAE0);
  static const Color bgSuccessDark = Color(0xFF1A3318);
  static const Color textSuccessDark = Color(0xFFA8D89A);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORS — Legacy aliases (kept for backward compatibility, avoid new usage)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Prefer primaryVariant. iOS system blue — avoid in new UI.
  static const Color primary2Color = Color(0xFF007AFF);

  /// Prefer overlayDark
  static const Color backDrop = overlayDark;

  /// Prefer overlayLight
  static const Color backDrop1 = overlayLight;

  /// Prefer primaryVariant
  static const Color blueBackground = primaryVariant;

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORS — Dark Mode Surfaces
  // Used to build the dark ThemeData in main.dart
  // ═══════════════════════════════════════════════════════════════════════════

  /// Scaffold background in dark mode — neutral charcoal
  static const Color surfaceDark = Color(0xFF121212);

  /// Card / container surface in dark mode
  static const Color surfaceContDark = Color(0xFF1E1E1E);

  /// Elevated card surface in dark mode
  static const Color surfaceHighDark = Color(0xFF2C2C2C);

  /// Primary text on dark surfaces
  static const Color onSurfaceDark = Color(0xFFE5E7EB);

  /// Secondary / muted text on dark surfaces
  static const Color onSurfaceVarDark = Color(0xFF9E9E9E);

  // ═══════════════════════════════════════════════════════════════════════════
  // EMAIL HTML — CSS hex strings for dark/light mode HTML rendering
  // Used by NativeAppHtmlView and HtmlSanitizerService to inject theme-aware
  // CSS into email WebView/iframe content. Single source of truth so both
  // platforms stay consistent with the Flutter theme.
  // ═══════════════════════════════════════════════════════════════════════════

  // Light mode
  static const String emailBgLight = '#ffffff';
  static const String emailFgLight = '#000000';
  static const String emailLinkLight = '#1c5ad6';
  static const String emailQuoteBorderLight = '#ddd';

  // Dark mode
  static const String emailBgDark = '#121212'; // matches surfaceDark scaffold
  static const String emailFgDark = '#D1D5DB'; // readingBodyDark
  static const String emailLinkDark = '#7EB3FF'; // linkBlue dark
  static const String emailQuoteBorderDark = '#3A3A3A';

  /// Helper — returns the correct CSS hex string for the given brightness.
  static String emailBg(bool isDark) => isDark ? emailBgDark : emailBgLight;
  static String emailFg(bool isDark) => isDark ? emailFgDark : emailFgLight;
  static String emailLink(bool isDark) => isDark ? emailLinkDark : emailLinkLight;
  static String emailQuoteBorder(bool isDark) =>
      isDark ? emailQuoteBorderDark : emailQuoteBorderLight;

  // ═══════════════════════════════════════════════════════════════════════════
  // TYPE SCALE — moved to AppTypography (lib/constant/app_typography.dart)
  //
  // The responsive type scale (displayLarge, headlineLarge, bodyMedium, etc.)
  // now lives in AppTypography with breakpoint-aware sizing. Use:
  //   AppTypography.titleLarge(context)
  //   AppTypography.bodyMedium(context).copyWith(color: ...)
  // ═══════════════════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════════════════
  // LEGACY TEXT STYLES — migrate to AppTypography responsive equivalents
  // See @Deprecated annotations for the replacement method to use.
  // ═══════════════════════════════════════════════════════════════════════════

  @Deprecated('Use AppTypography.flag(context)')
  static const TextStyle flagText = TextStyle(
    color: AppStyles.orange,
    fontSize: 12.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.button(context)')
  static const TextStyle buttonText = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated('Use AppTypography.heroTitle(context)')
  static const TextStyle titleText = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 27.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.subTitle(context)')
  static const TextStyle subTitleText = TextStyle(
    color: Color(0xFFB3CCFF),
    fontSize: 17.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.appBarTitle(context)')
  static const TextStyle appBarTitleText = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
  );

  @Deprecated(
    'Use AppTypography.inboxCount(context).copyWith(color: AppStyles.textError)',
  )
  static const TextStyle inboxCount = TextStyle(
    color: AppStyles.textError,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.inboxCount(context)')
  static const TextStyle inboxCount2 = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.draftCount(context)')
  static const TextStyle draftCount2 = TextStyle(
    color: Color(0xFF001625),
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.hintText(context)')
  static const TextStyle hintText = TextStyle(
    color: Color(0xFFB3CCFF),
    fontSize: 15.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.inboxTitle(context)')
  static const TextStyle inboxTitleText = TextStyle(
    color: Color(0xFF001625),
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated('Use AppTypography.draftText(context)')
  static const TextStyle draftText = TextStyle(
    color: AppStyles.primaryColor,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated('Use AppTypography.emailAddress(context)')
  static const TextStyle email = TextStyle(
    color: AppStyles.primaryColor,
    fontSize: 17.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.inboxSubTitle(context)')
  static const TextStyle inboxSubTitleText = TextStyle(
    color: Color(0xFF001625),
    fontSize: 17.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.emailPreText(context)')
  static const TextStyle emailPreText = TextStyle(
    color: Color(0xFF1C5AD6),
    fontSize: 17.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.inboxSubTitle2(context)')
  static const TextStyle inboxSubTitleText2 = TextStyle(
    color: Color(0xFF001625),
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated('Use AppTypography.cantEdit(context)')
  static const TextStyle cantEdit = TextStyle(
    color: Color(0xFFFF3535),
    fontSize: 8.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.drawerTitle(context)')
  static const TextStyle drawerTitle = TextStyle(
    color: Color(0xFF001625),
    fontSize: 17.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.drawerTitle2(context)')
  static const TextStyle drawerTitle2 = TextStyle(
    color: Color(0xFF001625),
    fontSize: 17.0,
    fontWeight: FontWeight.w800,
  );

  @Deprecated('Use AppTypography.slogan(context)')
  static const TextStyle sloganText = TextStyle(
    color: Color(0xFF747474),
    fontSize: 15.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated(
    'Use AppTypography.slogan(context).copyWith(color: AppStyles.primaryColor)',
  )
  static const TextStyle sloganTextMobile = TextStyle(
    color: AppStyles.primaryColor,
    fontSize: 15.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.loginContent(context)')
  static const TextStyle loginStaticContent = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated('Use AppTypography.popUpTitle(context)')
  static const TextStyle popUpTitle = TextStyle(
    color: Color(0xFF001625),
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated('Use AppTypography.tagPopUpTitle(context)')
  static const TextStyle tagPopUpTitle = TextStyle(
    color: Color(0xFF001625),
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated('Use AppTypography.copyright(context)')
  static const TextStyle copyrightText = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 14.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.alfaListText(context)')
  static const TextStyle alfaListText = TextStyle(
    color: Color(0xFF1c5ad6),
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.alfaSelectedListText(context)')
  static const TextStyle alfaSelectedListText = TextStyle(
    color: Color(0xFF1c5ad6),
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
  );

  @Deprecated('Use AppTypography.emailText(context)')
  static const TextStyle emailText = TextStyle(
    color: Color(0xFF1c5ad6),
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.logOut(context)')
  static const TextStyle logOutText = TextStyle(
    color: Color.fromARGB(255, 253, 26, 26),
    fontSize: 17.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.noteText(context)')
  static const TextStyle noteText = TextStyle(
    color: Color.fromARGB(255, 253, 26, 26),
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.profileSubTitle(context)')
  static const TextStyle editProfileSubTitleText = TextStyle(
    color: Color(0xFF747474),
    fontSize: 17.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.profileTitle(context)')
  static const TextStyle editProfileTitleText = TextStyle(
    color: Color(0xFF001625),
    fontSize: 27.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.userNameTitle(context)')
  static const TextStyle userNameTitle = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 40.0,
    fontWeight: boldFontWeight,
  );

  @Deprecated('Use AppTypography.webRoute(context)')
  static const TextStyle webRouteText = TextStyle(
    color: Color(0xFF001625),
    fontSize: 32.0,
    fontWeight: boldFontWeight,
  );

  @Deprecated('Use AppTypography.displayLarge(context).copyWith(color: white)')
  static const TextStyle planText = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 40.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.planSubTitle(context)')
  static const TextStyle planSubTitle = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 20.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.timeStamp(context)')
  static const TextStyle timeText = TextStyle(
    color: AppStyles.grey,
    fontSize: 13.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.planName(context)')
  static const TextStyle planName = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 25.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated(
    'Use AppTypography.displayLarge(context).copyWith(color: white, fontWeight: FontWeight.w800)',
  )
  static const TextStyle planPrice = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 35.0,
    fontWeight: FontWeight.w800,
  );

  @Deprecated('Use AppTypography.checkOutTitle(context)')
  static const TextStyle checkOutPlanTitle = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 35.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated('Use AppTypography.checkOutSummary(context)')
  static const TextStyle checkOutOrderSummaryText = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 16.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.emailLabel(context)')
  static const TextStyle emailLabel = TextStyle(
    color: grey,
    fontSize: 17.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.actionSheetDelete(context)')
  static const TextStyle actionSheetDelete = TextStyle(
    color: Color(0xFFFF3B30),
    fontSize: 17.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.actionSheetItem(context)')
  static const TextStyle actionSheetItem = TextStyle(
    color: primary2Color,
    fontSize: 17.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.actionSheetCancel(context)')
  static const TextStyle actionSheetCancel = TextStyle(
    color: primary2Color,
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated('Use AppTypography.titleTxt(context)')
  static const TextStyle titleTxt = TextStyle(
    color: Color(0xFF747474),
    fontSize: 15.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.subject(context)')
  static const TextStyle subject = TextStyle(
    color: Color(0xFF001625),
    fontSize: 25.0,
    fontWeight: FontWeight.w700,
  );

  @Deprecated('Use AppTypography.viewEmailSubject(context)')
  static const TextStyle viewEmailSubject = TextStyle(
    color: Color(0xFF001625),
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
  );

  @Deprecated('Use AppTypography.titleTxt2(context)')
  static const TextStyle titleTxt2 = TextStyle(
    color: Color(0xFF747474),
    fontSize: 14.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.gray16(context)')
  static const TextStyle gray16Text = TextStyle(
    color: Color(0xFF747474),
    fontSize: 16.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.black20(context)')
  static const TextStyle black20Text = TextStyle(
    color: Color(0xFF0B2239),
    fontSize: 20.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.black22(context)')
  static const TextStyle black22Text = TextStyle(
    color: Color(0xFF0B2239),
    fontSize: 22.0,
    fontWeight: regularFontWeight,
  );

  @Deprecated('Use AppTypography.blackBold20(context)')
  static const TextStyle blackBold20Text = TextStyle(
    color: Color(0xFF0B2239),
    fontSize: 20.0,
    fontWeight: boldFontWeight,
  );

  @Deprecated('Use AppTypography.redMedium15(context)')
  static const TextStyle redMedium15Text = TextStyle(
    color: Color(0xFFff3535),
    fontSize: 15.0,
    fontWeight: mediumFontWeight,
  );

  @Deprecated('Use AppTypography.minMed14Black(context)')
  static const TextStyle minMed14BoldBlack = TextStyle(
    color: Color(0xFF001625),
    fontSize: 14.0,
    fontWeight: miniMediumFontWeight,
  );

  @Deprecated('Use AppTypography.minMed14White(context)')
  static const TextStyle minMed14BoldWhite = TextStyle(
    color: Colors.white,
    fontSize: 14.0,
    fontWeight: miniMediumFontWeight,
  );

  @Deprecated('Use AppTypography.inboxTitle1(context)')
  static const TextStyle inboxTitleText1 = TextStyle(
    color: Color(0xFF000000),
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
  );

  @Deprecated('Use AppTypography.inboxSubTitle1(context)')
  static const TextStyle inboxSubTitleText1 = TextStyle(
    color: Color(0xFF000000),
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated('Use AppTypography.timeStamp1(context)')
  static const TextStyle timeText1 = TextStyle(
    color: Color(0xFF5c5252),
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
  );

  @Deprecated('Use AppTypography.appBarTitle1(context)')
  static const TextStyle appBarTitleText1 = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 17.0,
    fontWeight: FontWeight.w500,
  );

  @Deprecated('Use AppTypography.attachmentSize(context)')
  static const TextStyle attachmentsSize = TextStyle(
    color: Color(0xFF747474),
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated('Use AppTypography.transactionDetails(context)')
  static const TextStyle transactionDetails = TextStyle(
    color: Color(0xFF001625),
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
  );

  @Deprecated('Use AppTypography.passKeyDescription(context)')
  static const TextStyle passKeyDescription = TextStyle(
    color: Color(0xFFB3CCFF),
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
  );

  @Deprecated('Use AppTypography.noPassKey(context)')
  static const TextStyle noPassKey = TextStyle(
    color: clickableTextColor,
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
  );
}
