import '../model/contentdetailmodel.dart';
import '../model/episodebyseasonmodel.dart' as episode;

import 'package:flutter/material.dart';

import '../model/relatedcontentmodel.dart';
import '../model/successmodel.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class ShowDetailsProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();
  ContentDetailModel contentDetailModel = ContentDetailModel();
  RelatedContentModel relatedContentModel = RelatedContentModel();
  List<episode.Result>? episodeList = [];

  bool loading = false;
  int seasonPos = 0, mCurrentEpiPos = -1;
  String tabClickedOn = "related";

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> getSectionDetails(
      typeId, videoType, videoId, upcomingType) async {
    loading = true;
    contentDetailModel = ContentDetailModel();
    contentDetailModel = await ApiService()
        .contentDetails(typeId, videoType, videoId, upcomingType);
    loading = false;
    notifyListeners();
  }

  Future<void> getRelatedContent(
      typeId, videoType, videoId, subVideoType, pageNo) async {
    printLog("getRelatedContent typeId :========> $typeId");
    printLog("getRelatedContent videoType :=====> $videoType");
    printLog("getRelatedContent videoId :=======> $videoId");
    printLog("getRelatedContent subVideoType :==> $subVideoType");
    printLog("getRelatedContent pageNo :========> $pageNo");
    loading = true;
    relatedContentModel = await ApiService()
        .relatedContent(typeId, videoType, videoId, subVideoType, pageNo);
    printLog("getRelatedContent status :==> ${relatedContentModel.status}");
    printLog("getRelatedContent message :==> ${relatedContentModel.message}");
    loading = false;
    notifyListeners();
  }

  setEpisodeBySeason(List<episode.Result>? episodeList) async {
    this.episodeList = [];
    final Map<int, episode.Result> postMap = {};
    episodeList?.forEach((item) {
      postMap[item.id ?? 0] = item;
    });
    this.episodeList = postMap.values.toList();
    printLog(
        "setEpisodeBySeason episodeList ================> ${this.episodeList?.length}");
    await getLastWatchedEpisode();
    notifyListeners();
  }

  getLastWatchedEpisode() {
    for (var i = 0; i < (episodeList?.length ?? 0); i++) {
      if ((episodeList?[i].stopTime ?? 0) > 0) {
        if (episodeList?[i].videoDuration != null) {
          if ((episodeList?[i].videoDuration ?? 0) > 0 &&
              (episodeList?[i].videoDuration ?? 0) !=
                  (episodeList?[i].stopTime ?? 0) &&
              (episodeList?[i].videoDuration ?? 0) >
                  (episodeList?[i].stopTime ?? 0)) {
            mCurrentEpiPos = i;
            return;
          } else {
            mCurrentEpiPos = 0;
          }
        }
      }
    }
    if ((episodeList?.length ?? 0) > 0 && mCurrentEpiPos == -1) {
      mCurrentEpiPos = 0;
    }
    printLog("mCurrentEpiPos ========> $mCurrentEpiPos");
  }

  Future<void> setBookMark(
      BuildContext context, subVideoType, videoType, videoId) async {
    loading = true;
    if ((contentDetailModel.result?[0].isBookmark ?? 0) == 0) {
      contentDetailModel.result?[0].isBookmark = 1;
      Utils.showSnackbar(context, "success", "addwatchlistmessage", true);
    } else {
      contentDetailModel.result?[0].isBookmark = 0;
      Utils.showSnackbar(context, "success", "removewatchlistmessage", true);
    }
    loading = false;
    notifyListeners();
    getAddBookMark(subVideoType, videoType, videoId);
  }

  Future<void> getAddBookMark(subVideoType, videoType, videoId) async {
    printLog("getAddBookMark subVideoType :==> $subVideoType");
    printLog("getAddBookMark videoType :=====> $videoType");
    printLog("getAddBookMark videoId :=======> $videoId");
    successModel =
        await ApiService().addRemoveBookmark(subVideoType, videoType, videoId);
    printLog("add_remove_bookmark status :===> ${successModel.status}");
    printLog("add_remove_bookmark message :==> ${successModel.message}");
  }

  setSeasonPosition(int position) async {
    printLog("setSeasonPosition ===> $position");
    mCurrentEpiPos = -1;
    await getLastWatchedEpisode();
    seasonPos = position;
    notifyListeners();
  }

  updateRentPurchase() {
    if (contentDetailModel.result != null) {
      contentDetailModel.result?[0].rentBuy == 1;
    }
  }

  updatePrimiumPurchase() {
    if (contentDetailModel.result != null) {
      contentDetailModel.result?[0].isBuy == 1;
    }
  }

  setTabClick(clickedOn) {
    printLog("clickedOn ===> $clickedOn");
    tabClickedOn = clickedOn;
    notifyListeners();
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    contentDetailModel = ContentDetailModel();
    episodeList?.clear();
    episodeList = [];
    successModel = SuccessModel();
    seasonPos = 0;
    mCurrentEpiPos = -1;
    tabClickedOn = "related";
  }
}
