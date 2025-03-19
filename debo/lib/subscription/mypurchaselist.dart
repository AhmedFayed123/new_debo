
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../provider/purchaselistprovider.dart';
import '../routes/routes_constant.dart';
import '../shimmer/shimmerutils.dart';
import '../utils/color.dart';
import '../utils/dimens.dart';
import '../utils/utils.dart';
import '../webpages/webcomman.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';

class MyPurchaselist extends StatefulWidget {
  final String? newPage, oldPage;
  final dynamic reqText;
  const MyPurchaselist({
    required this.newPage,
    required this.oldPage,
    required this.reqText,
    super.key,
  });

  @override
  State<MyPurchaselist> createState() => _MyPurchaselistState();
}

class _MyPurchaselistState extends State<MyPurchaselist> {
  late PurchaselistProvider purchaselistProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    purchaselistProvider =
        Provider.of<PurchaselistProvider>(context, listen: false);
    _getData();
    super.initState();
  }

  _getData() async {
    purchaselistProvider.contentList?.clear();
    purchaselistProvider.contentList = [];
    await purchaselistProvider.getUserRentVideoList(1);
    Future.delayed(const Duration(milliseconds: 300)).then((value) async {
      if (purchaselistProvider.isMorePage == true) {
        await purchaselistProvider.getUserRentVideoList(2);
      }
      if (!mounted) return;
      setState(() {});
    });
  }

  _scrollListener() async {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (purchaselistProvider.isMorePage ?? false) &&
        widget.newPage == RoutesConstant.rentPurchasePage) {
      await purchaselistProvider.setLoadMore(true);
      _fetchNewData(purchaselistProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchNewData(int? nextPage) async {
    printLog("_fetchNewData nextPage  ========> $nextPage");
    printLog(
        "_fetchNewData isMorePage  ======> ${purchaselistProvider.isMorePage}");
    printLog(
        "_fetchNewData currentPage ======> ${purchaselistProvider.currentPage}");
    printLog(
        "_fetchNewData totalPage   ======> ${purchaselistProvider.totalPage}");

    await purchaselistProvider.getUserRentVideoList((nextPage ?? 0) + 1);
    printLog(
        "_fetchNewData length ==> ${purchaselistProvider.contentList?.length}");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    purchaselistProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebComman(
        newPage: widget.newPage,
        oldPage: widget.oldPage,
        reqText: '',
        newChild: _buildForWeb(),
      );
    } else {
      return Scaffold(
        backgroundColor: appBgColor,
        appBar: Utils.myAppBarWithBack(context, "purchases", true),
        body: _buildForOther(),
      );
    }
  }

  Widget _buildForWeb() {
    return Column(
      children: [
        SizedBox(height: Dimens.homeTabHeight + 30),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                color: colorPrimary,
                text: "purchases",
                multilanguage: true,
                textalign: TextAlign.center,
                maxline: 2,
                fontsizeNormal: 20,
                fontsizeWeb: 25,
                fontweight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
              if (purchaselistProvider.contentList != null &&
                  (purchaselistProvider.contentList?.length ?? 0) > 0)
                const SizedBox(width: 15),
              if (purchaselistProvider.contentList != null &&
                  (purchaselistProvider.contentList?.length ?? 0) > 0)
                MyText(
                  color: descTextColor,
                  text: (purchaselistProvider.contentList?.length ?? 0) > 1
                      ? "(${(purchaselistProvider.contentList?.length ?? 0)} items)"
                      : "(${(purchaselistProvider.contentList?.length ?? 0)} item)",
                  textalign: TextAlign.center,
                  fontsizeNormal: 14,
                  fontsizeWeb: 16,
                  maxline: 1,
                  fontweight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Consumer<PurchaselistProvider>(
          builder: (context, purchaselistProvider, child) {
            if (purchaselistProvider.loading) {
              return ShimmerUtils.buildRentShimmer(
                  context, Dimens.heightLand, Dimens.widthLand);
            } else {
              if (purchaselistProvider.contentList == null ||
                  (purchaselistProvider.contentList?.length ?? 0) == 0) {
                return const NoData(
                  title: 'rent_and_buy_your_favorites',
                  subTitle: 'no_purchases_note',
                );
              } else {
                if (purchaselistProvider.contentList != null) {
                  return _buildPurchasedList();
                } else {
                  return const NoData(
                    title: 'rent_and_buy_your_favorites',
                    subTitle: 'no_purchases_note',
                  );
                }
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildForOther() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Consumer<PurchaselistProvider>(
              builder: (context, purchaselistProvider, child) {
                if (purchaselistProvider.loading) {
                  return SingleChildScrollView(
                    child: ShimmerUtils.buildRentShimmer(
                        context, Dimens.heightLand, Dimens.widthLand),
                  );
                } else {
                  if (purchaselistProvider.contentList == null ||
                      (purchaselistProvider.contentList?.length ?? 0) == 0) {
                    return const NoData(
                      title: 'rent_and_buy_your_favorites',
                      subTitle: 'no_purchases_note',
                    );
                  } else {
                    if (purchaselistProvider.contentList != null) {
                      return RefreshIndicator(
                        backgroundColor: white,
                        color: complimentryColor,
                        displacement: 80,
                        onRefresh: () async {
                          await Future.delayed(
                                  const Duration(milliseconds: 1500))
                              .then((value) {
                            _getData();
                          });
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: _buildPurchasedList(),
                        ),
                      );
                    } else {
                      return const NoData(
                        title: 'rent_and_buy_your_favorites',
                        subTitle: 'no_purchases_note',
                      );
                    }
                  }
                }
              },
            ),
          ),
          /* AdMob Banner */
          Container(
            child: Utils.showBannerAd(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasedList() {
    if ((purchaselistProvider.contentList?.length ?? 0) > 0) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: ResponsiveGridList(
          minItemWidth: Dimens.isBigScreen(context)
              ? Dimens.widthPortOtherWeb
              : Dimens.widthPortOther,
          verticalGridSpacing: 5,
          horizontalGridSpacing: 5,
          minItemsPerRow: 2,
          maxItemsPerRow: 15,
          listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            (purchaselistProvider.contentList?.length ?? 0),
            (position) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.cardRadiusSmall),
                child: InkWell(
                  onTap: () async {
                    printLog("Clicked on position ==> $position");
                    Utils.openDetails(
                      context: context,
                      videoId:
                          purchaselistProvider.contentList?[position].id ?? 0,
                      subVideoType: purchaselistProvider
                              .contentList?[position].subVideoType ??
                          0,
                      videoType: purchaselistProvider
                              .contentList?[position].videoType ??
                          0,
                      typeId:
                          purchaselistProvider.contentList?[position].typeId ??
                              0,
                      newPage: ((purchaselistProvider
                                          .contentList?[position].videoType ??
                                      0) ==
                                  2 ||
                              (purchaselistProvider.contentList?[position]
                                          .subVideoType ??
                                      0) ==
                                  2)
                          ? RoutesConstant.showDetailsPage
                          : RoutesConstant.videoDetailsPage,
                      oldPage: "",
                      reqText: "",
                    );
                  },
                  child: Container(
                    width: Dimens.isBigScreen(context)
                        ? Dimens.widthPortOtherWeb
                        : Dimens.widthPortOther,
                    height: Dimens.isBigScreen(context)
                        ? Dimens.heightPortOtherWeb
                        : Dimens.heightPortOther,
                    alignment: Alignment.center,
                    child: MyNetworkImage(
                      imageUrl: purchaselistProvider
                              .contentList?[position].thumbnail
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
    } else {
      return const SizedBox.shrink();
    }
  }
}
