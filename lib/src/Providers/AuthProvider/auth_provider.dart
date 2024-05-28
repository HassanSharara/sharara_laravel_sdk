

import 'package:flutter/foundation.dart';
import 'package:sharara_apps_building_helpers/sharara_apps_building_helpers.dart';
import 'package:sharara_laravel_sdk/src/Providers/AuthProvider/cache.dart';
import 'package:sharara_laravel_sdk/src/models/Auth/user.dart';
import 'package:sharara_laravel_sdk/src/models/Response/laravel_response.dart';

class AuthProvider<U extends AuthUser> {
  final U Function(dynamic) builder;
  AuthProvider(this.builder);
  final ValueNotifier<U?> userNotifier = ValueNotifier(null);
  final AuthProviderCache cache =AuthProviderCache();

  init(){
    _fromCache();
  }

  _fromCache(){
    _changeUserObjectByDynamic(cache.get(),callSaver:false);
  }

  Future<void> handleApiResponse(final LaravelResponse response)async{
    if(response.couldInvokeAuthHandler) {
      return  await _handleAuthUserResponse(response);
    } else if(response.couldInvokeUserUpdate) {
      return await _handleUpdateUserResponse(response);
    }
  }

  Future<void> _handleAuthUserResponse(final LaravelResponse response)async{
    await _changeUserObjectByDynamic(response.data);
  }

  Future<void> _handleUpdateUserResponse(final LaravelResponse response)async{
    if(response.data is! Map)return;
    final Map data = userNotifier.value?.jsonParsedMap ?? {};
    response.data.forEach((key,value){
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