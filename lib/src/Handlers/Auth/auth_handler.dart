
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sharara_apps_building_helpers/ui.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/http/http.dart';

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
   dispose(){
     controller.dispose();
   }
}

class PhoneAuthModel extends AuthModel{
  PhoneAuthModel(super.column,{super.controller,
    super.required =true,
    super.name,super.numeric = true}):assert(controller is PhoneTextEditController);
  String verifiedNumber = "";
  String? otpToken;
  bool get verified => verifiedNumber == (controller as PhoneTextEditController).nText;

  Map<String,dynamic> get toMap => {
    "phone":(controller as PhoneTextEditController).nText,
    if(otpToken!=null)
      "otp_token":otpToken
  };

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

  Future<Map<String,dynamic>> get generateMap async {
    final Map<String,dynamic> body ={
      for(final AuthModel model in currentModels)
        if (model is PhoneAuthModel)
        ...model.toMap
      else
        model.column:
        model.controller is PhoneTextEditController ?
        (model.controller as PhoneTextEditController).nText
            :model.controller.text,
    };
    if(laravelConfig.onAuthHandlerMapGeneratorInvoked!=null){
      return await laravelConfig.onAuthHandlerMapGeneratorInvoked!(body);
    }
    return body;
  }



  Future<void> callApi()async{
    if(!everyThingIsValid)return;
    await LaravelHttp.instance.post<LaravelResponse>(
        url: url,
        queryParameters:await generateMap,
        withLoading:true,
      )
    .then((res){

      if(res==null ) return;
      if(!res.isSuccess){
        if(res.msg?.contains("otp") == true){
           for (final model in currentModels){
             if(model is PhoneAuthModel) {
               model.otpToken = null;
             }
           }
        }
      }
      for (final e in currentModels) {
        e.controller.clear();
      }
    });
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

  String get mainAppUrl => laravelConfig.mainApiUrl;
  LaravelConfigurations get laravelConfig => LaravelConfigurations.configurations!;
  String get _prefixUrl {
    final String main = mainAppUrl ;
    return "$main${main.endsWith("/")?"":"/"}RoyalFirster";
  }

  String get _loginUrl => "$_prefixUrl/${laravelConfig.loginApiKeyWord}";
  String get _registerUrl => "$_prefixUrl/${laravelConfig.registerApiKeyWord}";
  String get _forgetUrl => "$_prefixUrl/${laravelConfig.forgetApiKeyWord}";
}