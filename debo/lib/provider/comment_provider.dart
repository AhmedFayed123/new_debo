import 'package:flutter/material.dart';
import '../model/comment_model.dart';
import '../model/successmodel.dart';
import '../webservice/apiservices.dart';
import '../utils/utils.dart';

class CommentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _loading = false;
  bool get loading => _loading;

  List<String> _comments = [];
  List<String> get comments => _comments;

  List<CommentModel> _commentModels = [];
  List<CommentModel> get commentModels => _commentModels;

  setLoading(bool isLoading) {
    _loading = isLoading;
    notifyListeners();
  }

  Future<void> addComment(int videoId, String comment, int videoType, int subVideoType) async {
    if (comment.isEmpty) return;

    printLog("Adding comment: $comment for videoId: $videoId");

    setLoading(true);
    try {
      SuccessModel response = await _apiService.addComment(
        videoId: videoId,
        comment: comment,
        videoType: videoType,
        subVideoType: subVideoType,
      );

      if (response.status == 200) {
        print('Comment added successfully');

        await getComments(videoId, videoType, subVideoType);
      }
    } catch (e) {
      printLog("Comment error: $e");
    } finally {
      setLoading(false);
    }
  }

  Future<void> getComments(int videoId, int videoType, int subVideoType) async {
    setLoading(true);
    try {
      List<CommentModel>? fetchedComments = await _apiService.getComments(
        videoId: videoId,
        videoType: videoType,
        subVideoType: subVideoType,
      );

      _commentModels = fetchedComments;

      printLog("Fetched ${_commentModels.length} comments");
      notifyListeners();
    } catch (e) {
      printLog("Failed to fetch comments: $e");
      _commentModels = []; // تأكد من أنها لا تبقى `null`
    } finally {
      setLoading(false);
    }
  }


  Future<void> editComment(int commentId, String comment) async {
    setLoading(true);
    try {
      SuccessModel response = await _apiService.editComment(
        commentId: commentId,
        comment: comment,
      );

      if (response.status == 200) {
        int index = _comments.indexWhere((c) => c.contains(commentId.toString()));
        if (index != -1) {
          _comments[index] = comment;
          notifyListeners();
        }
      }
    } catch (e) {
      printLog("Edit comment error: $e");
    } finally {
      setLoading(false);
    }
  }
  Future<void> deleteComment(int commentId) async {
    setLoading(true);
    try {
      SuccessModel response = await _apiService.deleteComment(commentId: commentId);

      if (response.status == 200) {
        _comments.removeWhere((c) => c.contains(commentId.toString()));
        notifyListeners();
      }
    } catch (e) {
      printLog("Delete comment error: $e");
    } finally {
      setLoading(false);
    }
  }


  void clearProvider() {
    _loading = false;
    _comments.clear();
    _commentModels.clear();
    notifyListeners();
  }
}