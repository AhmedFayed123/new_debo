
import 'package:debo/routes/routes_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';


import '../main.dart';
import '../model/playermodel.dart';
import '../pages/aboutprivacyterms.dart';
import '../pages/activetv.dart';
import '../pages/contentbyid.dart';
import '../pages/contentshowdetails.dart';
import '../pages/contentvideodetails.dart';
import '../pages/find.dart';
import '../pages/myspace.dart';
import '../pages/mywatchlist.dart';
import '../pages/profile.dart';
import '../pages/profileavatar.dart';
import '../pages/profileedit.dart';
import '../pages/rentstore.dart';
import '../pages/sectionviewall.dart';
import '../pages/settings.dart';
import '../pages/splash.dart';
import '../pages/viewall.dart';
import '../players/DropBoxNormalPlayer.dart';
import '../players/player_video.dart';
import '../players/player_vimeo.dart';
import '../players/player_youtube.dart';
import '../subscription/allpayment.dart';
import '../subscription/mypurchaselist.dart';
import '../subscription/subscription.dart';
import '../subscription/subscriptionhistory.dart';
import '../utils/constant.dart';
import '../utils/utils.dart';
import '../webpages/webaboutprivacyterms.dart';
import '../webpages/webcontentbyid.dart';
import '../webpages/webcontentshowdetails.dart';
import '../webpages/webcontentvideodetails.dart';
import '../webpages/weberrorpage.dart';
import '../webpages/webhome.dart';
import '../webpages/webmyspace.dart';
import '../webpages/webmywatchlist.dart';
import '../webpages/webprofile.dart';
import '../webpages/webprofileavatar.dart';
import '../webpages/webprofileedit.dart';
import '../webpages/webrentstore.dart';
import '../webpages/websearch.dart';
import '../webpages/websectionviewall.dart';
import '../webpages/websettings.dart';
import '../webpages/webviewall.dart';

class RoutesConfig {
  GoRouter goRouter = GoRouter(
    initialLocation: '/',
    navigatorKey: navigatorKey,
    observers: [routeObserver], //HERE
    routes: [
      /* Initial route by Platform */
      GoRoute(
        name: RoutesConstant.homePage,
        path: '/',
        builder: (context, state) {
          if (kIsWeb || Constant.isTV) {
            return const WebHome(
              newPage: RoutesConstant.homePage,
              oldPage: RoutesConstant.homePage,
              reqText: '',
            );
          }
          return const Splash();
        },
      ),

      /* Search */
      GoRoute(
        name: RoutesConstant.searchPage,
        path: '/${RoutesConstant.searchPage}',
        builder: (context, state) {
          String newPage = "";
          if (state.extra != null && state.extra is String) {
            newPage = state.extra as String;

            if (kIsWeb || Constant.isTV) {
              return WebSearch(
                newPage: RoutesConstant.searchPage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return const Find();
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Rent */
      GoRoute(
        name: RoutesConstant.storePage,
        path: '/${RoutesConstant.storePage}',
        builder: (context, state) {
          String newPage = "";
          if (state.extra != null) {
            newPage = state.extra as String;

            printLog("newPage =====> $newPage");
            if (kIsWeb || Constant.isTV) {
              return WebRentStore(
                newPage: RoutesConstant.storePage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return const RentStore();
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Watchlist */
      GoRoute(
        name: RoutesConstant.myWatchlistPage,
        path: '/${RoutesConstant.myWatchlistPage}',
        builder: (context, state) {
          String newPage = "";
          if (state.extra != null) {
            newPage = state.extra as String;

            printLog("newPage =====> $newPage");
            if (kIsWeb || Constant.isTV) {
              return WebMyWatchlist(
                newPage: RoutesConstant.myWatchlistPage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return const MyWatchlist();
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Video Details */
      GoRoute(
        name: RoutesConstant.videoDetailsPage,
        path: '/${RoutesConstant.videoDetailsPage}',
        builder: (context, state) {
          String newPage = "";
          Map<String, dynamic> extraData = {};
          String? videoId, videoType, subVideoType, typeId;
          if (state.extra != null && state.extra is Map<String, dynamic>) {
            extraData = state.extra as Map<String, dynamic>;
            newPage = extraData['newpage'] as String;
            videoId = extraData['videoid'] as String;
            videoType = extraData['videotype'] as String;
            subVideoType = extraData['subvideotype'] as String;
            typeId = extraData['typeid'] as String;

            printLog("newPage =====> $newPage");
            if (kIsWeb || Constant.isTV) {
              return WebContentVideoDetails(
                int.parse(videoId),
                int.parse(subVideoType),
                int.parse(videoType),
                int.parse(typeId),
                newPage: RoutesConstant.videoDetailsPage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return ContentVideoDetails(
              int.parse(videoId),
              int.parse(subVideoType),
              int.parse(videoType),
              int.parse(typeId),
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Show Details */
      GoRoute(
        name: RoutesConstant.showDetailsPage,
        path: '/${RoutesConstant.showDetailsPage}',
        builder: (context, state) {
          String newPage = "";
          Map<String, dynamic> extraData = {};
          String? videoId, videoType, subVideoType, typeId;
          if (state.extra != null && state.extra is Map<String, dynamic>) {
            extraData = state.extra as Map<String, dynamic>;
            newPage = extraData['newpage'] as String;
            videoId = extraData['videoid'] as String;
            videoType = extraData['videotype'] as String;
            subVideoType = extraData['subvideotype'] as String;
            typeId = extraData['typeid'] as String;

            printLog("newPage =====> $newPage");
            if (kIsWeb || Constant.isTV) {
              return WebContentShowDetails(
                int.parse(videoId),
                int.parse(subVideoType),
                int.parse(videoType),
                int.parse(typeId),
                newPage: RoutesConstant.showDetailsPage,
                oldPage: newPage,
                reqText: '',
              );
            }
            // return SizedBox();

            return ContentShowDetails(
              int.parse(videoId),
              int.parse(subVideoType),
              int.parse(videoType),
              int.parse(typeId),
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Players */
      GoRoute(
        name: RoutesConstant.playerPage,
        path: '/${RoutesConstant.playerPage}',
        builder: (context, state) {
          String newPage = "";
          PlayerModel playerModel;
          if (state.extra != null && state.extra is PlayerModel) {
            playerModel = state.extra as PlayerModel;
            printLog("newPage =====> $newPage");
            if (playerModel.uploadType == "youtube") {
              return PlayerYoutube(playerModel: playerModel);
            } else if (playerModel.uploadType == "external") {
              if ((playerModel.videoUrl ?? "").contains('youtube')) {
                return PlayerYoutube(playerModel: playerModel);
              } else {
                //todo the player
                print("videoUrl ${playerModel.videoUrl!}");
               return DropBoxNormalPlayer(url: playerModel.videoUrl!,) ;
                //return PlayerVideo(playerModel: playerModel);
              }
            } else if (playerModel.uploadType == "vimeo") {
              return PlayerVimeo(playerModel: playerModel);
            } else {
              return PlayerVimeo(playerModel: playerModel);

              // return PlayerVideo(playerModel: playerModel);
            }
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Section ViewAll */
      GoRoute(
        name: RoutesConstant.sectionDetailsPage,
        path: '/${RoutesConstant.sectionDetailsPage}',
        builder: (context, state) {
          String newPage = "";
          Map<String, dynamic> extraData = {};
          String? itemID, videoType, appBarTitle;
          if (state.extra != null && state.extra is Map<String, dynamic>) {
            extraData = state.extra as Map<String, dynamic>;
            newPage = extraData['newpage'] as String;
            itemID = extraData['itemid'] as String;
            videoType = extraData['videotype'] as String;
            appBarTitle = extraData['title'] as String;

            printLog("newPage =====> $newPage");
            printLog("videoType ===> $videoType");
            if (kIsWeb || Constant.isTV) {
              return WebSectionViewAll(
                sectionId: int.parse(itemID),
                videoType: int.parse(videoType),
                appBarTitle: appBarTitle,
                newPage: RoutesConstant.sectionDetailsPage,
                oldPage: newPage,
                reqText: itemID,
              );
            }
            return SectionViewAll(
              appBarTitle: appBarTitle,
              sectionId: int.parse(itemID),
              videoType: int.parse(videoType),
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Video By Category */
      GoRoute(
        name: RoutesConstant.videoByCatPage,
        path: '/${RoutesConstant.videoByCatPage}',
        builder: (context, state) {
          String newPage = "";
          Map<String, dynamic> extraData = {};
          String? itemID, appBarTitle, layoutType;
          if (state.extra != null && state.extra is Map<String, dynamic>) {
            extraData = state.extra as Map<String, dynamic>;
            newPage = extraData['newpage'] as String;
            itemID = extraData['itemid'] as String;
            appBarTitle = extraData['title'] as String;
            layoutType = extraData['layouttype'] as String;

            printLog("newPage =====> $newPage");
            if (kIsWeb || Constant.isTV) {
              return WebVideosByID(
                int.parse(itemID),
                appBarTitle,
                layoutType,
                newPage: RoutesConstant.videoByCatPage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return ContentByID(
              int.parse(itemID),
              appBarTitle,
              layoutType,
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Video By Language */
      GoRoute(
        name: RoutesConstant.videoByLanguagePage,
        path: '/${RoutesConstant.videoByLanguagePage}',
        builder: (context, state) {
          String newPage = "";
          Map<String, dynamic> extraData = {};
          String? itemID, appBarTitle, layoutType;
          if (state.extra != null && state.extra is Map<String, dynamic>) {
            extraData = state.extra as Map<String, dynamic>;
            newPage = extraData['newpage'] as String;
            itemID = extraData['itemid'] as String;
            appBarTitle = extraData['title'] as String;
            layoutType = extraData['layouttype'] as String;

            printLog("newPage =====> $newPage");
            if (kIsWeb || Constant.isTV) {
              return WebVideosByID(
                int.parse(itemID),
                appBarTitle,
                layoutType,
                newPage: RoutesConstant.videoByLanguagePage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return ContentByID(
              int.parse(itemID),
              appBarTitle,
              layoutType,
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Video By Channel */
      GoRoute(
        name: RoutesConstant.videoByChannelPage,
        path: '/${RoutesConstant.videoByChannelPage}',
        builder: (context, state) {
          String newPage = "";
          Map<String, dynamic> extraData = {};
          String? itemID, appBarTitle, layoutType;
          if (state.extra != null && state.extra is Map<String, dynamic>) {
            extraData = state.extra as Map<String, dynamic>;
            newPage = extraData['newpage'] as String;
            itemID = extraData['itemid'] as String;
            appBarTitle = extraData['title'] as String;
            layoutType = extraData['layouttype'] as String;

            printLog("newPage =====> $newPage");
            if (kIsWeb || Constant.isTV) {
              return WebVideosByID(
                int.parse(itemID),
                appBarTitle,
                layoutType,
                newPage: RoutesConstant.videoByChannelPage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return ContentByID(
              int.parse(itemID),
              appBarTitle,
              layoutType,
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Video By Cast */
      GoRoute(
        name: RoutesConstant.videoByCastPage,
        path: '/${RoutesConstant.videoByCastPage}',
        builder: (context, state) {
          String newPage = "";
          Map<String, dynamic> extraData = {};
          String? itemID, appBarTitle, layoutType;
          if (state.extra != null && state.extra is Map<String, dynamic>) {
            extraData = state.extra as Map<String, dynamic>;
            newPage = extraData['newpage'] as String;
            itemID = extraData['itemid'] as String;
            appBarTitle = extraData['title'] as String;
            layoutType = extraData['layouttype'] as String;

            printLog("newPage =====> $newPage");
            if (kIsWeb || Constant.isTV) {
              return WebVideosByID(
                int.parse(itemID),
                appBarTitle,
                layoutType,
                newPage: RoutesConstant.videoByCastPage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return ContentByID(
              int.parse(itemID),
              appBarTitle,
              layoutType,
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Related Content (ViewAll) */
      GoRoute(
        name: RoutesConstant.relatedContentPage,
        path: '/${RoutesConstant.relatedContentPage}',
        builder: (context, state) {
          String newPage = "";
          Map<String, dynamic> extraData = {};
          String? itemID, appBarTitle, videoType, subVideoType, typeId;
          if (state.extra != null && state.extra is Map<String, dynamic>) {
            extraData = state.extra as Map<String, dynamic>;
            newPage = extraData['newpage'] as String;
            itemID = extraData['itemid'] as String;
            appBarTitle = extraData['title'] as String;
            subVideoType = extraData['subvideotype'] as String;
            videoType = extraData['videotype'] as String;
            typeId = extraData['typeid'] as String;

            printLog("newPage =====> $newPage");
            if (kIsWeb || Constant.isTV) {
              return WebViewAll(
                appBarTitle: appBarTitle,
                videoId: int.parse(itemID),
                subVideoType: int.parse(subVideoType),
                videoType: int.parse(videoType),
                typeId: int.parse(typeId),
                newPage: RoutesConstant.relatedContentPage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return ViewAll(
              appBarTitle: appBarTitle,
              videoId: int.parse(itemID),
              subVideoType: int.parse(subVideoType),
              videoType: int.parse(videoType),
              typeId: int.parse(typeId),
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Continue Watching (ViewAll) */
      GoRoute(
        name: RoutesConstant.continueWatchPage,
        path: '/${RoutesConstant.continueWatchPage}',
        builder: (context, state) {
          String newPage = "";
          Map<String, dynamic> extraData = {};
          String? appBarTitle;
          if (state.extra != null && state.extra is Map<String, dynamic>) {
            extraData = state.extra as Map<String, dynamic>;
            newPage = extraData['newpage'] as String;
            appBarTitle = extraData['title'] as String;

            printLog("newPage =====> $newPage");
            if (kIsWeb || Constant.isTV) {
              return WebViewAll(
                appBarTitle: appBarTitle,
                videoId: 0,
                subVideoType: 0,
                videoType: 0,
                typeId: 0,
                newPage: RoutesConstant.continueWatchPage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return ViewAll(
              appBarTitle: appBarTitle,
              videoId: 0,
              subVideoType: 0,
              videoType: 0,
              typeId: 0,
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* About Us, Privacy Policy & etc. */
      GoRoute(
        name: RoutesConstant.aboutPrivacyTermsPage,
        path: '/${RoutesConstant.aboutPrivacyTermsPage}',
        builder: (context, state) {
          String newPage = "";
          Map<String, dynamic> extraData = {};
          String? appBarTitle, url;
          if (state.extra != null && state.extra is Map<String, dynamic>) {
            extraData = state.extra as Map<String, dynamic>;
            newPage = extraData['newpage'] as String;
            appBarTitle = extraData['title'] as String;
            url = extraData['url'] as String;

            printLog("newPage =====> $newPage");
            if (kIsWeb || Constant.isTV) {
              return WebAboutPrivacyTerms(
                newPage: RoutesConstant.aboutPrivacyTermsPage,
                oldPage: newPage,
                reqText: '',
                appBarTitle: appBarTitle,
                loadURL: url,
              );
            }
            return AboutPrivacyTerms(
              appBarTitle: appBarTitle,
              loadURL: url,
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Login */
      // GoRoute(
      //   name: RoutesConstant.loginSocialPage,
      //   path: '/${RoutesConstant.loginSocialPage}',
      //   builder: (context, state) {
      //     String newPage = "";
      //     if (state.extra != null && state.extra is String) {
      //       newPage = state.extra as String;
      //       printLog("newPage =====> $newPage");
      //       if (kIsWeb || Constant.isTV) {
      //         return WebLoginSocial(
      //           newPage: RoutesConstant.loginSocialPage,
      //           oldPage: newPage,
      //           reqText: '',
      //         );
      //       }
      //       return const LoginSocial();
      //     } else {
      //       return WebErrorPage(state.error!);
      //     }
      //   },
      // ),

      /* Login OTP */
      // GoRoute(
      //   name: RoutesConstant.loginOTPPage,
      //   path: '/${RoutesConstant.loginOTPPage}',
      //   builder: (context, state) {
      //     String newPage = "", mobileNumber = "";
      //     Map<String, dynamic> extraData = {};
      //     if (state.extra != null && state.extra is Map<String, dynamic>) {
      //       extraData = state.extra as Map<String, dynamic>;
      //       newPage = extraData['newpage'] as String;
      //       mobileNumber = extraData['mobile'] as String;
      //       printLog("newPage =======> $newPage");
      //       printLog("mobileNumber ==> $mobileNumber");
      //       if (kIsWeb || Constant.isTV) {
      //         return WebOTPVerify(
      //           mobileNumber,
      //           newPage: RoutesConstant.loginOTPPage,
      //           oldPage: newPage,
      //           reqText: '',
      //         );
      //       }
      //       return OTPVerify(mobileNumber);
      //     } else {
      //       return WebErrorPage(state.error!);
      //     }
      //   },
      // ),

      /* Avatar */
      GoRoute(
        name: RoutesConstant.avatarPage,
        path: '/${RoutesConstant.avatarPage}',
        builder: (context, state) {
          String newPage = "";
          if (state.extra != null && state.extra is String) {
            newPage = state.extra as String;
            printLog("newPage =======> $newPage");

            if (kIsWeb || Constant.isTV) {
              return WebProfileAvatar(
                newPage: RoutesConstant.avatarPage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return const ProfileAvatar();
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Profile */
      GoRoute(
        name: RoutesConstant.myProfilePage,
        path: '/${RoutesConstant.myProfilePage}',
        builder: (context, state) {
          String newPage = "";
          if (state.extra != null && state.extra is String) {
            newPage = state.extra as String;
            printLog("newPage =======> $newPage");

            if (kIsWeb || Constant.isTV) {
              return WebProfile(
                newPage: RoutesConstant.myProfilePage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return const Profile();
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* My Sapce */
      GoRoute(
        name: RoutesConstant.mySpacePage,
        path: '/${RoutesConstant.mySpacePage}',
        builder: (context, state) {
          String newPage = "";
          if (state.extra != null && state.extra is String) {
            newPage = state.extra as String;
            printLog("newPage =======> $newPage");

            if (kIsWeb || Constant.isTV) {
              return WebMySpace(
                newPage: RoutesConstant.mySpacePage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return const MySpace();
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Settings */
      GoRoute(
        name: RoutesConstant.settingsPage,
        path: '/${RoutesConstant.settingsPage}',
        builder: (context, state) {
          String newPage = "";
          if (state.extra != null && state.extra is String) {
            newPage = state.extra as String;
            printLog("newPage =======> $newPage");

            if (kIsWeb || Constant.isTV) {
              return WebSettings(
                newPage: RoutesConstant.settingsPage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return const Settings();
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Edit Profile */
      GoRoute(
        name: RoutesConstant.editProfilePage,
        path: '/${RoutesConstant.editProfilePage}',
        builder: (context, state) {
          String newPage = "";
          if (state.extra != null && state.extra is String) {
            newPage = state.extra as String;
            printLog("newPage =======> $newPage");

            if (kIsWeb || Constant.isTV) {
              return WebProfileEdit(
                newPage: RoutesConstant.editProfilePage,
                oldPage: newPage,
                reqText: '',
              );
            }
            return const ProfileEdit();
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Active TV */
      GoRoute(
        name: RoutesConstant.activeTVPage,
        path: '/${RoutesConstant.activeTVPage}',
        builder: (context, state) {
          String newPage = "";
          if (state.extra != null && state.extra is String) {
            newPage = state.extra as String;
            printLog("newPage =======> $newPage");
            return ActiveTV(
              newPage: RoutesConstant.activeTVPage,
              oldPage: newPage,
              reqText: '',
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Subscription */
      GoRoute(
        name: RoutesConstant.subscriptionPage,
        path: '/${RoutesConstant.subscriptionPage}',
        builder: (context, state) {
          String newPage = "";
          if (state.extra != null && state.extra is String) {
            newPage = state.extra as String;
            printLog("newPage =======> $newPage");

            return Subscription(
              newPage: RoutesConstant.subscriptionPage,
              oldPage: newPage,
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* All Payments Page */
      GoRoute(
        name: RoutesConstant.paymentPage,
        path: '/${RoutesConstant.paymentPage}',
        builder: (context, state) {
          String newPage = "";
          Map<String, dynamic> extraData = {};
          final String? payType,
              itemId,
              price,
              itemTitle,
              typeId,
              videoType,
              productPackage,
              currency;
          if (state.extra != null && state.extra is Map<String, dynamic>) {
            extraData = state.extra as Map<String, dynamic>;
            newPage = extraData['newpage'] as String;
            itemId = extraData['itemid'] as String;
            payType = extraData['paytype'] as String;
            price = extraData['price'] as String;
            itemTitle = extraData['title'] as String;
            typeId = extraData['typeid'] as String;
            videoType = extraData['videotype'] as String;
            productPackage = extraData['productpackage'] as String;
            currency = extraData['currency'] as String;

            printLog("newPage =====> $newPage");
            return AllPayment(
              newPage: RoutesConstant.paymentPage,
              oldPage: newPage,
              reqText: '',
              payType: payType,
              itemId: itemId,
              price: price,
              itemTitle: itemTitle,
              typeId: typeId,
              videoType: videoType,
              productPackage: productPackage,
              currency: currency,
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Subscription History */
      GoRoute(
        name: RoutesConstant.subsHistoryPage,
        path: '/${RoutesConstant.subsHistoryPage}',
        builder: (context, state) {
          String newPage = "";
          if (state.extra != null && state.extra is String) {
            newPage = state.extra as String;
            printLog("newPage =======> $newPage");
            return SubscriptionHistory(
              newPage: RoutesConstant.subsHistoryPage,
              oldPage: newPage,
              reqText: '',
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Rent Purchases */
      GoRoute(
        name: RoutesConstant.rentPurchasePage,
        path: '/${RoutesConstant.rentPurchasePage}',
        builder: (context, state) {
          String newPage = "";
          if (state.extra != null && state.extra is String) {
            newPage = state.extra as String;
            printLog("newPage =======> $newPage");
            return MyPurchaselist(
              newPage: RoutesConstant.rentPurchasePage,
              oldPage: newPage,
              reqText: '',
            );
          } else {
            return WebErrorPage(state.error!);
          }
        },
      ),

      /* Payment Success */
      GoRoute(
        name: RoutesConstant.paymentSuccessPage,
        path: '/${RoutesConstant.paymentSuccessPage}',
        builder: (context, state) {
          return const SuccessPage();
        },
      ),

      /* Payment Cancel */
      GoRoute(
        name: RoutesConstant.paymentCancelPage,
        path: '/${RoutesConstant.paymentCancelPage}',
        builder: (context, state) {
          return const CancelPage();
        },
      ),
    ],
    errorBuilder: (context, state) {
      return WebErrorPage(state.error!);
    },
  );
}
