

import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';

class LaravelImage extends GeneralLaravelModel{
  String? path,fatherModel;
  LaravelImage.fromJson(super.parsed) : super.fromJson();
  @override
  void buildModelProperties() {

    path = get('path');
    fatherModel = get('father_model');
  }

  @override
  String? get imageUrl => url;
  String? get url {
    if(path==null)return null;
    return LaravelConfigurations.configurations!.imageUploadsUrlPath + path!;
  }

}