


import 'package:sharara_apps_building_helpers/http.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/Providers/general/general_provider.dart';

typedef PaginationChildBuilder<M> = M Function(dynamic);
class LaravelPaginationProvider
  <M extends GeneralLaravelModel>
  extends GeneralLaravelApiProvider<List<M>> {
  LaravelPaginationProvider({
    required super.url,
    required this.builder,
    this.cancelToken,
    super.key});
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
    if(isFirstPage){
      cache.insert(value.map((e) => e.jsonParsedMap).toList());
    }
  }
}

extension DataOrganizer<M extends GeneralLaravelModel> on LaravelPaginationProvider<M> {

  fromCache()async{
    final dynamic data = await cache.get();
    pushDataToNotifier(data);
  }
  fromApi({final Map? body,final Function()? onInternetError,
  onIncomeDataIsNotList}) async {
    final Response? response = await invokeApiCall(
        ShararaHttp
            .post(
            url: url,
            body:body ?? defaultBody,
            headers:headers,
            cancelToken:cancelToken
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
    }
    pushDataToNotifier(paginationModel.data);
  }

  bool get isFirstPage => lastPaginationModel?.currentPage == 1;

  pushDataToNotifier(final dynamic data){
    if(data is! List)return;
    final List<M> children = isFirstPage ? [] : ( notifierValue ?? [] );
    for(final dynamic j in data){
      final M? m = FunctionHelpers.tryCatch<M>(() => builder(j));
      if(m==null)continue;
      children.removeWhere((element) => element.id == m.id && m.id != null );
      children.add(m);
    }
    changeNotifier(children);
  }

  addOne(final M? model){
    if(model==null)return;
    final List<M>? models = notifierValue;
    if(models==null)return;
    models.add(model);
    changeNotifier(models);
  }

  insertOne(final M? model,{final int index = 0}){
    if(model==null)return;
    final List<M>? models = notifierValue;
    if(models==null)return;
    models.insert(index, model);
    changeNotifier(models);
  }
}

