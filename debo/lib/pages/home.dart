import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:debo/pages/sectionviewall.dart';

import '../model/sectiontypemodel.dart' as type;
import '../model/sectionlistmodel.dart' as list;
import '../model/sectionbannermodel.dart' as banner;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../model/playermodel.dart';
import '../model/sectionlistmodel.dart';
import '../provider/bottombarprovider.dart';
import '../provider/homeprovider.dart';
import '../provider/sectiondataprovider.dart';
import '../provider/sectionviewallprovider.dart';
import '../provider/videobyidprovider.dart';
import '../routes/routes_constant.dart';
import '../shimmer/shimmerutils.dart';
import '../utils/adhelper.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/strings.dart';
import '../utils/utils.dart';
import '../widget/morehomedialog.dart';
import '../widget/myimage.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';
import 'contentbyid.dart';

class Home extends StatefulWidget {
  final String? pageName;
  const Home({super.key, required this.pageName});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  late HomeProvider homeProvider;
  late BottombarProvider bottombarProvider;
  late SectionDataProvider sectionDataProvider;
  CarouselSliderController carouselController = CarouselSliderController();
  final nestedScrollController = ScrollController();
  final tabScrollController = ScrollController();
  late ListObserverController observerController;
  String? currentPage, subscriptionStatus;

  /* Notification CLICK START ************** */
  _handleNotificationOpened(OSNotificationClickEvent result) {
    /* id, video_type, type_id */

    printLog(
        "setNotificationOpenedHandler additionalData ===> ${result.notification.additionalData.toString()}");
    printLog(
        "setNotificationOpenedHandler video_id ===> ${result.notification.additionalData?['id']}");
    printLog(
        "setNotificationOpenedHandler upcoming_type ===> ${result.notification.additionalData?['upcoming_type']}");
    printLog(
        "setNotificationOpenedHandler video_type ===> ${result.notification.additionalData?['video_type']}");
    printLog(
        "setNotificationOpenedHandler type_id ===> ${result.notification.additionalData?['type_id']}");

    if (result.notification.additionalData?['id'] != null &&
        result.notification.additionalData?['upcoming_type'] != null &&
        result.notification.additionalData?['video_type'] != null &&
        result.notification.additionalData?['type_id'] != null) {
      String? videoID =
          result.notification.additionalData?['id'].toString() ?? "";
      String? subVideoType =
          result.notification.additionalData?['sub_video_type'].toString() ??
              "";
      String? videoType =
          result.notification.additionalData?['video_type'].toString() ?? "";
      String? typeID =
          result.notification.additionalData?['type_id'].toString() ?? "";
      printLog("videoID =======> $videoID");
      printLog("subVideoType ==> $subVideoType");
      printLog("videoType =====> $videoType");
      printLog("typeID ========> $typeID");

      Utils.openDetails(
        context: context,
        videoId: int.parse(videoID),
        subVideoType: int.parse(subVideoType),
        videoType: int.parse(videoType),
        typeId: int.parse(typeID),
        newPage: (int.parse(videoType) == 2 || int.parse(subVideoType) == 2)
            ? RoutesConstant.showDetailsPage
            : RoutesConstant.videoDetailsPage,
        oldPage: '',
        reqText: '',
      );
    }
  }
  /* **************** Notification CLICK END */

  _nestedScrollListener() async {
    if (!nestedScrollController.hasClients) return;
    if (nestedScrollController.offset >=
            nestedScrollController.position.maxScrollExtent &&
        !nestedScrollController.position.outOfRange &&
        (sectionDataProvider.isMorePage ?? false)) {
      await sectionDataProvider.setLoadMore(true);
      _fetchSectionData(sectionDataProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchSectionData(int? nextPage) async {
    printLog("_fetchSectionData nextPage  ========> $nextPage");
    printLog(
        "_fetchSectionData isMorePage  ======> ${sectionDataProvider.isMorePage}");
    printLog(
        "_fetchSectionData currentPage ======> ${sectionDataProvider.currentPage}");
    printLog(
        "_fetchSectionData totalPage   ======> ${sectionDataProvider.totalPage}");

    await sectionDataProvider.getSectionList(
        (homeProvider.selectedIndex == -1)
            ? 0
            : (homeProvider
                    .sectionTypeModel.result?[homeProvider.selectedIndex].id ??
                0),
        (homeProvider.selectedIndex == -1) ? "1" : "2",
        (nextPage ?? 0) + 1);
    printLog(
        "sectionList length ==> ${sectionDataProvider.sectionList?.length}");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void initState() {
    nestedScrollController.addListener(_nestedScrollListener);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: transparent,
        systemNavigationBarColor: secondaryBgColor,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    bottombarProvider = Provider.of<BottombarProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    observerController =
        ListObserverController(controller: tabScrollController);
    currentPage = widget.pageName ?? "";
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    if (!kIsWeb) {
      OneSignal.Notifications.addClickListener(_handleNotificationOpened);
    }
  }

  _getData() async {
    subscriptionStatus =
        await Utils.configByStatus(status: Constant.subscriptionStatus);
    printLog('_getData subscriptionStatus ===> $subscriptionStatus');
    await homeProvider.setLoading(true);
    await homeProvider.getSectionType();

    if (!homeProvider.loading) {
      if (homeProvider.sectionTypeModel.status == 200 &&
          homeProvider.sectionTypeModel.result != null) {
        if ((homeProvider.sectionTypeModel.result?.length ?? 0) > 0) {
          if ((sectionDataProvider.sectionBannerModel.result?.length ?? 0) ==
                  0 ||
              (sectionDataProvider.sectionList?.length ?? 0) == 0) {
            getTabData(-1, homeProvider.sectionTypeModel.result);
          }
        }
      }
    }
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    await homeProvider.getGenres();
    await homeProvider.getChannel();
    await homeProvider.getLanguage();
    Utils.getCurrencySymbol();
  }

  Future<void> setSelectedTab(int tabPos) async {
    printLog("setSelectedTab tabPos ====> $tabPos");
    if (!mounted) return;
    await homeProvider.setSelectedTab(tabPos);
    printLog(
        "setSelectedTab selectedIndex ====> ${homeProvider.selectedIndex}");
    printLog(
        "setSelectedTab lastTabPosition ====> ${sectionDataProvider.lastTabPosition}");
    if (sectionDataProvider.lastTabPosition == tabPos) {
      return;
    } else {
      sectionDataProvider.setTabPosition(tabPos);
    }
  }

  Future<void> getTabData(
      int position, List<type.Result>? sectionTypeList) async {
    printLog("getTabData position ====> $position");
    await sectionDataProvider.setLoading(true);
    await bottombarProvider.setAppbarVisibility(true);

    if (nestedScrollController.hasClients) {
      await nestedScrollController.animateTo(0,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
    }
    if (position == -1) {
      await setSelectedTab(-1);
      await sectionDataProvider.getSectionBanner("0", "1");
      await sectionDataProvider.getSectionList("0", "1", 1);
    } else {
      await setSelectedTab(position);
      await sectionDataProvider.getSectionBanner(
          sectionTypeList?[position].id ?? 0, "2");
      await sectionDataProvider.getSectionList(
          sectionTypeList?[position].id ?? 0, "2", 1);
    }
  }

  openDetailPage(
      int videoId, int subVideoType, int videoType, int typeId) async {
    printLog("videoId ========> $videoId");
    printLog("subVideoType ===> $subVideoType");
    printLog("videoType ======> $videoType");
    printLog("typeId =========> $typeId");
    if (!mounted) return;
    Utils.openDetails(
      context: context,
      videoId: videoId,
      subVideoType: subVideoType,
      videoType: videoType,
      typeId: typeId,
      newPage: (subVideoType == 1 || videoType == 1)
          ? RoutesConstant.videoDetailsPage
          : RoutesConstant.showDetailsPage,
      oldPage: '',
      reqText: '',
    );
  }

  /* ========= Open Player ========= */
  openPlayer(
      String playType, int position, List<Datum>? continueWatchingList) async {
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
      playType: ((continueWatchingList?[position].videoType ?? 0) == 2 ||
              (continueWatchingList?[position].subVideoType ?? 0) == 2)
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
          await getTabData(-1, homeProvider.sectionTypeModel.result);
          Future.delayed(Duration.zero).then((value) {
            if (!mounted) return;
            setState(() {});
          });
        }
      },
    );
  }
  /* ========= Open Player ========= */

  _openMoreDialog() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: transparent,
      builder: (BuildContext context) {
        return Wrap(
          alignment: WrapAlignment.center,
          children: [
            Container(
              height: 3,
              width: 50,
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              decoration: Utils.setBackground(secondaryBgColor, 5),
            ),
            const MoreHomeDialog(),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _scrollToCurrent() {
    if (homeProvider.selectedIndex == -1) return;
    printLog("selectedIndex ======> ${homeProvider.selectedIndex.toDouble()}");
    observerController.animateTo(
      index: homeProvider.selectedIndex,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (!mounted) return false;
          if (nestedScrollController.position.userScrollDirection ==
                  ScrollDirection.reverse &&
              sectionDataProvider.sectionList != null &&
              (sectionDataProvider.sectionList?.length ?? 0) > 2) {
            bottombarProvider.setAppbarVisibility(false);
          } else if (nestedScrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
            bottombarProvider.setAppbarVisibility(true);
          }
          return true;
        },
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: Consumer2<HomeProvider, BottombarProvider>(
                  builder: (context, homeProvider, bottombarProvider, child) {
                    return SliverAppBar(
                      centerTitle: false,
                      automaticallyImplyLeading: false,
                      backgroundColor: transparent,
                      toolbarHeight:
                          (bottombarProvider.isShowAppbar) ? kToolbarHeight : 0,
                      title: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FittedBox(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              splashColor: transparent,
                              highlightColor: transparent,
                              onTap: () async {
                                await getTabData(
                                    -1, homeProvider.sectionTypeModel.result);
                              },
                              child: MyImage(
                                width: 80,
                                height: 80,
                                imagePath: "appicon.png",
                              ),
                            ),
                          ),
                        ),
                      ),
                      pinned: true,
                      floating: true,
                      expandedHeight: 0,
                      forceElevated: innerBoxIsScrolled,
                    );
                  },
                ),
              ),
            ];
          },
          body: _buildPageUI(),
        ),
      ),
    );
  }

  Widget _buildPageUI() {
    if (homeProvider.loading) {
      return ShimmerUtils.buildHomeMobileShimmer(context);
    } else {
      if (homeProvider.sectionTypeModel.status == 200) {
        if (homeProvider.sectionTypeModel.result != null ||
            (homeProvider.sectionTypeModel.result?.length ?? 0) > 0) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              /* Banner & Sections */
              Consumer<SectionDataProvider>(
                builder: (context, sectionDataProvider, child) {
                  if ((sectionDataProvider.sectionBannerModel.result == null ||
                          (sectionDataProvider
                                      .sectionBannerModel.result?.length ??
                                  0) ==
                              0) &&
                      (sectionDataProvider.sectionList?.length ?? 0) == 0 &&
                      !sectionDataProvider.loadingBanner &&
                      !sectionDataProvider.loadingSection) {
                    return Center(
                      child:
                          NoData(title: 'no_data', subTitle: 'no_video_show'),
                    );
                  } else {
                    return _buildTypeTabData(
                        homeProvider.sectionTypeModel.result);
                  }
                },
              ),

              /* Types */
              FittedBox(
                child: Container(
                  height: Dimens.homeTabHeightSmall,
                  padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: _buildTypeTabs(homeProvider.sectionTypeModel.result),
                ),
              ),
            ],
          );
        } else {
          return const Center(
            child: NoData(title: 'no_data', subTitle: 'no_video_show'),
          );
        }
      } else {
        return const Center(
          child: NoData(title: 'no_data', subTitle: 'no_video_show'),
        );
      }
    }
  }

  /* Type START ************** */
  Widget _buildTypeTabs(List<type.Result>? sectionTypeList) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        if (homeProvider.selectedIndex != -1) {
          return _buildSelectedTypeView(sectionTypeList);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (tabScrollController.hasClients) {
              _scrollToCurrent();
            }
          });
          return Visibility(
            visible: (homeProvider.selectedIndex == -1),
            maintainAnimation: true,
            maintainState: true,
            child: AnimatedOpacity(
              opacity: (homeProvider.selectedIndex == -1) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1000),
              child: ListViewObserver(
                controller: observerController,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 30),
                  decoration: Utils.setBGWithBorder(
                      secondaryBgColor, transparent, Dimens.menuRadius, 0),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ListView.separated(
                    itemCount: (sectionTypeList?.length ?? 0) > 3
                        ? 3
                        : (sectionTypeList?.length ?? 0),
                    shrinkWrap: true,
                    controller: tabScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    separatorBuilder: (context, index) => Container(
                      width: 1.5,
                      margin: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                      decoration: Utils.setBackground(grayDark, 5),
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 2) {
                        return _buildMoreBtn();
                      }
                      return InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () async {
                          printLog("index ===========> $index");
                          AdHelper.showFullscreenAd(
                              context, Constant.interstialAdType, () async {
                            await bottombarProvider.setAppbarVisibility(true);
                            await getTabData(
                                index, homeProvider.sectionTypeModel.result);
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                          child: MyText(
                            color: white,
                            multilanguage: false,
                            text:
                                (sectionTypeList?[index].name.toString() ?? ""),
                            fontsizeNormal: 14,
                            fontweight: FontWeight.w600,
                            fontsizeWeb: 15,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildSelectedTypeView(List<type.Result>? sectionTypeList) {
    return Visibility(
      visible: (homeProvider.selectedIndex != -1),
      maintainAnimation: true,
      maintainState: true,
      child: AnimatedOpacity(
        opacity: (homeProvider.selectedIndex != -1) ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 1000),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 35),
              decoration: Utils.setBGWithBorder(
                  secondaryBgColor, transparent, Dimens.menuRadius, 0),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: MyText(
                  color: white,
                  multilanguage: false,
                  text: (sectionTypeList?[(homeProvider.selectedIndex)]
                          .name
                          .toString() ??
                      ""),
                  fontsizeNormal: 14,
                  fontweight: FontWeight.w600,
                  fontsizeWeb: 15,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            /* Close */
            InkWell(
              onTap: () async {
                await getTabData(-1, sectionTypeList);
              },
              focusColor: white,
              borderRadius: BorderRadius.circular(Dimens.menuRadius),
              child: FittedBox(
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: secondaryBgColor,
                    borderRadius: BorderRadius.circular(Dimens.menuRadius),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: MyImage(
                    imagePath: "ic_close.png",
                    color: white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreBtn() {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () async {
        _openMoreDialog();
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: MyText(
          color: white,
          multilanguage: true,
          text: "more",
          fontsizeNormal: 14,
          fontweight: FontWeight.w600,
          fontsizeWeb: 15,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          textalign: TextAlign.center,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  Widget _buildTypeTabData(List<type.Result>? sectionTypeList) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: RefreshIndicator(
        backgroundColor: white,
        color: complimentryColor,
        displacement: 80,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 1500))
              .then((value) {
            printLog(
                "selectedIndex ===========> ${homeProvider.selectedIndex}");
            _getData();
            getTabData(homeProvider.selectedIndex,
                homeProvider.sectionTypeModel.result);
          });
        },
        child: SingleChildScrollView(
          controller: nestedScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: _buildBannerSections(),
        ),
      ),
    );
  }

  Widget _buildBannerSections() {
    printLog("sectionList ===> ${sectionDataProvider.sectionList?.length}");
    return Column(
      children: [
        /* Banner */
        if (sectionDataProvider.loadingBanner)
          if (Dimens.isBigScreen(context))
            ShimmerUtils.bannerWeb(context)
          else
            ShimmerUtils.bannerMobile(context)
        else if (sectionDataProvider.sectionBannerModel.status == 200 &&
            sectionDataProvider.sectionBannerModel.result != null)
          _mobileHomeBanner(sectionDataProvider.sectionBannerModel.result)
        else
          SafeArea(child: SizedBox(height: Dimens.homeTabHeightSmall)),

        /* AdMob Banner */
        Utils.showBannerAd(context),

        /* Remaining Sections */
        if (sectionDataProvider.loadingSection && !sectionDataProvider.loadMore)
          sectionShimmer()
        else if (sectionDataProvider.sectionList != null &&
            (sectionDataProvider.sectionList?.length ?? 0) > 0)
          setSectionByType(sectionDataProvider.sectionList)
        else
          const SizedBox.shrink(),

        /* Pagination loader */
        if (sectionDataProvider.loadMore)
          ShimmerUtils.sectionPortraitListView(context)
        else
          const SizedBox.shrink(),
        SizedBox(height: Dimens.homeTabHeight),
      ],
    );
  }
  /* **************** Type END */

  /* Banner START ************** */
  Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          /* Poster */
          SizedBox(
            height: Dimens.homeBanner,
            child: InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(0),
              onTap: () {
                printLog(
                    "Clicked on index ==> ${sectionDataProvider.cBannerIndex}");
                openDetailPage(
                  sectionBannerList?[(sectionDataProvider.cBannerIndex ?? 0)]
                          .id ??
                      0,
                  sectionBannerList?[(sectionDataProvider.cBannerIndex ?? 0)]
                          .subVideoType ??
                      0,
                  sectionBannerList?[(sectionDataProvider.cBannerIndex ?? 0)]
                          .videoType ??
                      0,
                  sectionBannerList?[(sectionDataProvider.cBannerIndex ?? 0)]
                          .typeId ??
                      0,
                );
              },
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: Dimens.homeBanner,
                    margin: EdgeInsets.only(bottom: Dimens.homeTabHeight),
                    child: MyNetworkImage(
                      imageUrl: sectionBannerList?[
                                  (sectionDataProvider.cBannerIndex ?? 0)]
                              .landscape ??
                          "",
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width,
                    height: Dimens.homeBanner,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          appBgColor.withOpacity(0.9),
                          appBgColor.withOpacity(0.5),
                          appBgColor.withOpacity(0.1),
                          transparent,
                          transparent,
                          transparent,
                          transparent,
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width,
                    height: Dimens.homeBanner,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          transparent,
                          appBgColor.withOpacity(0.2),
                          appBgColor.withOpacity(0.3),
                          appBgColor.withOpacity(0.5),
                          appBgColor.withOpacity(0.7),
                          appBgColor.withOpacity(0.8),
                          appBgColor.withOpacity(0.9),
                          appBgColor,
                          appBgColor,
                          appBgColor,
                          appBgColor,
                          appBgColor,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          /* Text */
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.homeBanner,
            child: CarouselSlider.builder(
              itemCount: (sectionBannerList?.length ?? 0),
              carouselController: carouselController,
              options: CarouselOptions(
                initialPage: 0,
                height: Dimens.homeBanner,
                enlargeCenterPage: false,
                enableInfiniteScroll:
                    (sectionBannerList?.length ?? 0) > 1 ? true : false,
                autoPlay: true,
                autoPlayCurve: Curves.linear,
                autoPlayInterval:
                    Duration(milliseconds: Constant.bannerDuration),
                autoPlayAnimationDuration:
                    Duration(milliseconds: Constant.animationDuration),
                viewportFraction: 1.0,
                onPageChanged: (val, _) async {
                  await sectionDataProvider.setCurrentBanner(val);
                },
              ),
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                return InkWell(
                  focusColor: white,
                  borderRadius: BorderRadius.circular(0),
                  onTap: () {
                    printLog("Clicked on index ==> $index");
                    openDetailPage(
                      sectionBannerList?[index].id ?? 0,
                      sectionBannerList?[index].subVideoType ?? 0,
                      sectionBannerList?[index].videoType ?? 0,
                      sectionBannerList?[index].typeId ?? 0,
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 55),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        /* Name */
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: MyText(
                            color: white,
                            text: (sectionBannerList?[index].name != null &&
                                    sectionBannerList?[index].name != "")
                                ? (sectionBannerList?[index].name ?? "")
                                : "-",
                            textalign: TextAlign.center,
                            fontsizeNormal: 23,
                            fontsizeWeb: 23,
                            fontweight: FontWeight.w700,
                            multilanguage: false,
                            maxline: 2,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                            withShaderMask: true,
                          ),
                        ),

                        /* Languages */
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                          alignment: Alignment.center,
                          child: MyText(
                            color: white,
                            text: (sectionBannerList?[index].totalLanguage !=
                                        null &&
                                    (sectionBannerList?[index].totalLanguage ??
                                            0) >
                                        0)
                                ? ("${(sectionBannerList?[index].totalLanguage ?? 0)} ${((sectionBannerList?[index].totalLanguage ?? 0) == 1) ? "Language" : "Languages"}")
                                : "-",
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            fontsizeWeb: 14,
                            fontweight: FontWeight.w600,
                            multilanguage: false,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                        /* Category */
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 3, 20, 38),
                          alignment: Alignment.center,
                          child: MyText(
                            color: white,
                            text: (sectionBannerList?[index].categoryName !=
                                        null &&
                                    sectionBannerList?[index].categoryName !=
                                        "")
                                ? ((sectionBannerList?[index].categoryName ??
                                        "")
                                    .replaceAll(RegExp('[,]'), ' $dotText'))
                                : "-",
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            fontsizeWeb: 14,
                            fontweight: FontWeight.w700,
                            multilanguage: false,
                            maxline: 2,
                            overflow: TextOverflow.ellipsis,
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
          /* Buttons & Dots */
          Positioned(
            bottom: 5,
            child: Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /* Watch Now */
                  _buildBannerWatchNow(
                      sectionDataProvider.cBannerIndex ?? 0, sectionBannerList),
                  /* Dots */
                  AnimatedSmoothIndicator(
                    count: (sectionBannerList?.length ?? 0),
                    activeIndex: sectionDataProvider.cBannerIndex ?? 0,
                    effect: const ScrollingDotsEffect(
                      spacing: 8,
                      radius: 4,
                      activeDotScale: 1.2,
                      activeDotColor: colorPrimary,
                      dotColor: defaultIconColor,
                      dotHeight: 6,
                      dotWidth: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildBannerWatchNow(
      int index, List<banner.Result>? sectionBannerList) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /* Watch Now */
          InkWell(
            onTap: () {
              openDetailPage(
                sectionBannerList?[index].id ?? 0,
                sectionBannerList?[index].subVideoType ?? 0,
                sectionBannerList?[index].videoType ?? 0,
                sectionBannerList?[index].typeId ?? 0,
              );
            },
            focusColor: white,
            borderRadius: BorderRadius.circular(10),
            child: FittedBox(
              child: Container(
                height: 45,
                padding: const EdgeInsets.fromLTRB(40, 2, 40, 2),
                decoration: BoxDecoration(
                  color: secondaryBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyImage(
                      width: 10,
                      height: 10,
                      imagePath: "ic_play.png",
                    ),
                    const SizedBox(width: 15),
                    MyText(
                      color: white,
                      text: "watch_now",
                      multilanguage: true,
                      textalign: TextAlign.start,
                      fontsizeNormal: 12,
                      fontweight: FontWeight.w700,
                      fontsizeWeb: 14,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          /* Add to Watchlist */
          InkWell(
            onTap: () async {
              if (Constant.userID != null) {
                await sectionDataProvider.setBookMark(
                    context, (sectionDataProvider.cBannerIndex ?? 0));
              } else {
                await Utils.openLogin(context: context, newPage: "");
              }
            },
            focusColor: white,
            borderRadius: BorderRadius.circular(10),
            child: FittedBox(
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: secondaryBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                child: MyImage(
                  imagePath: (sectionBannerList?[
                                      (sectionDataProvider.cBannerIndex ?? 0)]
                                  .isBookmark ??
                              0) ==
                          1
                      ? "ic_tick.png"
                      : "ic_plus.png",
                  color: white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  /* **************** Banner END */

  /* Sections START ************** */
  Widget setSectionByType(List<list.Result>? sectionList) {
    return ListView.builder(
      itemCount: sectionList?.length ?? 0,
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        if (sectionList?[index].data != null &&
            (sectionList?[index].data?.length ?? 0) > 0) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleViewAll(
                sectionList: sectionList,
                index: index,
                onViewAllClick: () async {
                  printLog("viewAll ====> ${sectionList?[index].viewAll}");
                  final sectionViewAllProvider =
                      Provider.of<SectionViewAllProvider>(context,
                          listen: false);
                  if ((sectionList?[index].viewAll ?? 0) == 1) {
                    await sectionViewAllProvider.setLoading(true);
                    if (!context.mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SectionViewAll(
                            sectionId: sectionList?[index].id ?? 0,
                            appBarTitle: sectionList?[index].title ?? "",
                            videoType: sectionList?[index].videoType ?? 0,
                          );
                        },
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: getRemainingDataHeight(
                  sectionList?[index].videoType.toString() ?? "",
                  sectionList?[index].screenLayout ?? "",
                ),
                child: setSectionData(sectionList: sectionList, index: index),
              ),
              const SizedBox(height: 25),
            ],
          );
        } else {
          if ((sectionDataProvider.sectionBannerModel.result == null ||
                  (sectionDataProvider.sectionBannerModel.result?.length ??
                          0) ==
                      0) &&
              (sectionDataProvider.sectionList != null &&
                  (sectionDataProvider.sectionList?.length ?? 0) == 1) &&
              !sectionDataProvider.loadingBanner &&
              !sectionDataProvider.loadingSection) {
            return const Center(
              child: NoData(title: 'no_data', subTitle: 'no_video_show'),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  Widget _buildTitleViewAll({
    required List<list.Result>? sectionList,
    required int index,
    required Function()? onViewAllClick,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: InkWell(
        onTap:
            ((sectionList?[index].viewAll ?? 0) == 1) ? onViewAllClick : null,
        borderRadius: BorderRadius.circular(3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: MyText(
                  color: (sectionList?[index].rentVideo != null &&
                          (sectionList?[index].rentVideo ?? 0) == 1)
                      ? colorAccent
                      : white,
                  text: sectionList?[index].title.toString() ?? "",
                  textalign: TextAlign.start,
                  fontsizeNormal: 15,
                  fontweight: FontWeight.w600,
                  fontsizeWeb: 17,
                  multilanguage: false,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ),
            if ((sectionList?[index].viewAll ?? 0) == 1)
              Container(
                alignment: Alignment.centerRight,
                height: 25,
                padding: const EdgeInsets.all(6),
                child: MyImage(
                  imagePath: "ic_viewall.png",
                  fit: BoxFit.contain,
                  color: (sectionList?[index].rentVideo != null &&
                          (sectionList?[index].rentVideo ?? 0) == 1)
                      ? colorAccent
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget setSectionData(
      {required List<list.Result>? sectionList, required int index}) {
    /* video_type    =>  1-Video, 2-Show, 3-Category, 4-Language, 5-Channel List, 6-Upcoming Content,
                         7-Channel Content, 8-Continue Watching, 9-Kids Content */
    /* screen_layout =>  landscape, big_landscape, index_landscape, portrait, big_portrait, index_portrait, square */
    if ((sectionList?[index].videoType ?? 0) == 1) {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "big_landscape") {
        return landscapeBig(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") ==
          "index_landscape") {
        return landscapeIndex(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "portrait") {
        return portrait(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "big_portrait") {
        return portraitBig(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "index_portrait") {
        return portraitIndex(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else {
        return landscape(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      }
    } else if ((sectionList?[index].videoType ?? 0) == 2) {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "big_landscape") {
        return landscapeBig(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") ==
          "index_landscape") {
        return landscapeIndex(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "portrait") {
        return portrait(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "big_portrait") {
        return portraitBig(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "index_portrait") {
        return portraitIndex(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else {
        return landscape(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      }
    } else if ((sectionList?[index].videoType ?? 0) == 3) {
      return genresLayout(sectionList?[index].videoType,
          sectionList?[index].typeId ?? 0, sectionList?[index].data);
    } else if ((sectionList?[index].videoType ?? 0) == 4) {
      return languageLayout(sectionList?[index].videoType,
          sectionList?[index].typeId ?? 0, sectionList?[index].data);
    } else if ((sectionList?[index].videoType ?? 0) == 5) {
      return channelLayout(sectionList?[index].videoType,
          sectionList?[index].typeId ?? 0, sectionList?[index].data);
    } else {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "big_landscape") {
        return landscapeBig(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") ==
          "index_landscape") {
        return landscapeIndex(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "portrait") {
        return portrait(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "big_portrait") {
        return portraitBig(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "index_portrait") {
        return portraitIndex(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      } else {
        return landscape(sectionList?[index].videoType,
            sectionList?[index].subVideoType, sectionList?[index].data);
      }
    }
  }

  double getRemainingDataHeight(String? videoType, String? layoutType) {
    if (videoType == "1" || videoType == "2") {
      if (layoutType == "landscape" || layoutType == "index_landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "big_landscape") {
        return Dimens.heightLandBig;
      } else if (layoutType == "portrait" || layoutType == "index_portrait") {
        return Dimens.heightPort;
      } else if (layoutType == "big_portrait") {
        return Dimens.heightPortBig;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    } else if (videoType == "3") {
      return Dimens.heightGenTotal;
    } else if (videoType == "4") {
      return Dimens.heightLang;
    } else if (videoType == "5") {
      return Dimens.heightChannel;
    } else if (videoType == "8") {
      if (layoutType == "landscape" || layoutType == "index_landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "big_landscape") {
        return Dimens.heightLandBig;
      } else if (layoutType == "portrait" || layoutType == "index_portrait") {
        return Dimens.heightPort;
      } else if (layoutType == "big_portrait") {
        return Dimens.heightPortBig;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    } else {
      if (layoutType == "landscape" || layoutType == "index_landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "big_landscape") {
        return Dimens.heightLandBig;
      } else if (layoutType == "portrait" || layoutType == "index_portrait") {
        return Dimens.heightPort;
      } else if (layoutType == "big_portrait") {
        return Dimens.heightPortBig;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    }
  }

  /* Continue Watching START ************** */
  Widget continueWatchingLayout(int? videoType, int? subVideoType, int index,
      List<Datum>? sectionDataList) {
    if (videoType != 8) {
      if (sectionDataList?[index].isTitle == 0) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
        alignment: Alignment.bottomLeft,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: Utils.setGradTTBBGWithCenter(
            transparent, appBgColor.withOpacity(0.1), appBgColor, 0),
        child: MyText(
          color: white,
          multilanguage: false,
          text: sectionDataList?[index].name.toString() ?? "",
          fontsizeNormal: 13,
          fontweight: FontWeight.w600,
          fontsizeWeb: 15,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          textalign: TextAlign.start,
          fontstyle: FontStyle.normal,
        ),
      );
    }
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
              openPlayer("ContinueWatch", index, sectionDataList);
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
                sectionDataList?[index].videoDuration ?? 0,
                sectionDataList?[index].stopTime ?? 0),
            backgroundColor: secProgressColor,
            progressColor: colorPrimary,
          ),
        ),
      ],
    );
  }
  /* **************** Continue Watching END */

  Widget landscape(
      int? videoType, int? subVideoType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLand,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCards),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadius),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              width: Dimens.widthLand,
              height: Dimens.heightLand,
              child: InkWell(
                focusColor: white,
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.cardRadius),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].landscape.toString() ?? "",
                        fit: BoxFit.fill,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    continueWatchingLayout(
                        videoType, subVideoType, index, sectionDataList),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget landscapeIndex(
      int? videoType, int? subVideoType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLand,
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 1,
        mainAxisSpacing: 30,
        itemCount: (sectionDataList?.length ?? 0),
        padding: const EdgeInsets.fromLTRB(40, 0, 20, 0),
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, index) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              /* Image */
              InkWell(
                borderRadius: BorderRadius.circular(Dimens.cardRadius),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.cardRadius),
                  child: MyNetworkImage(
                    width: Dimens.widthLand,
                    height: Dimens.heightLand,
                    fit: BoxFit.fill,
                    imageUrl:
                        sectionDataList?[index].landscape.toString() ?? "",
                  ),
                ),
              ),
              /* Count */
              Container(
                transform: Matrix4.translationValues(-17, 0, 0),
                child: Text(
                  "${index + 1}",
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontSize: 40,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 5
                        ..color = colorPrimary.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              Container(
                transform: Matrix4.translationValues(-19, 0, 0),
                child: Text(
                  "${index + 1}",
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontSize: 40,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 5
                        ..color = colorPrimary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget landscapeBig(
      int? videoType, int? subVideoType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLandBig,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCards),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadius),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              width: Dimens.widthLandBig,
              height: Dimens.heightLandBig,
              child: InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(Dimens.cardRadius),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.cardRadius),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].landscape.toString() ?? "",
                        fit: BoxFit.fill,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    continueWatchingLayout(
                        videoType, subVideoType, index, sectionDataList),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget portrait(
      int? videoType, int? subVideoType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightPort,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCards),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadius),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              width: Dimens.widthPort,
              height: Dimens.heightPort,
              child: InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(Dimens.cardRadius),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.cardRadius),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].thumbnail.toString() ?? "",
                        fit: BoxFit.fill,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    continueWatchingLayout(
                        videoType, subVideoType, index, sectionDataList),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget portraitBig(
      int? videoType, int? subVideoType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightPortBig,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCards),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadius),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              width: Dimens.widthPortBig,
              height: Dimens.heightPortBig,
              child: InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(Dimens.cardRadius),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.cardRadius),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].thumbnail.toString() ?? "",
                        fit: BoxFit.fill,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    continueWatchingLayout(
                        videoType, subVideoType, index, sectionDataList),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget portraitIndex(
      int? videoType, int? subVideoType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightPort,
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 1,
        mainAxisSpacing: 25,
        itemCount: (sectionDataList?.length ?? 0),
        padding: const EdgeInsets.fromLTRB(35, 0, 20, 0),
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, index) {
          return Stack(
            alignment: Alignment.bottomLeft,
            children: [
              /* Image */
              InkWell(
                borderRadius: BorderRadius.circular(Dimens.cardRadius),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.cardRadius),
                  child: MyNetworkImage(
                    width: Dimens.widthPort,
                    height: Dimens.heightPort,
                    fit: BoxFit.fill,
                    imageUrl:
                        sectionDataList?[index].thumbnail.toString() ?? "",
                  ),
                ),
              ),
              /* Count */
              Container(
                transform: Matrix4.translationValues(-11, 10, 0),
                child: Text(
                  "${index + 1}",
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontSize: 60,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 6
                        ..color = colorPrimary.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              Container(
                transform: Matrix4.translationValues(-15, 10, 0),
                child: Text(
                  "${index + 1}",
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontSize: 60,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 6
                        ..color = colorPrimary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget square(
      int? videoType, int? subVideoType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightSquare,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCards),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadius),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              width: Dimens.widthSquare,
              height: Dimens.heightSquare,
              child: InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(Dimens.cardRadius),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.cardRadius),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].thumbnail.toString() ?? "",
                        fit: BoxFit.fill,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    continueWatchingLayout(
                        videoType, subVideoType, index, sectionDataList),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget channelLayout(
      int? videoType, int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightChannel,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCards),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadius),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimens.cardRadius),
              focusColor: white,
              onTap: () async {
                printLog("Clicked on index ==> $index");
                final videoByIDProvider =
                    Provider.of<VideoByIDProvider>(context, listen: false);
                await videoByIDProvider.setLoading(true);
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ContentByID(
                        sectionDataList?[index].id ?? 0,
                        sectionDataList?[index].name ?? "",
                        "ByChannel",
                      );
                    },
                  ),
                );
              },
              child: Container(
                height: Dimens.heightChannel,
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration:
                    Utils.setBackground(secondaryBgColor, Dimens.cardRadius),
                constraints: const BoxConstraints(minWidth: 80),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.cardRadius),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: MyNetworkImage(
                    imageUrl:
                        sectionDataList?[index].portraitImg.toString() ?? "",
                    fit: BoxFit.contain,
                    width: Dimens.widthChannel,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget languageLayout(
      int? videoType, int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLang,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCards),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadius),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimens.cardRadius),
              focusColor: white,
              onTap: () async {
                printLog("Clicked on index ==> $index");
                final videoByIDProvider =
                    Provider.of<VideoByIDProvider>(context, listen: false);
                await videoByIDProvider.setLoading(true);
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ContentByID(
                        sectionDataList?[index].id ?? 0,
                        sectionDataList?[index].name ?? "",
                        "ByLanguage",
                      );
                    },
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                decoration:
                    Utils.setBackground(secondaryBgColor, Dimens.cardRadius),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.cardRadius),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].image.toString() ?? "",
                        fit: BoxFit.contain,
                        height: Dimens.heightLangImage,
                        width: Dimens.widthLang,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: MyText(
                        color: colorPrimary,
                        text: sectionDataList?[index].name.toString() ?? "",
                        textalign: TextAlign.center,
                        fontsizeNormal: 12,
                        fontweight: FontWeight.w400,
                        fontsizeWeb: 15,
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget genresLayout(
      int? videoType, int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightGenTotal,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCategory),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: Dimens.heightGenTotal,
            width: Dimens.widthGen,
            alignment: Alignment.center,
            child: InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(Dimens.cardRadius),
              onTap: () async {
                printLog("Clicked on index ==> $index");
                final videoByIDProvider =
                    Provider.of<VideoByIDProvider>(context, listen: false);
                await videoByIDProvider.setLoading(true);
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ContentByID(
                        sectionDataList?[index].id ?? 0,
                        sectionDataList?[index].name ?? "",
                        "ByCategory",
                      );
                    },
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.widthGen / 2),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: MyNetworkImage(
                      imageUrl: sectionDataList?[index].image.toString() ?? "",
                      fit: BoxFit.cover,
                      height: Dimens.heightGen,
                      width: Dimens.widthGen,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child: MyText(
                      color: colorPrimary,
                      text: sectionDataList?[index].name.toString() ?? "",
                      textalign: TextAlign.center,
                      fontsizeNormal: 13,
                      fontweight: FontWeight.w500,
                      fontsizeWeb: 15,
                      multilanguage: false,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  /* ***************** Sections END */

  /* Section Shimmer */
  Widget sectionShimmer() {
    return ListView.builder(
      itemCount: 10, // itemCount must be greater than 5
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        if (index == 1) {
          return ShimmerUtils.setHomeSections(context, "portrait");
        } else if (index == 2) {
          return ShimmerUtils.setHomeSections(context, "square");
        } else if (index == 3) {
          return ShimmerUtils.setHomeSections(context, "langGen");
        } else {
          return ShimmerUtils.setHomeSections(context, "landscape");
        }
      },
    );
  }
}
