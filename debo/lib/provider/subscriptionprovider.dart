
import 'package:flutter/material.dart';

import '../model/subscriptionmodel.dart';
import '../utils/constant.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionModel subscriptionModel = SubscriptionModel();

  bool loading = false;

  Future<void> getPackages() async {
    printLog("getPackages userID :==> ${Constant.userID}");
    loading = true;
    subscriptionModel = await ApiService().subscriptionPackage();
    printLog("get_package status :==> ${subscriptionModel.status}");
    printLog("get_package message :==> ${subscriptionModel.message}");
    loading = false;
    notifyListeners();
  }

  clearProvider() {
    printLog("<================ clearSubscriptionProvider ================>");
    subscriptionModel = SubscriptionModel();
  }
}
