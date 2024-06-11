

import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';

class AuthUser extends GeneralLaravelModel{
  String? token,name,phone,email,fcmToken;
  AuthUser.fromJson(super.parsed) : super.fromJson();
  @override
  void buildModelProperties() {
    token = get('token');
    name = get('name');
    phone = get('phone');
    email = get('email');
    fcmToken = get('fcm');
  }



}

