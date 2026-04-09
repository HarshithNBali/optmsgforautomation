import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreditCardWidget extends StatelessWidget {
  final String cardType;
  final String cardNumber;
  final String expiryDate;
  final VoidCallback onDelete;

  const CreditCardWidget({
    super.key,
    required this.cardType,
    required this.cardNumber,
    required this.expiryDate,
    required this.onDelete,
  });

  @override

  /// A widget that displays a credit card.
  ///
  /// It displays the type of the credit card, the last four digits of the card number,
  /// and the expiry date of the card. It also includes a delete button that can be
  /// used to delete the card.
  ///
  /// The widget is a [Card] widget with a fixed width and height. The children of
  /// the [Card] widget are a [Column] widget with three [Row] children. The first
  /// [Row] contains the type of the credit card and a delete button. The second
  /// [Row] contains the last four digits of the card number. The third [Row] contains
  /// the expiry date of the card.
  ///
  /// The style of the text is [AppStyles.subject]. The text is in a [MouseRegion]
  /// widget with a [SystemMouseCursors.click] cursor. The text is also in a
  /// [GestureDetector] widget with a [onTap] callback that calls the [onDelete]
  /// callback when the text is tapped.
  ///
  /// The card number is displayed as '**** **** **** `<last four digits>`'.
  ///
  /// The expiry date is displayed as 'Expiry: `<expiry date>`'.
  ///
  /// The width of the widget is 323.0, and the height is 181.0. The margin of the
  /// widget is 8.0.
  ///
  /// The widget is a [SizedBox] widget with a fixed width and height. The child of
  /// the [SizedBox] widget is the [Card] widget.
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppBreakpoints.creditCardWidth,
      height: AppBreakpoints.creditCardHeight,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(CommonService().capitalize(cardType),
                      style: AppTypography.subject(context)),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: SvgPicture.asset(
                        svgCardTrash,
                        width: 40.0,
                        height: 40.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Text(
                    '**** **** **** ',
                    style: AppTypography.inboxTitle(context).copyWith(
                      letterSpacing: 2.0,
                    ),
                  ),
                  Text(cardNumber.substring(cardNumber.length - 4),
                      style: AppTypography.subject(context)),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Text('Expiry: ', style: AppTypography.minMed14Black(context)),
                  Text(
                    expiryDate,
                    style: AppTypography.titleMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
