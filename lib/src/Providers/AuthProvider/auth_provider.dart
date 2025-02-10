

import 'package:flutter/foundation.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/Providers/AuthProvider/cache.dart';

class AuthProvider<U extends AuthUser> {
  final U Function(dynamic) builder;
  AuthProvider(this.builder);
  factory AuthProvider.nativeOne()=> AuthProvider(
      (j)=> AuthUser.fromJson(j) as U
  );
  static AuthProvider instance = AuthProvider.nativeOne();

  static AuthProvider signNewAuthProvider(final AuthProvider provider)=> instance = provider;

  final ValueNotifier<U?> userNotifier = ValueNotifier(null);
  U? get user => userNotifier.value;
  final AuthProviderCache cache =AuthProviderCache();

  void init(){
    _fromCache();
  }


  _fromCache(){
    final dynamic data = cache.get();
    _changeUserObjectByDynamic(data,callSaver:false);
  }

  Future<void> handleApiResponse(final LaravelResponse response)async{
    if(response.responseContainsAuthMessage) {
      return  await _handleAuthUserResponse(response);
    } else if(response.couldInvokeUserUpdate) {
      return await _handleUpdateUserResponse(response);
    } else  if(response.responseContainsNotAuthMessage){
      await logout();
    }
  }

  Future<void> _handleAuthUserResponse(final LaravelResponse response)async{
    await _changeUserObjectByDynamic(response.data);
  }

  Future<void> _handleUpdateUserResponse(final LaravelResponse response)async{
    if(response.data is! Map)return;
    final Map data = userNotifier.value?.jsonParsedMap ?? {};
    response.data.forEach((key,value){
      if(key=="id")return;
      data[key] = value;
    });
    await _changeUserObjectByDynamic(data);
  }

  Future<void>_changeUserObjectByDynamic(final dynamic data,{final bool callSaver = true})async{
    final U? user = FunctionHelpers.tryCatch<U>(()=>builder(data));
    if(user==null || user.id == null)return;
    changeNotifier(user);
    if(callSaver)await cache.insert(user.jsonParsedMap);
  }

  changeNotifier(final U? value){
    userNotifier.value = value;
  }
  logout()async{
    cache.clear();
    changeNotifier(null);
  }
}