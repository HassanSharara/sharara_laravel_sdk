import 'package:example/api.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/http.dart';
import 'package:sharara_laravel_sdk/ui.dart';


class WhatsAppApiConstans {
  static const String templateName = "swia_auth";
  static const String accessToken = "EAAMpxfZBIDlwBO4BOlSDX28BofQadZAB2WF2sES3JtvozUqAI9p0eIAFZC41IZAJE4MSGZCcQb5w74RrS6rf6LdP41UreJpTiOKTRZBs70SI9E21LNQZB7qRB1vHDtJ72ZB11u72p9wgnXCTY7N7UAjZB3NggXpN8pmDWrQEFAsFD0epHGTpqSo9XBPa3Kt1BaBL4VslnmU2Tu4pC";
  static const int fromNumId = 140455345827741;
}

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await LaravelSDKInitializer.initialize(
    configurations:()=>
        LaravelConfigurations(
          whatsAppAuthor:WhatsAppAuthor(
          accessToken: WhatsAppApiConstans.accessToken,
          templateName:WhatsAppApiConstans.templateName,
          fromPhoneNumberId: WhatsAppApiConstans.fromNumId.toString()
        ),
        appName: "test",
        appLogo:RoyalShadowContainer(
          backgroundColor:RoyalColors.mainAppColor,
          child:const Text("LOGO",style:TextStyle(color:RoyalColors.white),),
        ),
        mainApiUrl:"http://192.168.0.190/dev/general/public"
    )
  );
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
            FunctionHelpers
            .jumpTo(context,const LaravelDefaultAuthScreen());
          },
         child:const Text("انشاء حساب")),
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
