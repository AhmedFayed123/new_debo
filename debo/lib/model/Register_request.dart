class RegisterRequest {
  RegisterRequest({
      this.fullName, 
      this.email, 
      this.password, 
      this.mobileNumber,});

  RegisterRequest.fromJson(dynamic json) {
    fullName = json['full_name'];
    email = json['email'];
    password = json['password'];
    mobileNumber = json['mobile_number'];
  }
  String? fullName;
  String? email;
  String? password;
  String? mobileNumber;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['full_name'] = fullName;
    map['email'] = email;
    map['password'] = password;
    map['mobile_number'] = mobileNumber;
    return map;
  }

}