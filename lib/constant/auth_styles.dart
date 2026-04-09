import 'package:flutter/material.dart';
import 'package:optmsg/constant/string_constant.dart' show headingFontFamily;
import 'package:optmsg/constant/styles.dart';

/// Fully isolated styling for auth screens (login, signup, OTP, setup profile).
///
/// Auth screens always render on a gradient/dark background, so these styles
/// are independent of the app's light/dark theme setting. Changing the core
/// app's type scale or color tokens will NOT affect auth screens.
class AuthStyles {
  AuthStyles._();

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORS — fixed, independent of theme mode
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3CCFF); // light blue
  static const Color textAccent = Color(0xFFFF6B35); // orange
  static const Color inputFill = Color(0x1A808080); // grey @ ~10%
  static const Color inputBorder = Color(0xFFB3CCFF); // light blue

  // ═══════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY — fixed sizes matching production v1.0.6
  // ═══════════════════════════════════════════════════════════════════════════

  /// "Login to OptMsg" / "Create Account" hero text — 27px
  static TextStyle heroTitle(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 27,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.15,
      );

  /// Subtitle / description text — 17px
  static TextStyle subTitle(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  /// Input field text style — 17px white
  static TextStyle inputText(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      );

  /// Hint text inside inputs — 15px light blue
  static TextStyle hintText(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  /// "@staging.optmsg.com" domain suffix — 17px white
  static TextStyle extensionText(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      );

  /// Button text — 17px white bold
  static TextStyle buttonText(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  /// "Forgot Username?" / "Resend" link — 17px white
  static TextStyle actionLink(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      );

  /// "Don't have an account?" prefix — 14px, w400
  static TextStyle linkLabel(BuildContext context, {required Color color}) =>
      TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      );

  /// "Click Here" / "Login" clickable link — 14px, w600
  static TextStyle linkAction(BuildContext context, {required Color color}) =>
      TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      );

  /// Copyright / small text — 14px white
  static TextStyle copyright(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      );

  /// Step badge text ("Step 1/4") — 14px white
  static TextStyle stepBadge(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      );

  /// Left column heading text ("Secure", "Private", "Simple") — 20px white
  static TextStyle loginStaticHeading(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.15,
      );

  /// Auth gradient button text (Login, Get Started, Submit) — 17px white
  static TextStyle authButtonText(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  /// Logo slogan on auth gradient background — 17px light blue
  static TextStyle authSlogan(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  /// OTP pin digit — 18px white bold
  static TextStyle pinDigit(BuildContext context) => const TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT DECORATION — standard auth form field look
  // ═══════════════════════════════════════════════════════════════════════════

  static const double inputRadius = 12.0;
  static const double buttonRadius = 12.0;

  /// Standard InputDecoration for auth text fields on gradient backgrounds.
  static InputDecoration inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      helperText: ' ',
      hintText: hint,
      hintStyle: hintText(context),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: inputBorder, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: inputBorder, width: 0.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
      ),
      filled: true,
      fillColor: inputFill,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PIN INPUT — OTP field decoration
  // ═══════════════════════════════════════════════════════════════════════════

  static BoxDecoration pinDecoration(BuildContext context) => BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        border: Border.all(color: textPrimary.withValues(alpha: 0.5)),
      );
}
