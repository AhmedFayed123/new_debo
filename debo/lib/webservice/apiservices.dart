import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../model/contentdetailmodel.dart' as contentdetails;
import '../model/episodebyseasonmodel.dart' as episode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../firebase_options.dart';
import '../model/avatarmodel.dart';
import '../model/castdetailmodel.dart';
import '../model/channelmodel.dart';
import '../model/comment_model.dart';
import '../model/contentbyidmodel.dart';
import '../model/continuewatchingmodel.dart';
import '../model/couponmodel.dart';
import '../model/devicesyncmodel.dart';
import '../model/download_item.dart';
import '../model/generalsettingmodel.dart';
import '../model/genresmodel.dart';
import '../model/historymodel.dart';
import '../model/introscreenmodel.dart';
import '../model/langaugemodel.dart';
import '../model/loginregistermodel.dart';
import '../model/pagesmodel.dart';
import '../model/paymentoptionmodel.dart';
import '../model/paytmmodel.dart';
import '../model/profilemodel.dart';
import '../model/relatedcontentmodel.dart';
import '../model/rentmodel.dart';
import '../model/searchmodel.dart';
import '../model/sectionbannermodel.dart';
import '../model/sectiondetailmodel.dart';
import '../model/sectionlistmodel.dart';
import '../model/sectiontypemodel.dart';
import '../model/sociallinkmodel.dart';
import '../model/subscriptionmodel.dart';
import '../model/successmodel.dart';
import '../model/watchlistmodel.dart';
import '../provider/showdownloadprovider.dart';
import '../provider/videodownloadprovider.dart';
import '../utils/constant.dart';
import '../utils/utils.dart';

class ApiService {
  String baseUrl = Constant.baseurl;

  late Dio dio;

  Options optHeaders = Options(headers: <String, dynamic>{
    'Content-Type': 'application/json',
  });

  ApiService() {
    dio = Dio();
    // dio.interceptors.add(
    //   PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseBody: true,
    //     responseHeader: false,
    //     compact: false,
    //   ),
    // );
  }

  /* Send FCM PushNotification START ************* */
  Future sendFCMPushNotification(
    notifyType,
    toUserDeviceToken,
    toUserDeviceType,
  ) async {
    printLog("notifyTyoe ===> $notifyType");
    printLog("deviceToken ==> $toUserDeviceToken");
    printLog("deviceType ===> $toUserDeviceType");
    printLog("projectId ===> ${DefaultFirebaseOptions.android.projectId}");
    var params = {
      "message": {
        "token": toUserDeviceToken.toString(),
        "notification": {
          "title": "You are going to logout from this device.",
          "body": notifyType
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "type": notifyType.toString(),
          "deviceToken": toUserDeviceToken.toString(),
          "deviceType": toUserDeviceType.toString(),
        },
        "android": {
          "priority": "high",
        },
        "apns": {
          "payload": {
            "aps": {"category": Constant.appName}
          }
        },
        "webpush": {"fcm_options": {}}
      }
    };
    var url =
        'https://fcm.googleapis.com/v1/projects/${DefaultFirebaseOptions.android.projectId}/messages:send';
    var response = await http.post(Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${Constant.accessToken}",
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8"
        },
        body: json.encode(params));

    if (response.statusCode == 200) {
      printLog("Send Notification");
      Map<String, dynamic> map = json.decode(response.body);
      printLog("fcm.google map :=====> $map");
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      printLog("fcm.google error :=====> $error");
    }
  }

  /* *************** Send FCM PushNotification END */

  // general_setting API
  Future<GeneralSettingModel> genaralSetting() async {
    GeneralSettingModel dataModel;
    String apiName = "general_setting";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
    );
    dataModel = GeneralSettingModel.fromJson(response.data);
    return dataModel;
  }

  // get_onboarding_screen API
  Future<IntroScreenModel> getOnboardingScreen() async {
    IntroScreenModel dataModel;
    String apiName = "get_onboarding_screen";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
    );
    dataModel = IntroScreenModel.fromJson(response.data);
    return dataModel;
  }

  // get_pages API
  Future<PagesModel> getPages() async {
    PagesModel dataModel;
    String apiName = "get_pages";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
    );
    dataModel = PagesModel.fromJson(response.data);
    return dataModel;
  }

  // get_social_link API
  Future<SocialLinkModel> getSocialLink() async {
    SocialLinkModel dataModel;
    String apiName = "get_social_link";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
    );
    dataModel = SocialLinkModel.fromJson(response.data);
    return dataModel;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    String? password,
    String? confirmPassword,
  }) async {
    const apiName = "reset_password";

    try {
      final data = {
        'email': email,
        if (password != null) 'password': password,
        if (confirmPassword != null) 'password_confirmation': confirmPassword,
      };

      final response = await dio.post(
        '$baseUrl$apiName',
        data: data,
        options: optHeaders,
      );

      return response.data;
    } on DioException catch (e) {
      printLog("Reset password error: ${e.response?.data}");
      throw Exception(e.response?.data?['message'] ?? "Password reset failed");
    }
  }
  Future<Map<String, dynamic>> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String mobileNumber,
  }) async {
    const apiName = "register";

    try {
      final response = await dio.post(
        '$baseUrl$apiName',
        options: optHeaders,
        data: FormData.fromMap({
          'full_name': fullName,
          'email': email,
          'password': password,
          'mobile_number': mobileNumber,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
          'device_token': await FirebaseMessaging.instance.getToken(),
        }),
      );

      if (response.statusCode == 200) {
        printLog("Registration Success: ${response.data}");
        return response.data;
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      printLog("Dio Error: ${e.response?.data}");
      throw Exception(e.response?.data?['message'] ?? "Registration failed");
    } catch (e) {
      printLog("Registration Error: $e");
      throw Exception("An error occurred during registration");
    }
  }

  /* type => 1-OTP, 2-Google, 3-Apple, 4-Normal */
  /* device_type => 1-Android, 2-Apple */
  // login API
  Future<LoginRegisterModel> loginWithEmailPW(
      email, password, deviceName, deviceType, deviceToken) async {
    printLog("email :========> $email");
    printLog("password :=====> $password");
    printLog("deviceName :===> $deviceName");
    printLog("deviceType :===> $deviceType");
    printLog("deviceToken :==> $deviceToken");
    printLog("deviceId :=====> ${Constant.currentDeviceId}");

    LoginRegisterModel dataModel;
    String apiName = "login";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: FormData.fromMap({
        'type': "4",
        'email': email,
        'password': password,
        'device_name': deviceName,
        'device_type': deviceType,
        'device_token': deviceToken,
        'device_id': Constant.currentDeviceId,
      }),
    );

    dataModel = LoginRegisterModel.fromJson(response.data);
    return dataModel;
  }

  /* type => 1-OTP, 2-Google, 3-Apple, 4-Normal */
  /* device_type => 1-Android, 2-Apple */
  // login API
  Future<LoginRegisterModel> loginWithSocial(email, name, type, deviceName,
      deviceType, deviceToken, File? profileImg) async {
    printLog("email :========> $email");
    printLog("name :=========> $name");
    printLog("type :=========> $type");
    printLog("deviceName :===> $deviceName");
    printLog("deviceType :===> $deviceType");
    printLog("deviceToken :==> $deviceToken");
    printLog("profileImg :===> $profileImg");
    printLog("deviceId :=====> ${Constant.currentDeviceId}");

    LoginRegisterModel dataModel;
    String apiName = "login";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: FormData.fromMap({
        'type': type,
        'email': email,
        'full_name': name,
        'device_name': deviceName,
        'device_type': deviceType,
        'device_token': deviceToken,
        'device_id': Constant.currentDeviceId,
        if (profileImg != null && profileImg.path.isNotEmpty)
          'image': MultipartFile.fromFileSync(
            profileImg.path,
            filename: profileImg.path.split('/').last,
          ),
      }),
    );

    dataModel = LoginRegisterModel.fromJson(response.data);
    return dataModel;
  }

  /* type => 1-OTP, 2-Google, 3-Apple, 4-Normal */
  /* device_type => 1-Android, 2-Apple */
  // login API
  Future<LoginRegisterModel> loginWithOTP(
      mobile, deviceName, deviceType, deviceToken) async {
    printLog("mobile :=======> $mobile");
    printLog("deviceName :===> $deviceName");
    printLog("deviceType :===> $deviceType");
    printLog("deviceToken :==> $deviceToken");
    printLog("deviceId :=====> ${Constant.currentDeviceId}");

    LoginRegisterModel dataModel;
    String apiName = "login";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'type': '1',
        'mobile_number': mobile,
        'device_name': deviceName,
        'device_type': deviceType,
        'device_token': deviceToken,
        'device_id': Constant.currentDeviceId,
      },
    );

    dataModel = LoginRegisterModel.fromJson(response.data);
    return dataModel;
  }

  // tv_login API
  Future<LoginRegisterModel> tvLogin(uniqueCode) async {
    printLog("tvLogin userID :======> ${Constant.userID}");
    printLog("tvLogin uniqueCode :==> $uniqueCode");

    LoginRegisterModel dataModel;
    String apiName = "tv_login";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'unique_code': uniqueCode,
      },
    );

    dataModel = LoginRegisterModel.fromJson(response.data);
    return dataModel;
  }

  // get_profile API
  Future<ProfileModel> profile() async {
    printLog("profile userID :==> ${Constant.userID}");

    ProfileModel dataModel;
    String apiName = "get_profile";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
      },
    );

    dataModel = ProfileModel.fromJson(response.data);
    return dataModel;
  }

  // update_profile API
  Future<SuccessModel> updateProfile(
      name, email, mobileNumber, pickedImage, avatarId) async {
    printLog("updateProfile userID :=======> ${Constant.userID}");
    printLog("updateProfile name :=========> $name");
    printLog("updateProfile email :=========> $email");
    printLog("updateProfile mobileNo :=====> $mobileNumber");
    printLog("updateProfile pickedImage :==> $pickedImage");
    printLog("updateProfile avatarId :=====> $avatarId");

    SuccessModel dataModel;
    String apiName = "update_profile";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: FormData.fromMap({
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'full_name': name,
        if (email != null && email != "" && !email.toString().contains("null"))
          'email': email,
        if (mobileNumber != null &&
            mobileNumber != "" &&
            !mobileNumber.toString().contains("null"))
          'mobile_number': mobileNumber,
        if (avatarId != null || pickedImage != null)
          'image_type': (avatarId != null) ? 2 : 1,
        if (avatarId != null) 'image': avatarId,
        if (pickedImage != null)
          'image': MultipartFile.fromFileSync(
            pickedImage?.path ?? "",
            filename: (pickedImage?.path ?? "").split('/').last,
          ),
      }),
    );

    dataModel = SuccessModel.fromJson(response.data);
    return dataModel;
  }

  // update_profile API
  Future<SuccessModel> updateDataForPayment(
      fullName, email, mobileNumber) async {
    printLog("updateDataForPayment userID :====> ${Constant.userID}");
    printLog("updateDataForPayment fullName :==> $fullName");
    printLog("updateDataForPayment email :=====> $email");
    printLog("updateProfile mobileNumber :=====> $mobileNumber");

    SuccessModel dataModel;
    String apiName = "update_profile";
    Response response = await dio.post(
      '$baseUrl$apiName',
      data: FormData.fromMap({
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'full_name': fullName,
        'email': email,
        'mobile_number': mobileNumber,
      }),
      options: optHeaders,
    );

    dataModel = SuccessModel.fromJson(response.data);
    return dataModel;
  }

  // update_profile API
  Future<SuccessModel> updatePCPassword(password) async {
    printLog("updatePCPassword userID :====> ${Constant.userID}");
    printLog("updatePCPassword password :==> $password");

    SuccessModel dataModel;
    String apiName = "update_profile";
    Response response = await dio.post(
      '$baseUrl$apiName',
      data: FormData.fromMap({
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'parent_control_password': password
      }),
      options: optHeaders,
    );

    dataModel = SuccessModel.fromJson(response.data);
    return dataModel;
  }

  // update_profile API
  Future<SuccessModel> updatePCStatus(pcStatus) async {
    printLog("updatePCStatus userID :====> ${Constant.userID}");
    printLog("updatePCStatus pcStatus :==> $pcStatus");

    SuccessModel dataModel;
    String apiName = "update_profile";
    Response response = await dio.post(
      '$baseUrl$apiName',
      data: FormData.fromMap({
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'parent_control_status': pcStatus
      }),
      options: optHeaders,
    );

    dataModel = SuccessModel.fromJson(response.data);
    return dataModel;
  }

  // parent_control_check_password API
  Future<SuccessModel> parentControlCheckPassword(password) async {
    printLog("parentControlCheckPassword userID :====> ${Constant.userID}");
    printLog("parentControlCheckPassword password :==> $password");

    SuccessModel dataModel;
    String apiName = "parent_control_check_password";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'password': password,
      },
    );

    dataModel = SuccessModel.fromJson(response.data);
    return dataModel;
  }

// دالة لإضافة أو إزالة الإعجاب باستخدام Dio
  Future<SuccessModel> addRemoveLike({
    required int videoId,
    required int videoType,
    required int subVideoType,
  }) async {
    printLog("addRemoveLike userID :====> ${Constant.userID}");
    printLog("addRemoveLike videoID :====> $videoId");

    SuccessModel dataModel;
    String apiName = "add_remove_like";

    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'video_type': videoType,
        'sub_video_type': subVideoType,
        'video_id': videoId,
      },
    );

    dataModel = SuccessModel.fromJson(response.data);
    return dataModel;
  }

//   addComment
  Future<SuccessModel> addComment({
    required int videoId,
    required String comment,
    required int videoType,
    required int subVideoType,
  }) async {
    printLog("addComment userID :====> ${Constant.userID}");
    printLog("addComment videoID :====> $videoId");
    printLog("addComment content :====> $comment");

    SuccessModel dataModel;
    String apiName = "add_comment";

    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id':  10,
        'video_type': videoType,
        'sub_video_type': subVideoType,
        'video_id': videoId,
        'comment': comment,
        'comment_id': 1,
      },
    );
    printLog("addComment :====> ${response}");

    dataModel = SuccessModel.fromJson(response.data);
    return dataModel;
  }
  Future<SuccessModel> deleteComment({required int commentId}) async {
    String apiName = "delete_comment";

    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'comment_id': commentId,
      },
    );

    return SuccessModel.fromJson(response.data);
  }

  Future<SuccessModel> editComment({
    required int commentId,
    required String comment,
  }) async {
    printLog("editComment userID :====> ${Constant.userID}");
    printLog("editComment commentID :====> $commentId");
    printLog("editComment content :====> $comment");

    SuccessModel dataModel;
    String apiName = "edit_comment";

    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': 10,
        'comment_id': commentId,
        'comment': comment,
      },
    );

    dataModel = SuccessModel.fromJson(response.data);
    return dataModel;
  }

// getComments
  Future<List<CommentModel>> getComments({
    required int videoId,
    required int videoType,
    required int subVideoType,
  }) async {
    printLog("getComments videoID :====> $videoId");

    String apiName = "get_comment";

    try {
      Response response = await dio.post(
        '$baseUrl$apiName',
        options: optHeaders,
        data: {
          'video_type': videoType,
          'sub_video_type': subVideoType,
          'video_id': videoId,
        },
      );
      printLog("getComments result:====> ${response}");

      if (response.statusCode == 200) {
        var result = response.data['result'];
        printLog("getComments result:====> ${result}");

        if (result != null && result is List) {
          return result.map((json) => CommentModel.fromJson(json)).toList();
        } else {
          printLog("No comments found, returning empty list.");
          return []; // ✅ إرجاع قائمة فارغة بدلاً من `null`
        }
      } else {
        throw Exception("Failed to fetch comments - Status: ${response.statusCode}");
      }
    } catch (e) {
      printLog("Error fetching comments: $e");
      return []; // ✅ عند الخطأ، إرجاع قائمة فارغة بدلاً من `null`
    }
  }


  // get_device_sync_list API
  Future<DeviceSyncModel> getDeviceSyncList() async {
    printLog("getDeviceSyncList userID :==> ${Constant.userID}");

    DeviceSyncModel dataModel;
    String apiName = "get_device_sync_list";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
      },
    );

    dataModel = DeviceSyncModel.fromJson(response.data);
    return dataModel;
  }

  // logout_device_sync API
  Future<SuccessModel> logoutDeviceSync(
      deviceSyncId, deviceType, deviceToken, deviceId) async {
    printLog("logoutDeviceSync userID :=======> ${Constant.userID}");
    printLog("logoutDeviceSync deviceSyncId :=> $deviceSyncId");
    printLog("logoutDeviceSync deviceType :===> $deviceType");
    printLog("logoutDeviceSync deviceToken :==> $deviceToken");
    printLog("logoutDeviceSync deviceId :=====> $deviceId");

    SuccessModel dataModel;
    String apiName = "logout_device_sync";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'child_user_id': deviceSyncId,
        'device_type': deviceType,
        'device_token': deviceToken,
        'device_id': deviceId,
      },
    );

    dataModel = SuccessModel.fromJson(response.data);
    return dataModel;
  }

  // add_remove_device_watching API
  Future<DeviceSyncModel> addRemoveDeviceWatching(type) async {
    printLog("addRemoveDeviceWatching userID :=====> ${Constant.userID}");
    printLog(
        "addRemoveDeviceWatching deviceId :===> ${Constant.currentDeviceId}");
    printLog("addRemoveDeviceWatching type :=======> $type");

    DeviceSyncModel dataModel;
    String apiName = "add_remove_device_watching";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'type': type,
        'device_id': "Constant.currentDeviceId",
      },
    );

    dataModel = DeviceSyncModel.fromJson(response.data);
    return dataModel;
  }

  // get_avatar API
  Future<AvatarModel> getAvatar() async {
    AvatarModel dataModel;
    String apiName = "get_avatar";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {},
    );
    dataModel = AvatarModel.fromJson(response.data);
    return dataModel;
  }

  /* type => 1-movies, 2-news, 3-sport, 4-tv show */
  // get_type API
  Future<SectionTypeModel> sectionType() async {
    SectionTypeModel dataModel;
    String sectionType = "get_type";
    Response response = await dio.post(
      '$baseUrl$sectionType',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
      },
    );
    dataModel = SectionTypeModel.fromJson(response.data);
    return dataModel;
  }

  // get_banner API
  Future<SectionBannerModel> sectionBanner(typeId, isHomeScreen) async {
    printLog('sectionBanner typeId ========>>> $typeId');
    printLog('sectionBanner isHomeScreen ==>>> $isHomeScreen');
    SectionBannerModel dataModel;
    String sectionBanner = "get_banner";
    Response response = await dio.post(
      '$baseUrl$sectionBanner',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'type_id': typeId,
        'is_home_screen': isHomeScreen,
      },
    );
    dataModel = SectionBannerModel.fromJson(response.data);
    return dataModel;
  }

  // section_list API
  /* ****** Below video_type only for Sections ****** */
  //1-Video, 2-Show, 3-Category, 4-Language, 5-Channel List,
  //6-Upcoming Content, 7-Channel Content, 8-Continue Watching,
  //9-Kids Content
  /* ************************************************ */
  Future<SectionListModel> sectionList(typeId, isHomeScreen, pageNo) async {
    printLog('sectionList typeId ========>>> $typeId');
    printLog('sectionList isHomeScreen ==>>> $isHomeScreen');
    printLog('sectionList pageNo ========>>> $pageNo');
    SectionListModel dataModel;
    String apiName = "section_list";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'type_id': typeId,
        'is_home_screen': isHomeScreen,
        'page_no': pageNo,
      },
    );
    dataModel = SectionListModel.fromJson(response.data);
    return dataModel;
  }

  // section_detail API
  Future<SectionDetailModel> sectionDetails(sectionId, pageNo) async {
    SectionDetailModel dataModel;
    String apiName = "section_detail";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'section_id': sectionId,
        'page_no': pageNo,
      },
    );
    dataModel = SectionDetailModel.fromJson(response.data);
    return dataModel;
  }

  // content_detail API
  Future<contentdetails.ContentDetailModel> contentDetails(
      typeId, videoType, videoId, subVideoType) async {
    contentdetails.ContentDetailModel dataModel;
    String apiName = "content_detail";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'type_id': typeId,
        'video_type': videoType,
        'video_id': videoId,
        'sub_video_type': subVideoType,
      },
    );
    dataModel = contentdetails.ContentDetailModel.fromJson(response.data);
    return dataModel;
  }

  // get_releted_content API
  Future<RelatedContentModel> relatedContent(
      typeId, videoType, videoId, subVideoType, pageNo) async {
    RelatedContentModel dataModel;
    String apiName = "get_releted_content";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'type_id': typeId,
        'video_type': videoType,
        'video_id': videoId,
        'sub_video_type': subVideoType,
        'page_no': pageNo
      },
    );
    dataModel = RelatedContentModel.fromJson(response.data);
    return dataModel;
  }

  // get_continue_watching API
  Future<ContinueWatchingModel> getContinueWatching(pageNo) async {
    ContinueWatchingModel dataModel;
    String apiName = "get_continue_watching";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'page_no': pageNo,
        'is_parent': 1
      },
    );
    dataModel = ContinueWatchingModel.fromJson(response.data);
    return dataModel;
  }

  // video_view API
  Future<SuccessModel> videoView(
      videoId, videoType, subVideoType, episodeId) async {
    printLog('videoView videoId ====>>> $videoId');
    printLog('videoView videoType ==>>> $videoType');
    printLog('videoView episodeId ==>>> $episodeId');
    SuccessModel successModel;
    String apiName = "add_video_view";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'video_id': videoId,
        'video_type': videoType,
        'sub_video_type': subVideoType,
        'episode_id': episodeId,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_remove_bookmark API
  Future<SuccessModel> addRemoveBookmark(
      subVideoType, videoType, videoId) async {
    printLog("addRemoveBookmark userID ==========> ${Constant.userID}");
    SuccessModel successModel;
    String sectionList = "add_remove_bookmark";
    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'sub_video_type': subVideoType,
        'video_type': videoType,
        'video_id': videoId,
        'is_parent': 1,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_continue_watching API
  Future<SuccessModel> addContinueWatching(
      videoId, videoType, subVideoType, stopTime) async {
    SuccessModel successModel;
    String continueWatching = "add_continue_watching";
    Response response = await dio.post(
      '$baseUrl$continueWatching',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'video_id': videoId,
        'video_type': videoType,
        'stop_time': stopTime,
        'sub_video_type': subVideoType,
        'is_parent':
            (Constant.userIsKid != null && Constant.userIsKid == true) ? 0 : 1,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // remove_continue_watching API
  Future<SuccessModel> removeContinueWatching(
      videoId, videoType, subVideoType) async {
    SuccessModel successModel;
    String removeContinueWatching = "remove_continue_watching";
    Response response = await dio.post(
      '$baseUrl$removeContinueWatching',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'video_type': videoType,
        'sub_video_type': subVideoType,
        'video_id': videoId,
        'is_parent':
            (Constant.userIsKid != null && Constant.userIsKid == true) ? 0 : 1,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_remove_download API
  /* user_id, video_id, video_type, type_id, other_id
    * Show :=> sub_video_type = 2
    * Video :=> sub_video_type = 1 */
  Future<SuccessModel> addRemoveDownload(
      videoId, videoType, subVideoType, episodeId) async {
    printLog("addRemoveDownload videoId ========> $videoId");
    printLog("addRemoveDownload videoType ======> $videoType");
    printLog("addRemoveDownload subVideoType ===> $subVideoType");
    printLog("addRemoveDownload episodeId ======> $episodeId");
    SuccessModel successModel;
    String addRemoveDownload = "add_remove_download";
    Response response = await dio.post(
      '$baseUrl$addRemoveDownload',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'video_type': videoType,
        'sub_video_type': subVideoType,
        'video_id': videoId,
        'episode_id': episodeId,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // get_video_by_season_id API
  Future<episode.EpisodeBySeasonModel> episodeBySeason(
      seasonId, showId, pageNo) async {
    episode.EpisodeBySeasonModel dataModel;
    String apiName = "get_video_by_season_id";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'season_id': seasonId,
        'show_id': showId,
        'page_no': pageNo,
      },
    );
    dataModel = episode.EpisodeBySeasonModel.fromJson(response.data);
    return dataModel;
  }

  // cast_detail API
  Future<CastDetailModel> getCastDetails(castId) async {
    CastDetailModel castDetailModel;
    String castDetails = "cast_detail";
    Response response = await dio.post(
      '$baseUrl$castDetails',
      options: optHeaders,
      data: {
        'cast_id': castId,
      },
    );
    castDetailModel = CastDetailModel.fromJson(response.data);
    return castDetailModel;
  }

  // get_category API
  Future<GenresModel> genres() async {
    GenresModel genresModel;
    String genres = "get_category";
    Response response = await dio.post(
      '$baseUrl$genres',
      options: optHeaders,
    );
    genresModel = GenresModel.fromJson(response.data);
    return genresModel;
  }

  // get_language API
  Future<LangaugeModel> language() async {
    LangaugeModel langaugeModel;
    String language = "get_language";
    Response response = await dio.post(
      '$baseUrl$language',
      options: optHeaders,
    );
    langaugeModel = LangaugeModel.fromJson(response.data);
    return langaugeModel;
  }

  // get_channel API
  Future<ChannelModel> channel() async {
    ChannelModel channelModel;
    String language = "get_channel";
    Response response = await dio.post(
      '$baseUrl$language',
      options: optHeaders,
    );
    channelModel = ChannelModel.fromJson(response.data);
    return channelModel;
  }

  // search_content API
  Future<SearchModel> searchContent(searchText, pageNo) async {
    printLog('searchContent searchText ==>>> $searchText');
    SearchModel searchModel;
    String search = "search_content";
    Response response = await dio.post(
      '$baseUrl$search',
      options: optHeaders,
      data: {
        'name': searchText,
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'page_no': pageNo,
      },
    );
    searchModel = SearchModel.fromJson(response.data);
    return searchModel;
  }

  // rent_content_list API
  // type : 1-Video, 2-Show
  Future<RentModel> rentContentList(contentType, pageNo) async {
    RentModel rentModel;
    String rentList = "rent_content_list";
    Response response = await dio.post(
      '$baseUrl$rentList',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'type': contentType,
        'page_no': pageNo,
      },
    );
    rentModel = RentModel.fromJson(response.data);
    return rentModel;
  }

  // user_rent_content_list API
  Future<RentModel> userRentVideoList(pageNo) async {
    RentModel rentModel;
    String rentList = "user_rent_content_list";
    Response response = await dio.post(
      '$baseUrl$rentList',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'page_no': pageNo
      },
    );
    rentModel = RentModel.fromJson(response.data);
    return rentModel;
  }

  // content_by_category API
  Future<ContentByIdModel> contentByCategory(categoryID, pageNo) async {
    printLog('contentByCategory categoryID ==>>> $categoryID');
    printLog('contentByCategory pageNo ======>>> $pageNo');
    ContentByIdModel videoByIdModel;
    String apiName = "content_by_category";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'category_id': categoryID,
        'page_no': pageNo,
      },
    );
    videoByIdModel = ContentByIdModel.fromJson(response.data);
    return videoByIdModel;
  }

  // content_by_language API
  Future<ContentByIdModel> contentByLanguage(languageID, pageNo) async {
    printLog('contentByLanguage languageID ==>>> $languageID');
    printLog('contentByLanguage pageNo ======>>> $pageNo');
    ContentByIdModel videoByIdModel;
    String apiName = "content_by_language";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'language_id': languageID,
        'page_no': pageNo,
      },
    );
    videoByIdModel = ContentByIdModel.fromJson(response.data);
    return videoByIdModel;
  }

  // content_by_channel API
  Future<ContentByIdModel> contentByChannel(channelID, pageNo) async {
    printLog('contentByChannel channelID ==>>> $channelID');
    printLog('contentByChannel pageNo =====>>> $pageNo');
    ContentByIdModel videoByIdModel;
    String apiName = "content_by_channel";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'channel_id': channelID,
        'page_no': pageNo,
      },
    );
    videoByIdModel = ContentByIdModel.fromJson(response.data);
    return videoByIdModel;
  }

  // content_by_cast API
  Future<ContentByIdModel> contentByCast(castID, pageNo) async {
    printLog('contentByCast castID =====>>> $castID');
    printLog('contentByCast pageNo =====>>> $pageNo');
    ContentByIdModel videoByIdModel;
    String apiName = "content_by_cast";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'cast_id': castID,
        'page_no': pageNo,
      },
    );
    videoByIdModel = ContentByIdModel.fromJson(response.data);
    return videoByIdModel;
  }

  // get_package API
  Future<SubscriptionModel> subscriptionPackage() async {
    printLog('subscriptionPackage userID ==>>> ${Constant.userID}');
    SubscriptionModel subscriptionModel;
    String getPackage = "get_package";
    Response response = await dio.post(
      '$baseUrl$getPackage',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
      },
    );
    subscriptionModel = SubscriptionModel.fromJson(response.data);
    return subscriptionModel;
  }

  // get_bookmark_video API
  Future<WatchlistModel> watchlist(pageNo) async {
    printLog("watchlist userID :==> ${Constant.userID}");
    printLog("watchlist pageNo :==> $pageNo");

    WatchlistModel watchlistModel;
    String getBookmarkVideo = "get_bookmark_video";
    printLog("getBookmarkVideo API :==> $baseUrl$getBookmarkVideo");
    Response response = await dio.post(
      '$baseUrl$getBookmarkVideo',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'is_parent': 1,
        'page_no': pageNo,
      },
    );

    watchlistModel = WatchlistModel.fromJson(response.data);
    return watchlistModel;
  }

  // get_payment_option API
  Future<PaymentOptionModel> getPaymentOption() async {
    PaymentOptionModel paymentOptionModel;
    String paymentOption = "get_payment_option";
    printLog("paymentOption API :==> $baseUrl$paymentOption");
    Response response = await dio.post(
      '$baseUrl$paymentOption',
      options: optHeaders,
    );

    paymentOptionModel = PaymentOptionModel.fromJson(response.data);
    return paymentOptionModel;
  }

  // apply_coupon API
  Future<CouponModel> applyPackageCoupon(couponCode, packageId) async {
    CouponModel couponModel;
    String applyCoupon = "apply_coupon";
    printLog("applyPackageCoupon API :==> $baseUrl$applyCoupon");
    Response response = await dio.post(
      '$baseUrl$applyCoupon',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'apply_coupon_type': "1",
        'unique_id': couponCode,
        'package_id': packageId,
      },
    );

    couponModel = CouponModel.fromJson(response.data);
    return couponModel;
  }

  // apply_coupon API
  Future<CouponModel> applyRentCoupon(
      couponCode, videoId, typeId, videoType, price) async {
    CouponModel couponModel;
    String applyCoupon = "apply_coupon";
    printLog("applyRentCoupon API :==> $baseUrl$applyCoupon");
    Response response = await dio.post(
      '$baseUrl$applyCoupon',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'apply_coupon_type': "2",
        'unique_id': couponCode,
        'video_id': videoId,
        'type_id': typeId,
        'video_type': videoType,
        'price': price,
      },
    );

    couponModel = CouponModel.fromJson(response.data);
    return couponModel;
  }

  // get_payment_token API
  Future<PayTmModel> getPaytmToken(merchantID, orderId, custmoreID, channelID,
      txnAmount, website, callbackURL, industryTypeID) async {
    PayTmModel payTmModel;
    String paytmToken = "get_payment_token";
    printLog("paytmToken API :==> $baseUrl$paytmToken");
    Response response = await dio.post(
      '$baseUrl$paytmToken',
      options: optHeaders,
      data: {
        'MID': merchantID,
        'order_id': orderId,
        'CUST_ID': custmoreID,
        'CHANNEL_ID': channelID,
        'TXN_AMOUNT': txnAmount,
        'WEBSITE': website,
        'CALLBACK_URL': callbackURL,
        'INDUSTRY_TYPE_ID': industryTypeID,
      },
    );

    payTmModel = PayTmModel.fromJson(response.data);
    return payTmModel;
  }

  // add_transaction API
  Future<SuccessModel> addTransaction(
      packageId, description, amount, paymentId, couponCode) async {
    printLog('addTransaction userID ========>>> ${Constant.userID}');
    printLog('addTransaction packageId =====>>> $packageId');
    printLog('addTransaction description ===>>> $description');
    printLog('addTransaction amount ========>>> $amount');
    printLog('addTransaction paymentId =====>>> $paymentId');
    printLog('addTransaction couponCode ====>>> $couponCode');
    SuccessModel successModel;
    String transaction = "add_transaction";
    Response response = await dio.post(
      '$baseUrl$transaction',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'package_id': packageId,
        'description': description,
        'price': amount,
        'transaction_id': paymentId,
        if (couponCode != null && couponCode != "") 'unique_id': couponCode,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_rent_transaction API
  Future<SuccessModel> addRentTransaction(
      videoId, price, typeId, videoType, couponCode) async {
    printLog('addRentTransaction userID ======>>> ${Constant.userID}');
    printLog('addRentTransaction video_id ====>>> $videoId');
    printLog('addRentTransaction price =======>>> $price');
    printLog('addRentTransaction typeId ======>>> $typeId');
    printLog('addRentTransaction videoType ===>>> $videoType');
    printLog('addRentTransaction couponCode ==>>> $couponCode');
    SuccessModel successModel;
    String rentTransaction = "add_rent_transaction";
    Response response = await dio.post(
      '$baseUrl$rentTransaction',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'video_id': videoId,
        'price': price,
        'type_id': typeId,
        'video_type': videoType,
        if (couponCode != null && couponCode != "") 'unique_id': couponCode,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // get_transaction_list API
  Future<HistoryModel> subscriptionList(pageNo) async {
    HistoryModel historyModel;
    String subscriptionListAPI = "get_transaction_list";
    Response response = await dio.post(
      '$baseUrl$subscriptionListAPI',
      options: optHeaders,
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'page_no': pageNo
      },
    );
    historyModel = HistoryModel.fromJson(response.data);
    return historyModel;
  }
}

/* ========================== Download Videos ========================== */
Future<void> prepareVideoDownload(
    BuildContext context, contentdetails.Result? contentDetails) async {
  final receivePort = ReceivePort();
  contentdetails.Result? sectionDetails = contentDetails;
  printLog('videoExtension ============> ${sectionDetails?.videoExtension}');
  final downloadProvider =
      Provider.of<VideoDownloadProvider>(context, listen: false);
  await downloadProvider.setCurrentDownload(sectionDetails?.id ?? 0);

  Dio dio = Dio();

  /* Hive */
  Box<DownloadItem> dowonloadBox;
  if (Constant.userIsKid == true) {
    dowonloadBox = Hive.box<DownloadItem>(
        '${Constant.hiveDownloadBox}_${Constant.userID}_KID');
  } else {
    dowonloadBox = Hive.box<DownloadItem>(
        '${Constant.hiveDownloadBox}_${Constant.userID}');
  }

  DateTime now = DateTime.now();
  String timeStamp = now.millisecondsSinceEpoch.abs().toString();

  /* Prepare Target Video File START ************* */
  File? mTargetFile;
  String? localPath;
  String? mFileName = (Constant.userIsKid == true)
      ? ('${(sectionDetails?.name ?? "").replaceAll(" ", "")}'
          '${(sectionDetails?.id ?? 0)}${(Constant.userID)}_KID')
      : ('${(sectionDetails?.name ?? "").replaceAll(" ", "")}'
          '${(sectionDetails?.id ?? 0)}${(Constant.userID)}');
  try {
    localPath = await Utils.prepareSaveDir();
    printLog("localPath ====> $localPath");
    mTargetFile = File(path.join(
        localPath, '$mFileName.${(sectionDetails?.videoExtension ?? "mp4")}'));
    // This is a sync operation on a real
    // app you'd probably prefer to use writeAsByte and handle its Future
  } catch (e) {
    printLog("saveVideoStorage Exception ===> $e");
  }
  printLog("mFileName ========> $mFileName");
  printLog("mTargetFile ========> ${mTargetFile?.absolute.path ?? ""}");
  /* *************** Prepare Target Video File END */

  /* Prepare Target Image Files START ************* */
  File? mTargetPortImageFile, mTargetLandImageFile;
  String? mPortImageFileName = 'port_$timeStamp';
  String? mLandImageFileName = 'land_$timeStamp';
  if (localPath != null) {
    try {
      mTargetPortImageFile =
          File(path.join(localPath, '$mPortImageFileName.png'));
      mTargetLandImageFile =
          File(path.join(localPath, '$mLandImageFileName.png'));
    } catch (e) {
      printLog("saveVideoStorage Exception ===> $e");
    }
  } else {
    return;
  }
  printLog("mPortImageFileName ========> $mPortImageFileName");
  printLog(
      "mTargetPortImageFile ======> ${mTargetPortImageFile?.absolute.path ?? ""}");
  printLog("mLandImageFileName ========> $mLandImageFileName");
  printLog(
      "mTargetLandImageFile ======> ${mTargetLandImageFile?.absolute.path ?? ""}");
  /* *************** Prepare Target Image Files END */

  try {
    Utils.showToast("Download started");

    /* Potrait Image Download */
    dio.download(sectionDetails?.thumbnail ?? "",
        path.join(localPath, '$mPortImageFileName.png'),
        onReceiveProgress: (received, total) {});

    /* Landscape Image Download */
    dio.download(sectionDetails?.landscape ?? "",
        path.join(localPath, '$mLandImageFileName.png'),
        onReceiveProgress: (received, total) {});

    /* Video Download */
    await dio.download(sectionDetails?.video320 ?? "", mTargetFile?.path,
        onReceiveProgress: (received, total) async {
      if (total != -1) {
        await downloadProvider
            .setDownloadProgress((received / total * 100).round());
      }
    });

    /* Encrypt Video File START ************** */
    String generateKey = Utils.generateRandomKey(32);
    printLog("generateKey =======> $generateKey");
    var rootToken = RootIsolateToken.instance!;
    final isolate = await Isolate.spawn(Utils.encryptFile,
        [mTargetFile, generateKey, receivePort.sendPort, rootToken]);
    receivePort.listen((message) {
      printLog("message =======> $message");
      if (message != null) {
        receivePort.close();
        isolate.kill(priority: Isolate.immediate);
      }
    });
    /* ***************** Encrypt Video File END */

    DownloadItem downloadedItem = DownloadItem(
      id: sectionDetails?.id,
      securityKey: generateKey,
      name: sectionDetails?.name,
      description: sectionDetails?.description,
      videoUrl: sectionDetails?.video320,
      savedDir: localPath,
      savedFile: mTargetFile?.path ?? "",
      videoType: sectionDetails?.videoType,
      subVideoType: sectionDetails?.subVideoType,
      typeId: sectionDetails?.typeId,
      isPremium: sectionDetails?.isPremium,
      isBuy: sectionDetails?.isBuy,
      isRent: sectionDetails?.isRent,
      rentBuy: sectionDetails?.rentBuy,
      rentPrice: sectionDetails?.price,
      isDownload: 1,
      videoUploadType: sectionDetails?.videoUploadType,
      trailerUploadType: sectionDetails?.trailerType,
      trailerUrl: sectionDetails?.trailerUrl,
      videoDuration: sectionDetails?.videoDuration,
      stopTime: sectionDetails?.stopTime ?? 0,
      releaseYear: sectionDetails?.releaseDate,
      thumbnailImg: mTargetPortImageFile?.path,
      landscapeImg: mTargetLandImageFile?.path,
      session: [],
    );

    /* Insert in Hive */
    dowonloadBox.add(downloadedItem);

    await downloadProvider.setDownloadProgress(-1);
    await downloadProvider.setCurrentDownload(null);
    await downloadProvider.setLoading(false);
    Utils.showToast("Download completed");
  } catch (e) {
    Utils.showToast("Download failed");
  }
}
/* ========================== Download Videos ========================== */

/* ========================== Download Shows ========================== */
Future<void> prepareShowDownload(
  BuildContext context, {
  required contentdetails.Result? contentDetails,
  required int? seasonPos,
  required int? episodePos,
  required episode.Result? episodeDetails,
}) async {
  final receivePort = ReceivePort();
  contentdetails.Result? sectionDetails = contentDetails;
  int seasonPosition = seasonPos ?? 0;
  int epiPos = episodePos ?? 0;
  episode.Result? epiDetails = episodeDetails;

  final downloadProvider =
      Provider.of<ShowDownloadProvider>(context, listen: false);
  await downloadProvider.setCurrentDownload(epiDetails?.id ?? 0);

  Dio dio = Dio();

  /* Hive */
  Box<DownloadItem> dowonloadBox;
  Box<SessionItem> dowonloadSeasonBox;
  Box<EpisodeItem> dowonloadEpiBox;
  if (Constant.userIsKid == true) {
    dowonloadBox = Hive.box<DownloadItem>(
        '${Constant.hiveDownloadBox}_${Constant.userID}_KID');
    dowonloadSeasonBox = Hive.box<SessionItem>(
        '${Constant.hiveSeasonDownloadBox}_${Constant.userID}_KID');
    dowonloadEpiBox = Hive.box<EpisodeItem>(
        '${Constant.hiveEpiDownloadBox}_${Constant.userID}_KID');
  } else {
    dowonloadBox = Hive.box<DownloadItem>(
        '${Constant.hiveDownloadBox}_${Constant.userID}');
    dowonloadSeasonBox = Hive.box<SessionItem>(
        '${Constant.hiveSeasonDownloadBox}_${Constant.userID}');
    dowonloadEpiBox = Hive.box<EpisodeItem>(
        '${Constant.hiveEpiDownloadBox}_${Constant.userID}');
  }
  if (!dowonloadBox.isOpen) {
    return;
  }

  DateTime now = DateTime.now();
  String timeStamp = now.millisecondsSinceEpoch.abs().toString();

  /* Prepare Target Video File START ************* */
  File? mTargetFile;
  String? localPath;
  try {
    localPath = await Utils.prepareShowSaveDir(
        (sectionDetails?.name ?? "").replaceAll(RegExp('\\W+'), ''),
        (sectionDetails?.season?[seasonPosition].name ?? "")
            .replaceAll(RegExp('\\W+'), ''));
    printLog("localPath ====> $localPath");
    String? mFileName =
        '${(sectionDetails?.season?[seasonPosition].name ?? "").replaceAll(RegExp('\\W+'), '')}'
        '_Ep${(epiPos + 1)}_${episodeDetails?.id}${(Constant.userID)}_KID';
    printLog("mFileName ======> $mFileName");

    mTargetFile = File(path.join(localPath,
        '$mFileName.${episodeDetails?.videoExtension != '' ? (episodeDetails?.videoExtension ?? 'mp4') : 'mp4'}'));
  } catch (e) {
    printLog("saveShowStorage Exception ===> $e");
  }
  printLog("mTargetFile ====> ${mTargetFile?.absolute.path ?? ""}");
  /* *************** Prepare Target Video File END */

  /* Prepare Target Image Files START ************* */
  File? mShowPortImageFile,
      mShowLandImageFile,
      mEpiPortImageFile,
      mEpiLandImageFile;
  String? mShowPortImgFileName = 'port_$timeStamp';
  String? mShowLandImgFileName = 'land_$timeStamp';
  String? mEpiPortImgFileName = 'port_epi_$timeStamp';
  String? mEpiLandImgFileName = 'land_epi_$timeStamp';
  if (localPath != null) {
    try {
      mShowPortImageFile =
          File(path.join(localPath, '$mShowPortImgFileName.png'));
      mShowLandImageFile =
          File(path.join(localPath, '$mShowLandImgFileName.png'));
      mEpiPortImageFile =
          File(path.join(localPath, '$mEpiPortImgFileName.png'));
      mEpiLandImageFile =
          File(path.join(localPath, '$mEpiLandImgFileName.png'));
    } catch (e) {
      printLog("saveShowStorage Exception ===> $e");
    }
  } else {
    return;
  }
  printLog("mPortImageFileName ======> $mShowPortImgFileName");
  printLog(
      "mTargetPortImageFile ====> ${mShowPortImageFile?.absolute.path ?? ""}");
  printLog("mLandImageFileName ======> $mShowLandImgFileName");
  printLog(
      "mTargetLandImageFile ====> ${mShowLandImageFile?.absolute.path ?? ""}");
  printLog("mEpiPortImgFileName =====> $mEpiPortImgFileName");
  printLog(
      "mEpiPortImageFile =======> ${mEpiPortImageFile?.absolute.path ?? ""}");
  printLog("mEpiLandImgFileName =====> $mEpiLandImgFileName");
  printLog(
      "mEpiLandImageFile =======> ${mEpiLandImageFile?.absolute.path ?? ""}");
  /* *************** Prepare Target Image Files END */

  try {
    if (!context.mounted) return;
    Utils.showToast("Download started");

    /* Save Video/Show */
    List<DownloadItem> myDownloadList = [];
    DownloadItem downloadedItem = DownloadItem(
      id: sectionDetails?.id,
      securityKey: "",
      name: sectionDetails?.name,
      description: sectionDetails?.description,
      videoUrl: "",
      savedDir: localPath,
      savedFile: "",
      videoType: sectionDetails?.videoType,
      subVideoType: sectionDetails?.subVideoType,
      typeId: sectionDetails?.typeId,
      isPremium: sectionDetails?.isPremium,
      isBuy: sectionDetails?.isBuy,
      isRent: sectionDetails?.isRent,
      rentBuy: sectionDetails?.rentBuy,
      rentPrice: sectionDetails?.price,
      isDownload: 1,
      videoUploadType: sectionDetails?.videoUploadType,
      trailerUploadType: sectionDetails?.trailerType,
      trailerUrl: sectionDetails?.trailerUrl,
      videoDuration: sectionDetails?.videoDuration,
      stopTime: sectionDetails?.stopTime ?? 0,
      releaseYear: sectionDetails?.releaseDate,
      thumbnailImg: mShowPortImageFile?.path,
      landscapeImg: mShowLandImageFile?.path,
      session: null,
    );
    /* Check in Download Box */
    myDownloadList = dowonloadBox.values.where((myDowonloadItem) {
      return (myDowonloadItem.id == sectionDetails?.id);
    }).toList();

    if (myDownloadList.isEmpty) {
      /* Potrait Image Download */
      dio.download(sectionDetails?.thumbnail ?? "",
          path.join(localPath, '$mShowPortImgFileName.png'),
          onReceiveProgress: (received, total) {});

      /* Landscape Image Download */
      dio.download(sectionDetails?.landscape ?? "",
          path.join(localPath, '$mShowLandImgFileName.png'),
          onReceiveProgress: (received, total) {});
    }

    /* Potrait Episode Image Download */
    dio.download(epiDetails?.thumbnail ?? "",
        path.join(localPath, '$mEpiPortImgFileName.png'),
        onReceiveProgress: (received, total) {});

    /* Landscape Episode Image Download */
    dio.download(epiDetails?.landscape ?? "",
        path.join(localPath, '$mEpiLandImgFileName.png'),
        onReceiveProgress: (received, total) {});

    /* Video Download */
    await dio.download(epiDetails?.video320 ?? "", mTargetFile?.path,
        onReceiveProgress: (received, total) async {
      if (total != -1) {
        await downloadProvider.setDownloadProgress(
            (received / total * 100).round(), epiDetails?.id ?? 0);
      }
    });

    /* Encrypt Episode File START ************** */
    String generateKey = Utils.generateRandomKey(32);
    printLog("generateKey =======> $generateKey");
    var rootToken = RootIsolateToken.instance!;
    final isolate = await Isolate.spawn(Utils.encryptFile,
        [mTargetFile, generateKey, receivePort.sendPort, rootToken]);
    receivePort.listen((message) {
      printLog("message =======> $message");
      if (message != null) {
        receivePort.close();
        isolate.kill(priority: Isolate.immediate);
      }
    });
    /* ***************** Encrypt Episode File END */

    /* Check In Downloaded Items START **************** */
    List<SessionItem> mySavedSeasonList = [];
    List<EpisodeItem> mySavedEpiList = [];

    /* Save Episode */
    EpisodeItem episodeItem = EpisodeItem(
      id: episodeDetails?.id,
      securityKey: generateKey,
      showId: sectionDetails?.id,
      sessionId: sectionDetails?.season?[seasonPosition].id,
      thumbnail: mEpiPortImageFile?.path,
      landscape: mEpiLandImageFile?.path,
      videoUploadType: episodeDetails?.videoUploadType,
      videoType: sectionDetails?.videoType,
      subVideoType: sectionDetails?.subVideoType,
      stopTime: episodeDetails?.stopTime,
      videoExtension: episodeDetails?.videoExtension != ''
          ? (episodeDetails?.videoExtension ?? 'mp4')
          : 'mp4',
      videoDuration: episodeDetails?.videoDuration,
      isPremium: episodeDetails?.isPremium,
      description: episodeDetails?.description,
      status: episodeDetails?.status,
      video320: episodeDetails?.video320,
      video480: episodeDetails?.video480,
      video720: episodeDetails?.video720,
      video1080: episodeDetails?.video1080,
      savedDir: localPath,
      savedFile: mTargetFile?.path ?? "",
      subtitleType: episodeDetails?.subtitleType,
      subtitle1: episodeDetails?.subtitle1,
      subtitle2: episodeDetails?.subtitle2,
      subtitle3: episodeDetails?.subtitle3,
      subtitleLang1: episodeDetails?.subtitleLang1,
      subtitleLang2: episodeDetails?.subtitleLang2,
      subtitleLang3: episodeDetails?.subtitleLang3,
      isDownloaded: 1,
      isBookmark: sectionDetails?.isBookmark,
      rentBuy: sectionDetails?.rentBuy,
      isRent: sectionDetails?.isRent,
      rentPrice: sectionDetails?.price,
      isBuy: episodeDetails?.isBuy,
      categoryName: sectionDetails?.categoryName,
    );

    /* Save Season */
    SessionItem sessionItem = SessionItem(
      id: sectionDetails?.season?[seasonPosition].id,
      showId: sectionDetails?.id,
      sessionPosition: seasonPosition,
      name: sectionDetails?.season?[seasonPosition].name,
      status: sectionDetails?.season?[seasonPosition].status,
      isDownload: 1,
      episode: null,
    );

    /* Check in Season Box */
    mySavedSeasonList = dowonloadSeasonBox.values.where((mySeasonItem) {
      return (mySeasonItem.showId == sectionDetails?.id &&
          mySeasonItem.id == sectionDetails?.season?[seasonPosition].id);
    }).toList();
    /* Check in Episode Box */
    mySavedEpiList = dowonloadEpiBox.values.where((myEpiItem) {
      return (myEpiItem.showId == sectionDetails?.id &&
          myEpiItem.id == episodeDetails?.id &&
          myEpiItem.sessionId == sectionDetails?.season?[seasonPosition].id);
    }).toList();
    printLog("myDownloadList =======> ${myDownloadList.length}");
    printLog("mySavedSeasonList ====> ${mySavedSeasonList.length}");
    printLog("mySavedEpiList =======> ${mySavedEpiList.length}");
    /* ****************** Check In Downloaded Items END */

    /* Insert in Hive */
    if (mySavedEpiList.isEmpty) {
      dowonloadEpiBox.add(episodeItem);
    }
    if (mySavedSeasonList.isEmpty) {
      dowonloadSeasonBox.add(sessionItem);
    }
    if (myDownloadList.isEmpty) {
      dowonloadBox.add(downloadedItem);
    }

    await downloadProvider.setDownloadProgress(-1, 0);
    await downloadProvider.setCurrentDownload(null);
    await downloadProvider.setLoading(false);
    Utils.showToast("Download completed");
  } catch (e) {
    if (!context.mounted) return;
    Utils.showToast("Download failed");
  }
} /* ========================== Download Shows ========================== */
