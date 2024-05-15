
import 'package:flutter/cupertino.dart';
import 'package:sharara_apps_building_helpers/http.dart';
import 'package:sharara_apps_building_helpers/sharara_apps_building_helpers.dart';

class GeneralLaravelApiProvider<G> {
  final String url;
  final LazyCache cache;
  final String key;
  final ValueNotifier<bool> loading = ValueNotifier(false);
  final ValueNotifier<G?> notifier = ValueNotifier(null);
  GeneralLaravelApiProvider({required this.url,final String? key}):
  key = key ?? url,
  cache = LazyCache(boxName:url,boxKey:key);
  Map? defaultBody;
  bool disposed = false;

  Future<Response?> invokeApiCall(Future<Object?>  callback)async{
    loading.value = true;
    final Object? response =  await FunctionHelpers.tryFuture<Object>(callback);
    loading.value = false;
    if ( response is Response) return response;
    return null;
  }
  changeNotifier(G? value){
    if(disposed || (value==null && notifier.value == null))return;
    notifier.value = value;
  }
  G? get notifierValue {
    if(disposed)return null;
    return notifier.value;
  }
  dispose(){
    loading.dispose();
    notifier.dispose();
  }
}