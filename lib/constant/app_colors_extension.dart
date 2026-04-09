import 'package:flutter/material.dart';
import 'package:optmsg/constant/styles.dart';

/// App-specific color tokens that extend the Material 3 ColorScheme.
///
/// Provides theme-aware access to status colors, accent/CTA colors, surface
/// tints, and gradients. Registered in both light and dark ThemeData so
/// widgets can use `context.appColors.X` without brightness checks.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    // Status / feedback
    required this.statusErrorBg,
    required this.statusErrorText,
    required this.statusWarnBg,
    required this.statusWarnText,
    required this.statusInfoBg,
    required this.statusInfoText,
    required this.statusSuccessBg,
    required this.statusSuccessText,
    // Interactive / CTA
    required this.accent,
    required this.accentBg,
    required this.accentHover,
    required this.accentButton,
    required this.linkBlue,
    required this.toggleGreen,
    // Icons
    required this.svgIconAccent,
    required this.svgIconMuted,
    // Surface tints
    required this.tintOrange,
    required this.tintSecondary,
    required this.messageSelectedRow,
    required this.semiTransparentSurface,
    required this.overlayBarrier,
    // Form fields
    required this.formFieldBorder,
    required this.formFieldHint,
    // Misc
    required this.stepBadgeBg,
    // Gradients
    required this.accentGradient,
    required this.disabledGradient,
    this.appBarGradient,
    required this.tagChipBg,
    required this.tagChipText,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Status / feedback
  // ═══════════════════════════════════════════════════════════════════════════

  final Color statusErrorBg;
  final Color statusErrorText;
  final Color statusWarnBg;
  final Color statusWarnText;
  final Color statusInfoBg;
  final Color statusInfoText;
  final Color statusSuccessBg;
  final Color statusSuccessText;

  // ═══════════════════════════════════════════════════════════════════════════
  // Interactive / CTA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Orange accent for links, icons, and CTAs (#FF6B35 — same both modes).
  final Color accent;

  /// Semi-transparent accent tint for backgrounds behind accent elements.
  final Color accentBg;

  /// Darker orange for hover/pressed states on accent elements.
  final Color accentHover;

  /// Solid orange for button backgrounds (#FD5D1A).
  final Color accentButton;

  /// Clickable link blue — lighter in dark mode for readability.
  final Color linkBlue;

  /// Toggle / switch active green.
  final Color toggleGreen;

  // ═══════════════════════════════════════════════════════════════════════════
  // Icons
  // ═══════════════════════════════════════════════════════════════════════════

  /// Accent-colored SVG icon tint (orange in light, lighter orange in dark).
  final Color svgIconAccent;

  /// Muted SVG icon tint for secondary/filter icons.
  final Color svgIconMuted;

  // ═══════════════════════════════════════════════════════════════════════════
  // Surface tints
  // ═══════════════════════════════════════════════════════════════════════════

  /// Orange badge / indicator background (near-white in light, semi-transparent in dark).
  final Color tintOrange;

  /// Subtle blue tint for secondary highlights.
  final Color tintSecondary;

  /// Background tint for multi-selected email rows.
  final Color messageSelectedRow;

  /// Semi-transparent surface for glass/frosted containers (auth screens).
  final Color semiTransparentSurface;

  /// Modal barrier / loading overlay scrim color.
  final Color overlayBarrier;

  // ═══════════════════════════════════════════════════════════════════════════
  // Form fields
  // ═══════════════════════════════════════════════════════════════════════════

  /// Border color for form fields and pickers.
  final Color formFieldBorder;

  /// Hint text color in form fields.
  final Color formFieldHint;

  // ═══════════════════════════════════════════════════════════════════════════
  // Misc
  // ═══════════════════════════════════════════════════════════════════════════

  /// Background for step/badge indicators (setup profile, etc.).
  final Color stepBadgeBg;

  // ═══════════════════════════════════════════════════════════════════════════
  // Gradients
  // ═══════════════════════════════════════════════════════════════════════════

  /// Orange gradient for primary CTA buttons.
  final LinearGradient accentGradient;

  /// Flat grey gradient for disabled buttons.
  final LinearGradient disabledGradient;

  /// AppBar gradient — nullable so dark mode / future themes can opt out.
  final LinearGradient? appBarGradient;

  /// Tag chip background — subtle tint behind tag labels.
  final Color tagChipBg;

  /// Tag chip text — label and icon color for tag chips.
  final Color tagChipText;

  // ═══════════════════════════════════════════════════════════════════════════
  // Light / Dark presets
  // ═══════════════════════════════════════════════════════════════════════════

  static const light = AppColorsExtension(
    statusErrorBg: AppStyles.bgError,
    statusErrorText: AppStyles.textError,
    statusWarnBg: AppStyles.bgWarn,
    statusWarnText: AppStyles.textWarn,
    statusInfoBg: AppStyles.bgInfo,
    statusInfoText: AppStyles.textInfo,
    statusSuccessBg: AppStyles.bgSuccess,
    statusSuccessText: AppStyles.textSuccess,
    accent: AppStyles.clickableTextColor,
    accentBg: AppStyles.clickableBgColor,
    accentHover: Color(0xFFE44D0F),
    accentButton: Color(0xFFFD5D1A),
    linkBlue: Color(0xFF1C5AD6),
    toggleGreen: AppStyles.toggleBackground,
    svgIconAccent: AppStyles.clickableTextColor, // #FF6B35
    svgIconMuted: Color(0x42000000), // Colors.black26
    tintOrange: AppStyles.lightOrange,
    tintSecondary: AppStyles.lightSecondaryColor,
    messageSelectedRow: AppStyles.messageSelectedRowLight,
    semiTransparentSurface: Color.fromRGBO(255, 255, 255, 0.1),
    overlayBarrier: Color(0x80FFFFFF),
    formFieldBorder: AppStyles.secondaryColor, // #B3CCFF
    formFieldHint: AppStyles.grey, // #747474
    stepBadgeBg: AppStyles.primaryVariant, // #2F4CC8
    accentGradient: AppStyles.accentButtonGradient,
    disabledGradient: AppStyles.disabledButtonGradient,
    appBarGradient: AppStyles.appBarGradient,
    tagChipBg: AppStyles.lightSecondaryColor,
    tagChipText: Color(0xFF1C5AD6),
  );

  static const dark = AppColorsExtension(
    statusErrorBg: AppStyles.bgErrorDark,
    statusErrorText: AppStyles.textErrorDark,
    statusWarnBg: AppStyles.bgWarnDark,
    statusWarnText: AppStyles.textWarnDark,
    statusInfoBg: AppStyles.bgInfoDark,
    statusInfoText: AppStyles.textInfoDark,
    statusSuccessBg: AppStyles.bgSuccessDark,
    statusSuccessText: AppStyles.textSuccessDark,
    accent: AppStyles.clickableTextColor,
    accentBg: Color.fromRGBO(255, 107, 53, 0.15),
    accentHover: Color(0xFFFF8A4B),
    accentButton: Color(0xFFFD5D1A),
    linkBlue: Color(0xFF7EB3FF),
    toggleGreen: Color(0xFF4AE54A),
    svgIconAccent: Color(0xFFFF8A4B),
    svgIconMuted: Color(0x3DFFFFFF), // Colors.white24
    tintOrange: Color.fromRGBO(255, 168, 0, 0.15),
    tintSecondary: Color.fromRGBO(179, 204, 255, 0.20),
    messageSelectedRow: AppStyles.messageSelectedRowDark,
    semiTransparentSurface: Color.fromRGBO(255, 255, 255, 0.05),
    overlayBarrier: Color(0x80000000),
    formFieldBorder: Color(0xFF3A4A6B),
    formFieldHint: Color(0xFF94A3B8),
    stepBadgeBg: Color(0xFFB3CCFF),
    accentGradient: AppStyles.accentButtonGradient,
    disabledGradient: LinearGradient(
      begin: Alignment(1, 0),
      end: Alignment(-1, 0),
      colors: [Color(0xFF3A3A3A), Color(0xFF3A3A3A)],
    ),
    tagChipBg: Color.fromRGBO(255, 168, 0, 0.15),
    tagChipText: Color(0xFFFF6B35),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ThemeExtension overrides
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  AppColorsExtension copyWith({
    Color? statusErrorBg,
    Color? statusErrorText,
    Color? statusWarnBg,
    Color? statusWarnText,
    Color? statusInfoBg,
    Color? statusInfoText,
    Color? statusSuccessBg,
    Color? statusSuccessText,
    Color? accent,
    Color? accentBg,
    Color? accentHover,
    Color? accentButton,
    Color? linkBlue,
    Color? toggleGreen,
    Color? svgIconAccent,
    Color? svgIconMuted,
    Color? tintOrange,
    Color? tintSecondary,
    Color? messageSelectedRow,
    Color? semiTransparentSurface,
    Color? overlayBarrier,
    Color? formFieldBorder,
    Color? formFieldHint,
    Color? stepBadgeBg,
    LinearGradient? accentGradient,
    LinearGradient? disabledGradient,
    LinearGradient? appBarGradient,
    Color? tagChipBg,
    Color? tagChipText,
  }) {
    return AppColorsExtension(
      statusErrorBg: statusErrorBg ?? this.statusErrorBg,
      statusErrorText: statusErrorText ?? this.statusErrorText,
      statusWarnBg: statusWarnBg ?? this.statusWarnBg,
      statusWarnText: statusWarnText ?? this.statusWarnText,
      statusInfoBg: statusInfoBg ?? this.statusInfoBg,
      statusInfoText: statusInfoText ?? this.statusInfoText,
      statusSuccessBg: statusSuccessBg ?? this.statusSuccessBg,
      statusSuccessText: statusSuccessText ?? this.statusSuccessText,
      accent: accent ?? this.accent,
      accentBg: accentBg ?? this.accentBg,
      accentHover: accentHover ?? this.accentHover,
      accentButton: accentButton ?? this.accentButton,
      linkBlue: linkBlue ?? this.linkBlue,
      toggleGreen: toggleGreen ?? this.toggleGreen,
      svgIconAccent: svgIconAccent ?? this.svgIconAccent,
      svgIconMuted: svgIconMuted ?? this.svgIconMuted,
      tintOrange: tintOrange ?? this.tintOrange,
      tintSecondary: tintSecondary ?? this.tintSecondary,
      messageSelectedRow: messageSelectedRow ?? this.messageSelectedRow,
      semiTransparentSurface: semiTransparentSurface ?? this.semiTransparentSurface,
      overlayBarrier: overlayBarrier ?? this.overlayBarrier,
      formFieldBorder: formFieldBorder ?? this.formFieldBorder,
      formFieldHint: formFieldHint ?? this.formFieldHint,
      stepBadgeBg: stepBadgeBg ?? this.stepBadgeBg,
      accentGradient: accentGradient ?? this.accentGradient,
      disabledGradient: disabledGradient ?? this.disabledGradient,
      appBarGradient: appBarGradient ?? this.appBarGradient,
      tagChipBg: tagChipBg ?? this.tagChipBg,
      tagChipText: tagChipText ?? this.tagChipText,
    );
  }

  @override
  AppColorsExtension lerp(covariant AppColorsExtension? other, double t) {
    if (other == null) return this;
    return AppColorsExtension(
      statusErrorBg: Color.lerp(statusErrorBg, other.statusErrorBg, t)!,
      statusErrorText: Color.lerp(statusErrorText, other.statusErrorText, t)!,
      statusWarnBg: Color.lerp(statusWarnBg, other.statusWarnBg, t)!,
      statusWarnText: Color.lerp(statusWarnText, other.statusWarnText, t)!,
      statusInfoBg: Color.lerp(statusInfoBg, other.statusInfoBg, t)!,
      statusInfoText: Color.lerp(statusInfoText, other.statusInfoText, t)!,
      statusSuccessBg: Color.lerp(statusSuccessBg, other.statusSuccessBg, t)!,
      statusSuccessText: Color.lerp(statusSuccessText, other.statusSuccessText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentBg: Color.lerp(accentBg, other.accentBg, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentButton: Color.lerp(accentButton, other.accentButton, t)!,
      linkBlue: Color.lerp(linkBlue, other.linkBlue, t)!,
      toggleGreen: Color.lerp(toggleGreen, other.toggleGreen, t)!,
      svgIconAccent: Color.lerp(svgIconAccent, other.svgIconAccent, t)!,
      svgIconMuted: Color.lerp(svgIconMuted, other.svgIconMuted, t)!,
      tintOrange: Color.lerp(tintOrange, other.tintOrange, t)!,
      tintSecondary: Color.lerp(tintSecondary, other.tintSecondary, t)!,
      messageSelectedRow: Color.lerp(messageSelectedRow, other.messageSelectedRow, t)!,
      semiTransparentSurface: Color.lerp(semiTransparentSurface, other.semiTransparentSurface, t)!,
      overlayBarrier: Color.lerp(overlayBarrier, other.overlayBarrier, t)!,
      formFieldBorder: Color.lerp(formFieldBorder, other.formFieldBorder, t)!,
      formFieldHint: Color.lerp(formFieldHint, other.formFieldHint, t)!,
      stepBadgeBg: Color.lerp(stepBadgeBg, other.stepBadgeBg, t)!,
      // Gradients don't lerp smoothly — snap to target
      accentGradient: t < 0.5 ? accentGradient : other.accentGradient,
      disabledGradient: t < 0.5 ? disabledGradient : other.disabledGradient,
      appBarGradient: t < 0.5 ? appBarGradient : other.appBarGradient,
      tagChipBg: Color.lerp(tagChipBg, other.tagChipBg, t)!,
      tagChipText: Color.lerp(tagChipText, other.tagChipText, t)!,
    );
  }
}
