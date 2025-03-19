@JS()
library script.js;

import 'package:flutter/services.dart';
import 'package:js/js.dart';

// This function will open new popup window for given URL.
@JS()
external dynamic jsOpenTab(String url, String target);

// This function will call BackgroundIsolateBinaryMessenger for given Token.
@JS()
external dynamic jsCallIsolate(RootIsolateToken rootToken);
