import 'package:flutter/material.dart';

import '../utils/utils.dart';

class VideoDownloadProvider extends ChangeNotifier {
  int dProgress = 0;
  int? itemId;
  bool loading = false;

  setDownloadProgress(int progress) {
    loading = (progress != -1);
    dProgress = progress;
    notifyListeners();
    printLog('setDownloadProgress dProgress ==============> $dProgress');
  }

  setLoading(bool isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  setCurrentDownload(int? itemId) {
    this.itemId = itemId;
    notifyListeners();
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    dProgress = 0;
    itemId = null;
    loading = false;
  }
}
