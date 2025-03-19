import 'package:flutter/services.dart';

class JSHelper {
  Future<String> callOpenTab(String url, String target) {
    return Future.value('');
  }

  void callIsolate(RootIsolateToken rootToken) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  }
}
