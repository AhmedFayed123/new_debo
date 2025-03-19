import 'package:avatar_glow/avatar_glow.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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

class Find extends StatefulWidget {
  const Find({super.key});

  @override
  State<Find> createState() => FindState();
}

class FindState extends State<Find> {
  late FindProvider findProvider;
  final SpeechToText _speechToText = SpeechToText();
  final nestedScrollController = ScrollController();
  final searchController = TextEditingController();

  /* Pagination START *********** */
  _nestedScrollListener() async {
    if (!nestedScrollController.hasClients) return;
    if (nestedScrollController.offset >=
            nestedScrollController.position.maxScrollExtent &&
        !nestedScrollController.position.outOfRange &&
        (findProvider.isMorePage ?? false)) {
      await findProvider.setLoadMore(true);
      _fetchNewPageData(findProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchNewPageData(int? nextPage) async {
    printLog("_fetchNewPageData nextPage  ========> $nextPage");
    printLog(
        "_fetchNewPageData isMorePage  ======> ${findProvider.isMorePage}");
    printLog(
        "_fetchNewPageData currentPage ======> ${findProvider.currentPage}");
    printLog("_fetchNewPageData totalPage   ======> ${findProvider.totalPage}");

    await findProvider.getSearchContent(
        searchController.text.toString(), (nextPage ?? 0) + 1);
    printLog(
        "searchDataList length ==> ${findProvider.searchDataList?.length}");
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }
  /* ************* Pagination END */

  @override
  void initState() {
    nestedScrollController.addListener(_nestedScrollListener);
    findProvider = Provider.of<FindProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    _initSpeech();
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
    if (nestedScrollController.hasClients) {
      await nestedScrollController.animateTo(0,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
    }

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

  /* Speech To Text START *********** */
  void _initSpeech() async {
    bool? speechEnabled = await _speechToText.initialize();
    printLog("speechEnabled =============> $speechEnabled");
    await findProvider.setSpeechStatus(speechEnabled);
  }

  void _startListening() async {
    printLog("<============== _startListening ==============>");
    await findProvider.setSpeechListening(true);
    await _speechToText.listen(onResult: _onSpeechResult);
    Future.delayed(const Duration(seconds: 5), () {
      if (findProvider.isListening &&
          searchController.text.toString().isEmpty) {
        Utils.showSnackbar(context, "info", "speechnotavailable", true);
        _stopListening();
      }
    });
  }

  void _stopListening() async {
    printLog("<============== _stopListening ==============>");
    await _speechToText.stop();
    await findProvider.setSpeechLastWord("");
    await findProvider.setSpeechListening(false);
  }

  void _onSpeechResult(SpeechRecognitionResult result) async {
    printLog("<============== _onSpeechResult ==============>");
    await findProvider.setSpeechLastWord(result.recognizedWords);
    printLog("_lastWords =============> ${findProvider.lastWords}");
    if (findProvider.lastWords.isNotEmpty && findProvider.isListening) {
      searchController.text = findProvider.lastWords.toString();
      await findProvider.setSpeechListening(false);
      if (!mounted) return;
      getTabData();
    }
  }
  /* *********** Speech To Text END */

  @override
  void dispose() {
    _stopListening();
    searchController.dispose();
    findProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: appBgColor,
      body: SafeArea(
        child: Consumer<FindProvider>(
          builder: (context, findProvider, child) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                _buildSearchData(),
                /* Type List */
                _buildPage(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPage() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appBgColor,
            appBgColor.withOpacity(0.9),
            appBgColor.withOpacity(0.8),
            appBgColor.withOpacity(0.7),
            appBgColor.withOpacity(0.6),
            appBgColor.withOpacity(0.0),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildSearchBox(),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 5),
            child: MyText(
              color: titleTextColor,
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
                    // if (!mounted) return;
                    // getTabData();
                  }
                },
                onChanged: (value) async {
                  if (!mounted) return;
                  getTabData();
                },
                textInputAction: TextInputAction.done,
                obscureText: false,
                controller: searchController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                style: GoogleFonts.inter(
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
            )
          else
            InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () async {
                printLog("Click on Microphone!");
                if (!findProvider.isListening) {
                  _startListening();
                }
              },
              child: findProvider.isListening
                  ? AvatarGlow(
                      glowColor: colorPrimary,
                      glowShape: BoxShape.circle,
                      duration: const Duration(milliseconds: 2000),
                      repeat: true,
                      glowCount: 3,
                      child: Material(
                        elevation: 5,
                        color: transparent,
                        shape: const CircleBorder(),
                        child: Container(
                          width: 42,
                          padding: const EdgeInsets.all(15),
                          color: transparent,
                          alignment: Alignment.center,
                          child: MyImage(
                            imagePath: "ic_voice.png",
                            color: defaultIconColor,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 42,
                      padding: const EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: MyImage(
                        imagePath: "ic_voice.png",
                        color: defaultIconColor,
                        fit: BoxFit.contain,
                      ),
                    ),
            )
        ],
      ),
    );
  }

  /* Search Data */
  Widget _buildSearchData() {
    if (findProvider.loadingSearch && !findProvider.loadMore) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 100, 8, 8),
        child: ShimmerUtils.responsiveGrid2(context, Dimens.heightPortOther,
            Dimens.widthPortOther, 3, 3, 3, 12),
      );
    }
    if (findProvider.searchDataList == null ||
        (findProvider.searchDataList?.length ?? 0) == 0) {
      return const NoData(title: 'no_search_title', subTitle: 'no_search_desc');
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      padding: const EdgeInsets.fromLTRB(0, 105, 0, 0),
      child: RefreshIndicator(
        backgroundColor: white,
        color: complimentryColor,
        displacement: 80,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 1500))
              .then((value) {
            if (!mounted) return;
            _getData();
            getTabData();
          });
        },
        child: SingleChildScrollView(
          controller: nestedScrollController,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ResponsiveGridList(
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
        ),
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
            oldPage: '',
            reqText: '',
          );
        },
        child: Container(
          width: Dimens.widthPortOther,
          height: Dimens.heightPortOther,
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
