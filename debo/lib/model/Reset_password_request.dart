class ResetPasswordRequest {
  ResetPasswordRequest({
      this.email, 
      this.password, 
      this.passwordConfirmation,});

  ResetPasswordRequest.fromJson(dynamic json) {
    email = json['email'];
    password = json['password'];
    passwordConfirmation = json['password_confirmation'];
  }
  String? email;
  String? password;
  String? passwordConfirmation;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['email'] = email;
    map['password'] = password;
    map['password_confirmation'] = passwordConfirmation;
    return map;
  }

}