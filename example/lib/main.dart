

import 'package:example/api.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/http.dart';
import 'package:sharara_laravel_sdk/ui.dart';

class CategoryModel extends GeneralLaravelModel {
  String? name;
  CategoryModel.fromJson(super.parsed) : super.fromJson();
  @override
  void buildModelProperties() {
    name = get("name");
  }
}

class CategoryPaginationProvider extends LaravelPaginationProvider<CategoryModel> {
  CategoryPaginationProvider():super(
    builder:CategoryModel.fromJson,
    url:Api.categories,
    mixFiltersResults:true,
    filters:[
      LaravelFilter(
          name: "الاقدم اولا",
          query: LaravelQueryBuilder.create.orderBy("created_at",value:"ASC")
      ),
      LaravelFilter(
          name: "الاحدث اولا",
          query: LaravelQueryBuilder.create.orderBy("created_at",value:"DESC")
      ),
    ],
    searchByFilters:[
      LaravelSearchFilter(
        column:"name",
        filter:LaravelFilter(
        name:"الاسم",
        query:LaravelQueryBuilder.create
      )),

      LaravelSearchFilter(
          column:"t",
          filter:LaravelFilter(
              name:"قوة الظهور",
              query:LaravelQueryBuilder.create
          ))
    ]
  );
}

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await LaravelSDKInitializer.initialize();
  ShararaHttp.defaultHeaders = <String,dynamic>{
    "Content-Type":"Application/Json",
    "Accept":"Application/Json",
    "Authorization":"Bearer ${Api.apiKey}"
  };
  runApp(
      ShararaAppHelper(builder:
      (_)=>const FirstScreen()
  ) );
}

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});
  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final CategoryPaginationProvider provider =
  CategoryPaginationProvider();
  @override
  void initState() {
    provider.init();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title:ElevatedButton(
          onPressed:()=>FunctionHelpers.jumpTo(context,const ShararaThemePicker()),
          child:const Text("settings"),
        ),
        actions: [
          ElevatedButton(onPressed:(){
            LaravelFiltersUiBuilder.showFilter(context, provider);
          }
          , child:const Text("فلترة")),

          ElevatedButton(onPressed:(){
            provider.cancelAllFilters();
          },
           style:ButtonStyle(
             foregroundColor:MaterialStateColor.resolveWith((states) => Colors.red)
           )
              , child:const Text("الغاء")),
        ],
      ),
      body:LaravelIterableBuilder(
        provider:provider,
        showLoadMoreOnTheEndOfItemBuilder:true,
        builder:(BuildContext context,CategoryModel model,_){
          return RoyalShadowContainer(
            key:UniqueKey(),
            margin:const EdgeInsets.symmetric(vertical:10,horizontal:8),
            child:Text(model.name??""),
          );
        },
      ),
    );
  }
}
