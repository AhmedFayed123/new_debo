import 'package:flutter/material.dart';

import '../utils/utils.dart';

class ShowDownloadProvider extends ChangeNotifier {
  int dProgress = 0;
  int? seasonClickIndex;
  int? itemId;
  bool loading = false;

  setDownloadProgress(int progress, int itemId) {
    this.itemId = itemId;
    loading = (progress != -1);
    dProgress = progress;
    notifyListeners();
    printLog('setDownloadProgress dProgress ==============> $dProgress');
  }

  setLoading(bool isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  setSelectedSeason(index) {
    seasonClickIndex = index;
    notifyListeners();
  }

  setCurrentDownload(int? itemId) {
    this.itemId = itemId;
    notifyListeners();
  }

  notifyProvider() {
    notifyListeners();
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    dProgress = 0;
    seasonClickIndex = 0;
    itemId = null;
    loading = false;
  }

  // Future<void> prepareDownload(
  //     BuildContext context,
  //     Result? sectionDetails,
  //     List<Season>? seasonList,
  //     int? seasonPos,
  //     List<episode.Result>? episodeList) async {
  //   this.context = context;
  //   final tasks = await FlutterDownloader.loadTasks();

  //   if (tasks == null) {
  //     printLog('No tasks were retrieved from the database.');
  //     return;
  //   }

  //   if (this.sectionDetails != null) {
  //     this.sectionDetails = Result();
  //   }
  //   if (this.seasonList != null) {
  //     this.seasonPos = null;
  //     this.seasonList = [];
  //   }
  //   if (this.episodeList != null) {
  //     this.episodeList = [];
  //   }

  //   this.sectionDetails = sectionDetails;
  //   this.seasonList = seasonList;
  //   this.seasonPos = seasonPos;
  //   this.episodeList = episodeList;

  //   mTotalEpi = this.episodeList?.length;
  //   printLog("mTotalEpi ----------------------> $mTotalEpi");
  //   localPath = await Utils.prepareShowSaveDir(
  //       (sectionDetails?.name ?? "").replaceAll(RegExp('\\W+'), ''),
  //       (seasonList?[(seasonPos ?? 0)].name ?? "")
  //           .replaceAll(RegExp('\\W+'), ''));
  //   printLog("localPath ====> $localPath");
  //   _downloadEpisodeByPos(0);
  // }

  // _downloadEpisodeByPos(int epiPosition) async {
  //   printLog("_downloadEpi epiPosition ========> $epiPosition");
  //   if ((episodeList?[epiPosition].video320 ?? "").isNotEmpty) {
  //     File? mTargetFile;
  //     String? mFileName =
  //         '${(seasonList?[(seasonPos ?? 0)].name ?? "").replaceAll(RegExp('\\W+'), '')}'
  //         '_Ep${(epiPosition + 1)}_${episodeList?[epiPosition].id}${(Constant.userID)}';

  //     try {
  //       mTargetFile = File(path.join(localPath ?? "",
  //           '$mFileName.${episodeList?[epiPosition].videoExtension != '' ? (episodeList?[epiPosition].videoExtension ?? 'mp4') : 'mp4'}'));
  //       // This is a sync operation on a real
  //       // app you'd probably prefer to use writeAsByte and handle its Future
  //     } catch (e) {
  //       printLog("saveShowStorage Exception ===> $e");
  //     }
  //     printLog("mFileName ========> $mFileName");
  //     printLog("mTargetFile ========> ${mTargetFile?.absolute.path ?? ""}");

  //     if (mTargetFile != null) {
  //       try {
  //         savedEpiPathList?.add(mTargetFile.path);
  //         printLog(
  //             "savedEpiPathList $epiPosition ========> ${savedEpiPathList?[epiPosition]}");
  //         printLog(
  //             "savedEpiPathList length ========> ${savedEpiPathList?.length}");
  //         await _requestDownload((episodeList?[epiPosition].video320 ?? ""),
  //             localPath, mTargetFile.path);
  //       } catch (e) {
  //         printLog("Downloading... Exception ======> $e");
  //       }
  //     }
  //   } else {
  //     if (!context.mounted) return;
  //     Utils.showSnackbar(context, "fail", "invalid_url", true);
  //   }
  // }

  // Future<void> _requestDownload(
  //     String? videoUrl, String? savedDir, String? savedFile) async {
  //   printLog('savedFile ===========> $savedFile');
  //   printLog('savedDir ============> $savedDir');
  //   printLog('videoUrl ============> $videoUrl');
  //   await FlutterDownloader.enqueue(
  //     url: videoUrl ?? "",
  //     headers: {'auth': 'test_for_sql_encoding'},
  //     fileName: basename(savedFile ?? ''),
  //     savedDir: savedDir ?? '',
  //     saveInPublicStorage: false,
  //   );
  // }

  // saveEpisodeInSecureStorage(int epiPosition) async {
  //   printLog("saveEpisode epiPosition ========> $epiPosition");
  //   String? listString = await storage.read(
  //           key:
  //               '${Constant.hawkEPISODEList}${Constant.userID}${seasonList?[(seasonPos ?? 0)].id}${sectionDetails?.id}') ??
  //       '';
  //   List<EpisodeItem>? myEpiList;
  //   if (listString != "") {
  //     myEpiList = List<EpisodeItem>.from(
  //         jsonDecode(listString)?.map((x) => EpisodeItem.fromJson(x)) ?? []);
  //   }
  //   printLog("myEpiList ===> ${myEpiList?.length}");

  //   /* Save Episodes */
  //   EpisodeItem episodeItem = EpisodeItem(
  //     id: episodeList?[epiPosition].id,
  //     showId: sectionDetails?.id,
  //     sessionId: seasonList?[(seasonPos ?? 0)].id,
  //     thumbnail: episodeList?[epiPosition].thumbnail,
  //     landscape: episodeList?[epiPosition].landscape,
  //     videoUploadType: episodeList?[epiPosition].videoUploadType,
  //     videoType: sectionDetails?.videoType,
  //     videoExtension: episodeList?[epiPosition].videoExtension != ''
  //         ? (episodeList?[epiPosition].videoExtension ?? 'mp4')
  //         : 'mp4',
  //     videoDuration: episodeList?[epiPosition].videoDuration,
  //     isPremium: episodeList?[epiPosition].isPremium,
  //     description: episodeList?[epiPosition].description,
  //     status: episodeList?[epiPosition].status,
  //     video320: episodeList?[epiPosition].video320,
  //     video480: episodeList?[epiPosition].video480,
  //     video720: episodeList?[epiPosition].video720,
  //     video1080: episodeList?[epiPosition].video1080,
  //     savedDir: localPath,
  //     savedFile: savedEpiPathList?[epiPosition],
  //     subtitleType: episodeList?[epiPosition].subtitleType,
  //     subtitle1: episodeList?[epiPosition].subtitle1,
  //     subtitle2: episodeList?[epiPosition].subtitle2,
  //     subtitle3: episodeList?[epiPosition].subtitle3,
  //     subtitleLang1: episodeList?[epiPosition].subtitleLang1,
  //     subtitleLang2: episodeList?[epiPosition].subtitleLang2,
  //     subtitleLang3: episodeList?[epiPosition].subtitleLang3,
  //     isDownloaded: 1,
  //     isBookmark: sectionDetails?.isBookmark,
  //     rentBuy: sectionDetails?.rentBuy,
  //     isRent: sectionDetails?.isRent,
  //     rentPrice: sectionDetails?.price,
  //     isBuy: episodeList?[epiPosition].isBuy,
  //     categoryName: sectionDetails?.categoryName,
  //   );

  //   myEpiList ??= [];
  //   if (myEpiList.isNotEmpty) {
  //     await checkEpisodeInSecure(
  //         myEpiList,
  //         episodeList?[epiPosition].id.toString() ?? "",
  //         sectionDetails?.id.toString() ?? "",
  //         seasonList?[(seasonPos ?? 0)].id.toString() ?? "");
  //   }
  //   myEpiList.add(episodeItem);
  //   printLog("myEpiList ===> ${myEpiList.length}");

  //   if (myEpiList.isNotEmpty) {
  //     await storage.write(
  //       key:
  //           '${Constant.hawkEPISODEList}${Constant.userID}${seasonList?[(seasonPos ?? 0)].id}${sectionDetails?.id}',
  //       value: jsonEncode(myEpiList),
  //     );
  //   }
  //   /* **************/

  //   printLog("epiPosition -------------------===> $epiPosition");
  //   printLog("myEpiList ---------------------===> ${myEpiList.length}");
  //   printLog("mTotalEpi ---------------------===> $mTotalEpi");
  //   if (myEpiList.length == mTotalEpi) {
  //     saveShowInSecureStorage(myEpiList.length);
  //   } else {
  //     _downloadEpisodeByPos(epiPosition + 1);
  //   }
  //   printLog("cEpisodePos -------------------===> $cEpisodePos");
  // }

  // saveShowInSecureStorage(int epiLength) async {
  //   final showDetailsProvider =
  //       Provider.of<ShowDetailsProvider>(context, listen: false);
  //   String? listString = await storage.read(
  //           key:
  //               "${Constant.hawkEPISODEList}${Constant.userID}${seasonList?[(seasonPos ?? 0)].id}${sectionDetails?.id}") ??
  //       '';
  //   printLog("listString ===> ${listString.toString()}");
  //   List<EpisodeItem>? myEpiList;
  //   if (listString != "") {
  //     myEpiList = List<EpisodeItem>.from(
  //         jsonDecode(listString)?.map((x) => EpisodeItem.fromJson(x)) ?? []);
  //   }

  //   /* Save Seasons */
  //   String? listSeasonString = await storage.read(
  //           key:
  //               "${Constant.hawkSEASONList}${Constant.userID}${sectionDetails?.id}") ??
  //       '';
  //   printLog("listSeasonString ===> ${listSeasonString.toString()}");
  //   List<SessionItem>? mySeasonList;
  //   if (listSeasonString != "") {
  //     mySeasonList = List<SessionItem>.from(
  //         jsonDecode(listSeasonString)?.map((x) => SessionItem.fromJson(x)) ??
  //             []);
  //   }
  //   SessionItem sessionItem = SessionItem(
  //     id: seasonList?[(seasonPos ?? 0)].id,
  //     showId: sectionDetails?.id,
  //     sessionPosition: seasonPos,
  //     name: seasonList?[(seasonPos ?? 0)].name,
  //     status: seasonList?[(seasonPos ?? 0)].status,
  //     isDownload: 1,
  //     episode: myEpiList,
  //   );
  //   mySeasonList ??= [];
  //   if (mySeasonList.isNotEmpty) {
  //     await checkSeasonInSecure(
  //         mySeasonList,
  //         sectionDetails?.id.toString() ?? "",
  //         seasonList?[(seasonPos ?? 0)].id.toString() ?? "");
  //   }
  //   mySeasonList.add(sessionItem);
  //   printLog("mySeasonList ===> ${mySeasonList.length}");

  //   if (mySeasonList.isNotEmpty) {
  //     await storage.write(
  //       key:
  //           "${Constant.hawkSEASONList}${Constant.userID}${sectionDetails?.id}",
  //       value: jsonEncode(mySeasonList),
  //     );
  //   }
  //   /* ************/

  //   /* Save Show */
  //   String? listShowString =
  //       await storage.read(key: "${Constant.hawkSHOWList}${Constant.userID}") ??
  //           '';
  //   printLog("listShowString ===> ${listShowString.toString()}");
  //   List<DownloadItem>? myShowList;
  //   if (listShowString != "") {
  //     myShowList = List<DownloadItem>.from(
  //         jsonDecode(listShowString)?.map((x) => DownloadItem.fromJson(x)) ??
  //             []);
  //   }
  //   DownloadItem downloadShowModel = DownloadItem(
  //     id: sectionDetails?.id,
  //     securityKey: sectionDetails?.id.toString(),
  //     name: sectionDetails?.name,
  //     description: sectionDetails?.description,
  //     videoType: sectionDetails?.videoType,
  //     typeId: sectionDetails?.typeId,
  //     isPremium: sectionDetails?.isPremium,
  //     isBuy: sectionDetails?.isBuy,
  //     isRent: sectionDetails?.isRent,
  //     rentBuy: sectionDetails?.rentBuy,
  //     rentPrice: sectionDetails?.price,
  //     isDownload: 1,
  //     releaseYear: sectionDetails?.releaseDate,
  //     landscapeImg: sectionDetails?.landscape,
  //     thumbnailImg: sectionDetails?.thumbnail,
  //     savedDir: localPath,
  //     session: mySeasonList,
  //   );
  //   myShowList ??= [];
  //   if (myShowList.isNotEmpty) {
  //     await checkShowInSecure(myShowList, sectionDetails?.id.toString() ?? "");
  //   }
  //   myShowList.add(downloadShowModel);
  //   printLog("myShowList ===> ${myShowList.length}");

  //   if (myShowList.isNotEmpty) {
  //     await storage.write(
  //       key: "${Constant.hawkSHOWList}${Constant.userID}",
  //       value: jsonEncode(myShowList),
  //     );
  //   }
  //   /* ************/

  //   printLog("mTotalEpi ------------------------===> $mTotalEpi");
  //   if (myEpiList?.length == mTotalEpi) {
  //     if (!context.mounted) return;
  //     Utils.setDownloadComplete(
  //       context,
  //       "Show",
  //       showDetailsProvider.contentDetailModel.result?[0]
  //           .season?[showDetailsProvider.seasonPos].id,
  //       showDetailsProvider.contentDetailModel.result?[0].videoType,
  //       showDetailsProvider.contentDetailModel.result?[0].subVideoType,
  //       showDetailsProvider.contentDetailModel.result?[0].id,
  //     );
  //   }
  //   notifyListeners();
  // }

  // checkShowInSecure(List<DownloadItem>? myShowList, String showID) async {
  //   printLog("checkShowInSecure UserID ===> ${Constant.userID}");
  //   printLog("checkShowInSecure showID ===> $showID");

  //   if ((myShowList?.length ?? 0) == 0) {
  //     await storage.delete(key: "${Constant.hawkSHOWList}${Constant.userID}");
  //     return;
  //   }
  //   for (int i = 0; i < (myShowList?.length ?? 0); i++) {
  //     printLog("Secure itemID ==> ${myShowList?[i].id}");

  //     if ((myShowList?[i].id.toString()) == (showID)) {
  //       printLog("myShowList =======================> i = $i");
  //       myShowList?.remove(myShowList[i]);

  //       await storage.write(
  //         key: "${Constant.hawkSHOWList}${Constant.userID}",
  //         value: jsonEncode(myShowList),
  //       );
  //     }
  //   }
  // }

  // checkSeasonInSecure(
  //     List<SessionItem>? mySeasonList, String showID, String seasonID) async {
  //   printLog("checkSeasonInSecure UserID ===> ${Constant.userID}");
  //   printLog("checkSeasonInSecure showID ===> $showID");
  //   printLog("checkSeasonInSecure seasonID ===> $seasonID");

  //   if ((mySeasonList?.length ?? 0) == 0) {
  //     await storage.delete(
  //         key: "${Constant.hawkSEASONList}${Constant.userID}$showID");
  //     return;
  //   }
  //   for (int i = 0; i < (mySeasonList?.length ?? 0); i++) {
  //     printLog("Secure itemID ==> ${mySeasonList?[i].id}");

  //     if ((mySeasonList?[i].id.toString()) == (seasonID) &&
  //         (mySeasonList?[i].showId.toString()) == (showID)) {
  //       printLog("mySeasonList =======================> i = $i");
  //       mySeasonList?.remove(mySeasonList[i]);

  //       await storage.write(
  //         key: "${Constant.hawkSEASONList}${Constant.userID}$showID",
  //         value: jsonEncode(mySeasonList),
  //       );
  //     }
  //   }
  // }

  // checkEpisodeInSecure(List<EpisodeItem>? myEpisodeList, String epiID,
  //     String showID, String seasonID) async {
  //   printLog("checkEpisodeInSecure UserID ===> ${Constant.userID}");
  //   printLog("checkEpisodeInSecure epiID ===> $epiID");
  //   printLog("checkEpisodeInSecure showID ===> $showID");
  //   printLog("checkEpisodeInSecure seasonID ===> $seasonID");

  //   if ((myEpisodeList?.length ?? 0) == 0) {
  //     await storage.delete(
  //         key: "${Constant.hawkEPISODEList}${Constant.userID}$seasonID$showID");
  //     return;
  //   }
  //   for (int i = 0; i < (myEpisodeList?.length ?? 0); i++) {
  //     printLog("Secure itemID ==> ${myEpisodeList?[i].id}");

  //     if ((myEpisodeList?[i].id.toString()) == (epiID) &&
  //         (myEpisodeList?[i].showId.toString()) == (showID) &&
  //         (myEpisodeList?[i].sessionId.toString()) == (seasonID)) {
  //       printLog("myEpisodeList =======================> i = $i");
  //       myEpisodeList?.remove(myEpisodeList[i]);

  //       await storage.write(
  //         key: "${Constant.hawkEPISODEList}${Constant.userID}$seasonID$showID",
  //         value: jsonEncode(myEpisodeList),
  //       );
  //     }
  //   }
  // }

  // Future<List<SessionItem>?> getDownloadedSeasons(String showID) async {
  //   loading = true;
  //   List<SessionItem>? mySeasonList;
  //   String? listString = await storage.read(
  //           key: "${Constant.hawkSEASONList}${Constant.userID}$showID") ??
  //       '';
  //   printLog("listString ===> ${listString.toString()}");
  //   if (listString != "") {
  //     mySeasonList = List<SessionItem>.from(
  //         jsonDecode(listString)?.map((x) => SessionItem.fromJson(x)) ?? []);
  //   }
  //   loading = false;
  //   notifyListeners();
  //   return mySeasonList;
  // }

  // Future<List<EpisodeItem>?> getDownloadedEpisodes(
  //     String showID, String seasonID) async {
  //   loading = true;
  //   List<EpisodeItem>? myEpisodeList;
  //   String? listString = await storage.read(
  //           key:
  //               "${Constant.hawkEPISODEList}${Constant.userID}$seasonID$showID") ??
  //       '';
  //   printLog("listString ===> ${listString.toString()}");
  //   if (listString != "") {
  //     myEpisodeList = List<EpisodeItem>.from(
  //         jsonDecode(listString)?.map((x) => EpisodeItem.fromJson(x)) ?? []);
  //   }
  //   loading = false;
  //   notifyListeners();
  //   return myEpisodeList;
  // }

  // Future<void> deleteShowFromDownload(String showID) async {
  //   printLog("deleteShowFromDownload UserID ===> ${Constant.userID}");
  //   printLog("deleteShowFromDownload showID ===> $showID");
  //   List<DownloadItem>? myShowList = [];
  //   String? listString =
  //       await storage.read(key: '${Constant.hawkSHOWList}${Constant.userID}') ??
  //           '';
  //   printLog("listString ===> ${listString.toString()}");
  //   if (listString != "") {
  //     myShowList = List<DownloadItem>.from(
  //         jsonDecode(listString)?.map((x) => DownloadItem.fromJson(x)) ?? []);
  //   }
  //   printLog("myShowList ===> ${myShowList.length}");

  //   if (myShowList.isEmpty) {
  //     await storage.delete(key: "${Constant.hawkSHOWList}${Constant.userID}");
  //     return;
  //   }
  //   for (int i = 0; i < myShowList.length; i++) {
  //     printLog("Secure itemID ==> ${myShowList[i].id}");

  //     if ((myShowList[i].id.toString()) == (showID)) {
  //       printLog("myShowList =======================> i = $i");
  //       String dirPath = myShowList[i].savedDir ?? "";
  //       myShowList.remove(myShowList[i]);
  //       File dirFolder = File(dirPath);
  //       printLog("File existsSync ==> ${dirFolder.existsSync()}");
  //       dirFolder.deleteSync(recursive: true);
  //       printLog("myShowList ==1==> ${myShowList.length}");
  //       if (myShowList.isEmpty) {
  //         await storage.delete(
  //             key: "${Constant.hawkSHOWList}${Constant.userID}");
  //         return;
  //       }
  //       printLog("myShowList ==2==> ${myShowList.length}");
  //       await storage.write(
  //         key: "${Constant.hawkSHOWList}${Constant.userID}",
  //         value: jsonEncode(myShowList),
  //       );
  //       return;
  //     }
  //   }
  // }

  // Future<void> deleteEpisodeFromDownload(
  //     String epiID, String showID, String seasonID) async {
  //   printLog("epiID ======> $epiID");
  //   printLog("showID =====> $showID");
  //   printLog("seasonID ===> $seasonID");
  //   List<DownloadItem>? myShowList;
  //   List<SessionItem>? mySessionList;
  //   List<EpisodeItem>? myEpisodeList;
  //   String? listString =
  //       await storage.read(key: '${Constant.hawkSHOWList}${Constant.userID}') ??
  //           '';
  //   if (listString != "") {
  //     myShowList = List<DownloadItem>.from(
  //         jsonDecode(listString)?.map((x) => DownloadItem.fromJson(x)) ?? []);
  //   }
  //   printLog("myShowList ===> ${myShowList?.length}");

  //   String? listSeasonString = await storage.read(
  //           key: '${Constant.hawkSEASONList}${Constant.userID}$showID') ??
  //       '';
  //   if (listSeasonString != "") {
  //     mySessionList = List<SessionItem>.from(
  //         jsonDecode(listSeasonString)?.map((x) => SessionItem.fromJson(x)) ??
  //             []);
  //   }
  //   printLog("mySeasonList ===> ${mySessionList?.length}");

  //   String? listEpiString = await storage.read(
  //           key:
  //               '${Constant.hawkEPISODEList}${Constant.userID}$seasonID$showID') ??
  //       '';
  //   printLog("listEpiString ===> $listEpiString");
  //   if (listEpiString != "") {
  //     myEpisodeList = List<EpisodeItem>.from(
  //         jsonDecode(listEpiString)?.map((x) => EpisodeItem.fromJson(x)) ?? []);
  //   }
  //   printLog("myEpisodeList ===> ${myEpisodeList?.length}");

  //   /* Main Download Loop */
  //   // for (int i = 0; i < (myShowList?.length ?? 0); i++) {
  //   //   if ((myShowList?[i].id.toString()) == showID) {
  //   //     printLog("Stored ShowID ========> ${myShowList?[i].id}");
  //   //     /* Season(Session) Loop */
  //   //     for (int j = 0; j < (mySessionList?.length ?? 0); j++) {
  //   //       if (mySessionList?[j].id.toString() == seasonID.toString() &&
  //   //           mySessionList?[j].showId.toString() == showID.toString()) {
  //   //         printLog("Stored SessionID ========> ${mySessionList?[j].id}");
  //   //         /* Episode Loop */
  //   //         for (int k = 0; k < (myEpisodeList?.length ?? 0); k++) {
  //   //           printLog("Hawk epiID ==> ${myEpisodeList?[k].id}");
  //   //           if (myEpisodeList?[k].id.toString() == epiID.toString() &&
  //   //               myEpisodeList?[k].showId.toString() == showID.toString() &&
  //   //               myEpisodeList?[k].sessionId.toString() ==
  //   //                   seasonID.toString()) {
  //   //             printLog("Stored EpisodeID ========> ${myEpisodeList?[k].id}");
  //   //             printLog(
  //   //                 "Stored SessionID ========> ${myEpisodeList?[k].sessionId}");
  //   //             printLog("Stored ShowID ========> ${myEpisodeList?[k].showId}");
  //   //             printLog("myEpisodeList =======================> k = $k");
  //   //             String dirPath = myShowList?[i].savedDir ?? "";
  //   //             String epiPath = myEpisodeList?[k].savedFile ?? "";
  //   //             printLog("epiPath =====> $epiPath");
  //   //             printLog("dirPath =====> $dirPath");
  //   //             printLog(
  //   //                 "myEpisodeList ====BEFORE=====> ${myEpisodeList?.length}");
  //   //             myEpisodeList?.remove(myEpisodeList[k]);
  //   //             printLog(
  //   //                 "myEpisodeList ====AFTER=====> ${myEpisodeList?.length}");
  //   //             await storage.write(
  //   //               key:
  //   //                   "${Constant.hawkEPISODEList}${Constant.userID}$seasonID$showID",
  //   //               value: jsonEncode(myEpisodeList),
  //   //             );
  //   //             if ((myEpisodeList?.length ?? 0) == 0) {
  //   //               printLog(
  //   //                   "mySessionList ====BEFORE=====> ${mySessionList?.length}");
  //   //               mySessionList?.remove(mySessionList[j]);
  //   //               printLog(
  //   //                   "mySessionList ====AFTER=====> ${mySessionList?.length}");
  //   //               await storage.delete(
  //   //                 key:
  //   //                     "${Constant.hawkEPISODEList}${Constant.userID}$seasonID$showID",
  //   //               );
  //   //             }
  //   //             if ((myEpisodeList?.length ?? 0) > 0) {
  //   //               mySessionList?[j].episode = myEpisodeList;
  //   //             }
  //   //             await storage.write(
  //   //               key: "${Constant.hawkSEASONList}${Constant.userID}$showID",
  //   //               value: jsonEncode(mySessionList),
  //   //             );
  //   //             if ((mySessionList?.length ?? 0) == 0) {
  //   //               printLog("myShowList ====BEFORE=====> ${myShowList?.length}");
  //   //               myShowList?.remove(myShowList[i]);
  //   //               printLog("myShowList ====AFTER=====> ${myShowList?.length}");
  //   //               await storage.delete(
  //   //                 key:
  //   //                     "${Constant.hawkSEASONList}${Constant.userID}$seasonID",
  //   //               );
  //   //             }
  //   //             if ((mySessionList?.length ?? 0) > 0) {
  //   //               myShowList?[i].session = mySessionList;
  //   //             }
  //   //             await storage.write(
  //   //               key: "${Constant.hawkSHOWList}${Constant.userID}",
  //   //               value: jsonEncode(myShowList),
  //   //             );
  //   //             printLog("myShowList ====SIZE=====> ${myShowList?.length}");
  //   //             if ((myEpisodeList?.length ?? 0) > 0) {
  //   //               File file = File(epiPath);
  //   //               if (await file.exists()) {
  //   //                 file.delete();
  //   //               }
  //   //             } else {
  //   //               if ((mySessionList?.length ?? 0) == 0) {
  //   //                 File dirFolder = File(dirPath);
  //   //                 printLog("File existsSync ==> ${dirFolder.existsSync()}");
  //   //                 if (dirFolder.existsSync()) {
  //   //                   dirFolder.deleteSync(recursive: true);
  //   //                 }
  //   //                 await storage.delete(
  //   //                     key: "${Constant.hawkSHOWList}${Constant.userID}");
  //   //               }
  //   //             }
  //   //             return;
  //   //           }
  //   //         }
  //   //       }
  //   //     }
  //   //   }
  //   // }
  // }

  // setSelectedSeason(index) {
  //   seasonClickIndex = index;
  //   notifyListeners();
  // }

  // clearProvider() {
  //   seasonClickIndex = 0;
  //   dProgress = 0;
  //   cEpisodePos = 0;
  //   seasonPos = 0;
  //   mTotalEpi = 0;
  //   sectionDetails;
  //   seasonList = [];
  //   episodeList = [];
  //   localPath = "";
  //   savedEpiPathList = [];
  //   printLog("<================ D clearProvider ================>");
  // }
}
