

import 'package:flutter/material.dart';

import '../model/avatarmodel.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class AvatarProvider extends ChangeNotifier {
  AvatarModel avatarModel = AvatarModel();

  bool loading = false;

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> getAvatar() async {
    loading = true;
    avatarModel = await ApiService().getAvatar();
    printLog("getAvatar status :==> ${avatarModel.status}");
    loading = false;
    notifyListeners();
  }

  clearProvider() {
    avatarModel = AvatarModel();
  }
}
