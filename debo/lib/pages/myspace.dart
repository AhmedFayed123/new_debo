
import 'package:debo/pages/profile.dart';
import 'package:debo/pages/profileedit.dart';
import 'package:debo/pages/settings.dart';
import 'package:debo/pages/viewall.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../model/continuewatchingmodel.dart';
import '../model/playermodel.dart';
import '../provider/bottombarprovider.dart';
import '../provider/homeprovider.dart';
import '../provider/myspaceprovider.dart';
import '../provider/profileprovider.dart';
import '../provider/sectiondataprovider.dart';
import '../provider/viewallprovider.dart';
import '../provider/watchlistprovider.dart';
import '../routes/routes_constant.dart';
import '../utils/adhelper.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/sharedpre.dart';
import '../utils/strings.dart';
import '../utils/utils.dart';
import '../widget/myimage.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import '../widget/myusernetworkimg.dart';
import 'mywatchlist.dart';

class MySpace extends StatefulWidget {
  const MySpace({super.key});

  @override
  State<MySpace> createState() => MySpaceState();
}

class MySpaceState extends State<MySpace> with RouteAware {
  String? subscriptionStatus;
  late MySpaceProvider mySpaceProvider;
  late ProfileProvider profileProvider;
  late HomeProvider homeProvider;
  late SectionDataProvider sectionDataProvider;
  late BottombarProvider bottombarProvider;
  SharedPre sharedPref = SharedPre();
  bool? isParentLocked;

  final pinPutController = TextEditingController();

  @override
  void initState() {
    mySpaceProvider = Provider.of<MySpaceProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    bottombarProvider = Provider.of<BottombarProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void didPop() {
    printLog("didPop");
    super.didPop();
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
  void didPush() {
    printLog("didPush");
    super.didPush();
  }

  @override
  void didPushNext() {
    printLog("didPushNext");
    super.didPushNext();
  }

  @override
  void dispose() {
    mySpaceProvider.clearProvider();
    super.dispose();
  }

  _getData() async {
    isParentLocked = await Utils.checkParentLock();
    printLog("_getData isParentLocked ======> $isParentLocked");

    subscriptionStatus =
        await Utils.configByStatus(status: Constant.subscriptionStatus);
    printLog('_getData subscriptionStatus ==> $subscriptionStatus');

    if (!mounted) return;
    if (Constant.userID != null) {
      mySpaceProvider.getProfile(context);
      mySpaceProvider.getContinueWatching(1);
      mySpaceProvider.getWatchlist(1);
    }

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  /* ========= Open Player ========= */
  openPlayer(
      String playType, int position, List<Result>? continueWatchingList) async {
    printLog("position ==========> $position");

    /* CHECK SUBSCRIPTION */
    if (playType != "Trailer") {
      bool? isPrimiumUser = await Utils.checkSubsRentLogin(
        context: context,
        isPremium: continueWatchingList?[position].isPremium ?? 0,
        isBuy: continueWatchingList?[position].isPremium ?? 0,
        isRent: continueWatchingList?[position].isRent ?? 0,
        rentBuy: continueWatchingList?[position].rentBuy ?? 0,
        videoId: (continueWatchingList?[position].id ?? 0).toString(),
        rentPrice: (continueWatchingList?[position].price ?? 0).toString(),
        vTitle: (continueWatchingList?[position].name ?? 0).toString(),
        typeId: (continueWatchingList?[position].typeId ?? 0).toString(),
        vType: (continueWatchingList?[position].videoType ?? 0).toString(),
        rentProductId:
            (continueWatchingList?[position].videoType ?? 0).toString(),
        newPage: '',
        oldPage: '',
        reqText: '',
      );
      printLog("isPrimiumUser =============> $isPrimiumUser");
      if (!isPrimiumUser) return;
    }
    /* CHECK SUBSCRIPTION */

    /* Set-up Quality URLs */
    Utils.setQualityURLs(
      video320: (continueWatchingList?[position].video320 ?? ""),
      video480: (continueWatchingList?[position].video480 ?? ""),
      video720: (continueWatchingList?[position].video720 ?? ""),
      video1080: (continueWatchingList?[position].video1080 ?? ""),
    );

    PlayerModel playerModel = PlayerModel(
      playType: (continueWatchingList?[position].videoType ?? 0) == 2
          ? "Show"
          : "Video",
      videoId: (continueWatchingList?[position].id ?? 0),
      videoTitle: continueWatchingList?[position].name ?? "",
      videoType: continueWatchingList?[position].videoType ?? 0,
      subVideoType: continueWatchingList?[position].subVideoType ?? 0,
      typeId: continueWatchingList?[position].typeId ?? 0,
      episodeId: continueWatchingList?[position].typeId ?? 0,
      videoUrl: continueWatchingList?[position].video320 ?? "",
      trailerUrl: continueWatchingList?[position].trailerUrl ?? "",
      uploadType: continueWatchingList?[position].videoUploadType ?? "",
      videoThumb: continueWatchingList?[position].landscape ?? "",
      stopTime: continueWatchingList?[position].stopTime ?? 0,
      securityKey: "",
    );

    if (!mounted) return;
    AdHelper.showFullscreenAd(
      context,
      Constant.interstialAdType,
      () async {
        dynamic isContinue = await Utils.openPlayer(
          context: context,
          playerModel: playerModel,
        );
        printLog("isContinue ===> $isContinue");
        if (isContinue != null && isContinue == true) {
          Future.delayed(Duration.zero).then((value) {
            if (!mounted) return;
            setState(() {});
          });
        }
      },
    );
  }
  /* ========= Open Player ========= */

  Future _clickToChangeProfiles({
    required bool userIsKid,
    required String clickFrom,
  }) async {
    printLog("userIsKid ===> $userIsKid");
    printLog("clickFrom ===> $clickFrom");
    if (!mounted) return;
    // Utils.showProgress(context);
    if (userIsKid == true) {
      await mySpaceProvider.getUpdatePCStatus("1");
    } else {
      await mySpaceProvider.getUpdatePCStatus("0");
    }
    // Utils.hideProgress();
    printLog("userIsKid ========> ${Constant.userIsKid}");
    if (mySpaceProvider.successModel.status == 200) {
      await Utils.setUserMode(userIsKid);
      /* Initialize Hive */
      await Utils.initializeHiveBoxes();
      homeProvider.clearProvider();
      sectionDataProvider.clearProvider();
      if (!mounted) return;
      await profileProvider.notifyProvider();
      await homeProvider.setLoading(true);
      await sectionDataProvider.setLoading(true);
      await bottombarProvider.setBottomNavIndex(0);
      if (!mounted) return;
      if (clickFrom == 'dialog' && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (!mounted) return;
      Utils.redirectToMainPage(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* AppIcon & Settings */
              _buildIconSettings(),
              Expanded(child: _buildPage()),
            ],
          ),
        ),
      ),
    );
  }

  /* App Icon & Settings */
  Widget _buildIconSettings() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(13, 13, 13, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(5),
                child: MyImage(
                  height: 20,
                  width: 62,
                  imagePath: "appicon.png",
                  fit: BoxFit.contain,
                ),
              ),
              if (Constant.userIsKid == false)
                InkWell(
                  borderRadius: BorderRadius.circular(Dimens.cardRadius),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const Settings();
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 15,
                          width: 15,
                          alignment: Alignment.centerLeft,
                          child: MyImage(
                            imagePath: "ic_setting.png",
                            fit: BoxFit.contain,
                            color: titleTextColor,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 5),
                          child: MyText(
                            color: titleTextColor,
                            text: "help_setting",
                            multilanguage: true,
                            textalign: TextAlign.start,
                            fontsizeNormal: 13,
                            fontsizeWeb: 15,
                            fontweight: FontWeight.w500,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        /* Subscribe */
        if (Constant.userID != null) _buildSubscribe(),
        if (Constant.userID != null) _buildLine(18.0, 18.0, 18.0, 0.0),
      ],
    );
  }

  Widget _buildPage() {
    return Consumer2<ProfileProvider, MySpaceProvider>(
      builder: (context, profileProvider, mySpaceProvider, child) {
        if (Constant.userID != null) {
          return _buildForLogin();
        } else {
          return _buildForNotLogin();
        }
      },
    );
  }

  /* If User Login */
  Widget _buildForLogin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          /* Profiles */
          _buildProfiles(),
          /* Watchlist */
          _buildWatchlist(),
          /* Continue Watching */
          const SizedBox(height: 18),
          _buildContinueWatching(),
        ],
      ),
    );
  }

  Widget _buildSubscribe() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* Current Plan */
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimens.cardRadius),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const Profile();
                    },
                  ),
                );
              },
              child: _buildSubscribeText(),
            ),
          ),
          /* Subscribe */
          if (profileProvider.profileModel.result != null &&
              (profileProvider.profileModel.result?.length ?? 0) > 0 &&
              (profileProvider.profileModel.result?[0].isBuy ?? 0) != 1 &&
              Constant.userIsKid == false)
            InkWell(
              borderRadius: BorderRadius.circular(Dimens.cardRadius),
              onTap: () async {
                await Utils.openSubscription(context: context, oldPage: "");
              },
              child: Container(
                height: 32,
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                decoration: Utils.setBackground(colorPrimary, 10),
                child: MyText(
                  color: black,
                  text: "subscribe",
                  multilanguage: true,
                  textalign: TextAlign.start,
                  fontsizeNormal: 13,
                  fontsizeWeb: 15,
                  fontweight: FontWeight.w500,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubscribeText() {
    if (profileProvider.profileModel.result != null &&
        (profileProvider.profileModel.result?.length ?? 0) > 0 &&
        (profileProvider.profileModel.result?[0].isBuy ?? 0) != 1) {
      return Container(
        constraints: const BoxConstraints(minHeight: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(right: 3),
              child: MyText(
                color: titleTextColor,
                text: "subscribe_to_enjoy",
                multilanguage: true,
                textalign: TextAlign.start,
                fontsizeNormal: 13,
                fontsizeWeb: 15,
                fontweight: FontWeight.w500,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(right: 8),
              child: MyText(
                color: colorPrimary,
                text: Constant.appName,
                multilanguage: false,
                textalign: TextAlign.start,
                fontsizeNormal: 13,
                fontsizeWeb: 15,
                fontweight: FontWeight.w700,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
            ),
            Container(
              height: 12,
              width: 12,
              alignment: Alignment.centerLeft,
              child: MyImage(
                imagePath: "ic_down.png",
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        constraints: const BoxConstraints(minHeight: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* Current Plan */
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(right: 8),
                  child: MyText(
                    color: titleTextColor,
                    text: (profileProvider.profileModel.result != null &&
                            (profileProvider.profileModel.result?.length ?? 0) >
                                0)
                        ? (profileProvider
                                .profileModel.result?[0].packageName ??
                            "")
                        : "-",
                    multilanguage: false,
                    textalign: TextAlign.center,
                    fontsizeNormal: 18,
                    fontsizeWeb: 22,
                    fontweight: FontWeight.w700,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                    withShaderMask: true,
                  ),
                ),
                Container(
                  height: 15,
                  width: 15,
                  alignment: Alignment.centerLeft,
                  child: MyImage(
                    imagePath: "ic_down.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            /* Mobile Number / Email Address */
            Container(
              margin: const EdgeInsets.fromLTRB(0, 3, 0, 0),
              child: MyText(
                color: titleTextColor,
                text: (profileProvider.profileModel.result == null ||
                        (profileProvider.profileModel.result?.length ?? 0) == 0)
                    ? "-"
                    : (Utils.convertToStar((profileProvider
                                .profileModel.result?[0].type ==
                            1)
                        ? (profileProvider
                                .profileModel.result?[0].mobileNumber ??
                            "")
                        : ((profileProvider.profileModel.result?[0].email ?? "")
                                .isNotEmpty
                            ? (profileProvider.profileModel.result?[0].email ??
                                "")
                            : "-"))),
                multilanguage: false,
                textalign: TextAlign.start,
                fontsizeNormal: 13,
                fontsizeWeb: 15,
                fontweight: FontWeight.w500,
                maxline: 2,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
                withShaderMask: false,
              ),
            ),
          ],
        ),
      );
    }
  }

  /* Profiles START *************** */
  Widget _buildProfiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* Title & Edit */
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(right: 10),
                child: MyText(
                  color: titleTextColor,
                  text: "profiles",
                  multilanguage: true,
                  textalign: TextAlign.start,
                  fontsizeNormal: 15,
                  fontsizeWeb: 17,
                  fontweight: FontWeight.w600,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ),
            if (Constant.userIsKid == false)
              InkWell(
                borderRadius: BorderRadius.circular(Dimens.cardRadius),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const ProfileEdit();
                      },
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        alignment: Alignment.center,
                        child: MyImage(
                          imagePath: "ic_edit.png",
                          fit: BoxFit.contain,
                          color: titleTextColor,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(left: 5),
                        child: MyText(
                          color: colorPrimary,
                          text: "edit",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: 13,
                          fontsizeWeb: 15,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        /* Data */
        Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileItem(
                    profileType: "user",
                    isActive: Constant.userIsKid == false,
                    profileImage: (mySpaceProvider.profileModel.result !=
                                null &&
                            (mySpaceProvider.profileModel.result?.length ?? 0) >
                                0)
                        ? (mySpaceProvider.profileModel.result?[0].image ?? "")
                        : "",
                    profileName: (mySpaceProvider.profileModel.result != null &&
                            (mySpaceProvider.profileModel.result?.length ?? 0) >
                                0)
                        ? (((mySpaceProvider.profileModel.result?[0].fullName ??
                                        "")
                                    .isEmpty ||
                                (mySpaceProvider
                                            .profileModel.result?[0].fullName ??
                                        "")
                                    .contains("null"))
                            ? (mySpaceProvider
                                    .profileModel.result?[0].userName ??
                                "")
                            : (mySpaceProvider
                                    .profileModel.result?[0].fullName ??
                                ""))
                        : "",
                    onClick: () async {
                      printLog("isParentLocked ====> $isParentLocked");
                      printLog("userIsKid ====1====> ${Constant.userIsKid}");
                      if (isParentLocked == true &&
                          Constant.userIsKid == true) {
                        parentPINDialog();
                      } else {
                        if (Constant.userIsKid == false) {
                          return;
                        }
                        _clickToChangeProfiles(userIsKid: false, clickFrom: '');
                      }
                      printLog("userIsKid ====2====> ${Constant.userIsKid}");
                    },
                  ),
                  const SizedBox(width: 15),
                  _buildProfileItem(
                    profileType: "kids",
                    profileImage: "kids.png",
                    profileName: "Kids",
                    isActive: Constant.userIsKid == true,
                    onClick: () async {
                      printLog("userIsKid ====1====> ${Constant.userIsKid}");
                      if (Constant.userIsKid != null &&
                          Constant.userIsKid == true) {
                        return;
                      }
                      _clickToChangeProfiles(userIsKid: true, clickFrom: '');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required String profileType,
    required String profileImage,
    required String profileName,
    required bool isActive,
    required Function() onClick,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onClick,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: Dimens.widthProfiles,
            height: Dimens.heightProfiles,
            padding: const EdgeInsets.all(2),
            alignment: Alignment.center,
            decoration: Utils.setBGWithBorder(
                transparent, isActive ? white : transparent, 40, 1),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: (profileType == "user")
                      ? MyUserNetworkImage(
                          imageUrl: profileImage,
                          fit: BoxFit.cover,
                          width: Dimens.widthProfiles,
                          height: Dimens.heightProfiles,
                        )
                      : MyImage(
                          imagePath: profileImage,
                          fit: BoxFit.cover,
                          width: Dimens.widthProfiles,
                          height: Dimens.heightProfiles,
                        ),
                ),
                if (isActive)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      transform: Matrix4.translationValues(0, 8, 0),
                      decoration: Utils.setBackground(white, 10),
                      padding: const EdgeInsets.all(1),
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: Utils.setBackground(colorAccent, 5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: Dimens.widthProfiles,
            padding: const EdgeInsets.all(5),
            alignment: Alignment.center,
            child: MyText(
              color: titleTextColor,
              multilanguage: false,
              text: profileName,
              fontsizeNormal: 12,
              fontweight: FontWeight.w500,
              fontsizeWeb: 15,
              maxline: 2,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  parentPINDialog() {
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
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyText(
                        color: titleTextColor,
                        text: "parental_lock",
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
                        text: "enter_pin",
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
                Consumer<MySpaceProvider>(
                  builder: (context, mySpaceProvider, child) {
                    return Pinput(
                      length: 4,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      controller: pinPutController,
                      readOnly: mySpaceProvider.loadingPCCheck,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      onCompleted: (value) async {
                        if (value.toString().isNotEmpty) {
                          await mySpaceProvider.notifyProvider();
                        }
                      },
                      onChanged: (value) async {
                        if (value.toString().isNotEmpty) {
                          await mySpaceProvider.notifyProvider();
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
                Consumer<MySpaceProvider>(
                  builder: (context, mySpaceProvider, child) {
                    if (pinPutController.text.toString().isEmpty ||
                        pinPutController.text.toString().length < 4) {
                      return const SizedBox.shrink();
                    }
                    if (mySpaceProvider.loadingPCCheck) {
                      return Container(
                        alignment: Alignment.centerRight,
                        height: 50,
                        width: 50,
                        child: Utils.pageLoader(),
                      );
                    }
                    return Container(
                      alignment: Alignment.centerRight,
                      child: _buildDialogBtn(
                        title: 'submit',
                        isPositive: true,
                        isMultilang: true,
                        onClick: () async {
                          _checkPINAndChangeMode();
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

  _checkPINAndChangeMode() async {
    if (pinPutController.text.toString().isEmpty) {
      Utils.showToast(enterPIN);
      return;
    }
    printLog("pinPutController =====> ${pinPutController.text}");
    await mySpaceProvider.setUpdateLoading(true);
    await mySpaceProvider
        .parentControlCheckPassword(pinPutController.text.toString());
    if (!mySpaceProvider.loadingPCCheck) {
      if (mySpaceProvider.successModel.status == 200) {
        _clickToChangeProfiles(userIsKid: false, clickFrom: 'dialog');
      } else {
        Utils.showToast(mySpaceProvider.successModel.message ?? "");
      }
    }
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
  /* **************** Profiles END */

  /* Watchlist START *************** */
  Widget _buildWatchlist() {
    if (mySpaceProvider.watchlistModel.result != null &&
        (mySpaceProvider.watchlistModel.result?.length ?? 0) > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          /* Title */
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(right: 10),
                  child: MyText(
                    color: white,
                    text: "watchlist",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: 16,
                    fontsizeWeb: 18,
                    fontweight: FontWeight.w600,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  final watchlistProvider =
                      Provider.of<WatchlistProvider>(context, listen: false);
                  if (!mounted) return;
                  AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                      () async {
                    if (Constant.userID != null) {
                      await watchlistProvider.setLoading(true);
                      if (!mounted) return;
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
                  mySpaceProvider.getWatchlist(1);
                },
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  alignment: Alignment.centerRight,
                  height: 25,
                  padding: const EdgeInsets.all(6),
                  child: MyImage(
                    imagePath: "ic_viewall.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: Dimens.isBigScreen(context)
                  ? Dimens.heightPortWeb
                  : Dimens.heightPort,
              child: ListView.separated(
                itemCount: mySpaceProvider.watchlistModel.result?.length ?? 0,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, position) => SizedBox(
                    width: Dimens.isBigScreen(context)
                        ? Dimens.spaceBetweenCardsWeb
                        : Dimens.spaceBetweenCards),
                itemBuilder: (BuildContext context, int position) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(4),
                    focusColor: white,
                    onTap: () async {
                      printLog("Clicked on position ==> $position");
                      await Utils.openDetails(
                        context: context,
                        videoId: mySpaceProvider
                                .watchlistModel.result?[position].id ??
                            0,
                        subVideoType: mySpaceProvider.watchlistModel
                                .result?[position].subVideoType ??
                            0,
                        videoType: mySpaceProvider
                                .watchlistModel.result?[position].videoType ??
                            0,
                        typeId: mySpaceProvider
                                .watchlistModel.result?[position].typeId ??
                            0,
                        newPage: ((mySpaceProvider.watchlistModel
                                            .result?[position].subVideoType ??
                                        0) ==
                                    2 ||
                                (mySpaceProvider.watchlistModel
                                            .result?[position].videoType ??
                                        0) ==
                                    2)
                            ? RoutesConstant.showDetailsPage
                            : RoutesConstant.videoDetailsPage,
                        oldPage: "",
                        reqText: Constant.userID ?? "",
                      );
                      await mySpaceProvider.getWatchlist(1);
                    },
                    child: Container(
                      width: Dimens.isBigScreen(context)
                          ? Dimens.widthPortWeb
                          : Dimens.widthPort,
                      height: Dimens.isBigScreen(context)
                          ? Dimens.heightPortWeb
                          : Dimens.heightPort,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(2.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                Dimens.isBigScreen(context)
                                    ? Dimens.cardRadiusWeb
                                    : Dimens.cardRadius),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: MyNetworkImage(
                              imageUrl: mySpaceProvider.watchlistModel
                                      .result?[position].thumbnail
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          if (mySpaceProvider
                                  .watchlistModel.result?[position].isTitle ==
                              1)
                            Container(
                              padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
                              alignment: Alignment.bottomLeft,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: Utils.setGradTTBBGWithCenter(
                                  transparent,
                                  appBgColor.withOpacity(0.1),
                                  appBgColor,
                                  0),
                              child: MyText(
                                color: white,
                                multilanguage: false,
                                text: mySpaceProvider
                                        .watchlistModel.result?[position].name
                                        .toString() ??
                                    "",
                                fontsizeNormal: 13,
                                fontweight: FontWeight.w600,
                                fontsizeWeb: 15,
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
                },
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
  /* ***************** Watchlist END */

  /* Continue Watching START *************** */
  Widget _buildContinueWatching() {
    if (mySpaceProvider.continueWatchingModel.result != null &&
        (mySpaceProvider.continueWatchingModel.result?.length ?? 0) > 0) {
      return Column(
        children: [
          /* Title */
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(right: 10),
                  child: MyText(
                    color: titleTextColor,
                    text: "continuewatching",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: 15,
                    fontsizeWeb: 17,
                    fontweight: FontWeight.w600,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  final viewAllProvider =
                      Provider.of<ViewAllProvider>(context, listen: false);
                  await viewAllProvider.setLoading(true);
                  if (!mounted) return;
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const ViewAll(
                          appBarTitle: 'continuewatching',
                          videoId: 0,
                          subVideoType: 0,
                          videoType: 0,
                          typeId: 0,
                        );
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  alignment: Alignment.centerRight,
                  height: 25,
                  padding: const EdgeInsets.all(6),
                  child: MyImage(
                    imagePath: "ic_viewall.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          /* Data */
          AlignedGridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25,
            itemCount:
                (mySpaceProvider.continueWatchingModel.result?.length ?? 0),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int position) {
              return _buildContinueWatchingItem(position: position);
            },
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildContinueWatchingItem({required int position}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimens.cardRadius),
      child: SizedBox(
        width: Dimens.widthContiLand,
        height: Dimens.heightContiLand,
        child: InkWell(
          focusColor: white,
          onTap: () {
            printLog("Clicked on position ==> $position");
            if (!mounted) return;
            Utils.openDetails(
              context: context,
              videoId:
                  mySpaceProvider.continueWatchingModel.result?[position].id ??
                      0,
              subVideoType: mySpaceProvider
                      .continueWatchingModel.result?[position].subVideoType ??
                  0,
              videoType: mySpaceProvider
                      .continueWatchingModel.result?[position].videoType ??
                  0,
              typeId: mySpaceProvider
                      .continueWatchingModel.result?[position].typeId ??
                  0,
              newPage: ((mySpaceProvider.continueWatchingModel.result?[position]
                                  .subVideoType ??
                              0) ==
                          2 ||
                      (mySpaceProvider.continueWatchingModel.result?[position]
                                  .videoType ??
                              0) ==
                          2)
                  ? RoutesConstant.showDetailsPage
                  : RoutesConstant.videoDetailsPage,
              oldPage: '',
              reqText: '',
            );
          },
          child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              Container(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.cardRadius),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: MyNetworkImage(
                    imageUrl: mySpaceProvider
                            .continueWatchingModel.result?[position].landscape
                            .toString() ??
                        "",
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
              continueWatchingLayout(position: position),
            ],
          ),
        ),
      ),
    );
  }

  Widget continueWatchingLayout({required int position}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              openPlayer("ContinueWatch", position,
                  mySpaceProvider.continueWatchingModel.result);
            },
            child: MyImage(
              width: 20,
              height: 20,
              imagePath: "play.png",
            ),
          ),
        ),
        Container(
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          padding: const EdgeInsets.all(0),
          child: LinearPercentIndicator(
            padding: const EdgeInsets.all(0),
            barRadius: const Radius.circular(2),
            lineHeight: 4,
            percent: Utils.getPercentage(
                mySpaceProvider.continueWatchingModel.result?[position]
                        .videoDuration ??
                    0,
                mySpaceProvider
                        .continueWatchingModel.result?[position].stopTime ??
                    0),
            backgroundColor: secProgressColor,
            progressColor: colorPrimary,
          ),
        ),
      ],
    );
  }
  /* **************** Continue Watching END */

  /* If User Not Login START *************** */
  Widget _buildForNotLogin() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: MyImage(
                height: 180,
                fit: BoxFit.contain,
                imagePath: "ic_not_login.png",
              ),
            ),
            const SizedBox(height: 15),
            MyText(
              color: titleTextColor,
              text: "no_login_title",
              fontsizeNormal: 23,
              fontsizeWeb: 25,
              maxline: 5,
              multilanguage: true,
              overflow: TextOverflow.ellipsis,
              fontweight: FontWeight.w600,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
            const SizedBox(height: 5),
            MyText(
              color: descTextColor,
              text: "no_login_desc",
              fontsizeNormal: 13,
              fontsizeWeb: 15,
              maxline: 5,
              multilanguage: true,
              overflow: TextOverflow.ellipsis,
              fontweight: FontWeight.w400,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
            /* Login Button */
            const SizedBox(height: 25),
            _buildLoginBtn(),
            /* Login Trouble Desc */
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(3, 8, 3, 8),
                  child: MyText(
                    color: descTextColor,
                    text: "login_trouble",
                    fontsizeNormal: 13,
                    fontsizeWeb: 15,
                    maxline: 1,
                    multilanguage: true,
                    overflow: TextOverflow.ellipsis,
                    fontweight: FontWeight.w400,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => AboutPrivacyTerms(
                    //       appBarTitle: '',
                    //       loadURL: '',
                    //     ),
                    //   ),
                    // );
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(3, 8, 3, 8),
                    child: MyText(
                      color: colorAccent,
                      text: "get_help",
                      fontsizeNormal: 13,
                      fontsizeWeb: 15,
                      maxline: 1,
                      multilanguage: true,
                      overflow: TextOverflow.ellipsis,
                      fontweight: FontWeight.w600,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return InkWell(
      borderRadius: BorderRadius.circular(45),
      onTap: () {
        Utils.openLogin(context: context, newPage: '');
      },
      child: FittedBox(
        child: Container(
          height: 45,
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.5),
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          decoration: Utils.setGradientBGWithCenter(colorPrimary,
              colorPrimary.withOpacity(0.6), colorPrimary.withOpacity(0.4), 45),
          child: MyText(
            color: white,
            text: "log_in",
            fontsizeNormal: 15,
            fontsizeWeb: 17,
            maxline: 5,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }
  /* **************** If User Not Login END */

  Widget _buildLine(double leftMargin, double topMargin, double rightMargin,
      double bottomMargin) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 0.7,
      margin:
          EdgeInsets.fromLTRB(leftMargin, topMargin, rightMargin, bottomMargin),
      decoration: Utils.setBackground(gray.withOpacity(0.3), 0.7),
    );
  }
}
