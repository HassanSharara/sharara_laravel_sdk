
import 'dart:async';
import 'dart:convert';
import 'package:sharara_apps_building_helpers/http.dart';
import 'package:sharara_apps_building_helpers/sharara_apps_building_helpers.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/models/Response/laravel_response.dart';

class LaravelHttp extends ShararaHttp {
  static final LaravelHttp instance = LaravelHttp().._init();
  Future<void> Function(LaravelResponse)? onLaravelResponse;


  _init(){
    onResponseReady = <T>(Response response)async{
      final LaravelResponse? laravelResponse = FunctionHelpers
          .tryCatch<LaravelResponse>(() => LaravelResponse
          .fromJson(json.decode(
          json.encode(response.data)
          )));
      if(laravelResponse==null)return null;
      if(laravelResponse.hasToast)FunctionHelpers.toast(laravelResponse.toast!,status:laravelResponse.isSuccess);
      if(onLaravelResponse!=null)onLaravelResponse!(laravelResponse);
      if(laravelResponse.couldInvokeAuthHandler){
        AuthProvider.instance.handleApiResponse(laravelResponse);
      }
      return laravelResponse as T;
    };
  }
  
  
}