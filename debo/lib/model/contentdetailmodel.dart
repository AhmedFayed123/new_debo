// To parse this JSON data, do
// final contentDetailModel = contentDetailModelFromJson(jsonString);

import 'dart:convert';

ContentDetailModel contentDetailModelFromJson(String str) =>
    ContentDetailModel.fromJson(json.decode(str));

String contentDetailModelToJson(ContentDetailModel data) =>
    json.encode(data.toJson());

class ContentDetailModel {
  int? status;
  String? message;
  List<Result>? result;

  ContentDetailModel({
    this.status,
    this.message,
    this.result,
  });

  factory ContentDetailModel.fromJson(Map<String, dynamic> json) =>
      ContentDetailModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  int? id;
  int? typeId;
  int? videoType;
  int? channelId;
  int? producerId;
  String? categoryId;
  String? languageId;
  String? castId;
  String? name;
  String? thumbnail;
  String? landscape;
  String? trailerType;
  String? trailerUrl;
  String? description;
  String? releaseDate;
  int? isPremium;
  int? isTitle;
  int? isLike;
  int? isComment;
  int? totalLike;
  int? totalView;
  int? isRent;
  int? price;
  int? rentDay;
  int? rentPriceId;
  String? androidProductPackage;
  String? iosProductPackage;
  String? webPriceId;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? isBuy;
  int? rentBuy;
  int? isBookmark;
  int? subVideoType;
  int? stopTime;
  String? categoryName;
  String? languageName;
  String? videoUploadType;
  String? video320;
  String? video480;
  String? video720;
  String? video1080;
  String? videoExtension;
  int? videoDuration;
  String? subtitleType;
  String? subtitleLang1;
  String? subtitle1;
  String? subtitleLang2;
  String? subtitle2;
  String? subtitleLang3;
  String? subtitle3;
  int? isDownload;
  int? isUserDownload;
  List<Cast>? cast;
  List<Season>? season;

  Result({
    this.id,
    this.typeId,
    this.videoType,
    this.channelId,
    this.producerId,
    this.categoryId,
    this.languageId,
    this.castId,
    this.name,
    this.thumbnail,
    this.landscape,
    this.trailerType,
    this.trailerUrl,
    this.description,
    this.releaseDate,
    this.isPremium,
    this.isTitle,
    this.isLike,
    this.isComment,
    this.totalLike,
    this.totalView,
    this.isRent,
    this.price,
    this.rentDay,
    this.rentPriceId,
    this.androidProductPackage,
    this.iosProductPackage,
    this.webPriceId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isBuy,
    this.rentBuy,
    this.isBookmark,
    this.subVideoType,
    this.stopTime,
    this.categoryName,
    this.languageName,
    this.videoUploadType,
    this.video320,
    this.video480,
    this.video720,
    this.video1080,
    this.videoExtension,
    this.videoDuration,
    this.subtitleType,
    this.subtitleLang1,
    this.subtitle1,
    this.subtitleLang2,
    this.subtitle2,
    this.subtitleLang3,
    this.subtitle3,
    this.isDownload,
    this.isUserDownload,
    this.cast,
    this.season,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        typeId: json["type_id"],
        videoType: json["video_type"],
        channelId: json["channel_id"],
        producerId: json["producer_id"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        castId: json["cast_id"],
        name: json["name"],
        thumbnail: json["thumbnail"],
        landscape: json["landscape"],
        trailerType: json["trailer_type"],
        trailerUrl: json["trailer_url"],
        description: json["description"],
        releaseDate: json["release_date"],
        isPremium: json["is_premium"],
        isTitle: json["is_title"],
        isLike: json["is_like"],
        isComment: json["is_comment"],
        totalLike: json["total_like"],
        totalView: json["total_view"],
        isRent: json["is_rent"],
        price: json["price"],
        rentDay: json["rent_day"],
        rentPriceId: json["rent_price_id"],
        androidProductPackage: json["android_product_package"],
        iosProductPackage: json["ios_product_package"],
        webPriceId: json["web_price_id"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isBuy: json["is_buy"],
        rentBuy: json["rent_buy"],
        isBookmark: json["is_bookmark"],
        subVideoType: json["sub_video_type"],
        stopTime: json["stop_time"],
        categoryName: json["category_name"],
        languageName: json["language_name"],
        videoUploadType: json["video_upload_type"],
        video320: json["video_320"],
        video480: json["video_480"],
        video720: json["video_720"],
        video1080: json["video_1080"],
        videoExtension: json["video_extension"],
        videoDuration: json["video_duration"],
        subtitleType: json["subtitle_type"],
        subtitleLang1: json["subtitle_lang_1"],
        subtitle1: json["subtitle_1"],
        subtitleLang2: json["subtitle_lang_2"],
        subtitle2: json["subtitle_2"],
        subtitleLang3: json["subtitle_lang_3"],
        subtitle3: json["subtitle_3"],
        isDownload: json["is_download"],
        isUserDownload: json["is_user_download"],
        cast: json["cast"] == null
            ? []
            : List<Cast>.from(json["cast"]?.map((x) => Cast.fromJson(x)) ?? []),
        season: json["season"] == null
            ? []
            : List<Season>.from(
                json["season"]?.map((x) => Season.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type_id": typeId,
        "video_type": videoType,
        "channel_id": channelId,
        "producer_id": producerId,
        "category_id": categoryId,
        "language_id": languageId,
        "cast_id": castId,
        "name": name,
        "thumbnail": thumbnail,
        "landscape": landscape,
        "trailer_type": trailerType,
        "trailer_url": trailerUrl,
        "description": description,
        "release_date": releaseDate,
        "is_premium": isPremium,
        "is_title": isTitle,
        "is_like": isLike,
        "is_comment": isComment,
        "total_like": totalLike,
        "total_view": totalView,
        "is_rent": isRent,
        "price": price,
        "rent_day": rentDay,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_buy": isBuy,
        "rent_buy": rentBuy,
        "rent_price_id": rentPriceId,
        "android_product_package": androidProductPackage,
        "ios_product_package": iosProductPackage,
        "web_price_id": webPriceId,
        "is_bookmark": isBookmark,
        "sub_video_type": subVideoType,
        "stop_time": stopTime,
        "category_name": categoryName,
        "language_name": languageName,
        "video_upload_type": videoUploadType,
        "video_320": video320,
        "video_480": video480,
        "video_720": video720,
        "video_1080": video1080,
        "video_extension": videoExtension,
        "video_duration": videoDuration,
        "subtitle_type": subtitleType,
        "subtitle_lang_1": subtitleLang1,
        "subtitle_1": subtitle1,
        "subtitle_lang_2": subtitleLang2,
        "subtitle_2": subtitle2,
        "subtitle_lang_3": subtitleLang3,
        "subtitle_3": subtitle3,
        "is_download": isDownload,
        "is_user_download": isUserDownload,
        "cast": cast == null
            ? []
            : List<dynamic>.from(cast?.map((x) => x.toJson()) ?? []),
        "season": season == null
            ? []
            : List<dynamic>.from(season?.map((x) => x.toJson()) ?? []),
      };
}

class Cast {
  int? id;
  String? name;
  String? image;
  String? type;
  String? personalInfo;
  int? status;
  String? createdAt;
  String? updatedAt;

  Cast({
    this.id,
    this.name,
    this.image,
    this.type,
    this.personalInfo,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Cast.fromJson(Map<String, dynamic> json) => Cast(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        type: json["type"],
        personalInfo: json["personal_info"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "type": type,
        "personal_info": personalInfo,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class Season {
  int? id;
  String? name;
  int? status;
  String? createdAt;
  String? updatedAt;

  Season({
    this.id,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        id: json["id"],
        name: json["name"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
