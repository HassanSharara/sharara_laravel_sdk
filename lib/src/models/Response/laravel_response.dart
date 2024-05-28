
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';

class LaravelResponse extends GeneralLaravelModel {
  LaravelResponse.fromJson(super.parsed) : super.fromJson();
  int? status;
  String? toast,msg;
  dynamic data,extraData;

  @override
  void buildModelProperties() {
    status = int.tryParse(get("status").toString());
    toast = get('toast');
    msg = get('msg');
    data = get('data');
    extraData = get('extra_data');
  }

  bool get hasToast => toast != null && toast!="no_toast";
  bool get isSuccess=> msg!=null && msg=="success";
  bool get hasMsg => msg != null && msg!="no_msg";
  bool get couldInvokeAuthHandler => msg!=null && msg!.toLowerCase().contains("auth");
  bool get couldInvokeUserUpdate => msg!= null && msg!.toLowerCase() == "update_user";
  bool get containUpdateMessage => msg!= null && msg!.toLowerCase() == "update";
  bool get hasData => data != null;

  bool get hasExtraLaravelResponse => extraData!=null && extraData is Map &&
      (extraData as Map).containsKey("status") &&
      (extraData as Map).containsKey("msg") &&
      (extraData as Map).containsKey("data") &&
      (extraData as Map).containsKey("toast") ;


}