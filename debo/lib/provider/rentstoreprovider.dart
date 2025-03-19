import '../model/typemodel.dart' as type;
import '../model/rentmodel.dart' as rent;
import 'package:flutter/material.dart';

import '../utils/constant.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class RentStoreProvider extends ChangeNotifier {
  rent.RentModel rentContentModel = rent.RentModel();
  List<type.Result>? sectionTypeList = [];
  List<rent.Result>? rentDataList = [];

  bool loading = false, loadingRent = false, isShowAppbar = true;

  int selectedIndex = 0;
  int? lastTabPosition;

  /* Pagination */
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  setRentLoading(isLoading) {
    loadingRent = isLoading;
    notifyListeners();
  }

  setAppbarVisibility(bool isShowAppbar) {
    this.isShowAppbar = isShowAppbar;
    notifyListeners();
  }

  setSelectedTab(index) {
    selectedIndex = index;
    notifyListeners();
  }

  setTabPosition(position) {
    lastTabPosition = position;
    notifyListeners();
  }

  Future<void> getSectionType() async {
    // type : 1-Video, 2-Show
    loading = true;
    List<Map<String, dynamic>> typeList = [
      {'name': 'Video', 'type': 1},
      {'name': 'Show', 'type': 2},
    ];
    loading = true;
    for (var i = 0; i < typeList.length; i++) {
      type.Result result = type.Result(
        id: (i + 1),
        isHome: 0,
        name: typeList[i]['name'],
        type: typeList[i]['type'],
      );
      debugPrint(
          "Section name =====> ${result.name} & type =====> ${result.type}");
      sectionTypeList?.add(result);
    }
    final Map<int, type.Result> postMap = {};
    sectionTypeList?.forEach((item) {
      postMap[item.id ?? 0] = item;
    });
    sectionTypeList = postMap.values.toList();
    debugPrint("sectionTypeList length :==> ${(sectionTypeList?.length ?? 0)}");
    loading = false;
    notifyListeners();
  }

  clearOldData() async {
    rentDataList?.clear();
    rentDataList = [];
    notifyListeners();
  }

  Future<void> getRentContentList(sectionType, pageNo) async {
    printLog("getRentContentList userID :=======> ${Constant.userID}");
    printLog("getRentContentList sectionType :==> $sectionType");
    printLog("getRentContentList pageNo :=======> $pageNo");
    if (pageNo == 1) {
      rentDataList?.clear();
      rentDataList = [];
    }
    loadingRent = true;
    rentContentModel = rent.RentModel();
    rentContentModel = await ApiService().rentContentList(sectionType, pageNo);
    if (pageNo == 1) {
      rentDataList?.clear();
      rentDataList = [];
    }
    printLog(
        "rentContentModel length :===> ${(rentContentModel.result?.length ?? 0)}");
    if (rentContentModel.status == 200) {
      setPagination(rentContentModel.totalRows, rentContentModel.totalPage,
          rentContentModel.currentPage, rentContentModel.morePage);
      if (rentContentModel.result != null &&
          (rentContentModel.result?.length ?? 0) > 0) {
        printLog(
            "rentContentModel length :=1=> ${(rentContentModel.result?.length ?? 0)}");
        for (var i = 0; i < (rentContentModel.result?.length ?? 0); i++) {
          rentDataList?.add(rentContentModel.result?[i] ?? rent.Result());
        }
        final Map<int, rent.Result> postMap = {};
        rentDataList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        rentDataList = postMap.values.toList();
        setLoadMore(false);
        printLog(
            "getRentContentList length :=2=> ${(rentContentModel.result?.length ?? 0)}");
      }
    }
    loadingRent = false;
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
    rentContentModel = rent.RentModel();
    rentDataList?.clear();
    rentDataList = [];
    selectedIndex = 0;
    loading = false;
    isShowAppbar = true;
    loadingRent = false;
    lastTabPosition;

    /* Pagination */
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
