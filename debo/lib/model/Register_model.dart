class RegisterModel {
  RegisterModel({
      this.status, 
      this.message, 
      this.userId,});

  RegisterModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    userId = json['user_id'];
  }
  int? status;
  String? message;
  int? userId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    map['user_id'] = userId;
    return map;
  }

}