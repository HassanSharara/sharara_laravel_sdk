
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sharara_apps_building_helpers/ui.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/http/http.dart';
import 'package:sharara_laravel_sdk/src/models/Response/laravel_response.dart';

enum AuthType {
  register,
  login,
  forget
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

  List<AuthModel> registerModels ,loginModels ,forgetModels;
  AuthHandler({
    this.registerModels = const [] ,
    this.loginModels = const [],
    this.forgetModels = const [],
   }){
    if(registerModels.isEmpty)registerModels = List.from(defaultRegisterModels);
    if(loginModels.isEmpty)loginModels = List.from(defaultLoginModels);
    if(forgetModels.isEmpty)forgetModels = List.from(defaultForgetModels);
  }

  final ValueNotifier<AuthType?> screenAuthType = ValueNotifier(null);

  bool get numberNeedToBeVerified => screenAuthType.value != AuthType.login;
  List<AuthModel> get currentModels => (
      screenAuthType.value==AuthType.login?loginModels:
      screenAuthType.value==AuthType.forget?forgetModels:
      registerModels
  )..sort(
      _sortingFields
  );

  int _sortingFields(final AuthModel a,final AuthModel b){
    if(a.isPassword && !b.isPassword) {
      return 1;
    }
    if(b.column != "name") {
      return 0;
    }
    return 1;
  }

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
   for(final i in currentModels){
     if(!numberNeedToBeVerified)break;
     if(i is! PhoneAuthModel || i.verified)continue;
     FunctionHelpers.toast("يجب توثيق رقم الهاتف");
     return false;
   }
    return FunctionHelpers.checkInputs(
        currentModels.map(
                (e)=>e.controller
        ).toList()
    );
  }

  Map<String,dynamic> get generateMap => {
    for(final AuthModel model in currentModels)
      model.column:model.controller is PhoneTextEditController ?
    (model.controller as PhoneTextEditController).nText
    :model.controller.text
  };



  Future<void> callApi()async{
    if(!everyThingIsValid)return;
    await LaravelHttp.instance.post<LaravelResponse>(
        url: url,
        queryParameters:generateMap,
        withLoading:true);
  }



  dispose(BuildContext context)async{
    await Future.delayed(const Duration(seconds:2));
    if(context.mounted)return;
    screenAuthType.dispose();
  }

  changeAuthScreen([AuthType? type]){
    screenAuthType.value = type;
  }


  static  List<AuthModel> defaultRegisterModels = [
    ...defaultLoginModels,
    AuthModel("name",name:"الاسم",required:true),
    _confirmPasswordAuthModel,
  ];

  static final AuthModel  _confirmPasswordAuthModel =  AuthModel("password_confirmation",name:"تأكيد كلمة السر",required:true,isPassword:true);

  static  List<AuthModel> defaultLoginModels = [
    PhoneAuthModel("phone",numeric:true,name: "رقم الهاتف",controller:PhoneTextEditController()),
    AuthModel("password",name: "كلمة السر",isPassword:true,required:true),
  ];

  static List<AuthModel> defaultForgetModels = [
    ...defaultLoginModels,
    _confirmPasswordAuthModel
  ];

}


extension ApiExt on AuthHandler {

  String get url => (screenAuthType.value == AuthType.login) ? _loginUrl :
    screenAuthType.value == AuthType.forget ? _forgetUrl:
   _registerUrl;

  String get mainAppUrl => LaravelConfigurations.configurations!.mainApiUrl;
  String get _prefixUrl {
    final String main = mainAppUrl ;
    return "$main${main.endsWith("/")?"":"/"}RoyalFirster";
  }

  String get _loginUrl => "$_prefixUrl/login";
  String get _registerUrl => "$_prefixUrl/register";
  String get _forgetUrl => "$_prefixUrl/forget";
}