import '../model/sectionbannermodel.dart';
import '../model/sectionlistmodel.dart' as section;

import 'package:flutter/material.dart';

import '../model/successmodel.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class SectionDataProvider extends ChangeNotifier {
  SectionBannerModel sectionBannerModel = SectionBannerModel();
  section.SectionListModel sectionListModel = section.SectionListModel();
  List<section.Result>? sectionList = [];
  SuccessModel successModel = SuccessModel();

  bool loadingBanner = false, loadingSection = false;
  int? cBannerIndex = 0, lastTabPosition;

  /* Post Pagination */
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  Future<void> getSectionBanner(typeId, isHomePage) async {
    cBannerIndex = 0;
    printLog("getSectionBanner typeId :==> $typeId");
    printLog("getSectionBanner isHomePage :==> $isHomePage");
    loadingBanner = true;
    sectionBannerModel = await ApiService().sectionBanner(typeId, isHomePage);
    loadingBanner = false;
    notifyListeners();
  }

  setLoading(bool flagLoading) {
    loadingBanner = flagLoading;
    loadingSection = flagLoading;
    notifyListeners();
  }

  setTabPosition(position) {
    lastTabPosition = position;
    notifyListeners();
  }

  setCurrentBanner(index) {
    cBannerIndex = index;
    notifyListeners();
  }

  Future<void> getSectionList(typeId, isHomePage, pageNo) async {
    printLog("getSectionList typeId :======> $typeId");
    printLog("getSectionList isHomePage :==> $isHomePage");
    printLog("getSectionList pageNo :======> $pageNo");
    if (pageNo == 1) {
      sectionList = [];
    }
    loadingSection = true;
    printLog("getSectionList length :======> ${sectionList?.length}");
    sectionListModel = section.SectionListModel();
    sectionListModel =
        await ApiService().sectionList(typeId, isHomePage, pageNo);
    printLog(
        "sectionListModel length :=1=> ${(sectionListModel.result?.length ?? 0)}");
    if (sectionListModel.status == 200) {
      setPagination(sectionListModel.totalRows, sectionListModel.totalPage,
          sectionListModel.currentPage, sectionListModel.morePage);
      if (sectionListModel.result != null &&
          (sectionListModel.result?.length ?? 0) > 0) {
        printLog(
            "sectionListModel length :=2=> ${(sectionListModel.result?.length ?? 0)}");
        for (var i = 0; i < (sectionListModel.result?.length ?? 0); i++) {
          sectionList?.add(sectionListModel.result?[i] ?? section.Result());
        }
        final Map<int, section.Result> postMap = {};
        sectionList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        sectionList = postMap.values.toList();
        await setLoadMore(false);
        printLog(
            "sectionListModel length :=3=> ${(sectionListModel.result?.length ?? 0)}");
      } else {
        await setLoadMore(false);
      }
    } else {
      await setLoadMore(false);
    }
    loadingSection = false;
    notifyListeners();
  }

  setLoadMore(loadMore) {
    printLog("setLoadMore loadMore :=> $loadMore");
    this.loadMore = loadMore;
    notifyListeners();
  }

  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    printLog("setPagination currentPage :==> $currentPage");
    printLog("setPagination totalRows :====> $totalRows");
    printLog("setPagination totalPage :====> $totalPage");
    printLog("setPagination morePage :=====> $morePage");
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

  Future<void> setBookMark(BuildContext context, position) async {
    if ((sectionBannerModel.result?[position].isBookmark ?? 0) == 0) {
      sectionBannerModel.result?[position].isBookmark = 1;
      Utils.showSnackbar(context, "success", "addwatchlistmessage", true);
    } else {
      sectionBannerModel.result?[position].isBookmark = 0;
      Utils.showSnackbar(context, "success", "removewatchlistmessage", true);
    }
    notifyListeners();
    addRemoveBookmark(
      sectionBannerModel.result?[position].subVideoType ?? 0,
      sectionBannerModel.result?[position].videoType ?? 0,
      sectionBannerModel.result?[position].id,
    );
  }

  Future<void> addRemoveBookmark(subVideoType, videoType, videoId) async {
    printLog("addRemoveBookmark subVideoType :==> $subVideoType");
    printLog("addRemoveBookmark videoType :=====> $videoType");
    printLog("addRemoveBookmark videoId :=======> $videoId");
    successModel =
        await ApiService().addRemoveBookmark(subVideoType, videoType, videoId);
    printLog("addRemoveBookmark status :===> ${successModel.status}");
    printLog("addRemoveBookmark message :==> ${successModel.message}");
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    loadingBanner = false;
    loadingSection = false;
    loadMore = false;
    sectionBannerModel = SectionBannerModel();
    sectionListModel = section.SectionListModel();
    successModel = SuccessModel();
    cBannerIndex = 0;
    lastTabPosition = 0;
    totalRows = null;
    totalPage = null;
    currentPage = null;
    isMorePage = null;
  }
}
