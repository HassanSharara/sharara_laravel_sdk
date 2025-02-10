
import 'package:flutter/cupertino.dart';

class LaravelFilter {
  final String name;
  final LaravelQueryBuilder query;
 bool active;
 LaravelFilter({required this.name,required this.query,this.active = false});
}
class LaravelSearchFilter {
  final TextEditingController controller = TextEditingController();
  TextInputType type;
  LaravelFilter filter;
  final String column;
  final Function(String)? onValueSearched;
  LaravelSearchFilter({
    required this.column,
    required this.filter,
    this.onValueSearched,
    this.type  = TextInputType.name});
}
class LaravelFilterQuery<T,V> {
  final LaravelQueryClosure closure;
  final String? column,middleAction;
  V? value;
  T? extraBuilder;
  LaravelFilterQuery({
    required this.closure,
    this.column,
    this.middleAction,
    this.value,
    this.extraBuilder,
  });
  Map get result {
    final Map result = {} ;
    switch ( closure ){
      case LaravelQueryClosure.where || LaravelQueryClosure.orWhere || LaravelQueryClosure.having:
        result[closure.name]={
          "root":{
            "column":column,
            if(value!=null)"value":value,
            "middleAction":middleAction??"=",
            if(extraBuilder is List<LaravelQueryBuilder> && (extraBuilder as List).isNotEmpty)
              "children":[
                ...(extraBuilder as List<LaravelQueryBuilder>)
                    .map((e)=>e.results)
              ]
          },

        };
        break;

      case LaravelQueryClosure.whereIn :
        assert(value is List);
        result[closure.name] ={
          "root":{
            "column":column,
            "value":value,
            if(extraBuilder is List<LaravelQueryBuilder> && (extraBuilder as List).isNotEmpty)
              "children":[
                ...(extraBuilder as List<LaravelQueryBuilder>)
                    .map((e)=>e.results)
              ]
          }
        };
        break;
      case LaravelQueryClosure.whereNull || LaravelQueryClosure.whereNotNull || LaravelQueryClosure.orWhereNull:
        result[closure.name]={
          "root":{
            "column":column,
            if(extraBuilder is List<LaravelQueryBuilder> && (extraBuilder as List).isNotEmpty)
              "children":[
                if(extraBuilder is List<LaravelQueryBuilder>)
                  ...(extraBuilder as List<LaravelQueryBuilder>)
                      .map((e)=>e.results)
              ]
          },

        };
        break;


      case LaravelQueryClosure.orderBy:
        result[closure.name] = {
          "root":{
            "column":column,
            if(value!=null)"value":value,
          },
        };
        break;


      case LaravelQueryClosure.distinct:
        result[closure.name] = {
          "root":{
            "column":column,
          },
        };
        break;


      case LaravelQueryClosure.whereHas:
        result[closure.name] = {
          "root":{
            if(value!=null)"value":value,
            if(extraBuilder is List<LaravelQueryBuilder> && (extraBuilder as List).isNotEmpty)
              "children":[
                ...(extraBuilder as List<LaravelQueryBuilder>).map((e) => e.results)
              ]
          }
        };
      case LaravelQueryClosure.withRelation:
        result[closure.name] = {
          "root":{
            if(value!=null)"value":value,
            if(extraBuilder is List<LaravelQueryBuilder> && (extraBuilder as List).isNotEmpty)
              "children":[
                ...(extraBuilder as List<LaravelQueryBuilder>).map((e) => e.results)
              ]
          }
        };
        break;
      case  LaravelQueryClosure.select || LaravelQueryClosure.groupBy:
        result[closure.name] = {
          "root":{
            "value":[
              if(value is String)
                value
              else if(value is List)
                ...(value as List)
            ],
          },
        };
        break;

      default:
        break;
    }
    return result;
  }
  String get id => closure.name+column.toString()+middleAction.toString()+value.toString();

  @override
  bool operator==(final Object other){
    return other is LaravelFilterQuery && other.id == id;
  }

  @override
  int get hashCode => super.hashCode + 10;

}
enum LaravelQueryClosure {
  where,
  whereIn,
  distinct,
  whereNull,
  orWhereNull,
  whereNotNull,
  having,
  orderBy,
  orWhere,
  withRelation,
  whereHas,
  select,
  groupBy,
}
extension QuerySet on Set {
  push<T>(final T value){
    removeWhere((element) => element == value);
    add(value);
  }
}
class LaravelQueryBuilder {
  final Set<LaravelFilterQuery> filters = {};
  static LaravelQueryBuilder get create => LaravelQueryBuilder();
  LaravelQueryBuilder get clear {
    filters.clear();
    return this;
  }
  LaravelQueryBuilder search(final String column,final String value,{
    final List<LaravelQueryBuilder>? insideConditions,
  })=> where(column,value:"%$value%",middleAction:"like");

  LaravelQueryBuilder where(final String column,{final String? value,middleAction,
    final List<LaravelQueryBuilder>? insideConditions,
  }){
    filters.push(
        LaravelFilterQuery(closure:LaravelQueryClosure.where,
            column:column,
            middleAction:middleAction,
            value:value,
            extraBuilder:insideConditions
        )
    );
    return this;
  }

  LaravelQueryBuilder whereHas({final String? value,
    final List<LaravelQueryBuilder>? insideConditions,
  }){
    filters.push(
        LaravelFilterQuery(
            closure:LaravelQueryClosure.whereHas,
            value:value,
            extraBuilder:insideConditions
        )
    );
    return this;
  }
  LaravelQueryBuilder having(final String column,{final String? value,middleAction,
    final List<LaravelQueryBuilder>? insideConditions,
  }){
    filters.push(
        LaravelFilterQuery(closure:LaravelQueryClosure.having,
            column:column,
            middleAction:middleAction,
            value:value,
            extraBuilder:insideConditions
        )
    );
    return this;
  }

  LaravelQueryBuilder orWhere(final String column,{final String? value,middleAction,
    final List<LaravelQueryBuilder>? insideConditions,
  }){
    filters.push(
        LaravelFilterQuery(closure:LaravelQueryClosure.orWhere,
            column:column,
            middleAction:middleAction,
            value:value,
            extraBuilder:insideConditions
        )
    );
    return this;
  }

  LaravelQueryBuilder whereNull(final String column,{
    final List<LaravelQueryBuilder>? insideConditions,
   }){
    filters.push(
        LaravelFilterQuery(closure:LaravelQueryClosure.whereNull,
            column:column,
            extraBuilder:insideConditions
        )
    );
    return this;
  }
  LaravelQueryBuilder orWhereNull(final String column,{
    final List<LaravelQueryBuilder>? insideConditions,
   }){
    filters.push(
        LaravelFilterQuery(closure:LaravelQueryClosure.orWhereNull,
            column:column,
            extraBuilder:insideConditions
        )
    );
    return this;
  }

  LaravelQueryBuilder whereIn(
      final String column,{final dynamic values,middleAction,
      final List<LaravelQueryBuilder>? insideConditions,
  }){
    filters.push(
        LaravelFilterQuery(closure:LaravelQueryClosure.whereIn,
            column:column,
            value:values,
            extraBuilder:insideConditions
        )
    );
    return this;
  }

  LaravelQueryBuilder whereNotNull(final String column,{
    final List<LaravelQueryBuilder>? insideConditions,
  }){
    filters.push(
        LaravelFilterQuery(closure:LaravelQueryClosure.whereNotNull,
            column:column,
            extraBuilder:insideConditions
        )
    );
    return this;
  }

  LaravelQueryBuilder orderBy(final String column,{final String value = "DESC"}){
    filters.push(LaravelFilterQuery(closure:LaravelQueryClosure.orderBy,
        column:column,
        value:value));
    return this;
  }

  LaravelQueryBuilder distinct(final String column){
    filters.push(LaravelFilterQuery(closure:LaravelQueryClosure.distinct,column:column));
    return this;
  }

  LaravelQueryBuilder groupBy(final dynamic values){
    filters.push(LaravelFilterQuery(closure:LaravelQueryClosure.groupBy,value:values));
    return this;
  }

  LaravelQueryBuilder select(final dynamic values){
    filters.push(LaravelFilterQuery(closure:LaravelQueryClosure.select,value:values));
    return this;
  }
  LaravelQueryBuilder withRelation(final dynamic values){
    filters.push(LaravelFilterQuery(closure:LaravelQueryClosure.withRelation,value:values));
    return this;
  }


  operator+(final LaravelQueryBuilder builder){
    filters.addAll(builder.filters);
  }
  Map get results {
    final Map result = {};
    for(final closure in LaravelQueryClosure.values){
      final List<LaravelFilterQuery> queries = filters.where((element) =>element.closure == closure).toList();
      if(queries.isEmpty)continue;
      result[closure.name] = queries.map((e) => e.result[closure.name]).toList();
    }
    return result;
  }
}


