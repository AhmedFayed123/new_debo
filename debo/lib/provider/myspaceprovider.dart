
import 'package:flutter/material.dart';

import '../model/continuewatchingmodel.dart';
import '../model/profilemodel.dart';
import '../model/successmodel.dart';
import '../model/watchlistmodel.dart';
import '../utils/constant.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class MySpaceProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  SuccessModel successModel = SuccessModel();
  ContinueWatchingModel continueWatchingModel = ContinueWatchingModel();
  WatchlistModel watchlistModel = WatchlistModel();

  bool loading = false,
      loadingContinue = false,
      loadingWatchlist = false,
      loadingUpdate = false,
      loadingPCCheck = false;

  Future<void> getProfile(BuildContext context) async {
    printLog("getProfile userID :==> ${Constant.userID}");

    loading = true;
    profileModel = await ApiService().profile();
    printLog("get_profile status :==> ${profileModel.status}");
    printLog("get_profile message :==> ${profileModel.message}");
    if (profileModel.status == 200 && profileModel.result != null) {
      if ((profileModel.result?.length ?? 0) > 0) {
        Utils.updatePremium(profileModel.result?[0].isBuy.toString() ?? "0");
        if (context.mounted) {
          printLog("========= get_profile loadAds =========");
          Utils.loadAds(context);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> getContinueWatching(pageNo) async {
    printLog("getContinueWatching pageNo :==> $pageNo");
    loadingContinue = true;
    continueWatchingModel = await ApiService().getContinueWatching(pageNo);
    printLog(
        "getContinueWatching status :===> ${continueWatchingModel.status}");
    printLog(
        "getContinueWatching message :==> ${continueWatchingModel.message}");
    loadingContinue = false;
    notifyListeners();
  }

  Future<void> getWatchlist(pageNo) async {
    printLog("getWatchlist pageNo :==> $pageNo");
    loadingWatchlist = true;
    watchlistModel = await ApiService().watchlist(pageNo);
    printLog("getWatchlist status :===> ${watchlistModel.status}");
    printLog("getWatchlist message :==> ${watchlistModel.message}");
    loadingWatchlist = false;
    notifyListeners();
  }

  Future<void> getUpdatePCStatus(pcStatus) async {
    printLog("getUpdatePCStatus pcStatus :==> $pcStatus");
    successModel = SuccessModel();
    loadingPCCheck = true;
    successModel = await ApiService().updatePCStatus(pcStatus);
    printLog("getUpdatePCStatus status :====> ${successModel.status}");
    printLog("getUpdatePCStatus message :===> ${successModel.message}");
    loadingPCCheck = false;
    notifyListeners();
  }

  Future<void> parentControlCheckPassword(password) async {
    printLog("parentControlCheckPassword password :==> $password");
    successModel = SuccessModel();
    loadingPCCheck = true;
    successModel = await ApiService().parentControlCheckPassword(password);
    printLog("parentControlCheckPassword status :===> ${successModel.status}");
    printLog("parentControlCheckPassword message :==> ${successModel.message}");
    loadingPCCheck = false;
    notifyListeners();
  }

  setUpdateLoading(bool isLoading) {
    loadingPCCheck = isLoading;
    notifyListeners();
  }

  notifyProvider() {
    notifyListeners();
  }

  clearProvider() {
    continueWatchingModel = ContinueWatchingModel();
    watchlistModel = WatchlistModel();
    successModel = SuccessModel();
    loading = false;
  }
}
