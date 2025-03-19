
import 'package:debo/webpages/webcomman.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../provider/findprovider.dart';
import '../routes/routes_constant.dart';
import '../shimmer/shimmerutils.dart';
import '../utils/color.dart';
import '../utils/dimens.dart';
import '../utils/strings.dart';
import '../utils/utils.dart';
import '../widget/myimage.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';

class WebSearch extends StatefulWidget {
  final String? newPage, oldPage;
  final dynamic reqText;
  const WebSearch({
    super.key,
    required this.newPage,
    required this.oldPage,
    required this.reqText,
  });

  @override
  State<WebSearch> createState() => WebSearchState();
}

class WebSearchState extends State<WebSearch> {
  late FindProvider findProvider;
  final searchController = TextEditingController();

  @override
  void initState() {
    findProvider = Provider.of<FindProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    super.initState();
  }

  _getData() async {
    await findProvider.getSearchContent("", 1);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  /* Search Data by Type START *********** */
  Future<void> getTabData() async {
    if (!mounted) return;
    await findProvider.setSearchLoading(true);
    await findProvider.clearSearchData();
    if (searchController.text.toString().isEmpty) {
      await findProvider.getSearchContent("", 1);
      return;
    }
    printLog("searchController ====> ${searchController.text}");
    await findProvider.getSearchContent(searchController.text.toString(), 1);
  }
  /* ************* Search Data by Type END */

  @override
  void dispose() {
    searchController.dispose();
    findProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebComman(
      newPage: widget.newPage,
      oldPage: widget.oldPage,
      reqText: searchController.text.toString(),
      newChild: Consumer<FindProvider>(
        builder: (context, findProvider, child) {
          return _buildPageUI();
        },
      ),
    );
  }

  Widget _buildPageUI() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorPrimaryDark,
            colorPrimaryDark.withOpacity(0.9),
            colorPrimaryDark.withOpacity(0.8),
            colorPrimaryDark.withOpacity(0.7),
            colorPrimaryDark.withOpacity(0.6),
            colorPrimaryDark.withOpacity(0.0),
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: Dimens.homeTabHeight),
          _buildSearchBox(),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 5),
            child: MyText(
              color: white,
              text: "people_search_for",
              multilanguage: true,
              textalign: TextAlign.start,
              fontsizeNormal: 15,
              fontweight: FontWeight.w600,
              fontsizeWeb: 17,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
          ),
          _buildSearchData(),
        ],
      ),
    );
  }

  /* Search View */
  Widget _buildSearchBox() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 55,
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      decoration: Utils.setBackground(white, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(14),
            child: MyImage(
              imagePath: "ic_find.png",
              color: defaultIconColor,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: TextField(
                onSubmitted: (value) async {
                  printLog("value ====> $value");
                  if (value.isNotEmpty) {
                    // if (!context.mounted) return;
                    // getTabData();
                  }
                },
                onChanged: (value) async {
                  if (!context.mounted) return;
                  getTabData();
                },
                textInputAction: TextInputAction.done,
                obscureText: false,
                controller: searchController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                style: kIsWeb
                    ? const TextStyle(
                        color: black,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w600,
                      )
                    : GoogleFonts.inter(
                        textStyle: const TextStyle(
                          color: black,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: transparent,
                  hintStyle: TextStyle(
                    color: descTextColor,
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: searchHint,
                ),
              ),
            ),
          ),
          if (searchController.text.toString().isNotEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () async {
                printLog("Click on Clear!");
                searchController.clear();
                getTabData();
              },
              child: Container(
                width: 42,
                padding: const EdgeInsets.all(13),
                alignment: Alignment.center,
                child: MyImage(
                  imagePath: "ic_close.png",
                  color: defaultIconColor,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /* Search Data */
  Widget _buildSearchData() {
    if (findProvider.loadingSearch && !findProvider.loadMore) {
      return Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
        child: ShimmerUtils.responsiveGrid2(
            context,
            Dimens.isBigScreen(context)
                ? Dimens.heightPortOtherWeb
                : Dimens.heightPortOther,
            Dimens.isBigScreen(context)
                ? Dimens.widthPortOtherWeb
                : Dimens.widthPortOther,
            3,
            3,
            3,
            12),
      );
    }
    if (findProvider.searchDataList == null ||
        (findProvider.searchDataList?.length ?? 0) == 0) {
      return const NoData(title: 'no_search_title', subTitle: 'no_search_desc');
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
      child: Column(
        children: [
          ResponsiveGridList(
            minItemWidth: Dimens.isBigScreen(context)
                ? Dimens.widthPortOtherWeb
                : Dimens.widthPortOther,
            verticalGridSpacing: 3,
            horizontalGridSpacing: 3,
            minItemsPerRow: 3,
            maxItemsPerRow: 8,
            listViewBuilderOptions: ListViewBuilderOptions(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(
              (findProvider.searchDataList?.length ?? 0),
              (position) {
                return _buildVideoContent(position: position);
              },
            ),
          ),

          /* Pagination loader */
          if (findProvider.loadMore)
            Container(
              height: 80,
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Utils.pageLoader(),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildVideoContent({required int position}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimens.cardRadiusSmall),
      child: InkWell(
        onTap: () {
          printLog("Clicked on position ==> $position");
          Utils.openDetails(
            context: context,
            videoId: findProvider.searchDataList?[position].id ?? 0,
            subVideoType:
                findProvider.searchDataList?[position].subVideoType ?? 0,
            videoType: findProvider.searchDataList?[position].videoType ?? 0,
            typeId: findProvider.searchDataList?[position].typeId ?? 0,
            newPage: ((findProvider.searchDataList?[position].subVideoType ??
                            0) ==
                        2 ||
                    (findProvider.searchDataList?[position].videoType ?? 0) ==
                        2)
                ? RoutesConstant.showDetailsPage
                : RoutesConstant.videoDetailsPage,
            oldPage: widget.newPage ?? "",
            reqText: '',
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
            imageUrl:
                findProvider.searchDataList?[position].thumbnail.toString() ??
                    "",
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
        ),
      ),
    );
  }
}
