
import 'package:flutter/cupertino.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/models/Response/laravel_response.dart';

abstract class GeneralLaravelApiProvider<G> {
  final String url,boxName,key;
  final LazyCache cache;
  final ValueNotifier<bool> loading = ValueNotifier(false);
  final ValueNotifier<G?> notifier = ValueNotifier(null);
  final List<LaravelFilter> filters;
  final List<LaravelSearchFilter> searchByFilters;
  bool mixFiltersResults;
  LaravelQueryBuilder? defaultQuery;
  LaravelQueryBuilder? searchByQueryBuilder,filterQueryBuilder;
  GeneralLaravelApiProvider({required this.url,
    final String? key,
    required this.boxName,
    this.defaultQuery ,
    this.mixFiltersResults = true,
    final LazyCache? lazyCache,
    this.filters = const [] ,
    this.searchByFilters = const[]
  }):
  key = key ?? url,
  cache = LazyCache(boxName:boxName,boxKey:key??url){
    searchByFilters.firstOrNull?.filter.active = true;
  }
  Map<String,dynamic>? defaultBody;
  bool disposed = false;
  G? notifierHolder;

   fromApi({
    final Map<String,dynamic>? body,
    final Function()? onInternetError,
    onIncomeDataIsNotList,
    final String? forcedUrl
  });

  Future<LaravelResponse?> invokeApiCall(Future<LaravelResponse?>  callback)async{
    if(disposed)return null;
    loading.value = true;
    final Object? response =  await FunctionHelpers.tryFuture<Object>(callback,
    );
    if(disposed)return null;
    loading.value = false;
    if ( response is LaravelResponse) return response;
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
    disposed = true;
    loading.dispose();
    notifier.dispose();
    for (final LaravelSearchFilter element in searchByFilters) {
      element.controller.dispose();
    }
  }

  refresh([final bool reFetchAllData = true])async{
    await fromApi();
  }


  filteringByPF()async{
    final List<LaravelFilter> f = filters.where((element) => element.active).toList();
    if(f.isEmpty)return;
    final LaravelQueryBuilder queryBuilder = LaravelQueryBuilder.create;
    for(final filter in f){
      queryBuilder + filter.query;
    }
    await filterNotifierBy(queryBuilder: queryBuilder);
  }

  searchByFilter({required LaravelQueryBuilder queryBuilder})async{
    searchByQueryBuilder = queryBuilder;
    if(!mixFiltersResults){
      _cancelNormalFilters();
      cleanDefaultBodyFromFilters();
    }
    await fromApi();
  }

  filterNotifierBy({required LaravelQueryBuilder queryBuilder})async{
    if(!mixFiltersResults){
      _cancelSearchFilter();
      cleanDefaultBodyFromFilters();
    }
    this.filterQueryBuilder = queryBuilder;
    holdNotifierOnRam();
    await fromApi();
  }
  cleanDefaultBodyFromFilters(){
    if( defaultBody != null) {
      defaultBody!.remove(LaravelPaginationProvider.laravelQueryMapKey);
    }
  }

  _cancelSearchFilter(){
    searchByQueryBuilder = null;
    for(final f in searchByFilters){
      f.controller.clear();
    }
  }
  cancelSearchFilter(){
    _cancelSearchFilter();
    refresh(true);
  }
  _cancelNormalFilters(){
    cleanDefaultBodyFromFilters();
    for (final LaravelFilter filter in filters) {
      filter.active = false;
    }
    filterQueryBuilder = null;
  } cancelNormalFilters(){
    _cancelNormalFilters();
    refresh(true);
  }
  cancelAllFilters(){
    _cancelSearchFilter();
    _cancelNormalFilters();
    refresh(true);
  }

  holdNotifierOnRam(){
    G? value = notifierValue;
    if( value is List) value = value.toList() as G;
    notifierHolder = value;
  }
}

