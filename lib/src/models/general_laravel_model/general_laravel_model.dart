

import 'package:sharara_apps_building_helpers/sharara_apps_building_helpers.dart';
import 'package:sharara_laravel_sdk/src/models/Errors/errors.dart';
import 'package:sharara_laravel_sdk/src/models/Image/laravel_image.dart';
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

  double? doubleParse(final dynamic key){
    return double.tryParse(get(key).toString());
  }

  int? intParse(final dynamic key){
    return int.tryParse(get(key).toString());
  }
  void buildModelProperties();
}


abstract class GeneralLaravelModel<T> extends GeneralModelsJsonSerializer {
  T? id;
  String? imageUrl;
  List<LaravelImage> images = [];
  GeneralLaravelModel.fromJson(super.parsed) : super.fromJson(){
    build();
  }

  void build(){
    id = get("id");
    rebuildModel();
  }
  void rebuildModel(){
    buildTimestampObjects();
    buildModelProperties();
    buildImagesProperties();
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

  void generateListOf<T extends GeneralLaravelModel>(List<T>? models,final String key,
       final T Function(dynamic) builder
      ){
    final dynamic data = get(key);
    if(data is! List )return;
    (models??=[]).clear();
    for(final dynamic j in data){
      final T? m = FunctionHelpers.tryCatch(()=>builder(j));
      if( m == null)continue;
      models.add(m);
    }
  }

  String? get modelImageUrl {
    for(final image in images){
      final String? url = image.url;
      if( url == null)continue;
      return url;
    }
    return imageUrl;
  }
  void buildImagesProperties(){
    imageUrl = get("image_url");
    final dynamic images = get('images');
    if(images==null || images is! List)return;
    this.images.clear();
    for(final dynamic imageJson in images){
      final LaravelImage? img = FunctionHelpers.tryCatch<LaravelImage>(
          ()=>LaravelImage.fromJson(imageJson));
      if(img==null)continue;
      this.images.add(img);
    }
  }

  R? buildPropertObject<R extends GeneralLaravelModel>(R Function(dynamic) builder,final dynamic key){
    final dynamic data = get(key);
    if(data is! Map)return null;
    return FunctionHelpers.tryCatch(()=>builder(data));
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


  bool  isTheyHaveTheSameId(final GeneralLaravelModel model){
    return model.id != null && model.id == id;
  }

  void operator<<(final GeneralLaravelModel? other){
    if(other==null)return;
    updateModelMapByKV(other.jsonParsedMap);
    rebuildModel();
  }

  void operator>>(final GeneralLaravelModel? other){
    if(other==null)return;
    other.updateModelMapByKV(jsonParsedMap);
    other.rebuildModel();
  }


  updateJsonMapWith(final String key,final dynamic value){
    jsonParsedMap?[key] = value;
  }


  bool get isValidApiModel => id !=null;
}
