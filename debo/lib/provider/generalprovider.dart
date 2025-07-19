import 'dart:io';

import '../model/Register_model.dart';
import '../model/generalsettingmodel.dart' as settings;
import '../model/introscreenmodel.dart';
import '../model/loginregistermodel.dart';
import '../model/pagesmodel.dart';
import '../model/sociallinkmodel.dart';
import '../utils/adhelper.dart';
import '../utils/constant.dart';
import '../utils/sharedpre.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GeneralProvider extends ChangeNotifier {
  settings.GeneralSettingModel generalSettingModel =
      settings.GeneralSettingModel();
  PagesModel pagesModel = PagesModel();
  IntroScreenModel introScreenModel = IntroScreenModel();
  SocialLinkModel socialLinkModel = SocialLinkModel();
  LoginRegisterModel loginSocialModel = LoginRegisterModel();
  LoginRegisterModel loginOTPModel = LoginRegisterModel();
  LoginRegisterModel loginNormalModel = LoginRegisterModel();
  LoginRegisterModel loginTVModel = LoginRegisterModel();
  RegisterModel registerNormalModel = RegisterModel();

  bool loading = false;
  String? appDescription;

  SharedPre sharedPre = SharedPre();

  Future<void> getGeneralsetting(BuildContext context) async {
    loading = true;
    if (generalSettingModel.result != null &&
        (generalSettingModel.result?.length ?? 0) > 0) {
      loading = false;
      notifyListeners();
    }
    generalSettingModel = await ApiService().genaralSetting();
    printLog('generalSettingData status ==> ${generalSettingModel.status}');
    if (generalSettingModel.status == 200) {
      if (generalSettingModel.result != null) {
        /* Insert in local db */
        await Future.forEach<settings.Result>(generalSettingModel.result ?? [],
            (generalSettingItem) async {
          await sharedPre.save(
            generalSettingItem.key.toString(),
            generalSettingItem.value.toString(),
          );
        });

        appDescription = await sharedPre.read("app_desripation") ?? "";
        Constant.vapidKeyForWeb = await sharedPre.read("vapid_key") ?? "";
        printLog("appDescription ===========> $appDescription");
        printLog("vapidKeyForWeb ===========> ${Constant.vapidKeyForWeb}");
        /* Get Ads Init */
        if (context.mounted && !kIsWeb) {
          AdHelper.getAds(context);
          Utils.initializeOneSignal();
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> getPages() async {
    loading = true;
    pagesModel = await ApiService().getPages();
    printLog("getPages status :==> ${pagesModel.status}");
    loading = false;
    notifyListeners();
  }

  Future<void> getIntroPages() async {
    loading = true;
    introScreenModel = await ApiService().getOnboardingScreen();
    printLog("getIntroPages status :==> ${introScreenModel.status}");
    loading = false;
    notifyListeners();
  }

  Future<void> getSocialLinks() async {
    loading = true;
    socialLinkModel = await ApiService().getSocialLink();
    printLog("getSocialLinks status :==> ${socialLinkModel.status}");
    loading = false;
    notifyListeners();
  }

  Future<void> loginWithSocial(email, name, type, deviceName, deviceType,
      deviceToken, File? profileImg) async {
    printLog("loginWithSocial email :========> $email");
    printLog("loginWithSocial name :=========> $name");
    printLog("loginWithSocial type :=========> $type");
    printLog("loginWithSocial deviceName :===> $deviceName");
    printLog("loginWithSocial deviceType :===> $deviceType");
    printLog("loginWithSocial deviceToken :==> $deviceToken");
    printLog("loginWithSocial profileImg :===> ${profileImg?.path}");

    loading = true;
    loginSocialModel = await ApiService().loginWithSocial(
        email, name, type, deviceName, deviceType, deviceToken, profileImg);
    printLog("loginWithSocial status :===> ${loginSocialModel.status}");
    printLog("loginWithSocial message :==> ${loginSocialModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> loginWithOTP(mobile, deviceName, deviceType, deviceToken) async {
    printLog("loginWithOTP mobile :=======> $mobile");
    printLog("loginWithOTP deviceName :===> $deviceName");
    printLog("loginWithOTP deviceType :===> $deviceType");
    printLog("loginWithOTP deviceToken :==> $deviceToken");

    loading = true;
    loginOTPModel = await ApiService()
        .loginWithOTP(mobile, deviceName, deviceType, deviceToken);
    printLog("loginWithOTP status :===> ${loginOTPModel.status}");
    printLog("loginWithOTP message :==> ${loginOTPModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> loginNormal(
      email, password, deviceName, deviceType, deviceToken) async {
    printLog("loginNormal email :========> $email");
    printLog("loginNormal password :=====> $password");
    printLog("loginNormal deviceName :===> $deviceName");
    printLog("loginNormal deviceType :===> $deviceType");
    printLog("loginNormal deviceToken :==> $deviceToken");

    loading = true;
    loginNormalModel = await ApiService()
        .loginWithEmailPW(email, password, deviceName, deviceType, deviceToken);
    printLog("loginNormal status :===> ${loginNormalModel.status}");
    printLog("loginNormal message :==> ${loginNormalModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> registerNormal(
      String fullName,
      String email,
      String password,
      String mobileNumber,
      ) async {
    loading = true;
    notifyListeners();

    try {
      final response = await ApiService().registerWithEmail(
        fullName: fullName,
        email: email,
        password: password,
        mobileNumber: mobileNumber,
      );

      registerNormalModel = RegisterModel.fromJson(response);

      printLog("Registration Status: ${registerNormalModel.status}");
      printLog("Registration Message: ${registerNormalModel.message}");
      printLog("User ID: ${registerNormalModel.userId}");

    } catch (e) {
      registerNormalModel = RegisterModel(
        status: 500,
        message: e.toString(),
      );
      printLog("Registration Error: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    String? password,
    String? confirmPassword,
  }) async {
    try {
      final response = await ApiService().resetPassword(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  Future<void> loginWithTV(strOTP) async {
    printLog("loginWithTV strOTP :==> $strOTP");

    loading = true;
    loginTVModel = await ApiService().tvLogin(strOTP);
    printLog("loginWithTV status :===> ${loginTVModel.status}");
    printLog("loginWithTV message :==> ${loginTVModel.message}");
    loading = false;
    notifyListeners();
  }
}
