import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../provider/sectionviewallprovider.dart';
import '../provider/videobyidprovider.dart';
import '../routes/routes_constant.dart';
import '../shimmer/shimmerutils.dart';
import '../utils/color.dart';
import '../utils/dimens.dart';
import '../utils/utils.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';
import 'contentbyid.dart';

class SectionViewAll extends StatefulWidget {
  final int sectionId, videoType;
  final String appBarTitle;
  const SectionViewAll({
    required this.appBarTitle,
    required this.sectionId,
    required this.videoType,
    super.key,
  });

  @override
  State<SectionViewAll> createState() => SectionViewAllState();
}

class SectionViewAllState extends State<SectionViewAll> {
  Timer? _timer;
  late SectionViewAllProvider sectionViewAllProvider;
  final _scrollController = ScrollController();

  _nestedScrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (sectionViewAllProvider.isMorePage ?? false)) {
      await sectionViewAllProvider.setLoadMore(true);
      _fetchSectionDetails(sectionViewAllProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchSectionDetails(int? nextPage) async {
    printLog("_fetchSectionDetails nextPage  ========> $nextPage");
    printLog(
        "_fetchSectionDetails isMorePage  ======> ${sectionViewAllProvider.isMorePage}");
    printLog(
        "_fetchSectionDetails currentPage ======> ${sectionViewAllProvider.currentPage}");
    printLog(
        "_fetchSectionDetails totalPage   ======> ${sectionViewAllProvider.totalPage}");

    await sectionViewAllProvider.getSectionDetails(
        widget.sectionId, (nextPage ?? 0) + 1);
    printLog(
        "sectionDetailsList length ==> ${sectionViewAllProvider.sectionDetailList?.length}");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void initState() {
    _scrollController.addListener(_nestedScrollListener);
    sectionViewAllProvider =
        Provider.of<SectionViewAllProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  _getData() async {
    await _fetchSectionDetails(0);
    if (widget.videoType.toString() == "3" ||
        widget.videoType.toString() == "4" ||
        widget.videoType.toString() == "5") {
      _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) async {
        if (sectionViewAllProvider.isMorePage == true) {
          await sectionViewAllProvider.setLoadMore(true);
          await _fetchSectionDetails(sectionViewAllProvider.currentPage ?? 0);
        } else {
          printLog("======== CANCELLED ========");
          timer.cancel();
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 400)).then((value) async {
        if (sectionViewAllProvider.isMorePage == true) {
          await sectionViewAllProvider.setLoadMore(true);
          await _fetchSectionDetails(sectionViewAllProvider.currentPage ?? 0);
        }
      });
    }
  }

  @override
  void dispose() {
    sectionViewAllProvider.clearProvider();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Utils.myAppBarWithBack(context, widget.appBarTitle, false),
            Expanded(
              child: _buildPage(),
            ),
            /* AdMob Banner */
            Container(
              child: Utils.showBannerAd(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    if (sectionViewAllProvider.loading && !sectionViewAllProvider.loadMore) {
      if (widget.videoType == 3) {
        return SingleChildScrollView(
          child: ShimmerUtils.responsiveGrid2(
              context, Dimens.heightGenTotal, Dimens.widthGen, 3, 3, 3, 25),
        );
      } else if (widget.videoType == 4 || widget.videoType == 5) {
        return SingleChildScrollView(
          child: ShimmerUtils.responsiveGrid2(
              context, Dimens.heightChannel, Dimens.widthChannel, 3, 3, 3, 25),
        );
      } else {
        return SingleChildScrollView(
          child: ShimmerUtils.responsiveGrid2(context, Dimens.heightPortOther,
              Dimens.widthPortOther, 3, 3, 3, 12),
        );
      }
    }
    if (sectionViewAllProvider.sectionDetailList != null &&
        (sectionViewAllProvider.sectionDetailList?.length ?? 0) > 0) {
      return RefreshIndicator(
        backgroundColor: white,
        color: complimentryColor,
        displacement: 80,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 1500))
              .then((value) {
            sectionViewAllProvider.setLoading(true);
            Future.delayed(Duration.zero).then((value) {
              if (!mounted) return;
              setState(() {});
            });
            _getData();
          });
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              if (widget.videoType == 3)
                _buildGenres()
              else if (widget.videoType == 4)
                _buildLanguage()
              else if (widget.videoType == 5)
                _buildChannelItem()
              else
                _buildVideoItem(),

              /* Pagination loader */
              Consumer<SectionViewAllProvider>(
                builder: (context, sectionViewAllProvider, child) {
                  if (sectionViewAllProvider.loadMore) {
                    return Container(
                      height: 80,
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: Utils.pageLoader(),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return NoData(
        title: (widget.videoType == 3)
            ? 'no_category_title'
            : ((widget.videoType == 4)
                ? 'no_language_title'
                : ((widget.videoType == 5) ? 'no_channel_title' : 'no_data')),
        subTitle: (widget.videoType == 3)
            ? 'no_category_desc'
            : ((widget.videoType == 4)
                ? 'no_language_desc'
                : ((widget.videoType == 5)
                    ? 'no_channel_desc'
                    : 'no_video_show')),
      );
    }
  }

  Widget _buildVideoItem() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
      child: ResponsiveGridList(
        minItemWidth: Dimens.widthPortOther,
        verticalGridSpacing: 3,
        horizontalGridSpacing: 3,
        minItemsPerRow: 3,
        maxItemsPerRow: 8,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          (sectionViewAllProvider.sectionDetailList?.length ?? 0),
          (position) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(Dimens.cardRadiusSmall),
              child: InkWell(
                onTap: () {
                  printLog("Clicked on position ==> $position");
                  Utils.openDetails(
                    context: context,
                    videoId: sectionViewAllProvider
                            .sectionDetailList?[position].id ??
                        0,
                    subVideoType: sectionViewAllProvider
                            .sectionDetailList?[position].subVideoType ??
                        0,
                    videoType: sectionViewAllProvider
                            .sectionDetailList?[position].videoType ??
                        0,
                    typeId: sectionViewAllProvider
                            .sectionDetailList?[position].typeId ??
                        0,
                    newPage: ((sectionViewAllProvider
                                        .sectionDetailList?[position]
                                        .subVideoType ??
                                    0) ==
                                2 ||
                            (sectionViewAllProvider.sectionDetailList?[position]
                                        .videoType ??
                                    0) ==
                                2)
                        ? RoutesConstant.showDetailsPage
                        : RoutesConstant.videoDetailsPage,
                    oldPage: "",
                    reqText: "",
                  );
                },
                child: Container(
                  width: Dimens.widthPortOther,
                  height: Dimens.heightPortOther,
                  alignment: Alignment.center,
                  child: MyNetworkImage(
                    imageUrl: sectionViewAllProvider
                            .sectionDetailList?[position].thumbnail
                            .toString() ??
                        "",
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChannelItem() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
      child: ResponsiveGridList(
        minItemWidth: Dimens.widthChannel,
        verticalGridSpacing: 8,
        horizontalGridSpacing: 8,
        minItemsPerRow: 3,
        maxItemsPerRow: 8,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          (sectionViewAllProvider.sectionDetailList?.length ?? 0),
          (position) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(Dimens.cardRadius),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimens.cardRadius),
                focusColor: white,
                onTap: () async {
                  printLog("Clicked on position ==> $position");
                  final videoByIDProvider =
                      Provider.of<VideoByIDProvider>(context, listen: false);
                  await videoByIDProvider.setLoading(true);
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ContentByID(
                          sectionViewAllProvider
                                  .sectionDetailList?[position].id ??
                              0,
                          sectionViewAllProvider
                                  .sectionDetailList?[position].name ??
                              "",
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
                      imageUrl: sectionViewAllProvider
                              .sectionDetailList?[position].landscapeImg
                              .toString() ??
                          "",
                      fit: BoxFit.contain,
                      width: Dimens.widthChannel,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguage() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
      child: ResponsiveGridList(
        minItemWidth: Dimens.widthLang,
        verticalGridSpacing: 8,
        horizontalGridSpacing: 5,
        minItemsPerRow: 3,
        maxItemsPerRow: 8,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          (sectionViewAllProvider.sectionDetailList?.length ?? 0),
          (position) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(Dimens.cardRadius),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimens.cardRadius),
                focusColor: white,
                onTap: () async {
                  printLog("Clicked on position ==> $position");
                  final videoByIDProvider =
                      Provider.of<VideoByIDProvider>(context, listen: false);
                  await videoByIDProvider.setLoading(true);
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ContentByID(
                          sectionViewAllProvider
                                  .sectionDetailList?[position].id ??
                              0,
                          sectionViewAllProvider
                                  .sectionDetailList?[position].name ??
                              "",
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
                          imageUrl: sectionViewAllProvider
                                  .sectionDetailList?[position].image
                                  .toString() ??
                              "",
                          fit: BoxFit.contain,
                          height: Dimens.heightLangImage,
                          width: Dimens.widthLang,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: MyText(
                          color: colorPrimary,
                          text: sectionViewAllProvider
                                  .sectionDetailList?[position].name
                                  .toString() ??
                              "",
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
      ),
    );
  }

  Widget _buildGenres() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
      child: ResponsiveGridList(
        minItemWidth: Dimens.widthGen,
        verticalGridSpacing: 12,
        horizontalGridSpacing: 10,
        minItemsPerRow: 3,
        maxItemsPerRow: 8,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          (sectionViewAllProvider.sectionDetailList?.length ?? 0),
          (position) {
            return Container(
              height: Dimens.heightGenTotal,
              width: Dimens.widthGen,
              alignment: Alignment.center,
              child: InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(Dimens.cardRadius),
                onTap: () async {
                  printLog("Clicked on position ==> $position");
                  final videoByIDProvider =
                      Provider.of<VideoByIDProvider>(context, listen: false);
                  await videoByIDProvider.setLoading(true);
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ContentByID(
                          sectionViewAllProvider
                                  .sectionDetailList?[position].id ??
                              0,
                          sectionViewAllProvider
                                  .sectionDetailList?[position].name ??
                              "",
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
                        imageUrl: sectionViewAllProvider
                                .sectionDetailList?[position].image
                                .toString() ??
                            "",
                        fit: BoxFit.cover,
                        height: Dimens.heightGen,
                        width: Dimens.widthGen,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: MyText(
                        color: white,
                        text: sectionViewAllProvider
                                .sectionDetailList?[position].name
                                .toString() ??
                            "",
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
      ),
    );
  }
}
