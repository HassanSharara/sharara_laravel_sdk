

import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';

class AuthUser extends GeneralLaravelModel{
  String? token,name,phone,email,fcmToken,apiToken;
  AuthUser.fromJson(super.parsed) : super.fromJson();
  @override
  void buildModelProperties() {
    token = get('token');
    name = get('name');
    phone = get('phone');
    email = get('email');
    fcmToken = get('fcm');
    apiToken = get('api_token');
  }


  Map<String,dynamic> get currentPropertiesToMap => {
    "name":name,
    "phone":phone,
    "email":email,
    "fcm":fcmToken,
  };

}

