import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';

class CountryPicker extends StatelessWidget {
  const CountryPicker({super.key});

  @override

  /// Returns a widget that displays a country picker.
  ///
  /// The widget displays a flag icon and the country code (+1).
  /// The widget is a container with a rounded border, a light grey background color and a padding.
  /// The widget is wrapped in a padding widget with a bottom padding of 20.
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          border: Border.all(color: Theme.of(context).extension<AppColorsExtension>()?.formFieldBorder ?? AppStyles.secondaryColor, width: 0.5),
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/svg/country.svg',
                height: 23,
                width: 23,
              ),
            ),
            Text(
              '(+1)',
              style: AppTypography.appBarTitle1(context),
            ),
          ],
        ),
      ),
    );
  }
}
