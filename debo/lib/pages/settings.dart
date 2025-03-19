import 'dart:io';


import 'package:debo/pages/profileedit.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../provider/generalprovider.dart';
import '../provider/profileprovider.dart';
import '../provider/sectiondataprovider.dart';
import '../provider/watchlistprovider.dart';
import '../routes/routes_constant.dart';
import '../subscription/mypurchaselist.dart';
import '../subscription/subscription.dart';
import '../subscription/subscriptionhistory.dart';
import '../utils/adhelper.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/sharedpre.dart';
import '../utils/strings.dart';
import '../utils/utils.dart';
import '../widget/myimage.dart';
import '../widget/mytext.dart';
import 'aboutprivacyterms.dart';
import 'activetv.dart';
import 'mywatchlist.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> with RouteAware {
  late ProfileProvider profileProvider;
  late GeneralProvider generalProvider;
  SharedPre sharedPref = SharedPre();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final pinPutController = TextEditingController();

  bool? isSwitched;
  bool isParentLocked = false;
  String? userName,
      userFullname,
      userType,
      userMobileNo,
      userDeviceType,
      userDeviceToken;
  String? activeTvStatus,
      parentControlStatus,
      watchlistStatus,
      subscriptionStatus;

  toggleSwitch(bool value) async {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
    } else {
      setState(() {
        isSwitched = false;
      });
    }
    printLog('toggleSwitch isSwitched ==> $isSwitched');
    if (!kIsWeb) {
      if ((isSwitched ?? false)) {
        OneSignal.User.pushSubscription.optIn();
      } else {
        OneSignal.User.pushSubscription.optOut();
      }
      await sharedPref.saveBool("PUSH", isSwitched);
    }
  }

  toggleParentLock(bool value) async {
    if (isParentLocked == false) {
      isParentLocked = true;
    } else {
      isParentLocked = false;
    }
    printLog('toggleParentLock isParentLocked ==> $isParentLocked');
    await Utils.setParentLock(isParentLocked);
    await profileProvider.notifyProvider();
  }

  @override
  void didPopNext() {
    printLog("didPopNext");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    super.didPopNext();
  }

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    super.initState();
  }

  _getData() async {
    if (!mounted) return;
    profileProvider.getProfile(context);
    userName = await sharedPref.read("username");
    userFullname = await sharedPref.read("userfullname");
    userType = await sharedPref.read("usertype");
    userMobileNo = await sharedPref.read("usermobile");
    userDeviceType = await sharedPref.read("devicetype");
    userDeviceToken = await sharedPref.read("devicetoken");
    printLog('_getData userName ========> $userName');
    printLog('_getData userFullname ====> $userFullname');
    printLog('_getData userType ========> $userType');
    printLog('_getData userMobileNo ====> $userMobileNo');
    printLog('_getData userDeviceType ==> $userDeviceType');
    printLog('_getData userDeviceToken => $userDeviceToken');

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    generalProvider.getPages();

    isSwitched = await sharedPref.readBool("PUSH");
    printLog('_getData isSwitched ==> $isSwitched');
    isParentLocked = await Utils.checkParentLock();
    printLog('_getData isParentLocked =======> $isParentLocked');

    /* Show/Hide by Admin Status =========== */
    activeTvStatus =
        await Utils.configByStatus(status: Constant.activeTvStatus);
    printLog('_getData activeTvStatus =======> $activeTvStatus');
    parentControlStatus =
        await Utils.configByStatus(status: Constant.parentControlStatus);
    printLog('_getData parentControlStatus ==> $parentControlStatus');
    watchlistStatus =
        await Utils.configByStatus(status: Constant.watchlistStatus);
    printLog('_getData watchlistStatus ======> $watchlistStatus');
    subscriptionStatus =
        await Utils.configByStatus(status: Constant.subscriptionStatus);
    printLog('_getData subscriptionStatus ===> $subscriptionStatus');
    /* =========== Show/Hide by Admin Status */

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    pinPutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      resizeToAvoidBottomInset: true,
      appBar: Utils.myAppBarWithBack(context, "setting", true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(22),
            child: Column(
              children: [
                /* Account Details */
                _buildSettingButton(
                  title: 'accountdetails',
                  subTitle: 'manageprofile',
                  titleMultilang: true,
                  subTitleMultilang: true,
                  iconColor: transparent,
                  iconName: '',
                  isEndIcon: false,
                  onClick: () {
                    AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                        () async {
                      if (Constant.userID != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfileEdit(),
                          ),
                        );
                      } else {
                        Utils.openLogin(context: context, newPage: "");
                      }
                    });
                  },
                ),
                _buildLine(16.0, 16.0),

                /* Active TV */
                if (activeTvStatus != null && activeTvStatus == "1")
                  _buildSettingButton(
                    title: 'activetv',
                    subTitle: 'activetv_desc',
                    titleMultilang: true,
                    subTitleMultilang: true,
                    iconColor: transparent,
                    iconName: '',
                    isEndIcon: false,
                    onClick: () {
                      AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                          () async {
                        if (Constant.userID != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ActiveTV(
                                newPage: RoutesConstant.activeTVPage,
                                oldPage: '',
                                reqText: '',
                              ),
                            ),
                          );
                        } else {
                          Utils.openLogin(context: context, newPage: "");
                        }
                      });
                    },
                  ),
                if (activeTvStatus != null && activeTvStatus == "1")
                  _buildLine(16.0, 16.0),

                /* Watchlist */
                if (watchlistStatus != null && watchlistStatus == "1")
                  _buildSettingButton(
                    title: 'watchlist',
                    subTitle: 'view_your_watchlist',
                    titleMultilang: true,
                    subTitleMultilang: true,
                    iconColor: transparent,
                    iconName: '',
                    isEndIcon: false,
                    onClick: () {
                      AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                          () async {
                        if (Constant.userID != null) {
                          final watchlistProvider =
                              Provider.of<WatchlistProvider>(context,
                                  listen: false);
                          await watchlistProvider.setLoading(true);
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyWatchlist(),
                            ),
                          );
                        } else {
                          Utils.openLogin(context: context, newPage: "");
                        }
                      });
                    },
                  ),
                if (watchlistStatus != null && watchlistStatus == "1")
                  _buildLine(16.0, 16.0),

                /* Purchases */
                if (subscriptionStatus != null && subscriptionStatus == "1")
                  _buildSettingButton(
                    title: 'purchases',
                    subTitle: 'view_your_purchases',
                    titleMultilang: true,
                    subTitleMultilang: true,
                    iconColor: transparent,
                    iconName: '',
                    isEndIcon: false,
                    onClick: () {
                      AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                          () async {
                        if (Constant.userID != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MyPurchaselist(
                                newPage: RoutesConstant.rentPurchasePage,
                                oldPage: '',
                                reqText: '',
                              ),
                            ),
                          );
                        } else {
                          Utils.openLogin(context: context, newPage: "");
                        }
                      });
                    },
                  ),
                if (subscriptionStatus != null && subscriptionStatus == "1")
                  _buildLine(16.0, 16.0),

                /* Parental Controls */
                if (parentControlStatus != null &&
                    parentControlStatus == "1" &&
                    Constant.userID != null)
                  _buildParentControls(),
                if (parentControlStatus != null &&
                    parentControlStatus == "1" &&
                    Constant.userID != null)
                  _buildLine(16.0, 16.0),

                /* Subscription */
                if (subscriptionStatus != null && subscriptionStatus == "1")
                  _buildSettingButton(
                    title: 'subsciption',
                    subTitle: 'subsciptionnotes',
                    titleMultilang: true,
                    subTitleMultilang: true,
                    iconColor: transparent,
                    iconName: '',
                    isEndIcon: false,
                    onClick: () {
                      AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                          () async {
                        if (Constant.userID != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const Subscription(newPage: "", oldPage: ""),
                            ),
                          );
                        } else {
                          Utils.openLogin(context: context, newPage: "");
                        }
                      });
                    },
                  ),
                if (subscriptionStatus != null && subscriptionStatus == "1")
                  _buildLine(16.0, 16.0),

                /* Transactions */
                if (subscriptionStatus != null && subscriptionStatus == "1")
                  _buildSettingButton(
                    title: 'transactions',
                    subTitle: 'transactions_notes',
                    titleMultilang: true,
                    subTitleMultilang: true,
                    iconColor: transparent,
                    iconName: '',
                    isEndIcon: false,
                    onClick: () {
                      AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                          () async {
                        if (Constant.userID != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionHistory(
                                newPage: RoutesConstant.subsHistoryPage,
                                oldPage: '',
                                reqText: '',
                              ),
                            ),
                          );
                        } else {
                          Utils.openLogin(context: context, newPage: "");
                        }
                      });
                    },
                  ),
                if (subscriptionStatus != null && subscriptionStatus == "1")
                  _buildLine(16.0, 16.0),

                /* MaltiLanguage */
                _buildSettingButton(
                  title: 'change_language',
                  subTitle: 'change_language_desc',
                  titleMultilang: true,
                  subTitleMultilang: true,
                  iconColor: transparent,
                  iconName: '',
                  isEndIcon: false,
                  onClick: () {
                    _languageChangeDialog();
                  },
                ),
                _buildLine(16.0, 16.0),

                /* Push Notification enable/disable */
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildSettingButton(
                        title: 'notification',
                        subTitle: 'recivepushnotification',
                        titleMultilang: true,
                        subTitleMultilang: true,
                        iconColor: transparent,
                        iconName: '',
                        isEndIcon: false,
                        onClick: () {
                          toggleSwitch(!(isSwitched ?? false));
                        },
                      ),
                    ),
                    Switch(
                      activeColor: secProgressColor,
                      activeTrackColor: colorPrimaryDark,
                      inactiveTrackColor: gray,
                      value: isSwitched ?? true,
                      onChanged: toggleSwitch,
                    ),
                  ],
                ),
                _buildLine(16.0, 16.0),

                /* Clear Cache */
                if (!Platform.isIOS)
                  _buildSettingButton(
                    title: 'clearcatch',
                    subTitle: 'clearlocallycatch',
                    titleMultilang: true,
                    subTitleMultilang: true,
                    iconColor: colorPrimary,
                    iconName: 'ic_clear',
                    isEndIcon: true,
                    onClick: () async {
                      if (!(kIsWeb) || !(Constant.isTV)) {
                        Utils.deleteCacheDir();
                      }
                      if (!mounted) return;
                      Utils.showSnackbar(
                          context, "success", "cacheclearmsg", true);
                    },
                  ),
                if (!Platform.isIOS) _buildLine(16.0, 16.0),

                /* SignIn / SignOut */
                _buildSettingButton(
                  title: Constant.userID == null
                      ? youAreNotSignIn
                      : (userType == "3" &&
                              ((userFullname ?? "").isEmpty ||
                                  (userFullname ?? "").contains("null")))
                          ? ((userMobileNo ?? "").isEmpty
                              ? ("$signedInAs ${userName ?? ""}")
                              : ("$signedInAs ${userMobileNo ?? ""}"))
                          : (((userFullname ?? "").isEmpty ||
                                  (userFullname ?? "").contains("null"))
                              ? ("$signedInAs ${userMobileNo ?? ""}")
                              : ("$signedInAs ${userFullname ?? ""}")),
                  subTitle: Constant.userID == null ? "sign_in" : "sign_out",
                  titleMultilang: false,
                  subTitleMultilang: true,
                  iconColor: transparent,
                  iconName: '',
                  isEndIcon: false,
                  onClick: () async {
                    if (Constant.userID != null) {
                      logoutConfirmDialog();
                    } else {
                      await Utils.openLogin(context: context, newPage: "");
                      setState(() {});
                    }
                  },
                ),
                _buildLine(16.0, 16.0),

                /* Rate App */
                _buildSettingButton(
                  title: 'rateus',
                  subTitle: 'rateourapp',
                  titleMultilang: true,
                  subTitleMultilang: true,
                  iconColor: transparent,
                  iconName: '',
                  isEndIcon: false,
                  onClick: () async {
                    printLog("Clicked on rateApp");
                    await Utils.redirectToStore();
                  },
                ),
                _buildLine(16.0, 16.0),

                /* Share App */
                _buildSettingButton(
                  title: 'shareapp',
                  subTitle: 'sharewithfriends',
                  titleMultilang: true,
                  subTitleMultilang: true,
                  iconColor: transparent,
                  iconName: '',
                  isEndIcon: false,
                  onClick: () async {
                    await Utils.shareApp(Platform.isIOS
                        ? Constant.iosAppShareUrlDesc
                        : Constant.androidAppShareUrlDesc);
                  },
                ),
                _buildLine(16.0, 16.0),

                /* Delete Account */
                if (Constant.userID != null)
                  _buildSettingButton(
                    title: 'delete_account',
                    subTitle: 'delete_account_desc',
                    titleMultilang: true,
                    subTitleMultilang: true,
                    iconColor: transparent,
                    iconName: '',
                    isEndIcon: false,
                    onClick: () async {
                      if (Constant.userID != null) {
                        deleteConfirmDialog();
                      } else {
                        await Utils.openLogin(context: context, newPage: "");
                        setState(() {});
                      }
                    },
                  ),
                if (Constant.userID != null) _buildLine(16.0, 16.0),

                /* Pages */
                _buildPages(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParentControls() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return ExpandableNotifier(
          child: Wrap(
            children: [
              ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: false,
                child: ExpandablePanel(
                  theme: const ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToCollapse: true,
                    tapBodyToExpand: true,
                    iconColor: descTextColor,
                  ),
                  header: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        color: titleTextColor,
                        text: "parental_controls",
                        fontsizeNormal: 14,
                        fontsizeWeb: 15,
                        maxline: 1,
                        multilanguage: true,
                        overflow: TextOverflow.ellipsis,
                        fontweight: FontWeight.w600,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 5),
                      MyText(
                        color: descTextColor,
                        text: "parental_lock",
                        fontsizeNormal: 12,
                        fontsizeWeb: 14,
                        multilanguage: true,
                        maxline: 2,
                        overflow: TextOverflow.ellipsis,
                        fontweight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
                  collapsed: const SizedBox.shrink(),
                  expanded: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 0, right: 60),
                        child: _buildLine(16.0, 16.0),
                      ),

                      /* Set PIN */
                      if (profileProvider.profileModel.result != null &&
                          (profileProvider.profileModel.result?.length ?? 0) >
                              0 &&
                          (profileProvider.profileModel.result?[0]
                                      .parentControlPassword ??
                                  "")
                              .isEmpty &&
                          isParentLocked)
                        Column(
                          children: [
                            _buildSettingButton(
                              title: 'set_pin',
                              subTitle: 'set_pin_desc',
                              titleMultilang: true,
                              subTitleMultilang: true,
                              iconColor: transparent,
                              iconName: '',
                              isEndIcon: false,
                              onClick: () {
                                pinPutController.clear();
                                setPINDialog();
                              },
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 0, right: 60),
                              child: _buildLine(16.0, 16.0),
                            ),
                          ],
                        ),

                      /* ON/OFF Parent Control */
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildSettingButton(
                              title: 'parental_lock',
                              subTitle: 'parental_lock_desc',
                              titleMultilang: true,
                              subTitleMultilang: true,
                              iconColor: transparent,
                              iconName: '',
                              isEndIcon: false,
                              onClick: () {
                                toggleParentLock(!isParentLocked);
                              },
                            ),
                          ),
                          Switch(
                            activeColor: secProgressColor,
                            activeTrackColor: colorPrimaryDark,
                            inactiveTrackColor: gray,
                            value: isParentLocked,
                            onChanged: toggleParentLock,
                          ),
                        ],
                      ),

                      /* Change PIN */
                      if (profileProvider.profileModel.result != null &&
                          (profileProvider.profileModel.result?.length ?? 0) >
                              0 &&
                          (profileProvider.profileModel.result?[0]
                                      .parentControlPassword ??
                                  "")
                              .isNotEmpty &&
                          isParentLocked)
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 0, right: 60),
                              child: _buildLine(16.0, 16.0),
                            ),
                            _buildSettingButton(
                              title: 'change_pin',
                              subTitle: 'change_pin_desc',
                              titleMultilang: true,
                              subTitleMultilang: true,
                              iconColor: transparent,
                              iconName: '',
                              isEndIcon: false,
                              onClick: () {
                                pinPutController.clear();
                                changePINDialog();
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                  builder: (_, collapsed, expanded) {
                    return Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPages() {
    return Consumer<GeneralProvider>(
      builder: (context, generalProvider, child) {
        if (generalProvider.loading) {
          return const SizedBox.shrink();
        } else {
          if (generalProvider.pagesModel.status == 200 &&
              generalProvider.pagesModel.result != null) {
            return AlignedGridView.count(
              shrinkWrap: true,
              crossAxisCount: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              itemCount: (generalProvider.pagesModel.result?.length ?? 0),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int position) {
                return Column(
                  children: [
                    _buildSettingButton(
                      title:
                          generalProvider.pagesModel.result?[position].title ??
                              '',
                      subTitle: generalProvider
                              .pagesModel.result?[position].pageSubtitle ??
                          '',
                      titleMultilang: false,
                      subTitleMultilang: false,
                      iconColor: transparent,
                      iconName: '',
                      isEndIcon: false,
                      onClick: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AboutPrivacyTerms(
                              appBarTitle: generalProvider
                                      .pagesModel.result?[position].title ??
                                  '',
                              loadURL: generalProvider
                                      .pagesModel.result?[position].url ??
                                  '',
                            ),
                          ),
                        );
                      },
                    ),
                    _buildLine(16.0, 0.0),
                  ],
                );
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  Widget _buildSettingButton({
    required String title,
    required String subTitle,
    required bool titleMultilang,
    required bool subTitleMultilang,
    required bool isEndIcon,
    required String iconName,
    required Color iconColor,
    required Function() onClick,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(2),
      onTap: onClick,
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
          minHeight: Dimens.minHeightSettings,
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    color: titleTextColor,
                    text: title,
                    fontsizeNormal: 14,
                    fontsizeWeb: 15,
                    maxline: 1,
                    multilanguage: titleMultilang,
                    overflow: TextOverflow.ellipsis,
                    fontweight: FontWeight.w600,
                    textalign: TextAlign.start,
                    fontstyle: FontStyle.normal,
                  ),
                  SizedBox(height: subTitle.isEmpty ? 0 : 5),
                  subTitle.isEmpty
                      ? const SizedBox.shrink()
                      : MyText(
                          color: descTextColor,
                          text: subTitle,
                          fontsizeNormal: 12,
                          fontsizeWeb: 14,
                          multilanguage: subTitleMultilang,
                          maxline: 2,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w500,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                ],
              ),
            ),
            if (isEndIcon)
              Container(
                padding: const EdgeInsets.all(5),
                child: MyImage(
                  width: 30,
                  height: 30,
                  imagePath: "$iconName.png",
                  color: iconColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(double topMargin, double bottomMargin) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 0.5,
      margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin),
      color: descTextColor,
    );
  }

  /* Set New PIN for Parent Control ************ */
  setPINDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      isDismissible: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(
                23, 23, 23, MediaQuery.of(context).viewInsets.bottom),
            color: lightBlack,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        color: titleTextColor,
                        text: "set_pin",
                        multilanguage: true,
                        textalign: TextAlign.start,
                        fontsizeNormal: 16,
                        fontsizeWeb: 18,
                        fontweight: FontWeight.bold,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 3),
                      MyText(
                        color: descTextColor,
                        text: "enter_pin_desc",
                        multilanguage: true,
                        textalign: TextAlign.start,
                        fontsizeNormal: 12,
                        fontsizeWeb: 15,
                        fontweight: FontWeight.w500,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                /* PIN */
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return Pinput(
                      length: 4,
                      keyboardType: TextInputType.number,
                      readOnly: profileProvider.loadingPCCheck,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      controller: pinPutController,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      onCompleted: (value) async {
                        if (value.toString().isNotEmpty) {
                          await profileProvider.notifyProvider();
                        }
                      },
                      defaultPinTheme: PinTheme(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: colorPrimary, width: 0.7),
                          shape: BoxShape.rectangle,
                          color: edtViewShadowColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        textStyle: GoogleFonts.inter(
                          color: white,
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return Container(
                      alignment: Alignment.centerRight,
                      child: _buildDialogBtn(
                        title: 'submit',
                        isPositive: true,
                        isMultilang: true,
                        onClick: () async {
                          _checkPINAndUpdate();
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      pinPutController.clear();
    });
  }

  _checkPINAndUpdate() async {
    if (pinPutController.text.toString().isEmpty) {
      Utils.showToast(enterPIN);
      return;
    }
    printLog("pinPutController ======> ${pinPutController.text}");
    await profileProvider.setPCLoading(true);
    await profileProvider.getUpdatePCPassword(pinPutController.text.toString());
    if (!profileProvider.loadingPCCheck) {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Utils.showToast(profileProvider.successModel.message ?? "");
    }
  }
  /* ************ Set New PIN for Parent Control */

  /* Change PIN for Parent Control ************ */
  changePINDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      isDismissible: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(
                23, 23, 23, MediaQuery.of(context).viewInsets.bottom),
            color: lightBlack,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        color: titleTextColor,
                        text: "change_pin",
                        multilanguage: true,
                        textalign: TextAlign.start,
                        fontsizeNormal: 16,
                        fontweight: FontWeight.bold,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 3),
                      MyText(
                        color: descTextColor,
                        text: "change_pin_desc",
                        multilanguage: true,
                        textalign: TextAlign.start,
                        fontsizeNormal: 12,
                        fontweight: FontWeight.w500,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                /* PIN */
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return Pinput(
                      length: 4,
                      keyboardType: TextInputType.number,
                      readOnly: profileProvider.loadingPCCheck,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      controller: pinPutController,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      onCompleted: (value) async {
                        if (value.toString().isNotEmpty) {
                          await profileProvider.notifyProvider();
                        }
                      },
                      defaultPinTheme: PinTheme(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: colorPrimary, width: 0.7),
                          shape: BoxShape.rectangle,
                          color: edtViewShadowColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        textStyle: GoogleFonts.inter(
                          color: white,
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return Container(
                      alignment: Alignment.centerRight,
                      child: _buildDialogBtn(
                        title: 'submit',
                        isPositive: true,
                        isMultilang: true,
                        onClick: () async {
                          _checkPINAndChange();
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      pinPutController.clear();
    });
  }

  _checkPINAndChange() async {
    if (pinPutController.text.toString().isEmpty) {
      Utils.showToast(enterPIN);
      return;
    }
    printLog("pinPutController ======> ${pinPutController.text}");
    await profileProvider.setPCLoading(true);
    await profileProvider.getUpdatePCPassword(pinPutController.text.toString());
    if (!profileProvider.loadingPCCheck) {
      if (!mounted) return;
      Navigator.pop(context);
      Utils.showToast(profileProvider.successModel.message ?? "");
      profileProvider.getProfile(context);
    }
  }
  /* ************ Change PIN for Parent Control */

  _languageChangeDialog() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, state) {
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: lightBlack,
                    padding: const EdgeInsets.all(23),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: titleTextColor,
                                text: "changelanguage",
                                multilanguage: true,
                                textalign: TextAlign.start,
                                fontsizeNormal: 16,
                                fontweight: FontWeight.bold,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(height: 3),
                              MyText(
                                color: descTextColor,
                                text: "selectyourlanguage",
                                multilanguage: true,
                                textalign: TextAlign.start,
                                fontsizeNormal: 12,
                                fontweight: FontWeight.w500,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              )
                            ],
                          ),
                        ),

                        /* English */
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "English",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('en');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Afrikaans */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Afrikaans",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('af');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Arabic */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Arabic",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('ar');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* German */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "German",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('de');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Spanish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Spanish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('es');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* French */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "French",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('fr');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Gujarati */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Gujarati",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('gu');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Hindi */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Hindi",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('hi');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Indonesian */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Indonesian",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('id');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Dutch */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Dutch",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('nl');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Portuguese (Brazil) */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Portuguese (Brazil)",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('pt');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Albanian */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Albanian",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('sq');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Turkish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Turkish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('tr');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),

                                /* Vietnamese */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Vietnamese",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('vi');
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLanguage({
    required String langName,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: Utils.setBGWithBorder(appBgColor, colorPrimary, 5, 0.5),
        child: MyText(
          color: titleTextColor,
          text: langName,
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          multilanguage: false,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontweight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  logoutConfirmDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              color: lightBlack,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: titleTextColor,
                          text: "confirmsognout",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: 16,
                          fontweight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: descTextColor,
                          text: "areyousurewanrtosignout",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: 12,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDialogBtn(
                          title: 'cancel',
                          isPositive: false,
                          isMultilang: true,
                          onClick: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildDialogBtn(
                          title: 'sign_out',
                          isPositive: true,
                          isMultilang: true,
                          onClick: () async {
                            await _onLogoutDelete();
                            _getData();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (!mounted) return;
      Utils.loadAds(context);
      setState(() {});
    });
  }

  Future<void> _onLogoutDelete() async {
    final sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    await sectionDataProvider.clearProvider();
    await profileProvider.clearProvider();
    // Firebase Signout
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await Utils.setUserId(null);
    sectionDataProvider.getSectionBanner("0", "1");
    sectionDataProvider.getSectionList("0", "1", 1);
    if (!mounted) return;
    Utils.loadAds(context);
    /* Initialize Hive */
    await Utils.initializeHiveBoxes();
    if (!mounted) return;
    _getData();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    Utils.openLogin(context: context, newPage: "");
  }

  deleteConfirmDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              color: lightBlack,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: titleTextColor,
                          text: "confirm_delete_account",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: 16,
                          fontweight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: descTextColor,
                          text: "delete_account_msg",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDialogBtn(
                          title: 'cancel',
                          isPositive: false,
                          isMultilang: true,
                          onClick: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildDialogBtn(
                          title: 'delete',
                          isPositive: true,
                          isMultilang: true,
                          onClick: () async {
                            await _onLogoutDelete();
                            _getData();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (!mounted) return;
      Utils.loadAds(context);
      setState(() {});
    });
  }

  Widget _buildDialogBtn({
    required String title,
    required bool isPositive,
    required bool isMultilang,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Container(
        constraints: const BoxConstraints(minWidth: 75),
        height: 50,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: Utils.setBGWithBorder(
            isPositive ? colorPrimary : transparent,
            isPositive ? transparent : descTextColor,
            5,
            0.5),
        child: MyText(
          color: isPositive ? black : white,
          text: title,
          multilanguage: isMultilang,
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          fontsizeWeb: 18,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontweight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }
}
