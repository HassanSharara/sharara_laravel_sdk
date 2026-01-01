
import 'package:flutter/material.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/models/Auth/user.dart';

class UserAuthorBuilder<U extends AuthUser> extends StatelessWidget {
  const UserAuthorBuilder({super.key,required this.provider,
    required this.builder,
    this.authScreen
  });
  final AuthProvider<U> provider;
  final Widget Function(BuildContext,U) builder;
  final Widget? authScreen;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<U?>(
        valueListenable: provider.userNotifier,
        child:authScreen??const SizedBox(),
        builder: (BuildContext context,final U? u,c){
          if(u==null)return c!;
          return builder(context,u);
        });
  }
}
