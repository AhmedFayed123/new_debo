import '../model/searchmodel.dart' as search;

import 'package:flutter/material.dart';

import '../model/successmodel.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class FindProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();
  search.SearchModel searchModel = search.SearchModel();
  List<search.Result>? searchDataList = [];

  /* For Speech Search */
  bool speechEnabled = false, isListening = false;
  String lastWords = '';

  bool loading = false, loadingSearch = false;

  /* Pagination */
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  setSpeechStatus(bool isEnable) {
    speechEnabled = isEnable;
    notifyListeners();
  }

  Future<void> setSpeechListening(bool isListening) async {
    this.isListening = isListening;
    printLog("isListening ==> $isListening");
    notifyListeners();
  }

  setSpeechLastWord(String lastWord) {
    lastWords = lastWord;
    notifyListeners();
  }

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  setSearchLoading(isLoading) {
    loadingSearch = isLoading;
    notifyListeners();
  }

  Future clearSearchData() async {
    searchDataList?.clear();
    searchDataList = [];
    notifyListeners();
  }

  Future<void> getSearchContent(searchText, pageNo) async {
    printLog("getSearchContent searchText :===> $searchText");
    printLog("getSearchContent pageNo :=======> $pageNo");
    if (pageNo == 1) {
      searchDataList = [];
    }
    loadingSearch = true;
    searchModel = search.SearchModel();
    searchModel = await ApiService().searchContent(searchText, pageNo);
    if (searchModel.status == 200) {
      setPagination(searchModel.totalRows, searchModel.totalPage,
          searchModel.currentPage, searchModel.morePage);
      if (searchModel.result != null && (searchModel.result?.length ?? 0) > 0) {
        printLog(
            "sectionListModel length :=1=> ${(searchModel.result?.length ?? 0)}");
        for (var i = 0; i < (searchModel.result?.length ?? 0); i++) {
          searchDataList?.add(searchModel.result?[i] ?? search.Result());
        }
        final Map<int, search.Result> postMap = {};
        searchDataList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        searchDataList = postMap.values.toList();
        setLoadMore(false);
        printLog(
            "sectionListModel length :=2=> ${(searchModel.result?.length ?? 0)}");
      }
    }
    loadingSearch = false;
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

  notifyProvider() {
    notifyListeners();
  }

  clearProvider() {
    printLog("============ clearProvider ============");
    loading = false;
    loadingSearch = false;
    lastWords = '';
    successModel = SuccessModel();
    searchModel = search.SearchModel();
    searchDataList?.clear();
    searchDataList = [];
    speechEnabled = false;
    isListening = false;

    /* Pagination */
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
