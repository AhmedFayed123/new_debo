import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class LikeProvider extends ChangeNotifier {
  final ApiService _likeService = ApiService();
  bool _loading = false;
  bool get loading => _loading;

  Map<int, bool> _likedVideos = {};

  LikeProvider() {
    _loadLikedVideos();
  }

  bool isLiked(int videoId) {
    return _likedVideos[videoId] ?? false;
  }

  setLoading(bool isLoading) {
    _loading = isLoading;
    notifyListeners();
  }

  Future<void> _loadLikedVideos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedList = prefs.getStringList("likedVideos");

    if (likedList != null) {
      _likedVideos = {for (var id in likedList) int.parse(id): true};
    }
    notifyListeners();
  }

  Future<void> _saveLikedVideos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      "likedVideos",
      _likedVideos.keys.map((id) => id.toString()).toList(),
    );
  }

  Future<void> addRemoveLike(int videoId, int videoType, int subVideoType) async {
    printLog("Calling addRemoveLike for video: $videoId");

    setLoading(true);
    try {
      await _likeService.addRemoveLike(
        videoId: videoId,
        videoType: videoType,
        subVideoType: subVideoType,
      );

      if (_likedVideos.containsKey(videoId)) {
        _likedVideos.remove(videoId);
      } else {
        _likedVideos[videoId] = true;
      }

      await _saveLikedVideos();
    } catch (e) {
      printLog("Like error: $e");
    } finally {
      setLoading(false);
    }

    notifyListeners();
  }

  void clearProvider() {
    printLog("<================ clearProvider ================>");
    _loading = false;
    _likedVideos.clear();
    notifyListeners();
  }
}
