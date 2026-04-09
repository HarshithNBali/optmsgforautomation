import 'package:optmsg/screens/subscription/change_payment/payment_method_notifier.dart';
import 'package:optmsg/widgets/credit_card.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import 'package:optmsg/webPackerHandler/mobile_check_out.dart'
    if (dart.library.js_interop) 'package:optmsg/webPackerHandler/web_check_out.dart';

class PaymentMethod extends ConsumerWidget {
  const PaymentMethod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentMethodProvider);
    final notifier = ref.read(paymentMethodProvider.notifier);

    // Push route — must include title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShellLayout.of(context)?.setAppBarConfig(const AppBarConfig(
        title: 'Payment method',
        hideUpgradeBanner: true,
      ));
    });

    return Scaffold(
      body: DelayedLoadingOverlay(
        isLoading: state.isLoading,
        child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 216,
                  child: CustomGradientButton(
                    text: 'Add New Card',
                    onPressed: () {
                      // Bug 13: Pre-open a blank popup synchronously within
                      // the user gesture so Safari doesn't block it. The
                      // notifier's async addCard() navigates this tab.
                      if (kIsWeb) CheckOutImp().preOpenTab();
                      notifier.addCard();
                    },
                  ),
                ),
                if (state.cardData.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: state.cardData.map((card) {
                        return CreditCardWidget(
                          cardType: card['card']['brand'],
                          cardNumber: card['card']['last4'],
                          expiryDate:
                              '${card['card']['exp_month'].toString().padLeft(2, '0')}/${card['card']['exp_year']}',
                          onDelete: () => notifier.deleteCard(card['id']),
                        );
                      }).toList(),
                    ),
                  ),
                if (state.showNoData)
                  const Expanded(
                    child: Center(child: Text('No cards available')),
                  )
              ],
            ),
      ),
    );
  }
}
