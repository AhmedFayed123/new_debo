class Result {
  Result({
      this.id, 
      this.userName, 
      this.fullName, 
      this.email, 
      this.mobileNumber, 
      this.imageType, 
      this.image, 
      this.type, 
      this.parentControlStatus, 
      this.parentControlPassword, 
      this.status, 
      this.createdAt, 
      this.updatedAt, 
      this.userOtp, 
      this.isBuy, 
      this.deviceId, 
      this.deviceType, 
      this.deviceToken,});

  Result.fromJson(dynamic json) {
    id = json['id'];
    userName = json['user_name'];
    fullName = json['full_name'];
    email = json['email'];
    mobileNumber = json['mobile_number'];
    imageType = json['image_type'];
    image = json['image'];
    type = json['type'];
    parentControlStatus = json['parent_control_status'];
    parentControlPassword = json['parent_control_password'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userOtp = json['user_otp'];
    isBuy = json['is_buy'];
    deviceId = json['device_id'];
    deviceType = json['device_type'];
    deviceToken = json['device_token'];
  }
  int? id;
  String? userName;
  String? fullName;
  String? email;
  String? mobileNumber;
  int? imageType;
  String? image;
  int? type;
  int? parentControlStatus;
  String? parentControlPassword;
  int? status;
  String? createdAt;
  String? updatedAt;
  dynamic userOtp;
  int? isBuy;
  String? deviceId;
  int? deviceType;
  String? deviceToken;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_name'] = userName;
    map['full_name'] = fullName;
    map['email'] = email;
    map['mobile_number'] = mobileNumber;
    map['image_type'] = imageType;
    map['image'] = image;
    map['type'] = type;
    map['parent_control_status'] = parentControlStatus;
    map['parent_control_password'] = parentControlPassword;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['user_otp'] = userOtp;
    map['is_buy'] = isBuy;
    map['device_id'] = deviceId;
    map['device_type'] = deviceType;
    map['device_token'] = deviceToken;
    return map;
  }

}