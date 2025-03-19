
import 'package:flutter/material.dart';

import '../model/sectiondetailmodel.dart';
import '../utils/constant.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class SectionViewAllProvider extends ChangeNotifier {
  SectionDetailModel sectionDetailModel = SectionDetailModel();
  List<Result>? sectionDetailList = [];

  bool loading = false;

  /* Post Pagination */
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> getSectionDetails(sectionId, pageNo) async {
    printLog("getSectionDetails userID :=====> ${Constant.userID}");
    printLog("getSectionDetails sectionId :==> $sectionId");
    printLog("getSectionDetails pageNo :=====> $pageNo");

    sectionDetailModel = SectionDetailModel();
    loading = true;
    sectionDetailModel = await ApiService().sectionDetails(sectionId, pageNo);
    if (sectionDetailModel.status == 200) {
      setPagination(sectionDetailModel.totalRows, sectionDetailModel.totalPage,
          sectionDetailModel.currentPage, sectionDetailModel.morePage);
      if (sectionDetailModel.result != null &&
          (sectionDetailModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (sectionDetailModel.result?.length ?? 0); i++) {
          sectionDetailList?.add(sectionDetailModel.result?[i] ?? Result());
        }
        final Map<int, Result> postMap = {};
        sectionDetailList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        sectionDetailList = postMap.values.toList();
        setLoadMore(false);
        printLog(
            "sectionDetailModel length :=2=> ${(sectionDetailModel.result?.length ?? 0)}");
      }
      printLog("getSectionDetails status :===> ${sectionDetailModel.status}");
      printLog("getSectionDetails message :==> ${sectionDetailModel.message}");
    }
    loading = false;
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

  clearProvider() {
    printLog("<================ clearProvider ================>");
    sectionDetailModel = SectionDetailModel();
    sectionDetailList?.clear();
    sectionDetailList = [];
    loading = false;
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
