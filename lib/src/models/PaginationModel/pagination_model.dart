

import 'package:sharara_laravel_sdk/src/models/general_laravel_model/general_laravel_model.dart';

class PaginationModel<M extends GeneralLaravelModel> extends GeneralModelsJsonSerializer {
  PaginationModel.fromJson(super.parsed):super.fromJson();
   int? currentPage,total;
   dynamic data;
   String? nextPageUrl;

  @override
  void buildModelObjects() {
    total = get("total");
    currentPage = get("current_page");
    nextPageUrl = get("next_page_url");
    data = get('data');
  }



}

