import 'dart:convert';

class SignInModel {
  String ?email;
  String? password;
  String? custClass;
  SignInModel({
    required this.email,
    required this.password,
    String? custClass
  });
  SignInModel.fromJson(Map<String, dynamic> json) {
    custClass = json['cust_class'];
  }
  Map<String, dynamic> toMap() {
    return {
      'username': email,
      'password': password,
    };
  }

  String toJson() => json.encode(toMap());
}
