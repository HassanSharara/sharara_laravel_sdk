
import 'dart:convert';

import 'package:sharara_apps_building_helpers/http.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/Constants/constants.dart';
import 'package:sharara_laravel_sdk/src/Providers/general/general_provider.dart';
import 'package:sharara_laravel_sdk/src/http/http.dart';
import 'package:sharara_laravel_sdk/src/models/Response/laravel_response.dart';

typedef PaginationChildBuilder<M> = M Function(dynamic);
class LaravelPaginationProvider
  <M extends GeneralLaravelModel>
  extends GeneralLaravelApiProvider<List<M>> {
  static const String laravelQueryMapKey = "laravel_query_filter";
  static const String defaultQueryMapKey = "default_query_filter";
  static const String searchQueryMapKey = "search_query_filter";
  LaravelPaginationProvider({
    required super.url,
    required this.builder,
    this.cancelToken,
    this.showLoadMoreOnTheEndOfItemBuilder = false,
    this.noMoreLabel = "لا يوجد المزيد",
    super.mixFiltersResults = true,
    super.defaultQuery,
    super.filters = const [],
    super.searchByFilters = const [],
    super.key}):super(
    boxName:Constants.paginationDataProvideBoxName
  );
  final String noMoreLabel;
  bool showLoadMoreOnTheEndOfItemBuilder;
  final PaginationChildBuilder<M> builder;
  PaginationModel? lastPaginationModel;
  Map<String,String>? get headers => null;
  CancelToken? cancelToken;

  init(){
    fromCache();
    fromApi();
  }

  @override
  changeNotifier(List<M>? value){
    if(value==null)return;
    super.changeNotifier(List.from(value));
  }

  bool get apiWouldBeFiltered => filterQueryBuilder !=null || searchByQueryBuilder != null;
  @override
  fromApi({
    final Map<String,dynamic>? body,
    final Function()? onInternetError,
    onIncomeDataIsNotList,
    final String? forcedUrl
  }) async {

    Map<String,dynamic>? toServerBody  = body ?? defaultBody;
    toServerBody??={};
    if(defaultQuery!=null){
      toServerBody[LaravelPaginationProvider.defaultQueryMapKey] = jsonEncode(defaultQuery!.results);
    }
    if (searchByQueryBuilder!=null){
      toServerBody[LaravelPaginationProvider.searchQueryMapKey] = jsonEncode(searchByQueryBuilder!.results);
    }
    if( filterQueryBuilder != null ){
      toServerBody[LaravelPaginationProvider.laravelQueryMapKey] = jsonEncode(filterQueryBuilder!.results);
    }
    final LaravelResponse? response = await invokeApiCall(
        LaravelHttp
            .instance
            .post(
          url:  forcedUrl ?? (lastPaginationModel?.nextPageUrl ?? url),
          queryParameters:toServerBody,
          headers:headers,
          cancelToken:cancelToken,
        )
    );
    if(response==null) {
      if(onInternetError!=null)onInternetError();
      return ;
    }

    final PaginationModel? paginationModel = FunctionHelpers.tryCatch(() =>
        PaginationModel.fromJson(response.data));
    if(paginationModel==null)return;
    lastPaginationModel = paginationModel;
    if ( paginationModel.data is! List ){
      if(onIncomeDataIsNotList!=null)onIncomeDataIsNotList();
      return;
    } else if( !apiWouldBeFiltered ) {
      if(isFirstPage){
        cache.insert(paginationModel.data);
      }

    }
    pushDataToNotifier(paginationModel.data);
  }
  @override
  refresh([final bool reFetchAllData = true])async{
    lastPaginationModel = null;
    init();
  }


  bool get thereIsNoMoreDataToPaginate => lastPaginationModel!=null && lastPaginationModel?.nextPageUrl == null;
  Future loadMore()async{
    if(thereIsNoMoreDataToPaginate){
      FunctionHelpers.toast(noMoreLabel);
      return;
    }
    await fromApi();
  }

  @override
  filterNotifierBy({required LaravelQueryBuilder queryBuilder}) {
    lastPaginationModel = null;
    return super.filterNotifierBy(queryBuilder: queryBuilder,);
  }

  @override
  searchByFilter({required LaravelQueryBuilder queryBuilder}) {
    lastPaginationModel = null;
    return super.searchByFilter(queryBuilder:queryBuilder);
  }

}

extension DataOrganizer<M extends GeneralLaravelModel> on LaravelPaginationProvider<M> {

  fromCache()async{
    final dynamic data = await cache.get();
    FunctionHelpers
    .tryCatch(() => pushDataToNotifier(data));
  }

  bool get isFirstPage => lastPaginationModel?.currentPage == 1;
  pushDataToNotifier(final dynamic data,{final bool cacheData = false}){
    if(data is! List)return;
    final List<M> children = isFirstPage || lastPaginationModel==null ? [] : ( notifierValue ?? [] );
    for(final dynamic j in data){
      final M? m = FunctionHelpers.tryCatch<M>(() => builder(j));
      if(m==null)continue;
      children.removeWhere((element) => element.id == m.id && m.id != null );
      children.add(m);
    }
    changeNotifier(children);
    if(cacheData)_saveAllModelsToLocal();
  }
  addOne(final M? model){
    if(model==null)return;
    final List<M>? models = notifierValue;
    if(models==null)return;
    models.add(model);
    changeNotifier(models);
    _saveAllModelsToLocal();
  }
  insertOne(final M? model,{final int index = 0}){
    if(model==null)return;
    final List<M>? models = notifierValue;
    if(models==null)return;
    models.insert(index, model);
    changeNotifier(models);
    _saveAllModelsToLocal();
  }

  _saveAllModelsToLocal()async{
    final models = notifierValue??[];
    if(!isFirstPage || models.isEmpty)return;
    final List<Map> data = [];
    for(final item in models){
      if(item.jsonParsedMap==null)continue;
      data.add(item.jsonParsedMap!);
    }
    await cache.insert(data);
  }

}

