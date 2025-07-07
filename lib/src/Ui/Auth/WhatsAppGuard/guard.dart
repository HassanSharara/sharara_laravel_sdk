

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sharara_apps_building_helpers/sharara_apps_building_helpers.dart';
import 'package:sharara_apps_building_helpers/ui.dart';
import 'package:sharara_laravel_sdk/http.dart';
import 'package:sharara_laravel_sdk/src/exporter.dart';

class LaravelWhatsAppGuard extends StatefulWidget {
  const LaravelWhatsAppGuard({super.key,
    required this.phoneNumber,
    required this.onAuthenticated ,
  });
  final String phoneNumber;
  final Function(String) onAuthenticated;

String get title => "التحقق بواسطة الواتساب" .orBuilder(LaravelConfigurations.configurations?.getByWhatsAppWord);
String get verifyOtpButton => "التحقق من رمز OTP".orBuilder(LaravelConfigurations.configurations!.getVerifyOtpWord);
String get resendOtp => "اعادة ارسال رمز التحقق".orBuilder(LaravelConfigurations.configurations!.getResendOtpWord);



  @override
  State<LaravelWhatsAppGuard> createState() => _LaravelWhatsAppGuardState();
}

class _LaravelWhatsAppGuardState extends State<LaravelWhatsAppGuard> {
  
  final ValueNotifier<int> counter = ValueNotifier(15);
  final ValueNotifier<String?> secret = ValueNotifier(null);
  final ValueNotifier<String?> otpToken = ValueNotifier(null);
  final TextEditingController otp = TextEditingController();
  bool _disposed = false;

  late Timer timer;
  
  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds:1),(_){
      _performCountDown();
    });
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      await Future.delayed(const Duration(milliseconds:300));
      _sendOtp();
    });
  }
  
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
    Future.delayed(const Duration(seconds: 12))
    .then((_){
      if(!mounted)return;
      counter.dispose();
      otp.dispose();
      secret.dispose();
      timer.cancel();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title: Text(widget.title),),
      body:ValueListenableBuilder(valueListenable: otpToken,
          builder:(BuildContext context,final String? token,_){
           if(token != null){
             return Column(
               mainAxisAlignment:MainAxisAlignment.center,
               crossAxisAlignment:CrossAxisAlignment.center,
               children: [

                 const Icon(Icons.check_circle,
                   size:40,
                   color:RoyalColors.green,
                 ),
                 const SizedBox(height:10,),
                 RoyalRoundedButton(
                   color:RoyalColors.green,
                   onPressed:(){
                     Navigator.maybePop(context);
                   },
                   title: "تم التحقق بنجاح".orBuilder(
                     LaravelConfigurations
                     .configurations?.getVerifiedWord
                   ),
                 )
               ],
             );
           }
           return ListView(
             children: [
               const SizedBox(height:10,),

               RoyalTextFormField(controller: otp,inputType:TextInputType.phone,),
               const SizedBox(height:20,),

               ValueListenableBuilder(
                   valueListenable: counter,
                   builder:(final BuildContext context,final int counter,_){

                     return ElevatedButton(
                         onPressed:counter>0?null:_sendOtp,
                         child: Text("${widget.resendOtp}  ${counter>0?counter:""}"));
                   }
               ),

               const SizedBox(height:15,),

               ValueListenableBuilder(
                   valueListenable: secret,
                   builder:(BuildContext context,String? text,_){
                     if(text==null)return const SizedBox();
                     return ValueListenableBuilder(
                         valueListenable: otp,
                         builder:(BuildContext context,TextEditingValue text,_){
                           return RoyalRoundedButton(
                             color:RoyalColors.green,
                             onPressed:text.text.isEmpty?null:_verifyOtp,
                             title: widget.verifyOtpButton,
                           );
                         }
                     );
                   }
               ),
             ],
           );
          }),
    );
  }
  
  
  _sendOtp()async{

    final LaravelResponse? response = await
    LaravelHttp.instance
    .post(
          url:"${LaravelConfigurations
              .configurations
          !.mainApiUrl
          }/RoyalFirster/sendOtp",
          withLoading:true,
          queryParameters:{
            "phone":widget.phoneNumber,
          },
          headers:{
            "Authorization":"Bearer ${LaravelConfigurations.configurations!.apiKey}"
          }
        );
    if( !(response != null && response.isSuccess ) ) return;
    final dynamic data = response.data;
    if(data is Map && data.containsKey("secret")){
      _changeSecret(data['secret']);
      _changeCounter(15);
      FunctionHelpers.successToast(
          "تم ارسال رمز التحقق بنجاح"
              .orBuilder(
            LaravelConfigurations
            .configurations?.getOtpSentSuccessfully
          )
      );
    }
  }


  _verifyOtp()async{
    final secretN = secret.value;
    if(secretN==null)return;
    final LaravelResponse? response = await
     LaravelHttp.instance
        .post(
        url:"${LaravelConfigurations
            .configurations
        !.mainApiUrl
        }/RoyalFirster/verifyOtp",
        withLoading:true,
        queryParameters:{
          "phone":widget.phoneNumber,
          "secret":secretN,
          "otp":otp.text
        },
        headers:{
          "Authorization":"Bearer ${LaravelConfigurations.configurations!.apiKey}"
        }
    );
    if( !(response != null && response.isSuccess ) ) return;
    final dynamic data = response.data;
    if(data is! Map || data['otp_token']==null)return;
    final String token =  data['otp_token'];
    widget.onAuthenticated(token);
    _changeOtp(token);
    FunctionHelpers.successToast(
        "تم التحقق بنجاح"
            .orBuilder(
            LaravelConfigurations
                .configurations?.getSuccessFullVerificationWord
        )
    );
  }
  

  
  _performCountDown(){
    if(_disposed)return;
    int  cv = counter.value;
    if(cv==0) return;
    if(cv<=1){
      _changeCounter(0);
      return;
    }
    _changeCounter(cv-1);
  }

  _changeCounter(final int value){
    if(_disposed)return;
    counter.value = value;
  }
  _changeSecret(final String value){
    if(_disposed)return;
    secret.value = value;
  }

  _changeOtp(final String value){
    if(_disposed)return;
    otpToken.value = value;
  }
  
}
