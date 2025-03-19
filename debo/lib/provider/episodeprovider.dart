

import 'package:flutter/material.dart';

import '../model/episodebyseasonmodel.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class EpisodeProvider extends ChangeNotifier {
  EpisodeBySeasonModel episodeBySeasonModel = EpisodeBySeasonModel();
  List<Result>? episodeList = [];

  bool loading = false;

  /* Post Pagination */
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  setLoading(bool isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> getEpisodeBySeason(seasonId, showId, pageNo) async {
    printLog("getEpisodeBySeason seasonId =====> $seasonId");
    printLog("getEpisodeBySeason showId =======> $showId");
    printLog("getEpisodeBySeason pageNo =======> $pageNo");
    if (pageNo == 1) {
      episodeList?.clear();
      episodeList = [];
    }
    loading = true;
    episodeBySeasonModel = EpisodeBySeasonModel();
    episodeBySeasonModel =
    await ApiService().episodeBySeason(seasonId, showId, pageNo);
    printLog(
        "episodeBySeasonModel length :=1=> ${(episodeBySeasonModel.result?.length ?? 0)}");
    if (episodeBySeasonModel.status == 200) {
      setPagination(
          episodeBySeasonModel.totalRows,
          episodeBySeasonModel.totalPage,
          episodeBySeasonModel.currentPage,
          episodeBySeasonModel.morePage);
      if (episodeBySeasonModel.result != null &&
          (episodeBySeasonModel.result?.length ?? 0) > 0) {
        printLog(
            "episodeBySeasonModel length :=2=> ${(episodeBySeasonModel.result?.length ?? 0)}");
        for (var i = 0; i < (episodeBySeasonModel.result?.length ?? 0); i++) {
          episodeList?.add(episodeBySeasonModel.result?[i] ?? Result());
        }
        final Map<int, Result> postMap = {};
        episodeList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        episodeList = postMap.values.toList();
        await setLoadMore(false);
        printLog(
            "episodeBySeasonModel length :=3=> ${(episodeBySeasonModel.result?.length ?? 0)}");
      } else {
        await setLoadMore(false);
      }
    } else {
      await setLoadMore(false);
    }
    loading = false;
    notifyListeners();
  }

  setLoadMore(loadMore) {
    printLog("setLoadMore loadMore :=> $loadMore");
    this.loadMore = loadMore;
    notifyListeners();
  }

  clearOldData() {
    episodeList?.clear();
    episodeList = [];
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
    episodeBySeasonModel = EpisodeBySeasonModel();
    loadMore = false;
    totalRows = null;
    totalPage = null;
    currentPage = null;
    isMorePage = null;
  }
}
