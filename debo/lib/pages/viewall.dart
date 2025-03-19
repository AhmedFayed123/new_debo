import 'dart:async';


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../provider/viewallprovider.dart';
import '../routes/routes_constant.dart';
import '../shimmer/shimmerutils.dart';
import '../utils/color.dart';
import '../utils/dimens.dart';
import '../utils/utils.dart';
import '../widget/mynetworkimg.dart';
import '../widget/nodata.dart';

class ViewAll extends StatefulWidget {
  final String appBarTitle;
  final int videoId, subVideoType, videoType, typeId;
  const ViewAll({
    required this.appBarTitle,
    required this.videoId,
    required this.subVideoType,
    required this.videoType,
    required this.typeId,
    super.key,
  });

  @override
  State<ViewAll> createState() => ViewAllState();
}

class ViewAllState extends State<ViewAll> {
  late ViewAllProvider viewAllProvider;
  final _scrollController = ScrollController();

  _nestedScrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (viewAllProvider.isMorePage ?? false)) {
      await viewAllProvider.setLoadMore(true);
      if (widget.appBarTitle == "customer_also_watch") {
        _fetchRelatedContent(viewAllProvider.currentPage ?? 0);
      } else if (widget.appBarTitle == "continuewatching") {
        _fetchContinueWatch(viewAllProvider.currentPage ?? 0);
      }
    }
  }

  Future<void> _fetchRelatedContent(int? nextPage) async {
    printLog("_fetchRelatedContent nextPage  ========> $nextPage");
    printLog(
        "_fetchRelatedContent isMorePage  ======> ${viewAllProvider.isMorePage}");
    printLog(
        "_fetchRelatedContent currentPage ======> ${viewAllProvider.currentPage}");
    printLog(
        "_fetchRelatedContent totalPage   ======> ${viewAllProvider.totalPage}");

    await viewAllProvider.getRelatedContent(widget.typeId, widget.videoType,
        widget.videoId, widget.subVideoType, (nextPage ?? 0) + 1);
    printLog(
        "_fetchRelatedContent length ==> ${viewAllProvider.relatedList?.length}");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _fetchContinueWatch(int? nextPage) async {
    printLog("_fetchContinueWatch nextPage  ========> $nextPage");
    printLog(
        "_fetchContinueWatch isMorePage  ======> ${viewAllProvider.isMorePage}");
    printLog(
        "_fetchContinueWatch currentPage ======> ${viewAllProvider.currentPage}");
    printLog(
        "_fetchContinueWatch totalPage   ======> ${viewAllProvider.totalPage}");

    await viewAllProvider.getContinueWatching((nextPage ?? 0) + 1);
    printLog(
        "_fetchContinueWatch length ==> ${viewAllProvider.continueWatchList?.length}");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void initState() {
    _scrollController.addListener(_nestedScrollListener);
    viewAllProvider = Provider.of<ViewAllProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  _getData() async {
    if (widget.appBarTitle == "customer_also_watch") {
      viewAllProvider.relatedList?.clear();
      viewAllProvider.relatedList = [];
      _fetchRelatedContent(0);
    } else if (widget.appBarTitle == "continuewatching") {
      viewAllProvider.continueWatchList?.clear();
      viewAllProvider.continueWatchList = [];
      _fetchContinueWatch(0);
    }
  }

  @override
  void dispose() {
    viewAllProvider.clearProvider();
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
            Utils.myAppBarWithBack(context, widget.appBarTitle, true),
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
    if (viewAllProvider.loading) {
      return SingleChildScrollView(
        child: ShimmerUtils.responsiveGrid2(context, Dimens.heightPortOther,
            Dimens.widthPortOther, 3, 3, 3, 12),
      );
    }
    if ((widget.appBarTitle == "customer_also_watch" &&
            viewAllProvider.relatedContentModel.status == 200 &&
            (viewAllProvider.relatedList?.length ?? 0) > 0) ||
        widget.appBarTitle == "continuewatching" &&
            viewAllProvider.continueWatchingModel.status == 200 &&
            (viewAllProvider.continueWatchList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _setContentByType(),

            /* Pagination loader */
            Consumer<ViewAllProvider>(
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
      );
    } else {
      return const NoData(title: 'no_data', subTitle: 'no_video_show');
    }
  }

  Widget _setContentByType() {
    switch (widget.appBarTitle) {
      case 'customer_also_watch':
        return _buildRelatedItem();
      case 'continuewatching':
        return _buildContinueWatchItem();
      default:
        return _buildRelatedItem();
    }
  }

  Widget _buildRelatedItem() {
    return RefreshIndicator(
      backgroundColor: white,
      color: complimentryColor,
      displacement: 80,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1500)).then((value) {
          viewAllProvider.setLoading(true);
          Future.delayed(Duration.zero).then((value) {
            if (!mounted) return;
            setState(() {});
          });
          _getData();
        });
      },
      child: Container(
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
            (viewAllProvider.relatedList?.length ?? 0),
            (position) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.cardRadiusSmall),
                child: InkWell(
                  onTap: () async {
                    printLog("Clicked on position ==> $position");
                    Utils.openDetailsWithReplace(
                      context: context,
                      videoId: viewAllProvider.relatedList?[position].id ?? 0,
                      subVideoType:
                          viewAllProvider.relatedList?[position].subVideoType ??
                              0,
                      videoType:
                          viewAllProvider.relatedList?[position].videoType ?? 0,
                      typeId:
                          viewAllProvider.relatedList?[position].typeId ?? 0,
                      newPage: ((viewAllProvider.relatedList?[position]
                                          .subVideoType ??
                                      0) ==
                                  2 ||
                              (viewAllProvider
                                          .relatedList?[position].videoType ??
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
                      imageUrl: viewAllProvider.relatedList?[position].thumbnail
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
      ),
    );
  }

  Widget _buildContinueWatchItem() {
    return RefreshIndicator(
      backgroundColor: white,
      color: complimentryColor,
      displacement: 80,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1500)).then((value) {
          viewAllProvider.setLoading(true);
          Future.delayed(Duration.zero).then((value) {
            if (!mounted) return;
            setState(() {});
          });
          _getData();
        });
      },
      child: Container(
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
            (viewAllProvider.continueWatchList?.length ?? 0),
            (position) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.cardRadiusSmall),
                child: InkWell(
                  onTap: () async {
                    printLog("Clicked on position ==> $position");
                    Utils.openDetails(
                      context: context,
                      videoId:
                          viewAllProvider.continueWatchList?[position].id ?? 0,
                      subVideoType: viewAllProvider
                              .continueWatchList?[position].subVideoType ??
                          0,
                      videoType: viewAllProvider
                              .continueWatchList?[position].videoType ??
                          0,
                      typeId:
                          viewAllProvider.continueWatchList?[position].typeId ??
                              0,
                      newPage: ((viewAllProvider.continueWatchList?[position]
                                          .subVideoType ??
                                      0) ==
                                  2 ||
                              (viewAllProvider.continueWatchList?[position]
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
                      imageUrl: viewAllProvider
                              .continueWatchList?[position].thumbnail
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
      ),
    );
  }
}
