// To parse this JSON data, do
// final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) =>
    ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  int? status;
  String? message;
  List<Result>? result;

  ProfileModel({
    this.status,
    this.message,
    this.result,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        status: json["status"],
        message: json["message"],
        result: List<Result>.from(
            json["result"]?.map((x) => Result.fromJson(x)) ?? []),
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
  String? userName;
  String? fullName;
  String? email;
  String? mobileNumber;
  String? image;
  int? type;
  int? parentControlStatus;
  String? parentControlPassword;
  int? status;
  String? expiryDate;
  int? deviceType;
  String? deviceToken;
  String? createdAt;
  String? updatedAt;
  int? isBuy;
  String? packageName;

  Result({
    this.id,
    this.userName,
    this.fullName,
    this.email,
    this.mobileNumber,
    this.image,
    this.type,
    this.parentControlStatus,
    this.parentControlPassword,
    this.status,
    this.expiryDate,
    this.deviceType,
    this.deviceToken,
    this.createdAt,
    this.updatedAt,
    this.isBuy,
    this.packageName,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        userName: json["user_name"],
        fullName: json["full_name"],
        email: json["email"],
        mobileNumber: json["mobile_number"],
        image: json["image"],
        type: json["type"],
        parentControlStatus: json["parent_control_status"],
        parentControlPassword: json["parent_control_password"],
        status: json["status"],
        expiryDate: json["expiry_date"],
        deviceType: json["device_type"],
        deviceToken: json["device_token"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isBuy: json["is_buy"],
        packageName: json["package_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_name": userName,
        "full_name": fullName,
        "email": email,
        "mobile_number": mobileNumber,
        "image": image,
        "type": type,
        "parent_control_status": parentControlStatus,
        "parent_control_password": parentControlPassword,
        "status": status,
        "expiry_date": expiryDate,
        "device_type": deviceType,
        "device_token": deviceToken,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_buy": isBuy,
        "package_name": packageName,
      };
}
