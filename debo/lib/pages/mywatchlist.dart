import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../model/playermodel.dart';
import '../provider/watchlistprovider.dart';
import '../routes/routes_constant.dart';
import '../shimmer/shimmerutils.dart';
import '../utils/adhelper.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/utils.dart';
import '../widget/myimage.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';

class MyWatchlist extends StatefulWidget {
  const MyWatchlist({super.key});

  @override
  State<MyWatchlist> createState() => _MyWatchlistState();
}

class _MyWatchlistState extends State<MyWatchlist> {
  late WatchlistProvider watchlistProvider;
  String? subscriptionStatus;
  final _scrollController = ScrollController();

  _nestedScrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (watchlistProvider.isMorePage ?? false)) {
      await watchlistProvider.setLoadMore(true);
      _fetchWatchlist(watchlistProvider.currentPage ?? 0);
    }
  }

  @override
  void initState() {
    _scrollController.addListener(_nestedScrollListener);
    watchlistProvider = Provider.of<WatchlistProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    super.initState();
  }

  _getData() async {
    subscriptionStatus =
        await Utils.configByStatus(status: Constant.subscriptionStatus);
    printLog('_getData subscriptionStatus ===> $subscriptionStatus');
    await watchlistProvider.getWatchlist(1);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _fetchWatchlist(int? nextPage) async {
    printLog("_fetchWatchlist nextPage  ========> $nextPage");
    printLog(
        "_fetchWatchlist isMorePage  ======> ${watchlistProvider.isMorePage}");
    printLog(
        "_fetchWatchlist currentPage ======> ${watchlistProvider.currentPage}");
    printLog(
        "_fetchWatchlist totalPage   ======> ${watchlistProvider.totalPage}");

    await watchlistProvider.getWatchlist((nextPage ?? 0) + 1);
    printLog(
        "_fetchWatchlist length ==> ${watchlistProvider.watchlistDataList?.length}");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    watchlistProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: Utils.myAppBarWithBack(context, "watchlist", true),
      body: SafeArea(
        child: Column(
          children: [
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
    if (watchlistProvider.loading) {
      return SingleChildScrollView(
        child: ShimmerUtils.buildWatchlistShimmer(context, 10),
      );
    }
    if (watchlistProvider.watchlistDataList != null &&
        (watchlistProvider.watchlistDataList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: RefreshIndicator(
          backgroundColor: white,
          color: complimentryColor,
          displacement: 80,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 1500))
                .then((value) {
              _getData();
            });
          },
          child: Column(
            children: [
              AlignedGridView.count(
                shrinkWrap: true,
                crossAxisCount: 1,
                crossAxisSpacing: 0,
                mainAxisSpacing: 8,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: watchlistProvider.watchlistDataList?.length ?? 0,
                itemBuilder: (BuildContext context, int position) {
                  return _buildWatchlistItem(position);
                },
              ),
              /* Pagination loader */
              Consumer<WatchlistProvider>(
                builder: (context, watchlistProvider, child) {
                  if (watchlistProvider.loadMore) {
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
      return const NoData(
        title: 'browse_now_watch_later',
        subTitle: 'watchlist_note',
      );
    }
  }

  Widget _buildWatchlistItem(position) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: BoxConstraints(minHeight: Dimens.heightWatchlist),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () async {
          printLog("Clicked on position ==> $position");
          await Utils.openDetails(
            context: context,
            videoId: watchlistProvider.watchlistDataList?[position].id ?? 0,
            subVideoType:
                watchlistProvider.watchlistDataList?[position].subVideoType ??
                    0,
            videoType:
                watchlistProvider.watchlistDataList?[position].videoType ?? 0,
            typeId: watchlistProvider.watchlistDataList?[position].typeId ?? 0,
            newPage: ((watchlistProvider
                                .watchlistDataList?[position].subVideoType ??
                            0) ==
                        2 ||
                    (watchlistProvider.watchlistDataList?[position].videoType ??
                            0) ==
                        2)
                ? RoutesConstant.showDetailsPage
                : RoutesConstant.videoDetailsPage,
            oldPage: "",
            reqText: "",
          );
          _getData();
        },
        child: Row(
          children: [
            _buildImage(position),
            _buildDetails(position),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(int position) {
    return Container(
      padding: const EdgeInsets.all(2),
      constraints: BoxConstraints(
        minHeight: Dimens.heightWatchlist,
        maxWidth: MediaQuery.of(context).size.width * 0.44,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: [
            Container(
              constraints: BoxConstraints(
                minHeight: Dimens.heightWatchlist,
                maxWidth: MediaQuery.of(context).size.width,
              ),
              child: MyNetworkImage(
                imageUrl: (watchlistProvider
                                .watchlistDataList?[position].landscape ??
                            "")
                        .isNotEmpty
                    ? (watchlistProvider
                            .watchlistDataList?[position].landscape ??
                        "")
                    : (watchlistProvider
                            .watchlistDataList?[position].thumbnail ??
                        ""),
                fit: BoxFit.fill,
              ),
            ),
            ((watchlistProvider.watchlistDataList?[position].videoType ?? 0) !=
                    2)
                ? _buildWatchBtnWithProgress(position)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(int position) {
    return Flexible(
      child: Container(
        constraints: BoxConstraints(
          minHeight: Dimens.heightWatchlist,
          maxWidth: MediaQuery.of(context).size.width * 0.66,
        ),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /* Title */
                  MyText(
                    color: titleTextColor,
                    text: watchlistProvider.watchlistDataList?[position].name ??
                        "",
                    textalign: TextAlign.start,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    fontsizeNormal: 13,
                    fontweight: FontWeight.w600,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 3),
                  /* Release Year & Video Duration */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (watchlistProvider
                                  .watchlistDataList?[position].releaseDate !=
                              null &&
                          (watchlistProvider.watchlistDataList?[position]
                                      .releaseDate ??
                                  "") !=
                              "")
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: MyText(
                            color: descTextColor,
                            text: DateFormat("yyyy").format(DateTime.parse(
                                watchlistProvider.watchlistDataList?[position]
                                        .releaseDate ??
                                    "")),
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.start,
                            fontsizeNormal: 12,
                            fontweight: FontWeight.w500,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      if ((watchlistProvider
                                      .watchlistDataList?[position].videoType ??
                                  0) !=
                              2 &&
                          watchlistProvider
                                  .watchlistDataList?[position].videoDuration !=
                              null &&
                          (watchlistProvider.watchlistDataList?[position]
                                      .videoDuration ??
                                  0) >
                              0)
                        Container(
                          margin: const EdgeInsets.only(right: 20),
                          child: MyText(
                            color: descTextColor,
                            text: Utils.convertInMin(watchlistProvider
                                    .watchlistDataList?[position]
                                    .videoDuration ??
                                0),
                            textalign: TextAlign.start,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontsizeNormal: 12,
                            fontweight: FontWeight.w500,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  /* Prime TAG  & Rent TAG */
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Prime TAG */
                      if ((watchlistProvider
                                  .watchlistDataList?[position].isPremium ??
                              0) ==
                          1)
                        MyText(
                          color: colorPrimary,
                          text: "primetag",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: 10,
                          fontweight: FontWeight.w800,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      const SizedBox(height: 3),
                      /* Rent TAG */
                      if ((watchlistProvider
                                  .watchlistDataList?[position].isRent ??
                              0) ==
                          1)
                        MyText(
                          color: titleTextColor,
                          text: "renttag",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: 11,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: InkWell(
                onTap: () {
                  _buildVideoMoreDialog(position);
                },
                child: Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(6),
                  child: MyImage(
                    width: 18,
                    height: 18,
                    imagePath: "ic_more.png",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchBtnWithProgress(position) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            openPlayer("Video", position);
          },
          child: Container(
            width: 35,
            height: 35,
            padding: const EdgeInsets.all(5),
            child: MyImage(
              imagePath: "play.png",
            ),
          ),
        ),
        if ((watchlistProvider.watchlistDataList?[position].videoDuration) !=
                null &&
            (watchlistProvider.watchlistDataList?[position].stopTime ?? 0) > 0)
          Container(
            constraints: const BoxConstraints(minWidth: 0),
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(3),
            child: LinearPercentIndicator(
              padding: const EdgeInsets.all(0),
              barRadius: const Radius.circular(2),
              lineHeight: 4,
              percent: Utils.getPercentage(
                  watchlistProvider
                          .watchlistDataList?[position].videoDuration ??
                      0,
                  watchlistProvider.watchlistDataList?[position].stopTime ?? 0),
              backgroundColor: secProgressColor,
              progressColor: colorAccent,
            ),
          ),
      ],
    );
  }

  _buildVideoMoreDialog(position) {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /* Title */
                  MyText(
                    text: watchlistProvider.watchlistDataList?[position].name ??
                        "",
                    multilanguage: false,
                    fontsizeNormal: 18,
                    fontsizeWeb: 20,
                    color: titleTextColor,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w700,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                  ),
                  const SizedBox(height: 5),
                  /* Release year, Video duration & Comment Icon */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if ((watchlistProvider
                                  .watchlistDataList?[position].releaseDate ??
                              "")
                          .isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: MyText(
                            color: descTextColor,
                            text: DateFormat("yyyy").format(DateTime.parse(
                                watchlistProvider.watchlistDataList?[position]
                                        .releaseDate ??
                                    "")),
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            fontsizeWeb: 13,
                            fontweight: FontWeight.w500,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      if ((watchlistProvider
                                      .watchlistDataList?[position].videoType ??
                                  0) !=
                              2 &&
                          watchlistProvider
                                  .watchlistDataList?[position].videoDuration !=
                              null &&
                          (watchlistProvider.watchlistDataList?[position]
                                      .videoDuration ??
                                  0) >
                              0)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: MyText(
                            color: descTextColor,
                            text: Utils.convertInMin(watchlistProvider
                                    .watchlistDataList?[position]
                                    .videoDuration ??
                                0),
                            textalign: TextAlign.center,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontsizeNormal: 12,
                            fontsizeWeb: 13,
                            fontweight: FontWeight.w500,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      MyImage(
                        width: 18,
                        height: 18,
                        imagePath: "ic_comment.png",
                        fit: BoxFit.fill,
                        color: defaultIconColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  /* Prime TAG  & Rent TAG */
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Prime TAG */
                      if ((watchlistProvider
                                  .watchlistDataList?[position].isPremium ??
                              0) ==
                          1)
                        MyText(
                          color: colorPrimary,
                          text: "primetag",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: 12,
                          fontweight: FontWeight.w800,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      const SizedBox(height: 5),
                      /* Rent TAG */
                      if ((watchlistProvider
                                  .watchlistDataList?[position].isRent ??
                              0) ==
                          1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: complimentryColor,
                                borderRadius: BorderRadius.circular(10),
                                shape: BoxShape.rectangle,
                              ),
                              margin: const EdgeInsets.only(right: 5),
                              alignment: Alignment.center,
                              child: MyText(
                                color: white,
                                text: Constant.currencySymbol,
                                textalign: TextAlign.center,
                                fontsizeNormal: 10,
                                multilanguage: false,
                                fontweight: FontWeight.w800,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                            MyText(
                              color: titleTextColor,
                              text: "renttag",
                              multilanguage: true,
                              textalign: TextAlign.start,
                              fontsizeNormal: 12,
                              fontweight: FontWeight.w500,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /* Watch Now / Resume */
                  if ((watchlistProvider
                              .watchlistDataList?[position].videoType ??
                          0) !=
                      2)
                    _buildDialogItems(
                      icon: (watchlistProvider
                                      .watchlistDataList?[position].stopTime ??
                                  0) >
                              0
                          ? "ic_resume.png"
                          : "ic_play.png",
                      title: (watchlistProvider
                                      .watchlistDataList?[position].stopTime ??
                                  0) >
                              0
                          ? "resume"
                          : "watch_now",
                      isMultilang: true,
                      onClick: () async {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        openPlayer("Video", position);
                      },
                    ),

                  /* Start Over */
                  if ((watchlistProvider
                                  .watchlistDataList?[position].stopTime ??
                              0) >
                          0 &&
                      (watchlistProvider
                                  .watchlistDataList?[position].videoType ??
                              0) !=
                          2)
                    _buildDialogItems(
                      icon: "ic_restart.png",
                      title: "startover",
                      isMultilang: true,
                      onClick: () async {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        openPlayer("startOver", position);
                      },
                    ),

                  /* Watch Trailer */
                  if ((watchlistProvider
                              .watchlistDataList?[position].videoType ??
                          0) !=
                      2)
                    _buildDialogItems(
                      icon: "ic_borderplay.png",
                      title: "watch_trailer",
                      isMultilang: true,
                      onClick: () async {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        if (!mounted) return;

                        AdHelper.showFullscreenAd(
                            context, Constant.interstialAdType, () async {
                          openPlayer("Trailer", position);
                        });
                      },
                    ),

                  /* Add to Watchlist / Remove from Watchlist */
                  _buildDialogItems(
                    icon: ((watchlistProvider
                                    .watchlistDataList?[position].isBookmark ??
                                0) ==
                            1)
                        ? "watchlist_remove.png"
                        : "ic_plus.png",
                    title: ((watchlistProvider
                                    .watchlistDataList?[position].isBookmark ??
                                0) ==
                            1)
                        ? "remove_from_watchlist"
                        : "add_to_watchlist",
                    isMultilang: true,
                    onClick: () async {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      printLog(
                          "isBookmark ====> ${watchlistProvider.watchlistDataList?[position].isBookmark ?? 0}");
                      if (Constant.userID != null) {
                        await watchlistProvider.setBookMark(
                          context,
                          position,
                          watchlistProvider
                                  .watchlistDataList?[position].subVideoType ??
                              0,
                          watchlistProvider
                                  .watchlistDataList?[position].videoType ??
                              0,
                          watchlistProvider.watchlistDataList?[position].id ??
                              0,
                        );
                      } else {
                        await Utils.openLogin(context: context, newPage: "");
                        _getData();
                      }
                    },
                  ),

                  /* Video Share */
                  _buildDialogItems(
                    icon: "ic_share.png",
                    title: "share",
                    isMultilang: true,
                    onClick: () async {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      _buildShareWithDialog(position);
                    },
                  ),

                  /* View Details */
                  _buildDialogItems(
                    icon: "ic_info.png",
                    title: "view_details",
                    isMultilang: true,
                    onClick: () async {
                      Navigator.pop(context);
                      printLog("Clicked on position :==> $position");
                      Utils.openDetails(
                        context: context,
                        videoId:
                            watchlistProvider.watchlistDataList?[position].id ??
                                0,
                        subVideoType: watchlistProvider
                                .watchlistDataList?[position].subVideoType ??
                            0,
                        videoType: watchlistProvider
                                .watchlistDataList?[position].videoType ??
                            0,
                        typeId: watchlistProvider
                                .watchlistDataList?[position].typeId ??
                            0,
                        newPage: ((watchlistProvider
                                            .watchlistDataList?[position]
                                            .subVideoType ??
                                        0) ==
                                    2 ||
                                (watchlistProvider.watchlistDataList?[position]
                                            .videoType ??
                                        0) ==
                                    2)
                            ? RoutesConstant.showDetailsPage
                            : RoutesConstant.videoDetailsPage,
                        oldPage: "",
                        reqText: "",
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _buildShareWithDialog(position) {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MyText(
                    text: watchlistProvider.watchlistDataList?[position].name ??
                        "",
                    multilanguage: false,
                    fontsizeNormal: 18,
                    fontsizeWeb: 20,
                    color: titleTextColor,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w700,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                  ),
                  const SizedBox(height: 12),

                  /* SMS */
                  _buildDialogItems(
                    icon: "ic_sms.png",
                    title: "sms",
                    isMultilang: true,
                    onClick: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      if (Platform.isAndroid) {
                        Utils.redirectToUrl(
                            'sms:?body=${Uri.encodeComponent("Hey! I'm watching ${watchlistProvider.watchlistDataList?[position].name ?? ""}. Check it out now on ${Constant.appName}! \n${Constant.androidAppUrl} \n")}');
                      } else if (Platform.isIOS) {
                        Utils.redirectToUrl(
                            'sms:&body=${Uri.encodeComponent("Hey! I'm watching ${watchlistProvider.watchlistDataList?[position].name ?? ""}. Check it out now on ${Constant.appName}! \n${Constant.iosAppUrl} \n")}');
                      }
                    },
                  ),

                  /* Instgram Stories */
                  _buildDialogItems(
                    icon: "ic_insta.png",
                    title: "instagram_stories",
                    isMultilang: true,
                    onClick: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      Utils.shareApp(Platform.isIOS
                          ? "Hey! I'm watching ${watchlistProvider.watchlistDataList?[position].name ?? ""}. Check it out now on ${Constant.appName}! \n${Constant.androidAppUrl} \n"
                          : "Hey! I'm watching ${watchlistProvider.watchlistDataList?[position].name ?? ""}. Check it out now on ${Constant.appName}! \n${Constant.iosAppUrl} \n");
                    },
                  ),

                  /* Copy Link */
                  _buildDialogItems(
                    icon: "ic_link.png",
                    title: "copy_link",
                    isMultilang: true,
                    onClick: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }

                      String message = "Hey! I'm watching ${watchlistProvider.watchlistDataList?[position].name ?? ""}. Check it out now on ${Constant.appName}! \n${Platform.isIOS ? Constant.iosAppUrl : Constant.androidAppUrl} \n";

                      // نسخ الرابط إلى الحافظة
                      Clipboard.setData(ClipboardData(text: message)).then((_) {
                        printLog("Link copied to clipboard");
                        Utils.showSnackbar(context, "success", "link_copied", true);
                      });
                    },                  ),

                  /* More */
                  _buildDialogItems(
                    icon: "ic_dots_h.png",
                    title: "more",
                    isMultilang: true,
                    onClick: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      Utils.shareApp(Platform.isIOS
                          ? "Hey! I'm watching ${watchlistProvider.watchlistDataList?[position].name ?? ""}. Check it out now on ${Constant.appName}! \n${Constant.androidAppUrl} \n"
                          : "Hey! I'm watching ${watchlistProvider.watchlistDataList?[position].name ?? ""}. Check it out now on ${Constant.appName}! \n${Constant.iosAppUrl} \n");
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogItems({
    required String icon,
    required String title,
    required bool isMultilang,
    required Function()? onClick,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: onClick,
      child: Container(
        height: Dimens.minHtDialogContent,
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MyImage(
              width: Dimens.dialogIconSize,
              height: Dimens.dialogIconSize,
              imagePath: icon,
              fit: BoxFit.contain,
              color: defaultIconColor,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: MyText(
                text: title,
                multilanguage: isMultilang,
                fontsizeNormal: 14,
                fontsizeWeb: 16,
                color: titleTextColor,
                fontstyle: FontStyle.normal,
                fontweight: FontWeight.w600,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ========= Open Player ========= */
  openPlayer(playType, position) async {
    /* CHECK SUBSCRIPTION */
    if (playType != "Trailer") {
      bool? isPrimiumUser = await Utils.checkSubsRentLogin(
        context: context,
        isPremium:
            watchlistProvider.watchlistDataList?[position].isPremium ?? 0,
        isBuy: watchlistProvider.watchlistDataList?[position].isPremium ?? 0,
        isRent: watchlistProvider.watchlistDataList?[position].isRent ?? 0,
        rentBuy: watchlistProvider.watchlistDataList?[position].rentBuy ?? 0,
        videoId:
            (watchlistProvider.watchlistDataList?[position].id ?? 0).toString(),
        rentPrice: (watchlistProvider.watchlistDataList?[position].price ?? 0)
            .toString(),
        vTitle: (watchlistProvider.watchlistDataList?[position].name ?? 0)
            .toString(),
        typeId: (watchlistProvider.watchlistDataList?[position].typeId ?? 0)
            .toString(),
        vType: (watchlistProvider.watchlistDataList?[position].videoType ?? 0)
            .toString(),
        rentProductId:
            (watchlistProvider.watchlistDataList?[position].videoType ?? 0)
                .toString(),
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
      video320: (watchlistProvider.watchlistDataList?[position].video320 ?? ""),
      video480: (watchlistProvider.watchlistDataList?[position].video480 ?? ""),
      video720: (watchlistProvider.watchlistDataList?[position].video720 ?? ""),
      video1080:
          (watchlistProvider.watchlistDataList?[position].video1080 ?? ""),
    );

    /* Set-up Subtitle URLs */
    Utils.setSubtitleURLs(
      subtitleUrl1:
          (watchlistProvider.watchlistDataList?[position].subtitle1 ?? ""),
      subtitleUrl2:
          (watchlistProvider.watchlistDataList?[position].subtitle2 ?? ""),
      subtitleUrl3:
          (watchlistProvider.watchlistDataList?[position].subtitle3 ?? ""),
      subtitleLang1:
          (watchlistProvider.watchlistDataList?[position].subtitleLang1 ?? ""),
      subtitleLang2:
          (watchlistProvider.watchlistDataList?[position].subtitleLang2 ?? ""),
      subtitleLang3:
          (watchlistProvider.watchlistDataList?[position].subtitleLang3 ?? ""),
    );

    PlayerModel playerModel = PlayerModel(
      playType: playType ?? "",
      videoId: watchlistProvider.watchlistDataList?[position].id ?? 0,
      videoTitle: watchlistProvider.watchlistDataList?[position].name ?? "",
      videoType: watchlistProvider.watchlistDataList?[position].videoType ?? 0,
      subVideoType:
          watchlistProvider.watchlistDataList?[position].subVideoType ?? 0,
      typeId: watchlistProvider.watchlistDataList?[position].typeId ?? 0,
      episodeId: 0,
      videoUrl: watchlistProvider.watchlistDataList?[position].video320 ?? "",
      trailerUrl:
          watchlistProvider.watchlistDataList?[position].trailerUrl ?? "",
      uploadType:
          watchlistProvider.watchlistDataList?[position].videoUploadType ?? "",
      videoThumb:
          watchlistProvider.watchlistDataList?[position].landscape ?? "",
      stopTime: watchlistProvider.watchlistDataList?[position].stopTime ?? 0,
      securityKey: "",
    );

    if (!mounted) return;
    AdHelper.showFullscreenAd(context, Constant.interstialAdType, () async {
      dynamic isContinue =
          await Utils.openPlayer(context: context, playerModel: playerModel);
      if (isContinue != null && isContinue == true) {
        await watchlistProvider.getWatchlist(1);
      }
    });
  }
  /* ========= Open Player ========= */
}
