class CommentModel {
  final int id;
  final int commentId;
  final int userId;
  final int videoType;
  final int subVideoType;
  final int videoId;
  final String comment;
  final String createdAt;
  final String updatedAt;
  final String userName;
  final String fullName;
  final String email;
  final String image;
  final int isReply;
  final int totalReply;

  CommentModel({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.videoType,
    required this.subVideoType,
    required this.videoId,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.fullName,
    required this.email,
    required this.image,
    required this.isReply,
    required this.totalReply,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      commentId: json['comment_id'],
      userId: json['user_id'],
      videoType: json['video_type'],
      subVideoType: json['sub_video_type'],
      videoId: json['video_id'],
      comment: json['comment'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      userName: json['user_name'],
      fullName: json['full_name'],
      email: json['email'],
      image: json['image'],
      isReply: json['is_reply'],
      totalReply: json['total_reply'],
    );
  }
}
