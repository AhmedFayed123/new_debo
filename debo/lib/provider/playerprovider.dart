
import 'package:flutter/material.dart';

import '../model/devicesyncmodel.dart';
import '../model/successmodel.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class PlayerProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();
  DeviceSyncModel deviceSyncModel = DeviceSyncModel();
  SuccessModel videoViewSuccessModel = SuccessModel();

  bool loading = false, isDeviceAdded = false;
  String currentSubtitle = "";
  String currentQuality = "";

  setCurrentSubtitle(String subtitleName) {
    currentSubtitle = subtitleName;
    notifyListeners();
  }

  setCurrentQuality(String qualityName) {
    currentQuality = qualityName;
    notifyListeners();
  }

  Future<void> addRemoveDevice(watchType) async {
    printLog("addRemoveDevice watchType :=======> $watchType");
    loading = true;
    deviceSyncModel = await ApiService().addRemoveDeviceWatching(watchType);
    printLog("addRemoveDevice message :==> ${deviceSyncModel.message}");
    if (deviceSyncModel.status == 200) {
      isDeviceAdded = true;
    } else {
      isDeviceAdded = false;
    }
    printLog("addRemoveDevice isDeviceAdded :==> $isDeviceAdded");
    loading = false;
    notifyListeners();
  }

  Future<void> addVideoView(videoId, videoType, subVideoType, episodeId) async {
    printLog("addVideoView videoId :=======> $videoId");
    printLog("addVideoView videoType :=====> $videoType");
    printLog("addVideoView subVideoType :==> $subVideoType");
    printLog("addVideoView episodeId :=====> $episodeId");
    videoViewSuccessModel = await ApiService()
        .videoView(videoId, videoType, subVideoType, episodeId);
    printLog("addVideoView message :==> ${videoViewSuccessModel.message}");
    notifyListeners();
  }

  Future<void> addToContinue(videoId, videoType, subVideoType, stopTime) async {
    printLog("addToContinue stopTime :======> $stopTime");
    printLog("addToContinue videoType :=====> $videoType");
    printLog("addToContinue subVideoType :==> $subVideoType");
    printLog("addToContinue videoId :=======> $videoId");
    successModel = await ApiService()
        .addContinueWatching(videoId, videoType, subVideoType, stopTime);
    printLog("addToContinue message :==> ${successModel.message}");
    notifyListeners();
  }

  Future<void> removeFromContinue(videoId, videoType, subVideoType) async {
    printLog("removeFromContinue videoType :=====> $videoType");
    printLog("removeFromContinue subVideoType :==> $subVideoType");
    printLog("removeFromContinue videoId :=======> $videoId");
    successModel = await ApiService()
        .removeContinueWatching(videoId, videoType, subVideoType);
    printLog("removeFromContinue message :==> ${successModel.message}");
    notifyListeners();
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    successModel = SuccessModel();
    deviceSyncModel = DeviceSyncModel();
    videoViewSuccessModel = SuccessModel();
    currentSubtitle = "";
    loading = false;
    isDeviceAdded = false;
  }
}
