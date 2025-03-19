import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as number;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:debo/utils/sharedpre.dart';
import 'package:debo/utils/strings.dart';

import 'package:email_validator/email_validator.dart';
import 'package:encrypt/encrypt.dart' as excrypt;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:hive/hive.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:html/parser.dart' show parse;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screen_protector/screen_protector.dart';

import '../model/download_item.dart';
import '../model/playermodel.dart';
import '../model/qualitymodel.dart';
import '../model/subtitlemodel.dart';
import '../pages/bottombar.dart';
import '../pages/contentshowdetails.dart';
import '../pages/contentvideodetails.dart';
import '../pages/loginsocial.dart';
import '../players/DropBoxNormalPlayer.dart';
import '../players/player_vimeo.dart';
import '../players/player_youtube.dart';
import '../provider/profileprovider.dart';
import '../provider/showdetailsprovider.dart';
import '../provider/videodetailsprovider.dart';
import '../routes/routes_constant.dart';
import '../subscription/allpayment.dart';
import '../subscription/subscription.dart';
import '../web_js/js_helper_mobile.dart';
import '../webpages/webprofileedit.dart';
import '../webservice/apiservices.dart';
import '../webwidget/webdialogs.dart';
import '../widget/myimage.dart';
import '../widget/mytext.dart';
import 'adhelper.dart';
import 'color.dart';
import 'constant.dart';
import 'dimens.dart';

printLog(String message) {
  if (kDebugMode) {
    return debugPrint(message);
  }
}

class Utils {
  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<String>? getFirebaseWebToken() async {
    String? fcmToken;
    try {
      if (kIsWeb) {
        fcmToken = await FirebaseMessaging.instance
            .getToken(vapidKey: Constant.vapidKeyForWeb);
      }
    } on Exception catch (e) {
      printLog("getFirebaseWebToken Exception ====> $e");
    }
    printLog("getFirebaseWebToken fcmToken ====> $fcmToken");
    return fcmToken ?? "";
  }

  static Future<Map<String, dynamic>> loadJsonFromAssets(
      String filePath) async {
    String jsonString = await rootBundle.loadString(filePath);
    return jsonDecode(jsonString);
  }

  static Future<void> initializeOneSignal() async {
    if (!kIsWeb) {
      SharedPre sharedPre = SharedPre();
      String? oneSignalAppId = await sharedPre.read("onesignal_apid");
      printLog("initializeOneSignal AppId ==> $oneSignalAppId");
      if (oneSignalAppId != null) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
        // Initialize OneSignal
        OneSignal.initialize(oneSignalAppId);
        OneSignal.Notifications.requestPermission(true);
        OneSignal.Notifications.addPermissionObserver((state) {
          printLog("Has permission ==> $state");
        });
        OneSignal.User.pushSubscription.addObserver((state) {
          printLog(
              "pushSubscription state ==> ${state.current.jsonRepresentation()}");
        });
        OneSignal.Notifications.addForegroundWillDisplayListener((event) {
          /// preventDefault to not display the notification
          event.preventDefault();
          // Do async work
          /// notification.display() to display after preventing default
          event.notification.display();
        });
      }
    }
  }

  static void preventScreenCapture() async {
    await ScreenProtector.preventScreenshotOn();
    if (Platform.isIOS) {
      await ScreenProtector.protectDataLeakageWithBlur();
    } else if (Platform.isAndroid) {
      await ScreenProtector.protectDataLeakageOn();
    }
  }

  static Widget showBannerAd(BuildContext context) {
    if (!kIsWeb) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 0,
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: AdHelper.bannerAd(context),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  static loadAds(BuildContext context) async {
    bool? isPremiumBuy = await Utils.checkPremiumUser();
    printLog("loadAds isPremiumBuy :==> $isPremiumBuy");
    if (context.mounted) {
      AdHelper.getAds(context);
    }
    if (!kIsWeb && !isPremiumBuy) {
      AdHelper.createInterstitialAd();
      AdHelper.createRewardedAd();
    }
  }

  static showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: kIsWeb ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: kIsWeb ? 5 : 2,
      webShowClose: false,
      backgroundColor: white,
      textColor: kIsWeb ? white : black,
      webBgColor: "linear-gradient(to right, #AEEC2B, #78A026)",
      fontSize: kIsWeb ? 20 : 16,
    );
  }

  static Future<String> configByStatus({required String status}) async {
    SharedPre sharedPre = SharedPre();
    String? configValue = "";
    printLog("configByStatus status ========> $status");

    if (status == Constant.trailerAutoPlay) {
      configValue = await sharedPre.read(Constant.trailerAutoPlay);
    } else if (status == Constant.parentControlStatus) {
      configValue = await sharedPre.read(Constant.parentControlStatus);
    } else if (status == Constant.multipleDeviceSync) {
      configValue = await sharedPre.read(Constant.multipleDeviceSync);
    } else if (status == Constant.subscriptionStatus) {
      configValue = await sharedPre.read(Constant.subscriptionStatus);
    } else if (status == Constant.activeTvStatus) {
      configValue = await sharedPre.read(Constant.activeTvStatus);
    } else if (status == Constant.watchlistStatus) {
      configValue = await sharedPre.read(Constant.watchlistStatus);
    } else if (status == Constant.downloadStatus) {
      configValue = await sharedPre.read(Constant.downloadStatus);
    } else if (status == Constant.continueWatchingStatus) {
      configValue = await sharedPre.read(Constant.continueWatchingStatus);
    } else if (status == Constant.couponStatus) {
      configValue = await sharedPre.read(Constant.couponStatus);
    } else if (status == Constant.rentStatus) {
      configValue = await sharedPre.read(Constant.rentStatus);
    } else if (status == Constant.introScreenStatus) {
      configValue = await sharedPre.read(Constant.introScreenStatus);
    } else {
      configValue = "";
    }
    printLog('configByStatus configValue ==> $configValue');
    return configValue ?? "";
  }

  static Future<bool> checkSubsRentLogin({
    required BuildContext context,
    required int isPremium,
    required int isRent,
    required int isBuy,
    required int rentBuy,
    required String videoId,
    required String rentPrice,
    required String vTitle,
    required String typeId,
    required String vType,
    required String rentProductId,
    required String newPage,
    required String oldPage,
    required String reqText,
  }) async {
    if (Constant.userID != null) {
      String? rentStatus = await configByStatus(status: Constant.rentStatus);
      String? subscriptionStatus =
          await configByStatus(status: Constant.subscriptionStatus);
      printLog('checkSubsRentLogin rentStatus ====> $rentStatus');
      printLog('checkSubsRentLogin subs. Status ==> $subscriptionStatus');
      if (isPremium == 1 && isRent == 1) {
        if (subscriptionStatus != "1") {
          return true;
        }
        if (isBuy == 1 || rentBuy == 1) {
          return true;
        } else {
          if (context.mounted) {
            openSubscription(context: context, oldPage: "");
          }
          return false;
        }
      } else if (isPremium == 1) {
        if (subscriptionStatus != "1") {
          return true;
        }
        if (isBuy == 1) {
          return true;
        } else {
          if (context.mounted) {
            openSubscription(context: context, oldPage: "");
          }
          return false;
        }
      } else if (isRent == 1) {
        if (rentStatus != "1") {
          return true;
        }
        if (rentBuy == 1) {
          return true;
        } else {
          if (context.mounted) {
            paymentForRent(
              context: context,
              videoId: videoId,
              rentPrice: rentPrice,
              vTitle: vTitle,
              typeId: typeId,
              vType: vType,
              newPage: newPage,
              oldPage: oldPage,
              reqText: reqText,
              rentProductId: rentProductId,
            );
          }
          return false;
        }
      } else {
        return true;
      }
    } else {
      openLogin(context: context, newPage: "");
      return false;
    }
  }

  static Future<bool> getTrailerAutoPlay() async {
    SharedPre sharedPref = SharedPre();
    String? autoPlayTrailer = await sharedPref.read("auto_play_trailer") ?? "";
    printLog('getTrailerAutoPlay autoPlayTrailer ==> $autoPlayTrailer');
    if (autoPlayTrailer != null && autoPlayTrailer == "1") {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> redirectToMainPage(
      {required BuildContext context}) async {
    if (!context.mounted) return;
    if (kIsWeb) {
      if (context.canPop()) {
        context.pop();
      }
      context.pushReplacementNamed(RoutesConstant.homePage);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const Bottombar()),
        (Route<dynamic> route) => false,
      ).then(
        (value) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const Bottombar()),
          );
        },
      );
    }
  }

  static Future<dynamic> openSubscription({
    required BuildContext context,
    required String oldPage,
  }) async {
    if (kIsWeb) {
      if (!context.mounted) return;
      dynamic isSubscribe = await context.pushNamed(
        RoutesConstant.subscriptionPage,
        extra: oldPage,
      );
      return isSubscribe;
    }
    if (!context.mounted) return;
    dynamic isSubscribe = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Subscription(
            newPage: RoutesConstant.subscriptionPage,
            oldPage: oldPage,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
    printLog("openSubscription isSubscribe ====> $isSubscribe");
    return isSubscribe;
  }

  /* ========= Open Details ========= */
  static Future<dynamic> openDetails({
    required BuildContext context,
    required int videoId,
    required int subVideoType,
    required int videoType,
    required int typeId,
    required String newPage,
    required String oldPage,
    required String reqText,
  }) async {
    printLog("openDetails videoId ========> $videoId");
    printLog("openDetails subVideoType ===> $subVideoType");
    printLog("openDetails videoType ======> $videoType");
    printLog("openDetails typeId =========> $typeId");

    final videoDetailsProvider =
        Provider.of<VideoDetailsProvider>(context, listen: false);
    final showDetailsProvider =
        Provider.of<ShowDetailsProvider>(context, listen: false);

    if (videoType == 5 || videoType == 6 || videoType == 7) {
      if (subVideoType == 1) {
        await videoDetailsProvider.setLoading(true);
        if (!(context.mounted)) return;
        if (kIsWeb || Constant.isTV) {
          context.pushNamed(
            RoutesConstant.videoDetailsPage,
            extra: {
              'newpage': oldPage.toString(),
              'videoid': videoId.toString(),
              'subvideotype': subVideoType.toString(),
              'videotype': videoType.toString(),
              'typeid': typeId.toString()
            },
          );
        } else {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return ContentVideoDetails(
                  videoId,
                  subVideoType,
                  videoType,
                  typeId,
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            ),
          );
        }
      } else if (subVideoType == 2) {
        await showDetailsProvider.setLoading(true);
        if (!(context.mounted)) return;
        if (kIsWeb || Constant.isTV) {
          context.pushNamed(
            RoutesConstant.showDetailsPage,
            extra: {
              'newpage': oldPage.toString(),
              'videoid': videoId.toString(),
              'subvideotype': subVideoType.toString(),
              'videotype': videoType.toString(),
              'typeid': typeId.toString()
            },
          );
        } else {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return ContentShowDetails(
                  videoId,
                  subVideoType,
                  videoType,
                  typeId,
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            ),
          );
        }
      }
    } else {
      if (videoType == 1) {
        await videoDetailsProvider.setLoading(true);
        if (!(context.mounted)) return;
        if (kIsWeb || Constant.isTV) {
          context.pushNamed(
            RoutesConstant.videoDetailsPage,
            extra: {
              'newpage': oldPage.toString(),
              'videoid': videoId.toString(),
              'subvideotype': subVideoType.toString(),
              'videotype': videoType.toString(),
              'typeid': typeId.toString()
            },
          );
        } else {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return ContentVideoDetails(
                  videoId,
                  subVideoType,
                  videoType,
                  typeId,
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            ),
          );
        }
      } else if (videoType == 2) {
        await showDetailsProvider.setLoading(true);
        if (!(context.mounted)) return;
        if (kIsWeb || Constant.isTV) {
          context.pushNamed(
            RoutesConstant.showDetailsPage,
            extra: {
              'newpage': oldPage.toString(),
              'videoid': videoId.toString(),
              'subvideotype': subVideoType.toString(),
              'videotype': videoType.toString(),
              'typeid': typeId.toString()
            },
          );
        } else {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return ContentShowDetails(
                  videoId,
                  subVideoType,
                  videoType,
                  typeId,
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            ),
          );
        }
      }
    }
  }

  static Future<dynamic> openDetailsWithReplace({
    required BuildContext context,
    required int videoId,
    required int subVideoType,
    required int videoType,
    required int typeId,
    required String newPage,
    required String oldPage,
    required String reqText,
  }) async {
    printLog("openDetails videoId ========> $videoId");
    printLog("openDetails subVideoType ===> $subVideoType");
    printLog("openDetails videoType ======> $videoType");
    printLog("openDetails typeId =========> $typeId");

    final videoDetailsProvider =
        Provider.of<VideoDetailsProvider>(context, listen: false);
    final showDetailsProvider =
        Provider.of<ShowDetailsProvider>(context, listen: false);

    if (videoType == 5 || videoType == 6 || videoType == 7) {
      if (subVideoType == 1) {
        await videoDetailsProvider.setLoading(true);
        if (!(context.mounted)) return;
        if (kIsWeb || Constant.isTV) {
          context.pushReplacementNamed(
            RoutesConstant.videoDetailsPage,
            extra: {
              'newpage': oldPage.toString(),
              'videoid': videoId.toString(),
              'subvideotype': subVideoType.toString(),
              'videotype': videoType.toString(),
              'typeid': typeId.toString()
            },
          );
        } else {
          await Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return ContentVideoDetails(
                  videoId,
                  subVideoType,
                  videoType,
                  typeId,
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            ),
          );
        }
      } else if (subVideoType == 2) {
        await showDetailsProvider.setLoading(true);
        if (!(context.mounted)) return;
        if (kIsWeb || Constant.isTV) {
          context.pushReplacementNamed(
            RoutesConstant.showDetailsPage,
            extra: {
              'newpage': oldPage.toString(),
              'videoid': videoId.toString(),
              'subvideotype': subVideoType.toString(),
              'videotype': videoType.toString(),
              'typeid': typeId.toString()
            },
          );
        } else {
          await Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return ContentShowDetails(
                  videoId,
                  subVideoType,
                  videoType,
                  typeId,
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            ),
          );
        }
      }
    } else {
      if (videoType == 1) {
        await videoDetailsProvider.setLoading(true);
        if (!(context.mounted)) return;
        if (kIsWeb || Constant.isTV) {
          context.pushReplacementNamed(
            RoutesConstant.videoDetailsPage,
            extra: {
              'newpage': oldPage.toString(),
              'videoid': videoId.toString(),
              'subvideotype': subVideoType.toString(),
              'videotype': videoType.toString(),
              'typeid': typeId.toString()
            },
          );
        } else {
          await Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return ContentVideoDetails(
                  videoId,
                  subVideoType,
                  videoType,
                  typeId,
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            ),
          );
        }
      } else if (videoType == 2) {
        await showDetailsProvider.setLoading(true);
        if (!(context.mounted)) return;
        if (kIsWeb || Constant.isTV) {
          context.pushReplacementNamed(
            RoutesConstant.showDetailsPage,
            extra: {
              'newpage': oldPage.toString(),
              'videoid': videoId.toString(),
              'subvideotype': subVideoType.toString(),
              'videotype': videoType.toString(),
              'typeid': typeId.toString()
            },
          );
        } else {
          await Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return ContentShowDetails(
                  videoId,
                  subVideoType,
                  videoType,
                  typeId,
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            ),
          );
        }
      }
    }
  }
  /* ========= Open Details ========= */

  static Future<dynamic> paymentForRent({
    required BuildContext context,
    required String? newPage,
    required String? oldPage,
    required String? reqText,
    required String? videoId,
    required String? vTitle,
    required String? vType,
    required String? typeId,
    required String? rentPrice,
    required String? rentProductId,
  }) async {
    dynamic isRented;
    if (kIsWeb) {
      isRented = await context.pushNamed(
        RoutesConstant.paymentPage,
        extra: {
          'newpage': newPage.toString(),
          'paytype': 'Rent',
          'itemid': videoId,
          'price': rentPrice,
          'title': vTitle,
          'videotype': vType,
          'typeid': typeId,
          'currency': '',
          'productpackage': rentProductId
        },
      );
    } else {
      isRented = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return AllPayment(
              payType: 'Rent',
              newPage: RoutesConstant.paymentPage,
              oldPage: newPage.toString(),
              reqText: '',
              itemId: videoId.toString(),
              price: rentPrice.toString(),
              itemTitle: vTitle.toString(),
              typeId: typeId.toString(),
              videoType: vType.toString(),
              productPackage: rentProductId,
              currency: '',
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        ),
      );
    }
    printLog("paymentForRent isRented ====> $isRented");
    return isRented;
  }

  static Future<dynamic> buildWebAlertDialog(BuildContext context,
      String pageName, String? reqData, String newPage) async {
    Widget? child;
    if (pageName == "profileedit") {
      child = WebProfileEdit(
        newPage: RoutesConstant.editProfilePage,
        oldPage: newPage,
        reqText: reqData,
      );
    }
    dynamic result = await showDialog<dynamic>(
      context: context,
      useSafeArea: true,
      barrierDismissible: (pageName == "search") ? true : false,
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.topCenter,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          insetPadding: EdgeInsets.fromLTRB(
            (MediaQuery.of(context).size.width > 900) ? 50 : 30,
            (MediaQuery.of(context).size.width > 900) ? 50 : 30,
            (MediaQuery.of(context).size.width > 900) ? 50 : 30,
            (MediaQuery.of(context).size.width > 900) ? 50 : 30,
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: (pageName == "search") ? transparent : lightBlack,
          child: child,
        );
      },
    );

    printLog("buildWebAlertDialog result ====> $result");
    return result;
  }

  static Future<dynamic> pushWebPage({
    required BuildContext context,
    required Widget newChild,
  }) async {
    printLog("pushWebPage newChild ============> $newChild");
    dynamic result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return newChild;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
    printLog("pushWebPage result =======> $result");
    return result;
  }

  static Future<dynamic> pushReplaceWebPage({
    required BuildContext context,
    required Widget newChild,
  }) async {
    printLog("pushReplaceWebPage newChild ============> $newChild");
    dynamic result = await Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return newChild;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
    printLog("pushReplaceWebPage result =======> $result");
    return result;
  }

  static checkLoginUser(BuildContext context) {
    if (Constant.userID != null) {
      return true;
    }
    openLogin(context: context, newPage: RoutesConstant.loginSocialPage);
    return false;
  }

  static Future<dynamic> openLogin({
    required BuildContext context,
    required String newPage,
  }) async {
    printLog("<<<<<<<< OPEN LOGIN >>>>>>>>");
    if ((kIsWeb || Constant.isTV)) {
      if (!context.mounted) return;
      dynamic result = await openWebDialog(
        context: context,
        newPage: RoutesConstant.loginSocialPage,
        oldPage: newPage,
        reqText: '',
      );
      return result;
    }
    if (!context.mounted) return;
    dynamic result = Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const LoginSocial();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
    return result;
  }

  static Future<dynamic> openWebDialog({
    required BuildContext context,
    required String newPage,
    required String oldPage,
    required String reqText,
  }) async {
    dynamic result = await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: appBgColor,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (BuildContext context, animation, secondaryAnimation) {
        return WebDialogs(
          dialogType: newPage,
          newPage: newPage,
          oldPage: oldPage,
          reqText: reqText,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        Tween<Offset> tween;
        if (newPage == RoutesConstant.loginSocialPage) {
          tween = Tween(begin: const Offset(0, 1), end: const Offset(0, 0));
        } else {
          tween = Tween(begin: const Offset(0, 0), end: const Offset(0, 0));
        }
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
    return result;
  }

  /* ========= Logout Device ========= */
  static Future<void> logoutFromApp(BuildContext context, int deviceSyncId,
      int deviceType, String deviceToken, String deviceId) async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    showProgress(context);
    await profileProvider.logoutDevice(
        deviceSyncId, deviceType, deviceToken, deviceId);
    if (!profileProvider.loadingLogout) {
      if (!context.mounted) return;
      hideProgress();
      if (!context.mounted) return;
      if (profileProvider.deviceLogoutModel.status == 200) {
        if (kIsWeb) {
          showToast(profileProvider.deviceLogoutModel.message ?? "");
        } else {
          showSnackbar(context, "success",
              "${profileProvider.deviceLogoutModel.message}", false);
        }

        /* Send Notification for Logout */
        await ApiService()
            .sendFCMPushNotification("logout", deviceToken, deviceType);
      } else {
        if (kIsWeb) {
          showToast(profileProvider.deviceLogoutModel.message ?? "");
        } else {
          showSnackbar(context, "fail",
              "${profileProvider.deviceLogoutModel.message}", false);
        }
      }
    }
  }
  /* ========= Logout Device ========= */

  /* ========= Open Player ========= */
  static Future<dynamic> openPlayer({
    required BuildContext context,
    required PlayerModel playerModel,
  }) async {
    dynamic isContinue;
    if (kIsWeb) {
      /* Pod Player & Youtube Player */
      if (!context.mounted) return;
      isContinue = await context.pushNamed(
        RoutesConstant.playerPage,
        extra: playerModel,
      );
    } else {
      /* Better, Youtube & Vimeo Players */
      if (playerModel.uploadType == "youtube") {
        isContinue = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return PlayerYoutube(playerModel: playerModel);
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
          ),
        );
      } else if (playerModel.uploadType == "vimeo") {
        isContinue = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return PlayerVimeo(playerModel: playerModel);
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
          ),
        );
      } else if (playerModel.uploadType == "external") {
        if ((playerModel.videoUrl ?? "").contains('youtube')) {
          isContinue = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return PlayerYoutube(playerModel: playerModel);
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            ),
          );
        } else {
          isContinue = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                //todo the player
                print("videoUrl ${playerModel.videoUrl!}");
                return DropBoxNormalPlayer(url: playerModel.videoUrl!,) ;
                //return PlayerVideo(playerModel: playerModel);
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
            ),
          );
        }
      } else {
        isContinue = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              //todo the player
              print("videoUrl ${playerModel.videoUrl!}");
              return DropBoxNormalPlayer(url: playerModel.videoUrl!,) ;
              //return PlayerVideo(playerModel: playerModel);
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
          ),
        );
      }
    }
    printLog("isContinue ===> $isContinue");
    return isContinue;
  }
  /* ========= Open Player ========= */

  /* ========= Set-up Quality URL START ========= */
  static void setQualityURLs({
    required String video320,
    required String video480,
    required String video720,
    required String video1080,
  }) {
    Map<String, String> qualityUrlList = <String, String>{};
    if (video320 != "") {
      qualityUrlList['320p'] = video320;
    }
    if (video480 != "") {
      qualityUrlList['480p'] = video480;
    }
    if (video720 != "") {
      qualityUrlList['720p'] = video720;
    }
    if (video1080 != "") {
      qualityUrlList['1080p'] = video1080;
    }
    printLog("qualityUrlList ==========> ${qualityUrlList.length}");
    Constant.resolutionsUrls.clear();
    Constant.resolutionsUrls = [];
    Constant.resolutionsUrls = qualityUrlList.entries
        .map((entry) => QualityModel(entry.key, entry.value))
        .toList();
    printLog("resolutionsUrls ==========> ${Constant.resolutionsUrls.length}");
  }
  /* ========= Set-up Quality URL END =========== */

  static void clearQualitySubtitle() {
    Constant.resolutionsUrls.clear();
    Constant.resolutionsUrls = [];
    Constant.subtitleUrls.clear();
    Constant.subtitleUrls = [];
  }

  /* ========= Set-up Subtitle URL START ========= */
  static void setSubtitleURLs({
    required String subtitleUrl1,
    required String subtitleUrl2,
    required String subtitleUrl3,
    required String subtitleLang1,
    required String subtitleLang2,
    required String subtitleLang3,
  }) {
    Map<String, String> subtitleUrlList = <String, String>{};
    if (subtitleUrl1 != "") {
      subtitleUrlList[subtitleLang1] = subtitleUrl1;
    }
    if (subtitleUrl2 != "") {
      subtitleUrlList[subtitleLang2] = subtitleUrl2;
    }
    if (subtitleUrl3 != "") {
      subtitleUrlList[subtitleLang3] = subtitleUrl3;
    }
    printLog("subtitleUrlList========> ${subtitleUrlList.length}");
    Constant.subtitleUrls.clear();
    Constant.subtitleUrls = [];
    Constant.subtitleUrls = subtitleUrlList.entries
        .map((entry) => SubTitleModel(entry.key, entry.value))
        .toList();
    printLog("subtitleUrls ==========> ${Constant.subtitleUrls.length}");
  }
  /* ========= Set-up Subtitle URL END =========== */

  /* Update Required profile data before Payment START ************************/
  static Widget dataUpdateDialog(
    BuildContext context, {
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController mobileController,
  }) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        width: Dimens.isBigScreen(context)
            ? (MediaQuery.of(context).size.width * 0.3)
            : (MediaQuery.of(context).size.width),
        padding: const EdgeInsets.all(23),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /* Title & Subtitle */
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    color: titleTextColor,
                    text: "update_profile",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: 16,
                    fontsizeWeb: 16,
                    fontweight: FontWeight.w700,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 3),
                  MyText(
                    color: descTextColor,
                    text: "update_profile_desc",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: 13,
                    fontsizeWeb: 14,
                    fontweight: FontWeight.w500,
                    maxline: 3,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  )
                ],
              ),
            ),

            /* Fullname */
            const SizedBox(height: 30),
            if (isNameReq)
              buildTextFormField(
                controller: nameController,
                hintText: "fullname",
                inputType: TextInputType.name,
                readOnly: false,
              ),

            /* Email */
            if (isEmailReq)
              buildTextFormField(
                controller: emailController,
                hintText: "email_address",
                inputType: TextInputType.emailAddress,
                readOnly: false,
              ),

            /* Mobile */
            if (isMobileReq)
              buildTextFormField(
                controller: mobileController,
                hintText: "mobile_number",
                inputType: const TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                readOnly: false,
              ),
            const SizedBox(height: 5),

            /* Cancel & Update Buttons */
            Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* Cancel */
                  InkWell(
                    onTap: () {
                      final profileEditProvider =
                          Provider.of<ProfileProvider>(context, listen: false);
                      if (!profileEditProvider.loadingUpdate) {
                        if (kIsWeb) {
                          if (context.canPop()) {
                            context.pop(false);
                          }
                        } else {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context, false);
                          }
                        }
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 75),
                      height: 50,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: descTextColor,
                          width: .5,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: MyText(
                        color: descTextColor,
                        text: "cancel",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontsizeNormal: 16,
                        fontsizeWeb: 16,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontweight: FontWeight.w500,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  /* Submit */
                  Consumer<ProfileProvider>(
                    builder: (context, profileEditProvider, child) {
                      if (profileEditProvider.loadingUpdate) {
                        return Container(
                          width: 100,
                          height: 50,
                          padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                          alignment: Alignment.center,
                          child: pageLoader(),
                        );
                      }
                      return InkWell(
                        onTap: () async {
                          SharedPre sharedPref = SharedPre();
                          final fullName =
                              nameController.text.toString().trim();
                          final emailAddress =
                              emailController.text.toString().trim();
                          final mobileNumber =
                              mobileController.text.toString().trim();

                          printLog(
                              "fullName =======> $fullName ; required ========> $isNameReq");
                          printLog(
                              "emailAddress ===> $emailAddress ; required ====> $isEmailReq");
                          printLog(
                              "mobileNumber ===> $mobileNumber ; required ====> $isMobileReq");
                          if (isNameReq && fullName.isEmpty) {
                            Utils.showToast("Enter your name.");
                          } else if (isEmailReq && emailAddress.isEmpty) {
                            Utils.showToast("Enter your email.");
                          } else if (isMobileReq && mobileNumber.isEmpty) {
                            Utils.showToast("Enter your mobile number");
                          } else if (isEmailReq &&
                              !EmailValidator.validate(emailAddress)) {
                            Utils.showToast("Enter valid email.");
                          } else {
                            final profileEditProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            await profileEditProvider.setUpdateLoading(true);

                            await profileEditProvider.getUpdateDataForPayment(
                                fullName, emailAddress, mobileNumber);
                            if (!profileEditProvider.loadingUpdate) {
                              await profileEditProvider.setUpdateLoading(false);
                              if (profileEditProvider.successModel.status ==
                                  200) {
                                if (isNameReq) {
                                  await sharedPref.save(
                                      'userfullname', fullName);
                                }
                                if (isEmailReq) {
                                  await sharedPref.save(
                                      'useremail', emailAddress);
                                }
                                if (isMobileReq) {
                                  await sharedPref.save(
                                      'usermobile', mobileNumber);
                                }
                                if (context.mounted) {
                                  if (kIsWeb) {
                                    if (context.canPop()) {
                                      context.pop(false);
                                    }
                                  } else {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context, true);
                                    }
                                  }
                                }
                              } else {
                                Utils.showToast(
                                    "${profileEditProvider.successModel.message}");
                              }
                            }
                          }
                        },
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 75),
                          height: 50,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(5),
                            shape: BoxShape.rectangle,
                          ),
                          child: MyText(
                            color: black,
                            text: "submit",
                            textalign: TextAlign.center,
                            fontsizeNormal: 16,
                            fontsizeWeb: 16,
                            multilanguage: true,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontweight: FontWeight.w700,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType inputType,
    required bool readOnly,
  }) {
    return Container(
      constraints: BoxConstraints(
          minHeight:
              kIsWeb ? Dimens.textFieldHeightWeb : Dimens.textFieldHeight),
      margin: const EdgeInsets.only(bottom: 25),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        obscureText: false,
        maxLines: 1,
        readOnly: readOnly,
        cursorColor: colorAccent,
        cursorRadius: const Radius.circular(2),
        decoration: InputDecoration(
          filled: true,
          isDense: false,
          fillColor: transparent,
          focusedBorder: const GradientOutlineInputBorder(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colorPrimary, colorPrimary],
            ),
            width: 1,
          ),
          border: GradientOutlineInputBorder(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorPrimary.withOpacity(0.5),
                colorPrimary.withOpacity(0.5)
              ],
            ),
            width: 1,
          ),
          label: MyText(
            multilanguage: true,
            color: titleTextColor,
            text: hintText,
            textalign: TextAlign.start,
            fontstyle: FontStyle.normal,
            fontsizeNormal: 14,
            fontsizeWeb: 16,
            fontweight: FontWeight.w500,
          ),
        ),
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        style: kIsWeb
            ? const TextStyle(
                fontSize: 16,
                color: white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
              )
            : GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                ),
              ),
      ),
    );
  }
  /* *********************** Update Required profile data before Payment END */

  static void getCurrencySymbol() async {
    SharedPre sharedPref = SharedPre();
    Constant.currencySymbol = await sharedPref.read("currency_code") ?? "";
    printLog('Constant currencySymbol ==> ${Constant.currencySymbol}');
    Constant.currency = await sharedPref.read("currency") ?? "";
    printLog('Constant currency ==> ${Constant.currency}');
  }

  /* For Stripe Web ***************** */
  static savePayParams({
    required String payType,
    required String itemId,
    required String price,
    required String itemTitle,
    required String typeId,
    required String videoType,
    required String productPackage,
    required String currency,
    required String paymentId,
  }) async {
    SharedPre sharedPref = SharedPre();
    await sharedPref.save("payType", payType);
    await sharedPref.save("itemId", itemId);
    await sharedPref.save("price", price);
    await sharedPref.save("itemTitle", itemTitle);
    await sharedPref.save("typeId", typeId);
    await sharedPref.save("videoType", videoType);
    await sharedPref.save("productPackage", productPackage);
    await sharedPref.save("currency", currency);
    await sharedPref.save("paymentId", paymentId);
  }

  static clearPayParams() async {
    SharedPre sharedPref = SharedPre();
    await sharedPref.remove("payType");
    await sharedPref.remove("itemId");
    await sharedPref.remove("price");
    await sharedPref.remove("itemTitle");
    await sharedPref.remove("typeId");
    await sharedPref.remove("videoType");
    await sharedPref.remove("productPackage");
    await sharedPref.remove("currency");
    await sharedPref.remove("paymentId");
  }
  /* ***************** For Stripe Web */

  static saveUserCreds({
    required userID,
    required userName,
    required fullName,
    required userEmail,
    required userMobile,
    required userImage,
    required userPremium,
    required userType,
    required deviceType,
    required deviceToken,
  }) async {
    SharedPre sharedPref = SharedPre();
    if (userID != null) {
      await sharedPref.save("userid", userID);
      await sharedPref.save("username", userName);
      await sharedPref.save("userfullname", fullName);
      await sharedPref.save("useremail", userEmail);
      await sharedPref.save("usermobile", userMobile);
      await sharedPref.save("userimage", userImage);
      await sharedPref.save("userpremium", userPremium);
      await sharedPref.save("usertype", userType);
      await sharedPref.save("devicetype", deviceType);
      await sharedPref.save("devicetoken", deviceToken);
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("username");
      await sharedPref.remove("userfullname");
      await sharedPref.remove("userimage");
      await sharedPref.remove("useremail");
      await sharedPref.remove("usermobile");
      await sharedPref.remove("userpremium");
      await sharedPref.remove("usertype");
      await sharedPref.remove("devicetype");
      await sharedPref.remove("devicetoken");
      await sharedPref.remove("useriskid");
    }
    Constant.userID = await sharedPref.read("userid");
    printLog('setUserId userID ==> ${Constant.userID}');
  }

  static Future<bool> checkParentLock() async {
    SharedPre sharedPre = SharedPre();
    bool? isParentLock = await sharedPre.readBool(Constant.parentLockKey);
    printLog('checkParentLock isParentLock ==> $isParentLock');
    return isParentLock ?? false;
  }

  static Future<void> setParentLock(bool parentLockStatus) async {
    printLog('setParentLock parentLockStatus ==> $parentLockStatus');
    SharedPre sharedPre = SharedPre();
    await sharedPre.saveBool(Constant.parentLockKey, parentLockStatus);
    bool? isParentLock = await checkParentLock();
    printLog('setParentLock isParentLock ==> $isParentLock');
  }

  static Future<bool> checkPremiumUser() async {
    SharedPre sharedPre = SharedPre();
    String? isPremiumBuy = await sharedPre.read("userpremium");
    printLog('checkPremiumUser isPremiumBuy ==> $isPremiumBuy');
    if (isPremiumBuy != null && isPremiumBuy == "1") {
      return true;
    } else {
      return false;
    }
  }

  static void updatePremium(String isPremiumBuy) async {
    printLog('updatePremium isPremiumBuy ==> $isPremiumBuy');
    SharedPre sharedPre = SharedPre();
    await sharedPre.save("userpremium", isPremiumBuy);
    String? isPremium = await sharedPre.read("userpremium");
    printLog('updatePremium ===============> $isPremium');
  }

  static setUserMode(bool? userIsKid) async {
    SharedPre sharedPref = SharedPre();
    if (userIsKid != null) {
      await sharedPref.saveBool(Constant.profileUserKey, userIsKid);
    } else {
      await sharedPref.remove(Constant.profileUserKey);
    }
    Constant.userIsKid = await sharedPref.readBool(Constant.profileUserKey);
    printLog('setUserMode userIsKid ==> ${Constant.userIsKid}');
  }

  static setUserId(userID) async {
    SharedPre sharedPref = SharedPre();
    if (userID != null) {
      await sharedPref.save("userid", userID);
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("username");
      await sharedPref.remove("userfullname");
      await sharedPref.remove("userimage");
      await sharedPref.remove("useremail");
      await sharedPref.remove("usermobile");
      await sharedPref.remove("userpremium");
      await sharedPref.remove("usertype");
      await sharedPref.remove("devicetype");
      await sharedPref.remove("devicetoken");
      await sharedPref.remove("useriskid");
    }
    Constant.userID = await sharedPref.read("userid");
    printLog('setUserId userID ==> ${Constant.userID}');
  }

  static setFirstTime(value) async {
    SharedPre sharedPref = SharedPre();
    await sharedPref.save("seen", value);
    String seenValue = await sharedPref.read("seen");
    printLog('setFirstTime seen ==> $seenValue');
  }

  static Future<String> getPrivacyTandCText(
      String privacyUrl, String termsConditionUrl) async {
    printLog('privacyUrl ==> $privacyUrl');
    printLog('T&C Url =====> $termsConditionUrl');

    String strPrivacyAndTNC =
        "<p style=color:white; > By continuing , I understand and agree with <a href=$privacyUrl>Privacy Policy</a> and <a href=$termsConditionUrl>Terms and Conditions</a> of ${Constant.appName}. </p>";

    printLog('strPrivacyAndTNC =====> $strPrivacyAndTNC');
    return strPrivacyAndTNC;
  }

  static Future<void> deleteCacheDir() async {
    if (Platform.isAndroid) {
      var tempDir = await getTemporaryDirectory();

      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    }
  }

  static BoxDecoration setGradientBGWithCenter(
      Color colorStart, Color colorCenter, Color colorEnd, double radius) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[colorStart, colorCenter, colorEnd],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradientBGTTB(
      Color colorStart, Color colorCenter, Color colorEnd, double radius) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[colorStart, colorCenter, colorEnd],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setBackground(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setBGWithBorder(
      Color color, Color borderColor, double radius, double border) {
    return BoxDecoration(
      color: color,
      border: Border.all(
        color: borderColor,
        width: border,
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradLTRBorderWithBG(Color colorStart, Color colorEnd,
      Color bgColor, double radius, double border) {
    return BoxDecoration(
      border: GradientBoxBorder(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[colorStart, colorEnd],
        ),
        width: border,
      ),
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradTTBBorderWithBG(Color colorTop, Color colorBottom,
      Color bgColor, double radius, double border) {
    return BoxDecoration(
      border: GradientBoxBorder(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[colorTop, colorBottom],
        ),
        width: border,
      ),
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradTTBBorderAndGradBG(
      Color colorTop, Color colorBottom, double radius, double border) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[colorTop, colorBottom],
      ),
      border: GradientBoxBorder(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[colorTop, colorBottom],
        ),
        width: border,
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradLTRBGWithBorder(Color colorStart, Color colorEnd,
      Color borderColor, double radius, double border) {
    return BoxDecoration(
      border: Border.all(
        color: borderColor,
        width: border,
      ),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[colorStart, colorEnd],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradTTBBGWithBorder(Color colorStart, Color colorEnd,
      Color borderColor, double radius, double border) {
    return BoxDecoration(
      border: Border.all(
        color: borderColor,
        width: border,
      ),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[colorStart, colorEnd],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradBGWithCenter(
      Color colorStart, Color colorCenter, Color colorEnd, double radius) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[colorStart, colorCenter, colorEnd],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradTTBBGWithCenter(
      Color colorTop, Color colorCenter, Color colorBottom, double radius) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[colorTop, colorCenter, colorBottom],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setGradTTBWithCenter(
      Color colorStart, Color colorCenter, Color colorEnd, double radius) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[colorStart, colorCenter, colorEnd],
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static Widget buildBackBtn(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      focusColor: gray.withOpacity(0.5),
      onTap: () {
        if (kIsWeb) {
          if (context.canPop()) {
            context.pop();
          }
        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: MyImage(
          height: 17,
          width: 17,
          imagePath: "back.png",
          fit: BoxFit.contain,
          color: white,
        ),
      ),
    );
  }

  static Widget buildCloseBtn(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      focusColor: gray.withOpacity(0.5),
      onTap: () {
        if (kIsWeb) {
          if (context.canPop()) {
            context.pop();
          }
        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5.0),
        child: SimpleShadow(
          color: colorPrimaryDark,
          sigma: 1,
          child: MyImage(
            height: 18,
            width: 18,
            imagePath: "ic_close.png",
            fit: BoxFit.contain,
            color: white,
          ),
        ),
      ),
    );
  }

  static Widget buildBackBtnDesign(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: MyImage(
        height: 17,
        width: 17,
        imagePath: "back.png",
        fit: BoxFit.contain,
        color: white,
      ),
    );
  }

  static AppBar myAppBar(
      BuildContext context, String appBarTitle, bool multilanguage) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: appBgColor,
      centerTitle: true,
      title: MyText(
        color: colorPrimary,
        text: appBarTitle,
        multilanguage: multilanguage,
        fontsizeNormal: 16,
        fontsizeWeb: 18,
        maxline: 1,
        overflow: TextOverflow.ellipsis,
        fontweight: FontWeight.bold,
        textalign: TextAlign.center,
        fontstyle: FontStyle.normal,
      ),
    );
  }

  static AppBar myAppBarWithBack(
      BuildContext context, String appBarTitle, bool multilanguage) {
    return AppBar(
      elevation: 5,
      backgroundColor: appBgColor,
      centerTitle: true,
      leading: IconButton(
        autofocus: true,
        focusColor: white.withOpacity(0.5),
        onPressed: () {
          if (kIsWeb) {
            if (context.canPop()) {
              context.pop();
            }
          } else {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
        },
        icon: MyImage(
          imagePath: "back.png",
          fit: BoxFit.contain,
          height: 17,
          width: 17,
          color: white,
        ),
      ),
      title: MyText(
        text: appBarTitle,
        multilanguage: multilanguage,
        fontsizeNormal: 16,
        fontsizeWeb: 18,
        fontstyle: FontStyle.normal,
        fontweight: FontWeight.bold,
        textalign: TextAlign.center,
        color: colorPrimary,
      ),
    );
  }

  static AppBar myAppBarWithOnlyActions(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: appBgColor,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          autofocus: true,
          focusColor: white.withOpacity(0.4),
          onPressed: () {
            if (kIsWeb) {
              if (context.canPop()) {
                context.pop();
              }
            } else {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          },
          icon: MyImage(
            imagePath: "ic_close.png",
            fit: BoxFit.contain,
            height: 17,
            width: 17,
            color: titleTextColor,
          ),
        ),
      ],
    );
  }

  static Widget pageLoader() {
    return const Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: colorPrimary,
        strokeWidth: 2.5,
      ),
    );
  }

  static void showSnackbar(BuildContext context, String showFor, String message,
      bool multilanguage) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.fixed,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: transparent,
      elevation: 0,
      padding: EdgeInsets.only(
        left: kIsWeb
            ? (Dimens.isBigScreen(context)
                ? (MediaQuery.of(context).size.width * 0.3)
                : 16)
            : 16,
        right: kIsWeb
            ? (Dimens.isBigScreen(context)
                ? (MediaQuery.of(context).size.width * 0.3)
                : 16)
            : 16,
        bottom: 16,
      ),
      content: Container(
        constraints: const BoxConstraints(minHeight: 60),
        alignment: Alignment.center,
        decoration: Utils.setBackground(
            showFor == "fail"
                ? failureBG
                : showFor == "warning"
                    ? warningBG
                    : showFor == "info"
                        ? infoBG
                        : showFor == "success"
                            ? successBG
                            : complimentryColor,
            4),
        padding: const EdgeInsets.all(15),
        child: MyText(
          text: message,
          multilanguage: multilanguage,
          fontstyle: FontStyle.normal,
          fontsizeNormal: 14,
          fontsizeWeb: 16,
          maxline: 5,
          overflow: TextOverflow.ellipsis,
          fontweight: FontWeight.w500,
          color: white,
          textalign: TextAlign.center,
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static late ProgressDialog? prDialog;
  static void showProgress(BuildContext context) async {
    printLog("===== SHOW PROGRESS =====");
    if (kIsWeb) {
      //For normal dialog
      prDialog = ProgressDialog(
        context,
        type: ProgressDialogType.normal,
        isDismissible: false,
        showLogs: false,
        customBody: Container(
          height: 60,
          width: MediaQuery.of(context).size.width > 400
              ? 300
              : MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: pageLoader(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MyText(
                  color: black,
                  multilanguage: false,
                  text: pleaseWait,
                  fontsizeNormal: 12,
                  fontweight: FontWeight.w700,
                  fontsizeWeb: 18,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.start,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      );
      prDialog?.style(
        borderRadius: 8,
        maxProgress: 100,
        backgroundColor: white,
        insetAnimCurve: Curves.easeInOut,
      );
    } else {
      //For normal dialog
      prDialog = ProgressDialog(context,
          type: ProgressDialogType.normal,
          isDismissible: false,
          showLogs: false);
      prDialog?.style(
        borderRadius: 5,
        message: pleaseWait,
        progressWidget: Container(
          padding: const EdgeInsets.all(8),
          child: const CircularProgressIndicator(),
        ),
        maxProgress: 100,
        progressTextStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: white,
        insetAnimCurve: Curves.easeInOut,
        messageTextStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    if (prDialog != null && !prDialog!.isShowing()) await prDialog?.show();
  }

  static void hideProgress() {
    printLog("===== HIDE PROGRESS =====");
    if (prDialog != null && prDialog!.isShowing()) {
      prDialog?.hide();
      prDialog = null;
    }
  }

  static String convertHalfStopToVLine(String strText) {
    return strText.replaceAll(',', ' |');
  }

  static String convertToColonText(int timeInMilli) {
    String convTime = "";

    try {
      if (timeInMilli > 0) {
        int seconds = ((timeInMilli / 1000) % 60).toInt();
        int minutes = ((timeInMilli / (1000 * 60)) % 60).toInt();
        int hours = ((timeInMilli / (1000 * 60 * 60)) % 24).toInt();

        if (hours >= 1) {
          if (minutes > 0 && seconds > 0) {
            convTime = "$hours : $minutes : $seconds hr";
          } else if (minutes > 0 && seconds == 0) {
            convTime = "$hours : $minutes : 00 hr";
          } else if (minutes == 0 && seconds > 0) {
            convTime = "$hours : 00 : $seconds hr";
          } else if (minutes == 0 && seconds == 0) {
            convTime = "$hours : 00 hr";
          }
        } else if (minutes > 0) {
          if (seconds > 0) {
            convTime = "$minutes : $seconds min";
          } else if (minutes > 0 && seconds == 0) {
            convTime = "$minutes : 00 min";
          }
        } else if (seconds > 0) {
          convTime = "00 : $seconds sec";
        }
      } else {
        convTime = "0";
      }
    } catch (e) {
      printLog("ConvTimeE Exception ==> $e");
    }
    return convTime;
  }

  static String convertTimeToText(int timeInMilli) {
    String convTime = "";

    try {
      if (timeInMilli > 0) {
        double seconds = ((timeInMilli / 1000) % 60);
        double minutes = ((timeInMilli / (1000 * 60)) % 60);
        double hours = ((timeInMilli / (1000 * 60 * 60)) % 24);

        if (hours >= 1) {
          if (minutes > 0 && seconds > 0) {
            convTime =
                "${hours.toInt()} hr ${minutes.toInt()} min ${seconds.toInt()} sec";
          } else if (minutes > 0 && seconds == 0) {
            convTime = "${hours.toInt()} hr ${minutes.toInt()} min";
          } else if (minutes == 0 && seconds > 0) {
            convTime = "${hours.toInt()} hr ${seconds.toInt()} sec";
          } else if (minutes == 0 && seconds == 0) {
            convTime = "${hours.toInt()} hr";
          }
        } else if (minutes > 0) {
          if (seconds > 0) {
            convTime = "${minutes.toInt()} min ${seconds.toInt()} sec";
          } else if (minutes > 0 && seconds == 0) {
            convTime = "${minutes.toInt()} min";
          }
        } else if (seconds > 0) {
          convTime = "${seconds.toInt()} sec";
        }
      } else {
        convTime = "0";
      }
    } catch (e) {
      printLog("ConvTimeE Exception ==> $e");
    }
    return convTime;
  }

  static String remainTimeInMin(int remainWatch) {
    String convTime = "";

    try {
      printLog("remainTimeInMin ==> ${(remainWatch / 1000)}");
      if (remainWatch > 0) {
        double seconds = ((remainWatch / 1000) % 60);
        double minutes = ((remainWatch / (1000 * 60)) % 60);
        double hours = ((remainWatch / (1000 * 60 * 60)) % 24);

        if (hours >= 1) {
          if (minutes > 0 && seconds > 0) {
            convTime =
                "${hours.toInt()} hr ${minutes.toInt()} min ${seconds.toInt()} sec";
          } else if (minutes > 0 && seconds == 0) {
            convTime = "${hours.toInt()} hr ${minutes.toInt()} min";
          } else if (minutes == 0 && seconds > 0) {
            convTime = "${hours.toInt()} hr ${seconds.toInt()} sec";
          } else if (minutes == 0 && seconds == 0) {
            convTime = "${hours.toInt()} hr";
          }
        } else if (minutes > 0) {
          if (seconds > 0) {
            convTime = "${minutes.toInt()} min ${seconds.toInt()} sec";
          } else if (minutes > 0 && seconds == 0) {
            convTime = "${minutes.toInt()} min";
          }
        } else if (seconds > 0) {
          convTime = "${seconds.toInt()} sec";
        }
      } else {
        convTime = "0";
      }
    } catch (e) {
      printLog("remainTimeInMin Exception ==> $e");
    }
    return convTime;
  }

  static String remainTimeInDays(String dateString) {
    String convTime = "";

    try {
      DateTime mExpireDate = DateTime.parse(dateString);
      DateTime mCurrentDate = DateTime.now();
      if (mExpireDate.isAfter(mCurrentDate)) {
        Duration difference;
        difference = mExpireDate.difference(mCurrentDate);
        printLog("difference =====> $difference");
        convTime = difference.inDays.toString();
      } else {
        convTime = "0";
      }
    } catch (e) {
      printLog("remainTimeInDays Exception ==> $e");
      convTime = "";
    }
    return convTime;
  }

  static String convertInMin(int remainWatch) {
    String convTime = "";

    try {
      if (remainWatch > 0) {
        double minutes = ((remainWatch / (1000 * 60)) % 60);
        double seconds = ((remainWatch / 1000) % 60);
        if (minutes >= 0 && minutes < 1) {
          convTime = "${seconds.toInt()} sec";
        } else if (minutes >= 1 && minutes < 10) {
          convTime = "0${minutes.toInt()} min";
        } else {
          convTime = "${minutes.toInt()} min";
        }
      } else {
        convTime = "00 min";
      }
    } catch (e) {
      printLog("convertInMin Exception ==> $e");
    }
    return convTime;
  }

  static String convertToStar(String mobileOREmail) {
    String finalSecureString = "";

    try {
      if (mobileOREmail.contains('+') && !mobileOREmail.contains(' ')) {
        finalSecureString = mobileOREmail.replaceRange(
            5, (mobileOREmail.length - 1), "********");
      } else if (mobileOREmail.contains('+') && mobileOREmail.contains(' ')) {
        finalSecureString = mobileOREmail.replaceRange(
            mobileOREmail.indexOf(" ") + 2,
            (mobileOREmail.length - 1),
            "********");
      } else if (mobileOREmail.contains('@')) {
        finalSecureString = mobileOREmail.replaceRange(
            1, mobileOREmail.indexOf("@") - 2, "********");
      } else {
        finalSecureString = mobileOREmail.replaceRange(1, 9, "********");
      }
    } catch (e) {
      printLog("convertToStar Exception ==> $e");
      finalSecureString = "-";
    }
    return finalSecureString;
  }

  static double getPercentage(int totalValue, int usedValue) {
    double percentage = 0.0;
    try {
      if (totalValue != 0) {
        percentage = ((usedValue / totalValue).clamp(0.0, 1.0) * 100);
      } else {
        percentage = 0.0;
      }
    } catch (e) {
      printLog("getPercentage Exception ==> $e");
      percentage = 0.0;
    }
    percentage = (percentage.round() / 100);
    return percentage;
  }

  //Convert Html to simple String
  static String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }

  static Future<String> getFileUrl(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/$fileName";
  }

  static Future<File?> saveImageInStorage(imgUrl) async {
    try {
      var response = await http.get(Uri.parse(imgUrl));
      Directory? documentDirectory;
      if (Platform.isAndroid) {
        documentDirectory = await getExternalStorageDirectory();
      } else {
        documentDirectory = await getApplicationDocumentsDirectory();
      }
      File file = File(path.join(documentDirectory?.path ?? "",
          '${DateTime.now().millisecondsSinceEpoch.toString()}.png'));
      file.writeAsBytesSync(response.bodyBytes);
      // This is a sync operation on a real
      // app you'd probably prefer to use writeAsByte and handle its Future
      return file;
    } catch (e) {
      printLog("saveImageInStorage Exception ===> $e");
      return null;
    }
  }

  static Html htmlTexts(var strText) {
    return Html(
      data: strText,
      style: {
        "body": Style(
          color: descTextColor,
          fontSize: FontSize(15),
          fontWeight: FontWeight.w500,
        ),
        "link": Style(
          color: colorPrimaryDark,
          fontSize: FontSize(15),
          fontWeight: FontWeight.w500,
        ),
      },
      onLinkTap: (url, _, ___) async {
        if (await canLaunchUrl(Uri.parse(url!))) {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.platformDefault,
          );
        } else {
          throw 'Could not launch $url';
        }
      },
      shrinkWrap: false,
    );
  }

  static Future<void> shareVideo(BuildContext context, String videoTitle) async {
    try {
      String shareMessage;
      String shareDesc =
          "Hey, I'm watching $videoTitle. Check it out now on ${Constant.appName}! and more.";

      if (Platform.isAndroid) {
        shareMessage = "$shareDesc\n${Constant.androidAppUrl}";
      } else {
        shareMessage = "$shareDesc\n${Constant.iosAppUrl}";
      }

      await Share.share(shareMessage);
    } catch (e) {
      print("shareFile Exception ===> $e");
    }
  }
  static Future<void> redirectToUrl(String url) async {
    printLog("_launchUrl url ===> $url");
    if (await canLaunchUrl(Uri.parse(url.toString()))) {
      await launchUrl(
        Uri.parse(url.toString()),
        mode: LaunchMode.platformDefault,
      );
    } else {
      throw "Could not launch $url";
    }
  }

  static Future<void> redirectToStore() async {
    final appId =
        Platform.isAndroid ? Constant.appPackageName : Constant.appleAppId;
    final url = Uri.parse(
      Platform.isAndroid
          ? "market://details?id=$appId"
          : "https://apps.apple.com/app/id$appId",
    );
    printLog("_launchUrl url ===> $url");
    if (await canLaunchUrl(Uri.parse(url.toString()))) {
      await launchUrl(
        Uri.parse(url.toString()),
        mode: LaunchMode.platformDefault,
      );
    } else {
      throw "Could not launch $url";
    }
  }

  static Future<void> shareApp(String shareMessage) async {
    try {
      await Share.share(shareMessage);
    } catch (e) {
      print("shareFile Exception ===> $e");
    }
  }

  /* ***************** generate Unique OrderID START ***************** */
  static String generateRandomOrderID() {
    int getRandomNumber;
    String? finalOID;
    printLog("fixFourDigit =>>> ${Constant.fixFourDigit}");
    printLog("fixSixDigit =>>> ${Constant.fixSixDigit}");

    number.Random r = number.Random();
    int ran5thDigit = r.nextInt(9);
    printLog("Random ran5thDigit =>>> $ran5thDigit");

    int randomNumber = number.Random().nextInt(9999999);
    printLog("Random randomNumber =>>> $randomNumber");
    if (randomNumber < 0) {
      randomNumber = -randomNumber;
    }
    getRandomNumber = randomNumber;
    printLog("getRandomNumber =>>> $getRandomNumber");

    finalOID = "${Constant.fixFourDigit.toInt()}"
        "$ran5thDigit"
        "${Constant.fixSixDigit.toInt()}"
        "$getRandomNumber";
    printLog("finalOID =>>> $finalOID");

    return finalOID;
  }
  /* ***************** generate Unique OrderID END ***************** */

  /* ***************** Download ***************** */
  static Future<bool> checkPermission() async {
    if (Platform.isIOS) {
      return true;
    }

    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status == PermissionStatus.granted) {
        return true;
      }

      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      // final result = await Permission.storage.request();
      printLog("result ========1========> ${statuses[Permission.storage]}");
      if (statuses[Permission.storage] != PermissionStatus.granted) {
        statuses = await [Permission.storage].request();
        printLog("result =======2=======> ${statuses[Permission.storage]}");
      }
      return (statuses[Permission.storage] == PermissionStatus.granted);
    }

    throw StateError('unknown platform');
  }

  static Future<String> prepareSaveDir() async {
    String localPath = (await _getSavedDir())!;
    printLog("localPath ------------> $localPath");
    final savedDir = Directory(localPath);
    printLog("savedDir -------------> $savedDir");
    printLog("is exists ? ----------> ${savedDir.existsSync()}");
    if (!(await savedDir.exists())) {
      await savedDir.create(recursive: true);
    }
    return localPath;
  }

  static Future<String?> _getSavedDir() async {
    String? externalStorageDirPath;

    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      try {
        externalStorageDirPath = "${directory?.absolute.path}/downloads/";
      } catch (err, st) {
        printLog('failed to get downloads path: $err, $st');
        externalStorageDirPath = "${directory?.absolute.path}/downloads/";
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    printLog("externalStorageDirPath ------------> $externalStorageDirPath");
    return externalStorageDirPath;
  }

  static Future<String> prepareShowSaveDir(
      String showName, String seasonName) async {
    printLog("showName -------------> $showName");
    printLog("seasonName -------------> $seasonName");
    String localPath = (await _getShowSavedDir(showName, seasonName))!;
    final savedDir = Directory(localPath);
    printLog("savedDir -------------> $savedDir");
    printLog("savedDir path --------> ${savedDir.path}");
    if (!savedDir.existsSync()) {
      await savedDir.create(recursive: true);
    }
    return localPath;
  }

  static Future<String?> _getShowSavedDir(
      String showName, String seasonName) async {
    String? externalStorageDirPath;

    if (Platform.isAndroid) {
      try {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath =
            "${directory?.path}/downloads/${showName.toLowerCase()}/${seasonName.toLowerCase()}";
      } catch (err, st) {
        printLog('failed to get downloads path: $err, $st');
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath =
            "${directory?.path}/downloads/${showName.toLowerCase()}/${seasonName.toLowerCase()}";
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          "${(await getApplicationDocumentsDirectory()).absolute.path}/downloads/${showName.toLowerCase()}/${seasonName.toLowerCase()}";
    }
    return externalStorageDirPath;
  }

  static Future<void> initializeHiveBoxes() async {
    printLog("initializeHiveBoxes userId =====> ${Constant.userID}");
    printLog("initializeHiveBoxes userIsKid ==> ${Constant.userIsKid}");
    if (kIsWeb) return;
    if (Constant.userID == null) {
      await Hive.deleteBoxFromDisk(Constant.hiveDownloadBox);
      await Hive.deleteBoxFromDisk(Constant.hiveSeasonDownloadBox);
      await Hive.deleteBoxFromDisk(Constant.hiveEpiDownloadBox);
    }

    printLog("hiveDownloadBox =========> ${Constant.hiveDownloadBox}");
    printLog("hiveSeasonDownloadBox ===> ${Constant.hiveSeasonDownloadBox}");
    printLog("hiveEpiDownloadBox ======> ${Constant.hiveEpiDownloadBox}");
    if (Constant.userID != null) {
      if (Constant.userIsKid == true) {
        bool? isDownloadBoxExists = await Hive.boxExists(
            '${Constant.hiveDownloadBox}_${Constant.userID}_KID');
        bool? isSeasonBoxExists = await Hive.boxExists(
            '${Constant.hiveSeasonDownloadBox}_${Constant.userID}_KID');
        bool? isEpisodeBoxExists = await Hive.boxExists(
            '${Constant.hiveEpiDownloadBox}_${Constant.userID}_KID');

        printLog("isDownloadBoxExists ===KID===> $isDownloadBoxExists");
        printLog("isSeasonBoxExists ====KID====> $isSeasonBoxExists");
        printLog("isEpisodeBoxExists ====KID===> $isEpisodeBoxExists");
        await Hive.openBox<DownloadItem>(
            '${Constant.hiveDownloadBox}_${Constant.userID}_KID');
        await Hive.openBox<SessionItem>(
            '${Constant.hiveSeasonDownloadBox}_${Constant.userID}_KID');
        await Hive.openBox<EpisodeItem>(
            '${Constant.hiveEpiDownloadBox}_${Constant.userID}_KID');
      } else {
        bool? isDownloadBoxExists = await Hive.boxExists(
            '${Constant.hiveDownloadBox}_${Constant.userID}');
        bool? isSeasonBoxExists = await Hive.boxExists(
            '${Constant.hiveSeasonDownloadBox}_${Constant.userID}');
        bool? isEpisodeBoxExists = await Hive.boxExists(
            '${Constant.hiveEpiDownloadBox}_${Constant.userID}');

        printLog("isDownloadBoxExists ========> $isDownloadBoxExists");
        printLog("isSeasonBoxExists ==========> $isSeasonBoxExists");
        printLog("isEpisodeBoxExists =========> $isEpisodeBoxExists");
        await Hive.openBox<DownloadItem>(
            '${Constant.hiveDownloadBox}_${Constant.userID}');
        await Hive.openBox<SessionItem>(
            '${Constant.hiveSeasonDownloadBox}_${Constant.userID}');
        await Hive.openBox<EpisodeItem>(
            '${Constant.hiveEpiDownloadBox}_${Constant.userID}');
      }
    } else {
      await Hive.openBox<DownloadItem>(Constant.hiveDownloadBox);
      await Hive.openBox<SessionItem>(Constant.hiveSeasonDownloadBox);
      await Hive.openBox<EpisodeItem>(Constant.hiveEpiDownloadBox);
    }
  }

  static String generateRandomKey(int len) {
    final random = Random.secure();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  static Future<void> encryptFile(List<dynamic> args) async {
    final JSHelper jsHelper = JSHelper();
    File inFile = args[0] as File;
    File outFile = args[0] as File;
    String generateKey = args[1] as String;
    final sendPort = args[2] as SendPort;
    if (!kIsWeb && !Platform.isLinux) {
      final rootToken = args[3] as RootIsolateToken;
      jsHelper.callIsolate(rootToken);
    }

    bool outFileExists = await outFile.exists();

    if (!outFileExists) {
      await outFile.create();
    }

    final videoFileContents = inFile.readAsStringSync(encoding: latin1);

    final key = excrypt.Key.fromUtf8(generateKey);
    final iv = excrypt.IV.fromLength(16);

    final encrypter =
        excrypt.Encrypter(excrypt.AES(key, mode: excrypt.AESMode.ecb));

    final encrypted = encrypter.encrypt(videoFileContents, iv: iv);
    await outFile.writeAsBytes(encrypted.bytes);
    sendPort.send(outFile);
  }

  static Future<dynamic> decryptFile(List<dynamic> args) async {
    final JSHelper jsHelper = JSHelper();
    File inFile = args[0] as File;
    String generateKey = args[1] as String;
    final sendPort = args[2] as SendPort;
    if (!kIsWeb && !Platform.isLinux) {
      final rootToken = args[3] as RootIsolateToken;
      jsHelper.callIsolate(rootToken);
    }

    final tempDir = await getTemporaryDirectory();
    final decryptedFile = File('${tempDir.path}/${path.basename(inFile.path)}');
    bool outFileExists = await decryptedFile.exists();

    if (!outFileExists) {
      await decryptedFile.create();
    }

    final videoFileContents = inFile.readAsBytesSync();

    final key = excrypt.Key.fromUtf8(generateKey);
    final iv = excrypt.IV.fromLength(16);

    final encrypter =
        excrypt.Encrypter(excrypt.AES(key, mode: excrypt.AESMode.ecb));

    final encryptedFile = excrypt.Encrypted(videoFileContents);
    final decrypted = encrypter.decrypt(encryptedFile, iv: iv);

    final decryptedBytes = latin1.encode(decrypted);
    await decryptedFile.writeAsBytes(decryptedBytes);
    printLog("decryptedFile ====> $decryptedFile");
    sendPort.send(decryptedFile);
  }

  /* ***************** Download ***************** */
}
