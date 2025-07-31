
import 'package:flutter/widgets.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/Constants/boxes.dart';
import 'package:sharara_laravel_sdk/src/Constants/constants.dart';


class LaravelConfigurations extends LaravelSDKInitializer {
  WhatsAppAuthor? whatsAppAuthor;
  Widget Function()? _appLogo;
  String appName,mainApiUrl,
      uploadedImagesPath,

      logoPath,
      apiKey;
  String? loginApiKeyWord,forgetApiKeyWord,registerApiKeyWord;
  String Function()? getLoginWord,getRegisterWord,getForgetWord,
  getForwardWord,getPhoneWord,getPasswordWord,getConfirmPasswordWord,
  getVerifiedWord,getPleaseVerifyWord,getBySendSmsWord,getByWhatsAppWord,
  getVerifyOtpWord,
  getNameWord,
  getOtpSentSuccessfully,
  getPasswordsAreNotIdenticalWord,
  getSuccessFullVerificationWord,
  getMustVerifyPhoneNumberWord,
  getPleaseInsertOtp,
  getErrorWhileValidatingPhoneNumber,
  getResendOtpWord;
  final bool activateFBPhoneAuth;
  static  LaravelConfigurations? configurations ;
  LaravelConfigurations({
    this.whatsAppAuthor,
    final Widget Function()? appLogo,
    this.activateFBPhoneAuth = false,
    required this.appName,
    required this.mainApiUrl,
    required this.logoPath,
    this.getForgetWord,
    this.getForwardWord,
    this.getLoginWord,
    this.getPhoneWord,
    this.getVerifyOtpWord,
    this.getResendOtpWord,
    this.getErrorWhileValidatingPhoneNumber,
    this.getMustVerifyPhoneNumberWord,
    this.getPasswordsAreNotIdenticalWord,
    this.getByWhatsAppWord,
    this.getNameWord,
    this.getOtpSentSuccessfully,
    this.getSuccessFullVerificationWord,
    this.getPleaseInsertOtp,
    this.getBySendSmsWord,
    this.getVerifiedWord,
    this.getPleaseVerifyWord,
    this.getPasswordWord,
    this.getConfirmPasswordWord,
    this.getRegisterWord,
    this.registerApiKeyWord = "register",
    this.loginApiKeyWord = "login",
    this.apiKey = "\$@6846546FGdasdfa864f68gd868d4g684jk5g8kf4684864eg68w4g684kt864j8er4gw68e46v544\$#%788894684fdsg__(03242342134_+4w653425623456)",
    this.uploadedImagesPath = "uploads/files/images/",
    this.forgetApiKeyWord = "forget",
    this.onAuthHandlerMapGeneratorInvoked,
  }){
    _appLogo = appLogo ?? ()=>Center(
        child: Image.asset(logoPath,height:75,)
    );
  }
  final Future<Map<String,dynamic>> Function(Map<String,dynamic>)? onAuthHandlerMapGeneratorInvoked;
  String get imageUploadsUrlPath => "$mainApiUrl/$uploadedImagesPath";

  Widget? get appLogo  {
   if(_appLogo!=null)return _appLogo!();
   return null;
  }
}

extension StringOrBuilder on String {

  String orBuilder([final String Function()? builder]){
    if(builder!=null)return builder();
    return this;
  }
}


class LaravelSDKInitializer {

  static initialize(
      {
      final List<String> withBoxesNames = const [],
      final List<String> lazyBoxesNames = const [],
      final LaravelConfigurations Function()? configurations
      }
      )async{
    await ShararaAppHelperInitializer.initialize(
      initTheseBoxesNames:[
        ...LaravelBoxesConstants.boxes,
        ...withBoxesNames
      ],
      lazyBoxesNames:[
        ...Constants.boxes,
        ...lazyBoxesNames
      ]
    );
   if(configurations!=null)LaravelConfigurations.configurations = configurations();
   AuthProvider.instance.init();
  }

}