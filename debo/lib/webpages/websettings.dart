
import 'package:debo/webpages/webcomman.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../provider/generalprovider.dart';
import '../provider/profileprovider.dart';
import '../provider/sectiondataprovider.dart';
import '../routes/routes_constant.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/sharedpre.dart';
import '../utils/strings.dart';
import '../utils/utils.dart';
import '../widget/myimage.dart';
import '../widget/mytext.dart';

class WebSettings extends StatefulWidget {
  final String? newPage, oldPage;
  final dynamic reqText;
  const WebSettings({
    required this.newPage,
    required this.oldPage,
    required this.reqText,
    super.key,
  });

  @override
  State<WebSettings> createState() => WebSettingsState();
}

class WebSettingsState extends State<WebSettings> with RouteAware {
  late ProfileProvider profileProvider;
  late GeneralProvider generalProvider;
  SharedPre sharedPref = SharedPre();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final pinPutController = TextEditingController();

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
      downloadStatus,
      subscriptionStatus;

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
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
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

    isParentLocked = await Utils.checkParentLock();
    printLog('_getData isParentLocked =======> $isParentLocked');

    if (!mounted) return;
    await generalProvider.getGeneralsetting(context);
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
    downloadStatus =
        await Utils.configByStatus(status: Constant.downloadStatus);
    printLog('_getData downloadStatus =======> $downloadStatus');
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
    routeObserver.unsubscribe(this);
    pinPutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebComman(
      newPage: widget.newPage,
      oldPage: widget.oldPage,
      reqText: '',
      newChild: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              colorPrimary.withOpacity(0.3),
              colorPrimary.withOpacity(0.2),
              colorPrimary.withOpacity(0.1),
              appBgColor.withOpacity(0.1),
              appBgColor,
            ],
          ),
          borderRadius: BorderRadius.circular(0),
          shape: BoxShape.rectangle,
        ),
        child: _buildPageUI(),
      ),
    );
  }

  Widget _buildPageUI() {
    return Container(
      margin: EdgeInsets.fromLTRB(
        Dimens.isBigScreen(context) ? 40 : 25,
        (Dimens.homeTabHeight + 20),
        Dimens.isBigScreen(context) ? 40 : 25,
        25,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: MyText(
              text: 'setting',
              multilanguage: true,
              color: colorPrimary,
              fontsizeNormal: 20,
              fontsizeWeb: 25,
              maxline: 1,
              fontweight: FontWeight.w600,
              fontstyle: FontStyle.normal,
              textalign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 30),
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
                if (Constant.userID != null) {
                  if (!mounted) return;
                  Utils.openWebDialog(
                    context: context,
                    newPage: RoutesConstant.activeTVPage,
                    oldPage: widget.oldPage ?? "",
                    reqText: "",
                  );
                } else {
                  Utils.openLogin(context: context, newPage: "");
                }
              },
            ),
          if (activeTvStatus != null && activeTvStatus == "1")
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
                if (Constant.userID != null) {
                  context.pushNamed(
                    RoutesConstant.rentPurchasePage,
                    extra: widget.newPage,
                  );
                } else {
                  Utils.openLogin(context: context, newPage: "");
                }
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
              onClick: () async {
                if (Constant.userID != null) {
                  await Utils.openSubscription(context: context, oldPage: "");
                } else {
                  Utils.openLogin(context: context, newPage: "");
                }
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
                if (Constant.userID != null) {
                  context.pushNamed(
                    RoutesConstant.subsHistoryPage,
                    extra: widget.newPage,
                  );
                } else {
                  Utils.openLogin(context: context, newPage: "");
                }
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
                _buildLogoutDialog();
              } else {
                await Utils.openLogin(context: context, newPage: "");
                setState(() {});
              }
            },
          ),
          _buildLine(16.0, 16.0),
        ],
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
        constraints: BoxConstraints(
          minHeight: Dimens.minHeightSettings,
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
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
      height: 0.5,
      margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin),
      color: descTextColor,
    );
  }

  /* Set New PIN for Parent Control ************ */
  setPINDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: Dimens.isBigScreen(context)
                    ? (MediaQuery.of(context).size.width * 0.3)
                    : (MediaQuery.of(context).size.width),
                margin: const EdgeInsets.fromLTRB(50, 50, 50, 50),
                padding: const EdgeInsets.all(23),
                decoration: Utils.setBackground(lightBlack, 5),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Expanded(
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
                          const SizedBox(width: 20),
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              }
                            },
                            icon: MyImage(
                              imagePath: "ic_close.png",
                              fit: BoxFit.contain,
                              height: 17,
                              width: 17,
                              color: defaultIconColor,
                            ),
                          ),
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
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
                              border:
                                  Border.all(color: colorPrimary, width: 0.7),
                              shape: BoxShape.rectangle,
                              color: edtViewShadowColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            textStyle: kIsWeb
                                ? const TextStyle(
                                    color: white,
                                    fontSize: 16,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w800,
                                  )
                                : GoogleFonts.inter(
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
                  ],
                ),
              ),
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
      if (context.canPop()) {
        context.pop();
      }
      Utils.showToast(profileProvider.successModel.message ?? "");
    }
  }
  /* ************ Set New PIN for Parent Control */

  /* Change PIN for Parent Control ************ */
  changePINDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: Dimens.isBigScreen(context)
                    ? (MediaQuery.of(context).size.width * 0.3)
                    : (MediaQuery.of(context).size.width),
                margin: const EdgeInsets.fromLTRB(50, 50, 50, 50),
                padding: const EdgeInsets.all(23),
                decoration: Utils.setBackground(lightBlack, 5),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Expanded(
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
                                  fontsizeWeb: 18,
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
                                  fontsizeWeb: 15,
                                  fontweight: FontWeight.w500,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              }
                            },
                            icon: MyImage(
                              imagePath: "ic_close.png",
                              fit: BoxFit.contain,
                              height: 17,
                              width: 17,
                              color: defaultIconColor,
                            ),
                          ),
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
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
                              border:
                                  Border.all(color: colorPrimary, width: 0.7),
                              shape: BoxShape.rectangle,
                              color: edtViewShadowColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            textStyle: kIsWeb
                                ? const TextStyle(
                                    color: white,
                                    fontSize: 16,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w800,
                                  )
                                : GoogleFonts.inter(
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
                  ],
                ),
              ),
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
      if (context.canPop()) {
        context.pop();
      }
      Utils.showToast(profileProvider.successModel.message ?? "");
      profileProvider.getProfile(context);
    }
  }
  /* ************ Change PIN for Parent Control */

  _languageChangeDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: Dimens.isBigScreen(context)
                  ? (MediaQuery.of(context).size.width * 0.35)
                  : (MediaQuery.of(context).size.width),
              margin: const EdgeInsets.fromLTRB(50, 50, 50, 50),
              padding: const EdgeInsets.all(23),
              decoration: Utils.setBackground(lightBlack, 5),
              child: StatefulBuilder(
                builder: (BuildContext context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
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
                                    fontsizeWeb: 18,
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
                                    fontsizeWeb: 15,
                                    fontweight: FontWeight.w500,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                }
                              },
                              icon: MyImage(
                                imagePath: "ic_close.png",
                                fit: BoxFit.contain,
                                height: 17,
                                width: 17,
                                color: defaultIconColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /* English */
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              _buildLanguage(
                                langName: "English",
                                onClick: () {
                                  state(() {});
                                  LocaleNotifier.of(context)?.change('en');
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
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
                                  if (context.canPop()) {
                                    context.pop();
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
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
          color: white,
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

  Future<void> _buildLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: Dimens.isBigScreen(context)
                    ? (MediaQuery.of(context).size.width * 0.3)
                    : (MediaQuery.of(context).size.width),
                margin: const EdgeInsets.fromLTRB(50, 50, 50, 50),
                padding: const EdgeInsets.all(23),
                decoration: Utils.setBackground(lightBlack, 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                            textalign: TextAlign.center,
                            fontsizeNormal: 16,
                            fontsizeWeb: 16,
                            fontweight: FontWeight.w600,
                            maxline: 2,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                          const SizedBox(height: 8),
                          MyText(
                            color: descTextColor,
                            text: "areyousurewanrtosignout",
                            multilanguage: true,
                            textalign: TextAlign.center,
                            fontsizeNormal: 13,
                            fontsizeWeb: 14,
                            fontweight: FontWeight.w500,
                            maxline: 2,
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
                              if (context.canPop()) {
                                context.pop();
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((value) {
      if (!mounted) return;
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
    _getData();
    if (context.canPop()) {
      context.pop();
    }
    Utils.openLogin(context: context, newPage: widget.newPage ?? "");
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
