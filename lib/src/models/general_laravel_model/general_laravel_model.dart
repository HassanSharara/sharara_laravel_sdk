
import 'package:sharara_laravel_sdk/src/models/Errors/errors.dart';
import 'package:sharara_laravel_sdk/src/models/RTime/r_time.dart';

abstract class GeneralModelsJsonSerializer {
  GeneralModelsJsonSerializer.fromJson(final dynamic parsed){
    if(parsed is! Map) throw LaravelModelFormatError("the parsed value is not Map or Valid Map");
    jsonParsedMap = parsed;
  }
  Map? jsonParsedMap;
  B? get<B>(final dynamic key){
    if(jsonParsedMap==null)return null;
    final dynamic v = jsonParsedMap![key];
    return v;
  }
  void buildModelProperties();
}


abstract class GeneralLaravelModel<T> extends GeneralModelsJsonSerializer {
  T? id;
  GeneralLaravelModel.fromJson(super.parsed) : super.fromJson(){

    id = get("id");
    rebuildModel();
  }
  void rebuildModel(){
    buildTimestampObjects();
    buildModelProperties();
  }
  RTime? createdAt,updatedAt;
  void updateModelMapByKV([final Map? data]){
    if(data==null || jsonParsedMap==null)return;
    if( id!=null && data.containsKey("id") ){
      if(data["id"] != id)return;
    }
    data.forEach((key, value) {
      jsonParsedMap![key] = value;
    });
  }
  void updateModelMapByEntry([final MapEntry? mapEntry]){
    if(mapEntry==null || jsonParsedMap==null)return;
    if(id!=null && mapEntry.key == "id"){
      if(mapEntry.value != id)return;
    }
    jsonParsedMap![mapEntry.key] = mapEntry.value;
  }
  buildTimestampObjects(){
    if(jsonParsedMap==null)return;
    final RTime createdAt = RTime.fromJson(jsonParsedMap);
    if(createdAt.dateTime!=null){
      this.createdAt = createdAt;
    }
    final RTime updatedAt = RTime.fromJson(jsonParsedMap,columnName:"updated_at");
    if(updatedAt.dateTime!=null){
      this.updatedAt = updatedAt;
    }
  }
}
