
import 'package:flutter/material.dart';

import '../model/devicesyncmodel.dart';
import '../model/profilemodel.dart';
import '../model/successmodel.dart';
import '../utils/constant.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  SuccessModel successModel = SuccessModel();
  DeviceSyncModel deviceSyncModel = DeviceSyncModel();
  SuccessModel deviceLogoutModel = SuccessModel();

  bool loading = false,
      loadingUpdate = false,
      loadingLogout = false,
      loadingPCCheck = false;

  Future<void> getProfile(BuildContext context) async {
    printLog("getProfile userID :==> ${Constant.userID}");

    loading = true;
    if (Constant.userID != null) {
      profileModel = await ApiService().profile();
      printLog("getProfile status :===> ${profileModel.status}");
      printLog("getProfile message :==> ${profileModel.message}");
      if (profileModel.status == 200 &&
          profileModel.result != null &&
          (profileModel.result?.length ?? 0) > 0) {
        Utils.updatePremium(profileModel.result?[0].isBuy.toString() ?? "0");
        if (context.mounted) {
          printLog("========= loadAds =========");
          Utils.loadAds(context);
        }
      } else {
        printLog("<<<<<<<< USER NOT FOUND >>>>>>>>");
        // if (context.mounted) {
        //   Utils.openLogin(context: context, newPage: "");
        // }
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> getUpdateProfile(
      name, email, mobileNumber, pickedImage, avatarId) async {
    printLog("getUpdateProfile userID :=======> ${Constant.userID}");
    printLog("getUpdateProfile name :=========> $name");
    printLog("getUpdateProfile email :========> $email");
    printLog("getUpdateProfile mobileNumber :=> $mobileNumber");
    printLog("getUpdateProfile pickedImage :==> $pickedImage");
    printLog("getUpdateProfile avatarId :=====> $avatarId");
    successModel = SuccessModel();
    loading = true;
    successModel = await ApiService()
        .updateProfile(name, email, mobileNumber, pickedImage, avatarId);
    printLog("getUpdateProfile status :===> ${successModel.status}");
    printLog("getUpdateProfile message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> getUpdateDataForPayment(fullName, email, mobileNumber) async {
    printLog("getUpdateDataForPayment fullname :==> $fullName");
    printLog("getUpdateDataForPayment email :=====> $email");
    printLog("getUpdateDataForPayment mobile :====> $mobileNumber");
    successModel = SuccessModel();
    loadingUpdate = true;
    successModel =
        await ApiService().updateDataForPayment(fullName, email, mobileNumber);
    printLog("getUpdateDataForPayment status :==> ${successModel.status}");
    printLog("getUpdateDataForPayment message :==> ${successModel.message}");
    loadingUpdate = false;
    notifyListeners();
  }

  Future<void> getUpdatePCPassword(password) async {
    printLog("getUpdatePCPassword password :==> $password");
    successModel = SuccessModel();
    loadingPCCheck = true;
    successModel = await ApiService().updatePCPassword(password);
    printLog("getUpdatePCPassword status :==> ${successModel.status}");
    printLog("getUpdatePCPassword message :==> ${successModel.message}");
    loadingPCCheck = false;
    notifyListeners();
  }

  Future<void> parentControlCheckPassword(password) async {
    printLog("parentControlCheckPassword password :==> $password");
    successModel = SuccessModel();
    loadingPCCheck = true;
    successModel = await ApiService().parentControlCheckPassword(password);
    printLog("parentControlCheckPassword status :==> ${successModel.status}");
    printLog("parentControlCheckPassword message :==> ${successModel.message}");
    loadingPCCheck = false;
    notifyListeners();
  }

  Future<void> getDeviceSyncList() async {
    loading = true;
    deviceSyncModel = await ApiService().getDeviceSyncList();
    printLog("getDeviceSyncList status :===> ${deviceSyncModel.status}");
    printLog("getDeviceSyncList message :==> ${deviceSyncModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> logoutDevice(
      deviceSyncId, deviceType, deviceToken, deviceId) async {
    printLog("logoutDevice deviceSyncId :===> $deviceSyncId");
    printLog("logoutDevice deviceType :=====> $deviceType");
    printLog("logoutDevice deviceToken :====> $deviceToken");
    printLog("logoutDevice deviceId :=======> $deviceId");
    loadingLogout = true;
    deviceLogoutModel = await ApiService()
        .logoutDeviceSync(deviceSyncId, deviceType, deviceToken, deviceId);
    printLog("logoutDevice status :===> ${deviceLogoutModel.status}");
    printLog("logoutDevice message :==> ${deviceLogoutModel.message}");
    loadingLogout = false;
    notifyListeners();
  }

  setUpdateLoading(bool isLoading) {
    loadingUpdate = isLoading;
    notifyListeners();
  }

  setPCLoading(bool isLoading) {
    loadingPCCheck = isLoading;
    notifyListeners();
  }

  notifyProvider() {
    notifyListeners();
  }

  clearProvider() {
    profileModel = ProfileModel();
    successModel = SuccessModel();
    deviceSyncModel = DeviceSyncModel();
    deviceLogoutModel = SuccessModel();
    loading = false;
    loadingUpdate = false;
  }
}
