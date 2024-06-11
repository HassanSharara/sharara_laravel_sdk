
import 'package:flutter/material.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/Ui/Auth/auth_screen.dart';
import 'package:sharara_laravel_sdk/src/models/Auth/user.dart';

class RequiredAuthScreen<U extends AuthUser> extends StatelessWidget {
  const RequiredAuthScreen({super.key,required this.userBuilder});
  final  Widget Function(BuildContext,U) userBuilder;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: AuthProvider.instance.userNotifier,
        builder:(BuildContext context,final AuthUser? user,_ ){
          if(user==null)return const LaravelDefaultAuthScreen();
          return userBuilder(context,user as U);
        });
  }
}
