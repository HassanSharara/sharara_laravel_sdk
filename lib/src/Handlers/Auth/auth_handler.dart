
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sharara_apps_building_helpers/ui.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/http/http.dart';
import 'package:sharara_laravel_sdk/src/models/Response/laravel_response.dart';

enum AuthType {
  register,login
}

class AuthModel {
  final String column,name;
  final bool required ;
  final bool numeric,isPassword;
  late TextEditingController controller ;
   AuthModel(this.column,{
    final String? name,
    this.required = false,
    this.isPassword = false,
    final TextEditingController? controller,
    this.numeric = false}):
  name = name??column{
     this.controller = controller?? (
     name == "phone"?
         PhoneTextEditController()
         :TextEditingController()
     );
   }
}

class PhoneAuthModel extends AuthModel{
  PhoneAuthModel(super.column,{super.controller,
    super.required =true,
    super.name,super.numeric = true}):assert(controller is PhoneTextEditController);
  String verifiedNumber = "";
  bool get verified => verifiedNumber == (controller as PhoneTextEditController).nText;
}
class AuthHandler {

  List<AuthModel> registerModels ,loginModels ;
  AuthHandler({
    this.registerModels = const [] ,
    this.loginModels = const []
   }){
    if(registerModels.isEmpty)registerModels = List.from(defaultRegisterModels);
    if(loginModels.isEmpty)loginModels = List.from(defaultLoginModels);
  }

  final ValueNotifier<AuthType?> screenAuthType = ValueNotifier(null);

  bool get isRegisterScreen => screenAuthType.value == AuthType.register;
  List<AuthModel> get currentModels => ( screenAuthType.value==AuthType.login?loginModels:
  registerModels)..sort(
      (a,b){
        if(a.isPassword && !b.isPassword) {
            return 1;
          }
        if(b.column != "name") {
          return 0;
        }
        return 1;
      }
  );

  bool get everyThingIsValid {
   final List<AuthModel> passwordsModels = currentModels.where((e)=>e.isPassword).toList();
   final List<String> passwords = [];
   for(final AuthModel model in passwordsModels){
     if(model.controller.text.isEmpty)break;
     if(passwords.isEmpty){
       passwords.add(model.controller.text);
       continue;
     }else{
       for(final String pass in passwords){
         if(model.controller.text!= pass){
           FunctionHelpers.toast('كلمات السر غير متطابقة');
           return false;
         }
       }
     }
   }
    return FunctionHelpers.checkInputs(
        currentModels.map((e)=>e.controller).toList()
    );
  }

  Map<String,dynamic> get generateMap => {
    for(final AuthModel model in currentModels)
      model.column:model.controller is PhoneTextEditController ?
    (model.controller as PhoneTextEditController).nText
    :model.controller.text
  };



  Future<void> callApi(BuildContext context)async{
    if(!everyThingIsValid)return;

    await LaravelHttp.instance.post<LaravelResponse>(
        url: url,
        queryParameters:generateMap,
        withLoading:true);

  }



  changeAuthScreen([AuthType? type]){
    screenAuthType.value = type;
  }


  static  List<AuthModel> defaultRegisterModels = [
    ...defaultLoginModels,
    AuthModel("name",name:"الاسم",required:true),
    AuthModel("password_confirmation",name:"تأكيد كلمة السر",required:true,isPassword:true),
  ];
  static  List<AuthModel> defaultLoginModels = [
    PhoneAuthModel("phone",numeric:true,name: "رقم الهاتف",controller:PhoneTextEditController()),
    AuthModel("password",name: "كلمة السر",isPassword:true,required:true),
  ];

}


extension ApiExt on AuthHandler {

  String get url => (screenAuthType.value == AuthType.login) ? loginUrl : registerUrl;
  String get mainAppUrl => LaravelConfigurations.configurations!.mainApiUrl;
  String get _prefixUrl {
    final String main = mainAppUrl ;
    return "$main${main.endsWith("/")?"":"/"}RoyalFirster";
  }

  String get loginUrl => "$_prefixUrl/login";
  String get registerUrl => "$_prefixUrl/register";
}