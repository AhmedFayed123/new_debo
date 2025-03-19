import 'dart:async';

import 'package:debo/webpages/webcomman.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:carousel_slider/carousel_slider.dart';


import '../model/playermodel.dart';
import '../model/sectionlistmodel.dart';
import '../model/sectiontypemodel.dart' as type;
import '../model/sectionlistmodel.dart' as list;
import '../model/sectionbannermodel.dart' as banner;

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../provider/generalprovider.dart';
import '../provider/homeprovider.dart';
import '../provider/sectiondataprovider.dart';
import '../provider/sectionviewallprovider.dart';
import '../routes/routes_constant.dart';
import '../shimmer/shimmerutils.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/sharedpre.dart';
import '../utils/utils.dart';
import '../webwidget/interactive_icon.dart';
import '../widget/myimage.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';

class WebHome extends StatefulWidget {
  final String? newPage, oldPage;
  final dynamic reqText;
  const WebHome({
    super.key,
    required this.newPage,
    required this.oldPage,
    required this.reqText,
  });

  @override
  State<WebHome> createState() => WebHomeState();
}

class WebHomeState extends State<WebHome> {
  SharedPre sharedPref = SharedPre();
  late SectionDataProvider sectionDataProvider;
  late HomeProvider homeProvider;

  final TextEditingController searchController = TextEditingController();
  CarouselSliderController carouselController = CarouselSliderController();

  int? videoId, videoType, typeId;
  bool isSearchEnable = false;
  String? currentPage, langCatName, mSearchText, subscriptionStatus;

  @override
  void initState() {
    currentPage = widget.newPage ?? "";
    sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  _getData() async {
    Utils.getCurrencySymbol();
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);

    subscriptionStatus =
        await Utils.configByStatus(status: Constant.subscriptionStatus);
    printLog('_getData subscriptionStatus ===> $subscriptionStatus');

    Constant.userID = await sharedPref.read("userid");
    Constant.userIsKid = await sharedPref.readBool(Constant.profileUserKey);
    printLog('Constant userID =====> ${Constant.userID}');
    printLog('Constant userIsKid ==> ${Constant.userIsKid}');
    await homeProvider.setLoading(true);
    await homeProvider.getSectionType();

    printLog('_getData oldPage ==> ${widget.oldPage}');
    printLog('_getData newPage ==> ${widget.newPage}');
    if (!homeProvider.loading && widget.oldPage == RoutesConstant.homePage) {
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
      if (!context.mounted) return;
      setState(() {});
    });
    if (!mounted) return;
    generalProvider.getGeneralsetting(context);
  }

  Future<void> setSelectedTab(int tabPos) async {
    if (!mounted) return;
    await homeProvider.setSelectedTab(tabPos);

    printLog("getTabData position ====> $tabPos");
    printLog(
        "getTabData lastTabPosition ====> ${sectionDataProvider.lastTabPosition}");
    if (sectionDataProvider.lastTabPosition == tabPos) {
      return;
    } else {
      sectionDataProvider.setTabPosition(tabPos);
    }
  }

  Future<void> getTabData(
      int position, List<type.Result>? sectionTypeList) async {
    await sectionDataProvider.setLoading(true);
    if (position == -1) {
      await setSelectedTab(0);
      await sectionDataProvider.getSectionBanner("0", "1");
      await sectionDataProvider.getSectionList("0", "1", 1);
    } else {
      await setSelectedTab(position + 1);
      await sectionDataProvider.getSectionBanner(
          sectionTypeList?[position].id ?? 0, "2");
      await sectionDataProvider.getSectionList(
          sectionTypeList?[position].id ?? 0, "2", 1);
    }
  }

  openDetailPage(
      int videoId, int subVideoType, int videoType, int typeId) async {
    printLog("videoId =========> $videoId");
    printLog("videoType =======> $videoType");
    printLog("subVideoType ====> $subVideoType");
    printLog("typeId ==========> $typeId");
    if (!mounted) return;
    Utils.openDetails(
      context: context,
      videoId: videoId,
      subVideoType: subVideoType,
      videoType: videoType,
      typeId: typeId,
      newPage: (subVideoType == 2 || videoType == 2)
          ? RoutesConstant.showDetailsPage
          : RoutesConstant.videoDetailsPage,
      oldPage: widget.newPage ?? "",
      reqText: '',
    );
  }

  /* ========= Open Player ========= */
  openPlayer(String playType, int index, List<list.Datum>? sectionList) async {
    printLog("index ==========> $index");

    /* CHECK SUBSCRIPTION */
    if (playType != "Trailer") {
      bool? isPrimiumUser = await Utils.checkSubsRentLogin(
        context: context,
        isPremium: sectionList?[index].isPremium ?? 0,
        isBuy: sectionList?[index].isPremium ?? 0,
        isRent: sectionList?[index].isRent ?? 0,
        rentBuy: sectionList?[index].rentBuy ?? 0,
        videoId: (sectionList?[index].id ?? 0).toString(),
        rentPrice: (sectionList?[index].price ?? 0).toString(),
        vTitle: (sectionList?[index].name ?? 0).toString(),
        typeId: (sectionList?[index].typeId ?? 0).toString(),
        vType: (sectionList?[index].videoType ?? 0).toString(),
        rentProductId: (sectionList?[index].videoType ?? 0).toString(),
        newPage: widget.newPage ?? "",
        oldPage: widget.oldPage ?? "",
        reqText: widget.reqText ?? "",
      );
      printLog("isPrimiumUser =============> $isPrimiumUser");
      if (!isPrimiumUser) return;
    }
    /* CHECK SUBSCRIPTION */

    if (!mounted) return;
    /* Set-up Quality URLs */
    Utils.setQualityURLs(
      video320: (sectionList?[index].video320 ?? ""),
      video480: (sectionList?[index].video480 ?? ""),
      video720: (sectionList?[index].video720 ?? ""),
      video1080: (sectionList?[index].video1080 ?? ""),
    );

    PlayerModel playerModel = PlayerModel(
      playType: ((sectionList?[index].videoType ?? 0) == 2 ||
              (sectionList?[index].subVideoType ?? 0) == 2)
          ? "Show"
          : "Video",
      videoId: (sectionList?[index].id ?? 0),
      videoTitle: sectionList?[index].name ?? "",
      videoType: sectionList?[index].videoType ?? 0,
      subVideoType: sectionList?[index].subVideoType ?? 0,
      typeId: sectionList?[index].typeId ?? 0,
      episodeId: 0,
      videoUrl: sectionList?[index].video320 ?? "",
      trailerUrl: sectionList?[index].trailerUrl ?? "",
      uploadType: sectionList?[index].videoUploadType ?? "",
      videoThumb: sectionList?[index].landscape ?? "",
      stopTime: sectionList?[index].stopTime ?? 0,
      securityKey: "",
    );

    var isContinues =
        await Utils.openPlayer(context: context, playerModel: playerModel);
    if (isContinues != null && isContinues == true) {
      getTabData(0, homeProvider.sectionTypeModel.result);
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }
  /* ========= Open Player ========= */

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebComman(
      newChild: _buildPageUI(),
      newPage: widget.newPage,
      oldPage: widget.oldPage,
      reqText: '',
    );
  }

  Widget _buildPageUI() {
    if (homeProvider.loading) {
      return ShimmerUtils.buildHomeMobileShimmer(context);
    } else {
      if (homeProvider.sectionTypeModel.status == 200) {
        if (homeProvider.sectionTypeModel.result != null ||
            (homeProvider.sectionTypeModel.result?.length ?? 0) > 0) {
          return _buildTypeTabData(homeProvider.sectionTypeModel.result);
        } else {
          return const SizedBox.shrink();
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildTypeTabData(List<type.Result>? sectionTypeList) {
    return Consumer<SectionDataProvider>(
      builder: (context, sectionDataProvider, child) {
        if ((sectionDataProvider.sectionBannerModel.result == null ||
                (sectionDataProvider.sectionBannerModel.result?.length ?? 0) ==
                    0) &&
            (sectionDataProvider.sectionList?.length ?? 0) == 0 &&
            !sectionDataProvider.loadingBanner &&
            !sectionDataProvider.loadingSection) {
          return Center(
            child: NoData(title: 'no_data', subTitle: 'no_video_show'),
          );
        } else {
          return _buildBannerSections();
        }
      },
    );
  }

  Widget _buildBannerSections() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          /* Banner */
          if (sectionDataProvider.loadingBanner)
            if (Dimens.isBigScreen(context))
              ShimmerUtils.bannerWeb(context)
            else
              ShimmerUtils.bannerMobile(context)
          else if (sectionDataProvider.sectionBannerModel.status == 200 &&
              sectionDataProvider.sectionBannerModel.result != null)
            if (Dimens.isBigScreen(context))
              _tvHomeBanner(sectionDataProvider.sectionBannerModel.result)
            else
              _mobileHomeBanner(sectionDataProvider.sectionBannerModel.result)
          else
            SizedBox(height: Dimens.homeTabHeight),

          /* Continue Watching & Remaining Sections */
          if (sectionDataProvider.loadingSection &&
              !sectionDataProvider.loadMore)
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
      ),
    );
  }

  /* Banner START ************** */
  Widget _tvHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimens.getResponsiveHeight(context, 0),
        child: CarouselSlider.builder(
          itemCount: (sectionBannerList?.length ?? 0),
          carouselController: carouselController,
          options: CarouselOptions(
            initialPage: 0,
            height: Dimens.getResponsiveHeight(context, 0),
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayCurve: Curves.easeInOutQuart,
            enableInfiniteScroll: true,
            autoPlayInterval: Duration(milliseconds: Constant.bannerDuration),
            autoPlayAnimationDuration:
                Duration(milliseconds: Constant.animationDuration),
            viewportFraction: 1.0,
            onPageChanged: (val, _) async {
              await sectionDataProvider.setCurrentBanner(val);
            },
          ),
          itemBuilder: (BuildContext context, int index, int pageViewIndex) {
            return InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                printLog("Clicked on index ==> $index");
                openDetailPage(
                  sectionBannerList?[index].id ?? 0,
                  sectionBannerList?[index].subVideoType ?? 0,
                  sectionBannerList?[index].videoType ?? 0,
                  sectionBannerList?[index].typeId ?? 0,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: Dimens.getResponsiveHeight(context, 0),
                      child: MyNetworkImage(
                        imageUrl: sectionBannerList?[index].landscape ?? "",
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(0),
                      width: MediaQuery.of(context).size.width * 0.5,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            appBgColor,
                            appBgColor.withOpacity(0.9),
                            appBgColor.withOpacity(0.7),
                            appBgColor.withOpacity(0.5),
                            appBgColor.withOpacity(0.3),
                            appBgColor.withOpacity(0.1),
                            transparent,
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(0),
                      width: MediaQuery.of(context).size.width,
                      transform: Matrix4.translationValues(0, 1, 0),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            appBgColor,
                            appBgColor.withOpacity(0.9),
                            appBgColor.withOpacity(0.7),
                            appBgColor.withOpacity(0.5),
                            appBgColor.withOpacity(0.3),
                            appBgColor.withOpacity(0.1),
                            transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 35,
                      bottom: 35,
                      child: Container(
                        width: Dimens.isBigScreen(context)
                            ? (MediaQuery.of(context).size.width * 0.35)
                            : (MediaQuery.of(context).size.width * 0.5),
                        constraints: const BoxConstraints(minHeight: 0),
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              color: white,
                              text: (sectionBannerList?[index].name != null &&
                                      sectionBannerList?[index].name != "")
                                  ? (sectionBannerList?[index].name ?? "")
                                  : "-",
                              textalign: TextAlign.start,
                              fontsizeNormal: 33,
                              fontsizeWeb: 33,
                              fontweight: FontWeight.w700,
                              multilanguage: false,
                              maxline: 2,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                              // withShaderMask: true,
                            ),
                            const SizedBox(height: 12),
                            /* Category */
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: MyText(
                                color: descTextColor,
                                text: Utils.convertHalfStopToVLine(
                                    sectionBannerList?[index].categoryName ??
                                        ""),
                                textalign: TextAlign.start,
                                fontsizeNormal: 13,
                                fontweight: FontWeight.w500,
                                fontsizeWeb: 15,
                                multilanguage: false,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              constraints: const BoxConstraints(minHeight: 0),
                              margin: const EdgeInsets.only(top: 8),
                              alignment: Alignment.centerLeft,
                              child: ExpandableText(
                                sectionBannerList?[index].description ?? "",
                                expandText: "",
                                collapseText: "",
                                maxLines: Dimens.isBigScreen(context) ? 2 : 3,
                                linkColor: descTextColor,
                                expandOnTextTap: true,
                                collapseOnTextTap: true,
                                style: kIsWeb
                                    ? TextStyle(
                                        fontSize: Dimens.isBigScreen(context)
                                            ? 15
                                            : 14,
                                        fontStyle: FontStyle.normal,
                                        color: descTextColor,
                                        fontWeight: FontWeight.normal,
                                      )
                                    : GoogleFonts.inter(
                                        textStyle: TextStyle(
                                          fontSize: Dimens.isBigScreen(context)
                                              ? 15
                                              : 14,
                                          fontStyle: FontStyle.normal,
                                          color: descTextColor,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                              ),
                            ),
                            /* Watch Now */
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _buildBannerWatchNow(
                                  index, sectionBannerList),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

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
                            // withShaderMask: true,
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
                                    .replaceAll(RegExp('[,]'), ' •'))
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
      height: Dimens.isBigScreen(context) ? 50 : 45,
      alignment: Alignment.center,
      margin: Dimens.isBigScreen(context)
          ? const EdgeInsets.fromLTRB(0, 30, 0, 20)
          : const EdgeInsets.fromLTRB(15, 15, 15, 15),
      child: Row(
        mainAxisAlignment: Dimens.isBigScreen(context)
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          /* Watch Now / Subscription */
          InteractiveIcon(builder: (isHovered) {
            return Material(
              type: MaterialType.transparency,
              child: InkWell(
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
                    height: Dimens.isBigScreen(context) ? 50 : 45,
                    padding: const EdgeInsets.fromLTRB(40, 2, 40, 2),
                    decoration: Dimens.isBigScreen(context)
                        ? Utils.setBackground(white.withOpacity(0.1), 8)
                        : Utils.setBackground(secondaryBgColor, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyImage(
                          width: 15,
                          height: 15,
                          imagePath: "ic_play.png",
                        ),
                        const SizedBox(width: 15),
                        MyText(
                          color: white,
                          text: "watch_now",
                          multilanguage: true,
                          fontsizeNormal: 14,
                          fontweight: FontWeight.w400,
                          fontsizeWeb: 15,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                          textalign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 20),
          /* Add to Watchlist */
          InteractiveIcon(builder: (isHovered) {
            return Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () async {
                  if (Constant.userID != null) {
                    await sectionDataProvider.setBookMark(
                        context, (sectionDataProvider.cBannerIndex ?? 0));
                  } else {
                    Utils.openLogin(
                        context: context, newPage: widget.newPage ?? "");
                  }
                },
                focusColor: white,
                borderRadius: BorderRadius.circular(10),
                child: FittedBox(
                  child: Container(
                    height: Dimens.isBigScreen(context) ? 50 : 45,
                    width: Dimens.isBigScreen(context) ? 50 : 45,
                    decoration: Dimens.isBigScreen(context)
                        ? Utils.setBackground(white.withOpacity(0.1), 8)
                        : Utils.setBackground(secondaryBgColor, 10),
                    padding: const EdgeInsets.all(16),
                    child: MyImage(
                      imagePath: (sectionBannerList?[
                                          (sectionDataProvider.cBannerIndex ??
                                              0)]
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
            );
          }),
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
                    context.pushNamed(
                      RoutesConstant.sectionDetailsPage,
                      extra: {
                        'newpage': widget.newPage.toString(),
                        'itemid': (sectionList?[index].id ?? 0).toString(),
                        'title': sectionList?[index].title ?? '',
                        'videotype':
                            (sectionList?[index].videoType ?? 0).toString(),
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: getRemainingDataHeight(
                  sectionList?[index].screenLayout.toString() ?? "",
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
      padding: EdgeInsets.fromLTRB(Dimens.isBigScreen(context) ? 35 : 20, 0,
          Dimens.isBigScreen(context) ? 35 : 20, 0),
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
                fontsizeNormal: 16,
                fontsizeWeb: 18,
                fontweight: FontWeight.w600,
                multilanguage: false,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
            ),
          ),
          if ((sectionList?[index].viewAll ?? 0) == 1)
            InkWell(
              onTap: onViewAllClick,
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
    );
  }

  Widget setSectionData(
      {required List<list.Result>? sectionList, required int index}) {
    /* video_type    =>  1-Video, 2-Show, 3-Category, 4-Language, 5-Channel List, 6-Upcoming Content, 
                         7-Channel Content, 8-Continue Watching, 9-Kids Content 
       screen_layout =>  landscape, big_landscape, index_landscape, portrait, big_portrait, index_portrait, 
                         square, category, language, channel */
    if ((sectionList?[index].screenLayout ?? "") == "landscape") {
      return landscape(sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "big_landscape") {
      return landscapeBig(sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "index_landscape") {
      return landscapeIndex(sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "portrait") {
      return portrait(sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "big_portrait") {
      return portraitBig(sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "index_portrait") {
      return portraitIndex(sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "square") {
      return square(sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "category") {
      return genresLayout(sectionList?[index].videoType,
          sectionList?[index].typeId ?? 0, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "language") {
      return languageLayout(sectionList?[index].videoType,
          sectionList?[index].typeId ?? 0, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "channel") {
      return channelLayout(sectionList?[index].videoType,
          sectionList?[index].typeId ?? 0, sectionList?[index].data);
    } else {
      return landscape(sectionList?[index].data);
    }
  }

  double getRemainingDataHeight(String? layoutType) {
    if (layoutType == "landscape" || layoutType == "index_landscape") {
      return Dimens.isBigScreen(context)
          ? Dimens.heightLandWeb
          : Dimens.heightLand;
    } else if (layoutType == "big_landscape") {
      return Dimens.isBigScreen(context)
          ? Dimens.heightLandBigWeb
          : Dimens.heightLandBig;
    } else if (layoutType == "portrait" || layoutType == "index_portrait") {
      return Dimens.isBigScreen(context)
          ? Dimens.heightPortWeb
          : Dimens.heightPort;
    } else if (layoutType == "big_portrait") {
      return Dimens.isBigScreen(context)
          ? Dimens.heightPortBigWeb
          : Dimens.heightPortBig;
    } else if (layoutType == "square") {
      return Dimens.isBigScreen(context)
          ? Dimens.heightSquareWeb
          : Dimens.heightSquare;
    } else if (layoutType == "category") {
      return Dimens.isBigScreen(context)
          ? Dimens.heightGenTotalWeb
          : Dimens.heightGenTotal;
    } else if (layoutType == "language") {
      return Dimens.isBigScreen(context)
          ? Dimens.heightLang
          : Dimens.heightLang;
    } else if (layoutType == "channel") {
      return Dimens.isBigScreen(context)
          ? Dimens.heightChannel
          : Dimens.heightChannel;
    } else {
      return Dimens.isBigScreen(context)
          ? Dimens.heightLandWeb
          : Dimens.heightLand;
    }
  }

  /* Continue Watching START ************** */
  Widget continueWatchingLayout(
      int? videoType, int index, List<Datum>? sectionDataList) {
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

  Widget landscape(List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.isBigScreen(context)
          ? Dimens.heightLandWeb
          : Dimens.heightLand,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            left: Dimens.isBigScreen(context) ? 35 : 20,
            right: Dimens.isBigScreen(context) ? 35 : 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCardsWeb),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              width: Dimens.isBigScreen(context)
                  ? Dimens.widthLandWeb
                  : Dimens.widthLand,
              height: Dimens.isBigScreen(context)
                  ? Dimens.heightLandWeb
                  : Dimens.heightLand,
              child: InkWell(
                focusColor: white,
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    sectionDataList?[index].subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].landscape.toString() ?? "",
                        fit: BoxFit.fill,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    continueWatchingLayout(videoType, index, sectionDataList),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget landscapeIndex(List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.isBigScreen(context)
          ? Dimens.heightLandWeb
          : Dimens.heightLand,
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 1,
        mainAxisSpacing: 30,
        itemCount: (sectionDataList?.length ?? 0),
        padding: EdgeInsets.only(
            left: Dimens.isBigScreen(context) ? 55 : 40,
            right: Dimens.isBigScreen(context) ? 35 : 20),
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, index) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              /* Image */
              InkWell(
                borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    sectionDataList?[index].subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
                  child: MyNetworkImage(
                    width: Dimens.isBigScreen(context)
                        ? Dimens.widthLandWeb
                        : Dimens.widthLand,
                    height: Dimens.isBigScreen(context)
                        ? Dimens.heightLandWeb
                        : Dimens.heightLand,
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
                  style: kIsWeb
                      ? TextStyle(
                          fontSize: 40,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 5
                            ..color = colorPrimary.withOpacity(0.7),
                        )
                      : GoogleFonts.inter(
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
                  style: kIsWeb
                      ? TextStyle(
                          fontSize: 40,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 5
                            ..color = colorPrimary,
                        )
                      : GoogleFonts.inter(
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

  Widget landscapeBig(List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.isBigScreen(context)
          ? Dimens.heightLandBigWeb
          : Dimens.heightLandBig,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            left: Dimens.isBigScreen(context) ? 35 : 20,
            right: Dimens.isBigScreen(context) ? 35 : 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCardsWeb),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              width: Dimens.isBigScreen(context)
                  ? Dimens.widthLandBigWeb
                  : Dimens.widthLandBig,
              height: Dimens.isBigScreen(context)
                  ? Dimens.heightLandBigWeb
                  : Dimens.heightLandBig,
              child: InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    sectionDataList?[index].subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
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
                        sectionDataList?[index].videoType ?? 0,
                        index,
                        sectionDataList),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget portrait(List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.isBigScreen(context)
          ? Dimens.heightPortWeb
          : Dimens.heightPort,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        padding: EdgeInsets.only(
            left: Dimens.isBigScreen(context) ? 35 : 20,
            right: Dimens.isBigScreen(context) ? 35 : 20),
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCardsWeb),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              width: Dimens.isBigScreen(context)
                  ? Dimens.widthPortWeb
                  : Dimens.widthPort,
              height: Dimens.isBigScreen(context)
                  ? Dimens.heightPortWeb
                  : Dimens.heightPort,
              child: InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    sectionDataList?[index].subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
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
                        sectionDataList?[index].videoType ?? 0,
                        index,
                        sectionDataList),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget portraitBig(List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.isBigScreen(context)
          ? Dimens.heightPortBigWeb
          : Dimens.heightPortBig,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        padding: EdgeInsets.only(
            left: Dimens.isBigScreen(context) ? 35 : 20,
            right: Dimens.isBigScreen(context) ? 35 : 20),
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCardsWeb),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              width: Dimens.isBigScreen(context)
                  ? Dimens.widthPortBigWeb
                  : Dimens.widthPortBig,
              height: Dimens.isBigScreen(context)
                  ? Dimens.heightPortBigWeb
                  : Dimens.heightPortBig,
              child: InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    sectionDataList?[index].subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
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
                        sectionDataList?[index].videoType ?? 0,
                        index,
                        sectionDataList),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget portraitIndex(List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.isBigScreen(context)
          ? Dimens.heightPortWeb
          : Dimens.heightPort,
      child: AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 1,
        mainAxisSpacing: 25,
        itemCount: (sectionDataList?.length ?? 0),
        padding: EdgeInsets.only(
            left: Dimens.isBigScreen(context) ? 50 : 35,
            right: Dimens.isBigScreen(context) ? 35 : 20),
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, index) {
          return Stack(
            alignment: Alignment.bottomLeft,
            children: [
              /* Image */
              InkWell(
                borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    sectionDataList?[index].subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
                  child: MyNetworkImage(
                    width: Dimens.isBigScreen(context)
                        ? Dimens.widthPortWeb
                        : Dimens.widthPort,
                    height: Dimens.isBigScreen(context)
                        ? Dimens.heightPortWeb
                        : Dimens.heightPort,
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
                  style: kIsWeb
                      ? TextStyle(
                          fontSize: 60,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 6
                            ..color = colorPrimary.withOpacity(0.7),
                        )
                      : GoogleFonts.inter(
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
                  style: kIsWeb
                      ? TextStyle(
                          fontSize: 60,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 6
                            ..color = colorPrimary,
                        )
                      : GoogleFonts.inter(
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

  Widget square(List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.isBigScreen(context)
          ? Dimens.heightSquareWeb
          : Dimens.heightSquare,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            left: Dimens.isBigScreen(context) ? 35 : 20,
            right: Dimens.isBigScreen(context) ? 35 : 20),
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCardsWeb),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              width: Dimens.isBigScreen(context)
                  ? Dimens.widthSquareWeb
                  : Dimens.widthSquare,
              height: Dimens.isBigScreen(context)
                  ? Dimens.heightSquareWeb
                  : Dimens.heightSquare,
              child: InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  openDetailPage(
                    sectionDataList?[index].id ?? 0,
                    sectionDataList?[index].subVideoType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
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
                        sectionDataList?[index].videoType ?? 0,
                        index,
                        sectionDataList),
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
      height: Dimens.isBigScreen(context)
          ? Dimens.heightChannel
          : Dimens.heightChannel,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            left: Dimens.isBigScreen(context) ? 35 : 20,
            right: Dimens.isBigScreen(context) ? 35 : 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCardsWeb),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
              focusColor: white,
              onTap: () async {
                printLog("Clicked on index ==> $index");
                if (!mounted) return;
                context.pushNamed(
                  RoutesConstant.videoByChannelPage,
                  extra: {
                    'newpage': widget.newPage.toString(),
                    'itemid': (sectionDataList?[index].id ?? 0).toString(),
                    'title': sectionDataList?[index].name ?? '',
                    'layouttype': 'ByChannel',
                  },
                );
              },
              child: Container(
                height: Dimens.isBigScreen(context)
                    ? Dimens.heightChannel
                    : Dimens.heightChannel,
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration:
                    Utils.setBackground(secondaryBgColor, Dimens.cardRadiusWeb),
                constraints: const BoxConstraints(minWidth: 80),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: MyNetworkImage(
                    imageUrl:
                        sectionDataList?[index].portraitImg.toString() ?? "",
                    fit: BoxFit.contain,
                    width: Dimens.isBigScreen(context)
                        ? Dimens.widthChannel
                        : Dimens.widthChannel,
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
      height:
          Dimens.isBigScreen(context) ? Dimens.heightLang : Dimens.heightLang,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            left: Dimens.isBigScreen(context) ? 35 : 20,
            right: Dimens.isBigScreen(context) ? 35 : 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCardsWeb),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
              focusColor: white,
              onTap: () async {
                printLog("Clicked on index ==> $index");
                if (!mounted) return;
                context.pushNamed(
                  RoutesConstant.videoByLanguagePage,
                  extra: {
                    'newpage': widget.newPage.toString(),
                    'itemid': (sectionDataList?[index].id ?? 0).toString(),
                    'title': sectionDataList?[index].name ?? '',
                    'layouttype': 'ByLanguage',
                  },
                );
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                decoration:
                    Utils.setBackground(secondaryBgColor, Dimens.cardRadiusWeb),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].image.toString() ?? "",
                        fit: BoxFit.contain,
                        width: Dimens.isBigScreen(context)
                            ? Dimens.widthLang
                            : Dimens.widthLang,
                        height: Dimens.isBigScreen(context)
                            ? Dimens.heightLangImage
                            : Dimens.heightLangImage,
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
      height: Dimens.isBigScreen(context)
          ? Dimens.heightGenTotalWeb
          : Dimens.heightGenTotal,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            left: Dimens.isBigScreen(context) ? 35 : 20,
            right: Dimens.isBigScreen(context) ? 35 : 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            SizedBox(width: Dimens.spaceBetweenCategoryWeb),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width:
                Dimens.isBigScreen(context) ? Dimens.widthGen : Dimens.widthGen,
            height: Dimens.isBigScreen(context)
                ? Dimens.heightGenTotalWeb
                : Dimens.heightGenTotal,
            alignment: Alignment.center,
            child: InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(Dimens.cardRadiusWeb),
              onTap: () async {
                printLog("Clicked on index ==> $index");
                if (!mounted) return;
                context.pushNamed(
                  RoutesConstant.videoByCatPage,
                  extra: {
                    'newpage': widget.newPage.toString(),
                    'itemid': (sectionDataList?[index].id ?? 0).toString(),
                    'title': sectionDataList?[index].name ?? '',
                    'layouttype': 'ByCategory',
                  },
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
                      width: Dimens.isBigScreen(context)
                          ? Dimens.widthGen
                          : Dimens.widthGen,
                      height: Dimens.isBigScreen(context)
                          ? Dimens.heightGen
                          : Dimens.heightGen,
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
