
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../model/contentdetailmodel.dart';
import '../model/download_item.dart';
import '../model/relatedcontentmodel.dart';
import '../model/successmodel.dart';
import '../utils/constant.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class VideoDetailsProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();
  ContentDetailModel contentDetailModel = ContentDetailModel();
  RelatedContentModel relatedContentModel = RelatedContentModel();

  bool loading = false;
  String tabClickedOn = "related";

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> getContentDetails(
      typeId, videoType, videoId, upcomingType) async {
    printLog("getContentDetails typeId :========> $typeId");
    printLog("getContentDetails videoType :=====> $videoType");
    printLog("getContentDetails videoId :=======> $videoId");
    printLog("getContentDetails upcomingType :==> $upcomingType");
    loading = true;
    contentDetailModel = await ApiService()
        .contentDetails(typeId, videoType, videoId, upcomingType);
    printLog("getContentDetails status :===> ${contentDetailModel.status}");
    printLog("getContentDetails message :==> ${contentDetailModel.message}");
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

  Future<void> setBookMark(
      BuildContext context, videoType, subVideoType, videoId) async {
    if ((contentDetailModel.result?[0].isBookmark ?? 0) == 0) {
      contentDetailModel.result?[0].isBookmark = 1;
      Utils.showSnackbar(context, "success", "addwatchlistmessage", true);
    } else {
      contentDetailModel.result?[0].isBookmark = 0;
      Utils.showSnackbar(context, "success", "removewatchlistmessage", true);
    }
    notifyListeners();
    getAddBookMark(subVideoType, videoType, videoId);
  }

  Future<void> getAddBookMark(subVideoType, videoType, videoId) async {
    printLog("getAddBookMark videoType :======> $videoType");
    printLog("getAddBookMark subVideoType :===> $subVideoType");
    printLog("getAddBookMark videoId :========> $videoId");
    successModel =
        await ApiService().addRemoveBookmark(subVideoType, videoType, videoId);
    printLog("getAddBookMark status :===> ${successModel.status}");
    printLog("getAddBookMark message :==> ${successModel.message}");
  }

  Future<void> removeFromContinue(videoId, videoType, subVideoType) async {
    contentDetailModel.result?[0].stopTime = 0;
    notifyListeners();

    printLog("removeFromContinue videoType :=====> $videoType");
    printLog("removeFromContinue videoId :=======> $videoId");
    printLog("removeFromContinue subVideoType :==> $subVideoType");
    successModel = await ApiService()
        .removeContinueWatching(videoId, videoType, subVideoType);
    printLog("removeFromContinue message :==> ${successModel.message}");
  }

  Future<void> addRemoveDownload(
      BuildContext context, videoId, videoType, subVideoType) async {
    printLog("addRemoveDownload subVideoType :==> $subVideoType");
    printLog("addRemoveDownload videoType :=====> $videoType");
    printLog("addRemoveDownload videoId :=======> $videoId");
    /* Remove from Hive */
    late Box<DownloadItem> downloadBox;
    if (Constant.userID != null) {
      if (Constant.userIsKid == true) {
        downloadBox = Hive.box<DownloadItem>(
            '${Constant.hiveDownloadBox}_${Constant.userID}_KID');
      } else {
        downloadBox = Hive.box<DownloadItem>(
            '${Constant.hiveDownloadBox}_${Constant.userID}');
      }
    } else {
      downloadBox = Hive.box<DownloadItem>(Constant.hiveDownloadBox);
    }
    printLog(
        "downloadBox length :========> ${downloadBox.values.toList().length}");
    if (downloadBox.values.toList().isNotEmpty) {
      printLog(
          "downloadBox indexWhere =====> ${downloadBox.values.toList().indexWhere((downloadItem) => (downloadItem.id == videoId && downloadItem.videoType == videoType && downloadItem.subVideoType == subVideoType))}");
      await downloadBox
          .delete(downloadBox.values.toList().indexWhere((downloadItem) {
        printLog("downloadBox videoId :=======> ${downloadItem.id}");
        printLog("downloadBox videoType :=====> ${downloadItem.videoType}");
        printLog("downloadBox subVideoType :==> ${downloadItem.subVideoType}");
        return (downloadItem.id == videoId &&
            downloadItem.videoType == videoType &&
            downloadItem.subVideoType == subVideoType);
      }));
      if (downloadBox.values.toList().isEmpty) {
        downloadBox.clear();
      }
    } else {
      downloadBox.clear();
    }
    if (context.mounted) {
      Utils.showSnackbar(context, "success", "download_remove_success", true);
    }
    notifyListeners();
    /* Remove from Hive */
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
    relatedContentModel = RelatedContentModel();
    successModel = SuccessModel();
    tabClickedOn = "related";
  }

  setLike(BuildContext context, int videoType, int subVideoType, int videoId) {}
}
