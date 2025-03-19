@JS()
library stripe;

import 'package:flutter/material.dart';
import 'package:js/js.dart';

import '../../utils/constant.dart';

void redirectToCheckout(BuildContext _) async {
  final stripe = Stripe(Constant.publishableKey ?? "");
  stripe.redirectToCheckout(CheckoutOptions(
    lineItems: [
      LineItem(price: Constant.packagePriceId ?? '', quantity: 1),
    ],
    mode: Constant.paymentMode ?? '',
    successUrl: Constant.successURL ?? '',
    cancelUrl: Constant.cancelURL ?? '',
  ));
}

@JS()
class Stripe {
  external Stripe(String key);

  external redirectToCheckout(CheckoutOptions options);
}

@JS()
@anonymous
class CheckoutOptions {
  external List<LineItem> get lineItems;

  external String get mode;

  external String get successUrl;

  external String get cancelUrl;

  external factory CheckoutOptions({
    List<LineItem> lineItems,
    String mode,
    String successUrl,
    String cancelUrl,
    String sessionId,
  });
}

@JS()
@anonymous
class LineItem {
  external String get price;

  external int get quantity;

  external factory LineItem({String price, int quantity});
}
