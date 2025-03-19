
import '../model/sectiontypemodel.dart' as type;

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../pages/contentbyid.dart';
import '../provider/bottombarprovider.dart';
import '../provider/homeprovider.dart';
import '../provider/sectiondataprovider.dart';
import '../provider/videobyidprovider.dart';
import '../utils/adhelper.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/dimens.dart';
import '../utils/utils.dart';
import 'mynetworkimg.dart';
import 'mytext.dart';

class MoreHomeDialog extends StatefulWidget {
  const MoreHomeDialog({super.key});

  @override
  State<MoreHomeDialog> createState() => _MoreHomeDialogState();
}

class _MoreHomeDialogState extends State<MoreHomeDialog> {
  late HomeProvider homeProvider;
  late BottombarProvider bottombarProvider;
  late SectionDataProvider sectionDataProvider;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    bottombarProvider = Provider.of<BottombarProvider>(context, listen: false);
    sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          return Container(
            width: MediaQuery.of(context).size.width,
            color: secondaryBgColor,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTypes(),
                  const SizedBox(height: 20),
                  _buildTitleForDialog(
                    title: "popular_language",
                    isMultiLang: true,
                  ),
                  _buildPopularLanguage(),
                  const SizedBox(height: 20),
                  _buildTitleForDialog(
                    title: "popular_channel",
                    isMultiLang: true,
                  ),
                  _buildPopularChannel(),
                  const SizedBox(height: 20),
                  _buildTitleForDialog(
                    title: "popular_genres",
                    isMultiLang: true,
                  ),
                  _buildPopularGenres(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypes() {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        if (homeProvider.sectionTypeModel.result == null ||
            (homeProvider.sectionTypeModel.result?.length ?? 0) == 0) {
          return const SizedBox.shrink();
        }
        return Container(
          constraints: const BoxConstraints(maxHeight: 55),
          decoration: Utils.setBGWithBorder(
              appBgColor, transparent, Dimens.menuRadius, 0),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          alignment: Alignment.topCenter,
          child: ListView.separated(
            itemCount: (homeProvider.sectionTypeModel.result?.length ?? 0),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => Container(
              width: 1.5,
              margin: const EdgeInsets.fromLTRB(4, 10, 4, 10),
              decoration: Utils.setBackground(grayDark, 5),
            ),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  printLog("index ===========> $index");
                  AdHelper.showFullscreenAd(context, Constant.interstialAdType,
                      () async {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
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
                    text: (homeProvider.sectionTypeModel.result?[index].name
                            .toString() ??
                        ""),
                    fontsizeNormal: 12,
                    fontweight: FontWeight.w600,
                    fontsizeWeb: 14,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPopularLanguage() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: (homeProvider.langaugeModel.result?.length ?? 0) == 1
          ? Dimens.heightLang
          : (homeProvider.langaugeModel.result?.length ?? 0) > 3
              ? (Dimens.heightLang * 2)
              : Dimens.heightLang,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: AlignedGridView.count(
          itemCount: homeProvider.langaugeModel.result?.length ?? 0,
          shrinkWrap: true,
          crossAxisCount: (homeProvider.langaugeModel.result?.length ?? 0) == 1
              ? 1
              : (homeProvider.langaugeModel.result?.length ?? 0) > 3
                  ? 2
                  : 1,
          crossAxisSpacing: Dimens.spaceBetweenCategory,
          mainAxisSpacing: Dimens.spaceBetweenCategory,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 18, right: 18),
          scrollDirection: Axis.horizontal,
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
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  await videoByIDProvider.setLoading(true);
                  if (!context.mounted) return;
                  Utils.pushWebPage(
                    context: context,
                    newChild: ContentByID(
                      homeProvider.langaugeModel.result?[index].id ?? 0,
                      homeProvider.langaugeModel.result?[index].name ?? "",
                      "ByLanguage",
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  decoration:
                      Utils.setBackground(appBgColor, Dimens.cardRadius),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimens.cardRadius),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl: homeProvider
                                  .langaugeModel.result?[index].image
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
                          text: homeProvider.langaugeModel.result?[index].name
                                  .toString() ??
                              "",
                          textalign: TextAlign.center,
                          fontsizeNormal: 13,
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

  Widget _buildPopularGenres() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: (homeProvider.genresModel.result?.length ?? 0) == 1
          ? Dimens.heightGenDialog
          : (homeProvider.genresModel.result?.length ?? 0) > 3
              ? (Dimens.heightGenDialog * 2)
              : Dimens.heightGenDialog,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: AlignedGridView.count(
          itemCount: homeProvider.genresModel.result?.length ?? 0,
          shrinkWrap: true,
          crossAxisCount: (homeProvider.genresModel.result?.length ?? 0) == 1
              ? 1
              : (homeProvider.genresModel.result?.length ?? 0) > 6
                  ? 2
                  : 1,
          crossAxisSpacing: Dimens.spaceBetweenCategory,
          mainAxisSpacing: Dimens.spaceBetweenCategory,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 18, right: 18),
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(Dimens.cardRadius),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Container(
                height: Dimens.heightGenDialog,
                width: Dimens.widthGenDialog,
                alignment: Alignment.center,
                child: InkWell(
                  focusColor: white,
                  borderRadius: BorderRadius.circular(Dimens.cardRadius),
                  onTap: () async {
                    final videoByIDProvider =
                        Provider.of<VideoByIDProvider>(context, listen: false);
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    await videoByIDProvider.setLoading(true);
                    if (!context.mounted) return;
                    Utils.pushWebPage(
                      context: context,
                      newChild: ContentByID(
                        homeProvider.genresModel.result?[index].id ?? 0,
                        homeProvider.genresModel.result?[index].name ?? "",
                        "ByCategory",
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimens.cardRadius),
                        child: MyNetworkImage(
                          imageUrl: homeProvider
                                  .genresModel.result?[index].image
                                  .toString() ??
                              "",
                          fit: BoxFit.fill,
                          height: Dimens.heightGenDialog,
                          width: Dimens.widthGenDialog,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.homeBanner,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              black.withOpacity(0.7),
                              black.withOpacity(0.5),
                              black.withOpacity(0.3),
                              black.withOpacity(0.3),
                              black.withOpacity(0.5),
                              black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: MyText(
                          color: white,
                          text: homeProvider.genresModel.result?[index].name
                                  .toString() ??
                              "",
                          textalign: TextAlign.center,
                          fontsizeNormal: 16,
                          fontweight: FontWeight.w700,
                          fontsizeWeb: 18,
                          multilanguage: false,
                          maxline: 2,
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

  Widget _buildPopularChannel() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: (homeProvider.channelModel.result?.length ?? 0) == 1
          ? Dimens.heightChannel
          : (homeProvider.channelModel.result?.length ?? 0) > 3
              ? (Dimens.heightChannel * 2)
              : Dimens.heightChannel,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: AlignedGridView.count(
          itemCount: homeProvider.channelModel.result?.length ?? 0,
          shrinkWrap: true,
          crossAxisCount: (homeProvider.channelModel.result?.length ?? 0) == 1
              ? 1
              : (homeProvider.channelModel.result?.length ?? 0) > 6
                  ? 2
                  : 1,
          crossAxisSpacing: Dimens.spaceBetweenCategory,
          mainAxisSpacing: Dimens.spaceBetweenCategory,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 18, right: 18),
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(Dimens.cardRadius),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimens.cardRadius),
                focusColor: white,
                onTap: () async {
                  final videoByIDProvider =
                      Provider.of<VideoByIDProvider>(context, listen: false);
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  await videoByIDProvider.setLoading(true);
                  if (!context.mounted) return;
                  Utils.pushWebPage(
                    context: context,
                    newChild: ContentByID(
                      homeProvider.channelModel.result?[index].id ?? 0,
                      homeProvider.channelModel.result?[index].name ?? "",
                      "ByChannel",
                    ),
                  );
                },
                child: Container(
                  height: Dimens.heightChannel,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  decoration:
                      Utils.setBackground(appBgColor, Dimens.cardRadius),
                  constraints: const BoxConstraints(minWidth: 80),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimens.cardRadius),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: MyNetworkImage(
                      imageUrl: homeProvider
                              .channelModel.result?[index].portraitImg
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

  Widget _buildTitleForDialog({
    required String title,
    required bool isMultiLang,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 75),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      alignment: Alignment.centerLeft,
      child: MyText(
        color: white,
        text: title,
        multilanguage: isMultiLang,
        textalign: TextAlign.start,
        fontsizeNormal: 15,
        fontsizeWeb: 17,
        fontweight: FontWeight.w500,
        maxline: 1,
        overflow: TextOverflow.ellipsis,
        fontstyle: FontStyle.normal,
      ),
    );
  }
}
