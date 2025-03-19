// To parse this JSON data, do
// final playerModel = playerModelFromJson(jsonString);

import 'dart:convert';

PlayerModel playerModelFromJson(String str) =>
    PlayerModel.fromJson(json.decode(str));

String playerModelToJson(PlayerModel data) => json.encode(data.toJson());

class PlayerModel {
  String? playType;
  int? videoId;
  String? videoTitle;
  int? videoType;
  int? subVideoType;
  int? typeId;
  int? episodeId;
  int? stopTime;
  String? videoUrl;
  String? trailerUrl;
  String? uploadType;
  String? videoThumb;
  String? securityKey;

  PlayerModel({
    required this.playType,
    required this.videoId,
    required this.videoTitle,
    required this.videoType,
    required this.subVideoType,
    required this.typeId,
    required this.episodeId,
    required this.stopTime,
    required this.videoUrl,
    required this.trailerUrl,
    required this.uploadType,
    required this.videoThumb,
    required this.securityKey,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
        playType: json["playType"],
        videoId: json["videoId"],
        videoTitle: json["videoTitle"],
        videoType: json["videoType"],
        subVideoType: json["subVideoType"],
        typeId: json["typeId"],
        episodeId: json["episodeId"],
        stopTime: json["stopTime"],
        videoUrl: json["videoUrl"],
        trailerUrl: json["trailerUrl"],
        uploadType: json["uploadType"],
        videoThumb: json["videoThumb"],
        securityKey: json["securityKey"],
      );

  Map<String, dynamic> toJson() => {
        "playType": playType,
        "videoId": videoId,
        "videoTitle": videoTitle,
        "videoType": videoType,
        "subVideoType": subVideoType,
        "typeId": typeId,
        "episodeId": episodeId,
        "stopTime": stopTime,
        "videoUrl": videoUrl,
        "trailerUrl": trailerUrl,
        "uploadType": uploadType,
        "videoThumb": videoThumb,
        "securityKey": securityKey,
      };
}
