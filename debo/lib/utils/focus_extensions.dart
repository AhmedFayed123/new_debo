import 'package:flutter/material.dart';

import '../webwidget/translate_on_focus.dart';

extension FocusExtensions on Widget {
  // Get a regerence to the body of the view
  Widget get moveUpOnFocus {
    return TranslateOnFocus(
      child: this,
    );
  }
}
